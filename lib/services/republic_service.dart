import 'preferences_service.dart';

class RepublicService {
  static const String _selectedRepublicKey = 'selected_republic';

  /// Сохранить выбранную республику
  static Future<void> saveSelectedRepublic(String republicName) async {
    final prefs = PreferencesService.instance;
    await prefs.setString(_selectedRepublicKey, republicName);
  }

  /// Получить выбранную республику
  static Future<String?> getSelectedRepublic() async {
    final prefs = PreferencesService.instance;
    return prefs.getString(_selectedRepublicKey);
  }

  /// Получить выбранную республику или значение по умолчанию
  static Future<String> getSelectedRepublicOrDefault({
    String defaultValue = 'Кабардино-Балкария',
  }) async {
    final selected = await getSelectedRepublic();
    return selected ?? defaultValue;
  }

  /// Очистить сохраненную республику
  static Future<void> clearSelectedRepublic() async {
    final prefs = PreferencesService.instance;
    await prefs.remove(_selectedRepublicKey);
  }
}

