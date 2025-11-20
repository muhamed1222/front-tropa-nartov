import 'dart:math';
import 'package:dio/dio.dart';
import '../../core/utils/logger.dart';

/// Interceptor для автоматического повторения запросов при ошибках сети
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;
  final Random _random = Random();

  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Повторяем только при сетевых ошибках и определенных HTTP кодах
    if (_shouldRetry(err) && err.requestOptions.extra['retries'] != maxRetries) {
      final retries = (err.requestOptions.extra['retries'] ?? 0) as int;
      
      if (retries < maxRetries) {
        err.requestOptions.extra['retries'] = retries + 1;
        
        // Экспоненциальная задержка с добавлением случайности (jitter)
        final delay = retryDelay * pow(2, retries);
        final jitter = Duration(milliseconds: _random.nextInt(500));
        final totalDelay = delay + jitter;
        
        AppLogger.info('Retrying request (${retries + 1}/$maxRetries) after ${totalDelay.inMilliseconds}ms');
        
        await Future.delayed(totalDelay);
        
        try {
          final response = await Dio().fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          // Если повторная попытка не удалась, продолжаем обработку ошибки
          return handler.next(err);
        }
      }
    }
    
    return handler.next(err);
  }

  /// Определяет, нужно ли повторять запрос при данной ошибке
  bool _shouldRetry(DioException err) {
    // Повторяем при сетевых ошибках
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Повторяем при определенных HTTP кодах (5xx, 429)
    if (err.response != null) {
      final statusCode = err.response!.statusCode;
      if (statusCode != null) {
        return statusCode >= 500 || statusCode == 429;
      }
    }

    return false;
  }
}

