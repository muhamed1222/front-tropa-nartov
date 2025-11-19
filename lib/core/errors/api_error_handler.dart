import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';

/// Класс для обработки ошибок API
class ApiErrorHandler {
  /// Обрабатывает HTTP ответ и выбрасывает исключение с понятным сообщением
  static void handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    // Обработка успешных ответов
    if (statusCode >= 200 && statusCode < 300) {
      return;
    }

    // Парсинг ошибки из ответа
    String errorMessage;
    try {
      final errorJson = json.decode(response.body);
      if (errorJson is Map<String, dynamic>) {
        // Пытаемся получить сообщение об ошибке из разных возможных полей
        errorMessage = errorJson['error'] ?? 
                      errorJson['message'] ?? 
                      errorJson['detail'] ?? 
                      'Неизвестная ошибка';
        
        // Если есть поле errors, используем его
        if (errorJson['errors'] != null) {
          if (errorJson['errors'] is List && (errorJson['errors'] as List).isNotEmpty) {
            errorMessage = (errorJson['errors'] as List).first.toString();
          } else if (errorJson['errors'] is Map) {
            final errors = errorJson['errors'] as Map;
            errorMessage = errors.values.first.toString();
          }
        }
      } else {
        errorMessage = response.body;
      }
    } catch (e) {
      // Если не удалось распарсить JSON, используем тело ответа или стандартное сообщение
      errorMessage = response.body.isNotEmpty 
          ? response.body 
          : _getDefaultErrorMessage(statusCode);
    }

    // Обработка специфичных статусов
    switch (statusCode) {
      case 401:
        // Неавторизован - автоматически выходим
        _handleUnauthorized();
        throw ApiException(
          message: 'Сессия истекла. Пожалуйста, войдите снова.',
          statusCode: statusCode,
          originalMessage: errorMessage,
        );
      
      case 403:
        throw ApiException(
          message: 'Доступ запрещен. У вас нет прав для выполнения этого действия.',
          statusCode: statusCode,
          originalMessage: errorMessage,
        );
      
      case 404:
        throw ApiException(
          message: 'Запрашиваемый ресурс не найден.',
          statusCode: statusCode,
          originalMessage: errorMessage,
        );
      
      case 422:
        // Ошибка валидации
        throw ApiException(
          message: errorMessage,
          statusCode: statusCode,
          originalMessage: errorMessage,
        );
      
      case 429:
        throw ApiException(
          message: 'Слишком много запросов. Пожалуйста, попробуйте позже.',
          statusCode: statusCode,
          originalMessage: errorMessage,
        );
      
      case 500:
      case 502:
      case 503:
      case 504:
        throw ApiException(
          message: 'Ошибка сервера. Пожалуйста, попробуйте позже.',
          statusCode: statusCode,
          originalMessage: errorMessage,
        );
      
      default:
        throw ApiException(
          message: errorMessage.isNotEmpty ? errorMessage : _getDefaultErrorMessage(statusCode),
          statusCode: statusCode,
          originalMessage: errorMessage,
        );
    }
  }

  /// Обрабатывает исключения при выполнении запросов
  static ApiException handleException(dynamic exception) {
    if (exception is ApiException) {
      return exception;
    }

    // Обработка ошибок подключения
    if (exception is http.ClientException) {
      final message = exception.message.toLowerCase();
      if (message.contains('connection refused') || message.contains('failed host lookup')) {
        return ApiException(
          message: 'Не удалось подключиться к серверу. Убедитесь, что сервер запущен и доступен.',
          statusCode: null,
          originalMessage: exception.message,
        );
      }
      return ApiException(
        message: 'Ошибка подключения. Проверьте интернет-соединение.',
        statusCode: null,
        originalMessage: exception.message,
      );
    }

    // Обработка таймаутов
    if (exception.toString().contains('timeout') || exception.toString().contains('TimeoutException')) {
      return ApiException(
        message: 'Превышено время ожидания. Проверьте подключение к серверу и попробуйте снова.',
        statusCode: null,
        originalMessage: exception.toString(),
      );
    }

    if (exception is FormatException) {
      return ApiException(
        message: 'Ошибка обработки данных от сервера.',
        statusCode: null,
        originalMessage: exception.message,
      );
    }

    // Общая обработка
    return ApiException(
      message: exception.toString().contains('Exception:')
          ? exception.toString().split('Exception:').last.trim()
          : 'Произошла ошибка. Пожалуйста, попробуйте снова.',
      statusCode: null,
      originalMessage: exception.toString(),
    );
  }

  /// Обрабатывает ситуацию неавторизованного доступа
  static Future<void> _handleUnauthorized() async {
    try {
      await AuthService.forceLogout();
    } catch (e) {
      // Игнорируем ошибки при выходе
    }
  }

  /// Возвращает стандартное сообщение об ошибке для статуса
  static String _getDefaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Неверный запрос';
      case 401:
        return 'Требуется авторизация';
      case 403:
        return 'Доступ запрещен';
      case 404:
        return 'Ресурс не найден';
      case 500:
        return 'Внутренняя ошибка сервера';
      case 502:
        return 'Ошибка шлюза';
      case 503:
        return 'Сервис недоступен';
      case 504:
        return 'Таймаут шлюза';
      default:
        return 'Ошибка: $statusCode';
    }
  }
}

/// Исключение для ошибок API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String originalMessage;

  ApiException({
    required this.message,
    this.statusCode,
    required this.originalMessage,
  });

  @override
  String toString() => message;
}

