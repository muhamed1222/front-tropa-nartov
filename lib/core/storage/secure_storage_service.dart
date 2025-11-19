import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Сохранение значения
  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Чтение значения
  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // Удаление значения
  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Удаление всех значений
  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // Проверка наличия ключа
  static Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }
}

