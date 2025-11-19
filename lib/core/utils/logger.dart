import 'package:flutter/foundation.dart';

/// Простой logger для приложения
/// В debug режиме выводит все логи, в release - только ошибки
class AppLogger {
  AppLogger._();

  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message');
      if (error != null) {
        debugPrint('[ERROR] $error');
        if (stackTrace != null) {
          debugPrint('[STACK] $stackTrace');
        }
      }
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
  }

  static void warning(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('[WARNING] $message');
      if (error != null) {
        debugPrint('[ERROR] $error');
      }
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    // В release режиме тоже показываем ошибки
    debugPrint('[ERROR] $message');
    if (error != null) {
      debugPrint('[ERROR DETAILS] $error');
      if (stackTrace != null) {
        debugPrint('[STACK TRACE] $stackTrace');
      }
    }
  }

  /// Логирование ошибок API
  static void apiError(String endpoint, Object error, [StackTrace? stackTrace]) {
    AppLogger.error('API Error: $endpoint', error, stackTrace);
  }

  /// Логирование ошибок загрузки данных
  static void loadError(String dataType, Object error, [StackTrace? stackTrace]) {
    AppLogger.error('Load Error: $dataType', error, stackTrace);
  }
}

