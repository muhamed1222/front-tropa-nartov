import 'package:dio/dio.dart';
import '../../core/errors/api_error_handler.dart';
import '../../core/utils/logger.dart';

/// Interceptor для централизованной обработки ошибок
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Если ошибка уже обработана (есть ApiException в error), пропускаем
    if (err.error is ApiException) {
      AppLogger.error('API Error: ${(err.error as ApiException).message}', err);
      return handler.next(err);
    }
    
    // Преобразуем DioException в ApiException
    final apiException = _convertToApiException(err);
    
    AppLogger.error('API Error: ${apiException.message}', err);
    
    // Создаем новую DioException с ApiException в error
    final newError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: apiException,
    );
    
    return handler.reject(newError);
  }

  /// Преобразует DioException в ApiException
  ApiException _convertToApiException(DioException err) {
    if (err.response != null) {
      // Сервер вернул ответ с ошибкой
      try {
        final statusCode = err.response!.statusCode;
        final responseData = err.response!.data;

        String message;
        if (responseData is Map && responseData.containsKey('error')) {
          message = responseData['error'].toString();
        } else if (responseData is Map && responseData.containsKey('message')) {
          message = responseData['message'].toString();
        } else {
          message = 'Ошибка сервера: $statusCode';
        }

        return ApiException(
          message: message,
          statusCode: statusCode,
          originalMessage: err.message ?? 'Unknown error',
        );
      } catch (e) {
        return ApiException(
          message: 'Ошибка обработки ответа сервера',
          statusCode: err.response!.statusCode,
          originalMessage: err.message ?? 'Unknown error',
        );
      }
    } else if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      // Таймаут
      return ApiException(
        message: 'Превышено время ожидания ответа от сервера. Проверьте подключение к интернету.',
        statusCode: null,
        originalMessage: 'Request timeout',
      );
    } else if (err.type == DioExceptionType.connectionError) {
      // Проблемы с подключением
      return ApiException(
        message: 'Не удалось подключиться к серверу. Проверьте подключение к интернету.',
        statusCode: null,
        originalMessage: 'Connection error',
      );
    } else {
      // Другая ошибка
      return ApiException(
        message: err.message ?? 'Неизвестная ошибка',
        statusCode: null,
        originalMessage: err.message ?? 'Unknown error',
      );
    }
  }
}

