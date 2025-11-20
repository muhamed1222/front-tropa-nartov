import 'package:flutter/foundation.dart';
import 'environment_config.dart';

/// Конфигурация приложения
/// 
/// Использует EnvironmentConfig для получения настроек из переменных окружения
class AppConfig {
  /// IP адрес сервера
  static String get serverIp => EnvironmentConfig.serverIp;
  
  /// Порт сервера
  static int get serverPort => EnvironmentConfig.serverPort;
  
  /// Базовый URL API
  /// 
  /// Использует EnvironmentConfig для определения URL в зависимости от окружения
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;

  // Таймауты для HTTP запросов (в секундах)
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 60); // Увеличено до 60 секунд
  
  /// Timeout для запросов, которые могут занять больше времени (например, загрузка файлов)
  static const Duration longRequestTimeout = Duration(seconds: 30);
  
  /// Старый requestTimeout (для обратной совместимости с ApiConfig)
  @Deprecated('Используйте connectTimeout')
  static const Duration requestTimeout = connectTimeout;

  /// Инициализация конфигурации
  /// 
  /// Вызывается при запуске приложения для валидации настроек
  static void init() {
    EnvironmentConfig.validate();
    
    if (kDebugMode) {
      final configInfo = EnvironmentConfig.getConfigInfo();
      print('=== App Config ===');
      configInfo.forEach((key, value) {
        print('$key: $value');
      });
      print('==================');
    }
  }
}