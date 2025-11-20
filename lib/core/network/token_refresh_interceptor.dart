import 'dart:async';
import 'package:dio/dio.dart';
import '../../services/auth_service.dart';
import '../../core/utils/logger.dart';

/// Interceptor для автоматического обновления токена при 401 ошибке
/// 
/// Автоматически обновляет access token через refresh token при получении 401 ошибки
class TokenRefreshInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;
  final List<Completer<Response<dynamic>>> _pendingRequests = [];

  TokenRefreshInterceptor({required Dio dio}) : _dio = dio;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Обрабатываем только 401 ошибки
    if (err.response?.statusCode == 401) {
      // Пропускаем запросы на refresh token, чтобы избежать бесконечного цикла
      if (err.requestOptions.path.contains('/auth/refresh')) {
        AppLogger.warning('Refresh token request failed, forcing logout');
        await AuthService.forceLogout();
        return handler.next(err);
      }

      // Если уже обновляем токен, ждем завершения
      if (_isRefreshing) {
        // Добавляем запрос в очередь
        final completer = Completer<Response<dynamic>>();
        _pendingRequests.add(completer);
        
        // Ждем завершения обновления токена
        try {
          final response = await completer.future;
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      }

      // Начинаем обновление токена
      _isRefreshing = true;

      try {
        // Пытаемся обновить токен
        final refreshed = await AuthService.refreshAccessToken();

        if (refreshed) {
          AppLogger.info('Token refreshed successfully, retrying request');
          
          // Обновляем токен в заголовке запроса
          final newToken = await AuthService.getToken();
          if (newToken != null) {
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          }

          // Повторяем оригинальный запрос с обновленным токеном через тот же Dio instance
          final options = Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
            contentType: err.requestOptions.contentType,
            responseType: err.requestOptions.responseType,
            followRedirects: err.requestOptions.followRedirects,
            validateStatus: err.requestOptions.validateStatus,
            receiveTimeout: err.requestOptions.receiveTimeout,
            sendTimeout: err.requestOptions.sendTimeout,
            extra: err.requestOptions.extra,
          );

          final response = await _dio.request<dynamic>(
            err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
            options: options,
            cancelToken: err.requestOptions.cancelToken,
          );
          
          // Разрешаем все ожидающие запросы
          for (final completer in _pendingRequests) {
            if (!completer.isCompleted) {
              completer.complete(response);
            }
          }
          _pendingRequests.clear();
          
          return handler.resolve(response);
        } else {
          // Не удалось обновить токен - делаем logout
          AppLogger.warning('Token refresh failed, forcing logout');
          await AuthService.forceLogout();
          
          // Отклоняем все ожидающие запросы
          for (final completer in _pendingRequests) {
            if (!completer.isCompleted) {
              completer.completeError(err);
            }
          }
          _pendingRequests.clear();
          
          return handler.next(err);
        }
      } catch (e) {
        AppLogger.error('Token refresh error: $e');
        await AuthService.forceLogout();
        
        // Отклоняем все ожидающие запросы
        for (final completer in _pendingRequests) {
          if (!completer.isCompleted) {
            completer.completeError(err);
          }
        }
        _pendingRequests.clear();
        
        return handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    }

    // Для других ошибок просто передаем дальше
    return handler.next(err);
  }
}

