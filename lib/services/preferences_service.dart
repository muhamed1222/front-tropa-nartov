import 'package:shared_preferences/shared_preferences.dart';

/// Singleton сервис для работы с SharedPreferences
/// Устраняет повторные вызовы SharedPreferences.getInstance()
class PreferencesService {
  static SharedPreferences? _instance;
  static bool _isInitialized = false;

  /// Инициализация SharedPreferences (вызывается один раз при старте приложения)
  static Future<void> init() async {
    if (!_isInitialized) {
      _instance = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  /// Получить экземпляр SharedPreferences
  /// 
  /// Выбросит исключение, если init() не был вызван
  static SharedPreferences get instance {
    if (!_isInitialized || _instance == null) {
      throw Exception(
        'PreferencesService не инициализирован. Вызовите PreferencesService.init() перед использованием.',
      );
    }
    return _instance!;
  }

  /// Проверка инициализации
  static bool get isInitialized => _isInitialized && _instance != null;
}

