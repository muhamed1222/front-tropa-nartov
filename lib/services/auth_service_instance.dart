import 'dart:convert';

import 'api_service.dart';
import '../models/api_models.dart';
import '../core/utils/logger.dart';
import '../core/storage/secure_storage_service.dart';
import 'preferences_service.dart';
import '../core/errors/api_error_handler.dart';

/// AuthService как instance-based класс для поддержки DI
class AuthService {
  final ApiServiceDio _apiService;
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _lastEmailKey = 'last_email';
  static const String _migrationTokenKey = 'auth_token'; // Ключ для миграции из SharedPreferences

  AuthService({required ApiServiceDio apiService}) : _apiService = apiService;

  /// Миграция токена из SharedPreferences в SecureStorage (однократная операция)
  Future<void> _migrateTokenFromPreferences() async {
    try {
      // Проверяем, не мигрировали ли уже
      final alreadyMigrated = await SecureStorageService.containsKey(_tokenKey);
      if (alreadyMigrated) {
        return; // Уже мигрировано
      }

      // Пытаемся получить токен из SharedPreferences
      final prefs = PreferencesService.instance;
      final oldToken = prefs.getString(_migrationTokenKey);
      
      if (oldToken != null && oldToken.isNotEmpty) {
        // Мигрируем токен в SecureStorage
        await SecureStorageService.write(_tokenKey, oldToken);
        
        // Удаляем из SharedPreferences
        await prefs.remove(_migrationTokenKey);
        
        AppLogger.info('Token migrated from SharedPreferences to SecureStorage');
      }
    } catch (e) {
      // Если миграция не удалась, просто логируем - это не критично
      AppLogger.warning('Token migration failed: $e');
    }
  }

  /// Сохранение токена в SecureStorage
  Future<void> saveToken(String token) async {
    await SecureStorageService.write(_tokenKey, token);
  }

  /// Сохранение refresh token в SecureStorage
  Future<void> saveRefreshToken(String refreshToken) async {
    await SecureStorageService.write(_refreshTokenKey, refreshToken);
  }

  /// Получение токена из SecureStorage с миграцией при первом запуске
  Future<String?> getToken() async {
    // Пытаемся мигрировать токен при первом запуске
    await _migrateTokenFromPreferences();
    
    return await SecureStorageService.read(_tokenKey);
  }

  /// Получение refresh token из SecureStorage
  Future<String?> getRefreshToken() async {
    return await SecureStorageService.read(_refreshTokenKey);
  }

  /// Сохранение данных пользователя
  Future<void> saveUser(User user) async {
    final prefs = PreferencesService.instance;
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  /// Получение данных пользователя
  Future<User?> getUser() async {
    final prefs = PreferencesService.instance;
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }

  /// Получение профиля с сервера
  Future<User> getProfile() async {
    return await _apiService.getProfile(null); // null - AuthInterceptor добавит токен автоматически
  }

  /// Обновление профиля
  Future<User> updateProfile(String firstName, String lastName, String email) async {
    final user = await _apiService.updateProfile(null, firstName, lastName, email);
    await saveUser(user);
    return user;
  }

  /// Выход
  Future<void> logout() async {
    // Удаляем токены из SecureStorage
    await SecureStorageService.delete(_tokenKey);
    await SecureStorageService.delete(_refreshTokenKey);
    
    // Удаляем данные пользователя из PreferencesService (нечувствительные данные)
    final prefs = PreferencesService.instance;
    await prefs.remove(_userKey);
  }

  /// Проверка авторизации
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// Удаление аккаунта
  Future<void> deleteAccount() async {
    try {
      await _apiService.deleteAccount(null); // null - AuthInterceptor добавит токен автоматически
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
  Future<bool> verifyPassword(String password) async {
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
      await _apiService.login(user.email, password);
      return true;
    } catch (e) {
      // Если логин не удался, пароль неверный или произошла другая ошибка
      // Не логируем здесь, так как это нормальное поведение при неверном пароле
      return false;
    }
  }

  /// Изменение пароля
  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _apiService.changePassword(oldPassword, newPassword);
  }

  /// Принудительный выход (очистка всех данных)
  Future<void> forceLogout() async {
    // Удаляем токены из SecureStorage
    await SecureStorageService.delete(_tokenKey);
    await SecureStorageService.delete(_refreshTokenKey);
    
    // Удаляем данные пользователя из PreferencesService
    final prefs = PreferencesService.instance;
    await prefs.remove(_userKey);
    
    // Дополнительно можно очистить другие данные если нужно
  }

  /// Проверка валидности токена через API
  Future<bool> isTokenValid() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      // Пытаемся проверить токен через API
      try {
        await _apiService.getProfile(null); // null - AuthInterceptor добавит токен автоматически
        return true; // Токен валиден
      } catch (e) {
        // Если ошибка 401, токен невалиден
        if (e is ApiException && e.statusCode == 401) {
          // Пытаемся обновить токен через refresh token
          final refreshed = await refreshAccessToken();
          return refreshed;
        }
        return false;
      }
    } catch (e) {
      AppLogger.warning('Token validation failed: $e');
      return false;
    }
  }

  /// Обновление access token через refresh token
  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        AppLogger.warning('Refresh token not found');
        return false; // Нет refresh token
      }

      // Вызываем API для обновления токена
      final newTokens = await _apiService.refreshToken(refreshToken);
      
      // Сохраняем новые токены
      await saveToken(newTokens.token);
      if (newTokens.refreshToken != null) {
        await saveRefreshToken(newTokens.refreshToken!);
      }
      
      AppLogger.info('Token refreshed successfully');
      return true;
    } catch (e) {
      AppLogger.warning('Token refresh failed: $e');
      // Если refresh не удался, выполняем logout
      await forceLogout();
      return false;
    }
  }

  /// Сохранение последнего email для автозаполнения
  Future<void> saveLastEmail(String email) async {
    final prefs = PreferencesService.instance;
    await prefs.setString(_lastEmailKey, email);
  }

  /// Получение последнего email
  Future<String?> getLastEmail() async {
    final prefs = PreferencesService.instance;
    return prefs.getString(_lastEmailKey);
  }
}

