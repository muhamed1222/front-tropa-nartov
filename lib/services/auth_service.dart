import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../models/api_models.dart';
import '../core/utils/logger.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _lastEmailKey = 'last_email';

  // Сохранение токена
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Получение токена
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Сохранение данных пользователя
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  // Получение данных пользователя
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }

  // Получение профиля с сервера
  static Future<User> getProfile() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    return await ApiService.getProfile(token);
  }

  // Обновление профиля
  static Future<User> updateProfile(String firstName, String lastName, String email) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    final user = await ApiService.updateProfile(token, firstName, lastName, email);
    await saveUser(user);
    return user;
  }

  // Выход
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Проверка авторизации
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  static Future<void> deleteAccount() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    try {
      await ApiService.deleteAccount(token);
      // После успешного удаления очищаем локальные данные
      await logout();
    } catch (e) {
      // Перебрасываем ошибку для обработки в UI
      rethrow;
    }
  }
  /// Проверка пароля через логин (без сохранения нового токена)
  /// 
  /// Использует endpoint логина для проверки правильности пароля.
  /// Не сохраняет новый токен, только проверяет валидность пароля.
  /// 
  /// Возвращает:
  /// - `true` если пароль верный
  /// - `false` если пароль неверный или произошла ошибка
  static Future<bool> verifyPassword(String password) async {
    try {
      final user = await getUser();
      if (user == null) {
        AppLogger.warning('Verify password: User not found');
        return false;
      }
      
      if (password.isEmpty) {
        return false;
      }
      
      // Пытаемся залогиниться с текущим email и паролем
      // Примечание: login возвращает новый токен, но мы его не сохраняем
      // Это позволяет проверить пароль без изменения текущей сессии
      await ApiService.login(user.email, password);
      return true;
    } catch (e) {
      // Если логин не удался, пароль неверный или произошла другая ошибка
      // Не логируем здесь, так как это нормальное поведение при неверном пароле
      return false;
    }
  }

  static Future<void> changePassword(String oldPassword, String newPassword) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Не авторизован');
    }
    await ApiService.changePassword(oldPassword, newPassword);
  }
  static Future<void> forceLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    // Дополнительно можно очистить другие данные если нужно
  }

  // Проверка валидности токена (дополнительная функция)
  static Future<bool> isTokenValid() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      // Можно добавить проверку срока действия токена
      // или сделать запрос к серверу для проверки валидности
      return true;
    } catch (e) {
      return false;
    }
  }

  // Сохранение последнего email для автозаполнения
  static Future<void> saveLastEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastEmailKey, email);
  }

  // Получение последнего email
  static Future<String?> getLastEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastEmailKey);
  }
}