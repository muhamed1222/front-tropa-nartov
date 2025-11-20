import 'dart:io';
import 'package:flutter/foundation.dart';

/// Конфигурация окружения приложения
/// 
/// Поддерживает dev, staging и production окружения
/// Конфигурация может быть установлена через --dart-define или .env файл
enum Environment {
  dev,
  staging,
  production,
}

/// Сервис для работы с конфигурацией окружения
class EnvironmentConfig {
  static const String _environmentKey = 'ENVIRONMENT';
  static const String _apiBaseUrlKey = 'API_BASE_URL';
  static const String _serverIpKey = 'SERVER_IP';
  static const String _serverPortKey = 'SERVER_PORT';
  static const String _enableLoggingKey = 'ENABLE_LOGGING';

  // Значения по умолчанию для разработки
  static const String _defaultServerIp = '192.168.1.48';
  static const int _defaultServerPort = 8001;

  /// Текущее окружение
  static Environment get environment {
    final envString = _getString(_environmentKey, 'dev') ?? 'dev';
    switch (envString.toLowerCase()) {
      case 'production':
      case 'prod':
        return Environment.production;
      case 'staging':
      case 'stage':
        return Environment.staging;
      case 'dev':
      case 'development':
      default:
        return Environment.dev;
    }
  }

  /// Базовый URL API
  /// 
  /// Приоритет:
  /// 1. --dart-define=API_BASE_URL=...
  /// 2. Переменная окружения
  /// 3. Автоматическое определение по платформе (для dev)
  static String get apiBaseUrl {
    // Пытаемся получить из dart-define
    final definedUrl = _getString(_apiBaseUrlKey);
    if (definedUrl != null && definedUrl.isNotEmpty) {
      return definedUrl;
    }

    // Для production и staging используем явно указанный URL
    if (environment != Environment.dev) {
      throw Exception(
        'API_BASE_URL must be set via --dart-define for ${environment.name} environment',
      );
    }

    // Для dev окружения используем автоматическое определение
    return _getDevBaseUrl();
  }

  /// IP адрес сервера
  static String get serverIp {
    return _getString(_serverIpKey, _defaultServerIp) ?? _defaultServerIp;
  }

  /// Порт сервера
  static int get serverPort {
    final portString = _getString(_serverPortKey);
    if (portString != null) {
      return int.tryParse(portString) ?? _defaultServerPort;
    }
    return _defaultServerPort;
  }

  /// Включено ли логирование
  static bool get enableLogging {
    final loggingString = _getString(_enableLoggingKey, 'true') ?? 'true';
    return loggingString.toLowerCase() == 'true';
  }

  /// Получение значения строковой переменной
  /// 
  /// Приоритет:
  /// 1. --dart-define
  /// 2. Переменная окружения (environment variable)
  /// 3. Значение по умолчанию (если указано)
  static String? _getString(String key, [String? defaultValue]) {
    // 1. Пытаемся получить из --dart-define (String.fromEnvironment)
    final dartDefineValue = String.fromEnvironment(key);
    if (dartDefineValue.isNotEmpty) {
      return dartDefineValue;
    }

    // 2. Пытаемся получить из переменной окружения
    try {
      final envValue = Platform.environment[key];
      if (envValue != null && envValue.isNotEmpty) {
        return envValue;
      }
    } catch (e) {
      // В веб-версии Platform.environment может не работать
      if (kDebugMode) {
        debugPrint('Warning: Could not read environment variable $key: $e');
      }
    }

    // 3. Возвращаем значение по умолчанию
    return defaultValue;
  }

  /// Получение базового URL для dev окружения
  /// 
  /// Автоматически определяет правильный адрес в зависимости от платформы
  static String _getDevBaseUrl() {
    if (kDebugMode) {
      if (Platform.isIOS) {
        // Для iOS симулятора используем localhost
        return 'http://localhost:$serverPort';
      } else if (Platform.isAndroid) {
        // Android эмулятор использует специальный адрес
        return 'http://10.0.2.2:$serverPort';
      }
    }

    // Для production или реальных устройств используем IP адрес
    return 'http://$serverIp:$serverPort';
  }

  /// Проверка валидности конфигурации
  static void validate() {
    if (environment == Environment.production) {
      final url = _getString(_apiBaseUrlKey);
      if (url == null || url.isEmpty) {
        throw Exception(
          'API_BASE_URL must be set for production environment via --dart-define',
        );
      }
    }
  }

  /// Информация о текущей конфигурации (только для debug)
  static Map<String, dynamic> getConfigInfo() {
    if (!kDebugMode) {
      return {'message': 'Config info only available in debug mode'};
    }

    return {
      'environment': environment.name,
      'apiBaseUrl': apiBaseUrl,
      'serverIp': serverIp,
      'serverPort': serverPort,
      'enableLogging': enableLogging,
    };
  }
}

