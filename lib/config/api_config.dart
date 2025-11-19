import 'app_config.dart';

/// Конфигурация API для разных окружений
class ApiConfig {
  /// Базовый URL API
  /// 
  /// Автоматически выбирается в зависимости от платформы:
  /// - iOS: IP адрес компьютера (192.168.0.103)
  /// - Android эмулятор: 10.0.2.2
  /// - Реальное устройство: IP адрес компьютера в локальной сети
  static String get baseUrl {
    // Используем конфигурацию из AppConfig
    return AppConfig.baseUrl;
  }
  
  /// Timeout для HTTP запросов (в секундах)
  static const Duration requestTimeout = Duration(seconds: 10);
  
  /// Timeout для запросов, которые могут занять больше времени (например, загрузка файлов)
  static const Duration longRequestTimeout = Duration(seconds: 30);
}

