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
  static const String _strapiBaseUrlKey = 'STRAPI_BASE_URL';
  static const String _strapiPortKey = 'STRAPI_PORT';
  static const String _enableLoggingKey = 'ENABLE_LOGGING';

  // Значения по умолчанию для разработки
  static const String _defaultServerIp = '192.168.1.48';
  static const int _defaultStrapiPort = 1337;

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

  /// Включено ли логирование
  static bool get enableLogging {
    final loggingString = _getString(_enableLoggingKey, 'true') ?? 'true';
    return loggingString.toLowerCase() == 'true';
  }

  /// Базовый URL Strapi CMS
  /// 
  /// Приоритет:
  /// 1. --dart-define=STRAPI_BASE_URL=...
  /// 2. Переменная окружения
  /// 3. Автоматическое определение по платформе (для dev)
  static String get strapiBaseUrl {
    // Пытаемся получить из dart-define
    final definedUrl = _getString(_strapiBaseUrlKey);
    if (definedUrl != null && definedUrl.isNotEmpty) {
      return definedUrl;
    }

    // Для dev окружения используем автоматическое определение
    return _getDevStrapiBaseUrl();
  }

  /// Порт Strapi
  static int get strapiPort {
    final portString = _getString(_strapiPortKey);
    if (portString != null) {
      return int.tryParse(portString) ?? _defaultStrapiPort;
    }
    return _defaultStrapiPort;
  }

  /// Получение базового URL для Strapi в dev окружении
  static String _getDevStrapiBaseUrl() {
    if (kDebugMode) {
      if (Platform.isIOS) {
        // Для iOS симулятора используем localhost
        return 'http://localhost:$strapiPort';
      } else if (Platform.isAndroid) {
        // Android эмулятор использует специальный адрес
        return 'http://10.0.2.2:$strapiPort';
      }
    }

    // Для production или реальных устройств используем IP адрес
    return 'http://$_defaultServerIp:$strapiPort';
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

  /// Проверка валидности конфигурации
  static void validate() {
    if (environment == Environment.production) {
      final url = _getString(_strapiBaseUrlKey);
      if (url == null || url.isEmpty) {
        throw Exception(
          'STRAPI_BASE_URL must be set for production environment via --dart-define',
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
      'strapiBaseUrl': strapiBaseUrl,
      'strapiPort': strapiPort,
      'enableLogging': enableLogging,
    };
  }
}

