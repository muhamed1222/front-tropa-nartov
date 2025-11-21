import 'dart:convert';

import 'strapi_service.dart';
import '../models/api_models.dart';
import '../core/utils/logger.dart';
import '../core/storage/secure_storage_service.dart';
import 'preferences_service.dart';
import '../core/errors/api_error_handler.dart';
import '../core/di/injection_container.dart' as di;

/// AuthService как instance-based класс для поддержки DI
/// 
/// ✅ МИГРАЦИЯ: Теперь использует Strapi вместо Go API
class AuthService {
  final StrapiService _strapiService;
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _lastEmailKey = 'last_email';
  static const String _migrationTokenKey = 'auth_token'; // Ключ для миграции из SharedPreferences

  AuthService({StrapiService? strapiService}) 
      : _strapiService = strapiService ?? di.sl<StrapiService>();

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

  /// Получение профиля с сервера через Strapi
  Future<User> getProfile() async {
    final token = await getToken();
    if (token == null) {
      throw ApiException(
        message: 'Не авторизован',
        statusCode: 401,
        originalMessage: 'Token not found',
      );
    }

    final userData = await _strapiService.getCurrentUser(token);
    final user = _convertStrapiUserToUser(userData);
    await saveUser(user);
    return user;
  }

  /// Обновление профиля через Strapi
  Future<User> updateProfile(String firstName, String lastName, String email) async {
    final token = await getToken();
    if (token == null) {
      throw ApiException(
        message: 'Не авторизован',
        statusCode: 401,
        originalMessage: 'Token not found',
      );
    }

    final currentUser = await getUser();
    if (currentUser == null) {
      throw ApiException(
        message: 'Пользователь не найден',
        statusCode: 404,
        originalMessage: 'User not found',
      );
    }

    final userData = await _strapiService.updateUser(
      userId: currentUser.id,
      jwt: token,
      email: email,
      username: currentUser.name, // Используем текущее имя пользователя
      firstName: firstName,
      lastName: lastName,
    );

    final user = _convertStrapiUserToUser(userData);
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

  /// Удаление аккаунта через Strapi
  /// 
  /// Примечание: Strapi не имеет встроенного endpoint для удаления аккаунта
  /// Можно реализовать через кастомный endpoint или просто очистить локальные данные
  Future<void> deleteAccount() async {
    try {
      // Strapi не имеет встроенного endpoint для удаления аккаунта
      // В реальном приложении нужно создать кастомный endpoint в Strapi
      // Пока просто очищаем локальные данные
      AppLogger.warning('Delete account: Strapi does not have built-in delete endpoint');
      await logout();
    } catch (e) {
      // Перебрасываем ошибку для обработки в UI
      rethrow;
    }
  }

  /// Проверка пароля через логин (без сохранения нового токена)
  /// 
  /// Использует Strapi endpoint логина для проверки правильности пароля.
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
      
      // Пытаемся залогиниться с текущим email и паролем через Strapi
      // Примечание: login возвращает новый токен, но мы его не сохраняем
      // Это позволяет проверить пароль без изменения текущей сессии
      await _strapiService.login(user.email, password);
      return true;
    } catch (e) {
      // Если логин не удался, пароль неверный или произошла другая ошибка
      // Не логируем здесь, так как это нормальное поведение при неверном пароле
      return false;
    }
  }

  /// Изменение пароля через Strapi
  /// 
  /// Примечание: Strapi не имеет встроенного endpoint для смены пароля
  /// Нужно использовать кастомный endpoint или обновить через updateUser
  Future<void> changePassword(String oldPassword, String newPassword) async {
    // Проверяем старый пароль
    final isValid = await verifyPassword(oldPassword);
    if (!isValid) {
      throw ApiException(
        message: 'Неверный текущий пароль',
        statusCode: 400,
        originalMessage: 'Invalid old password',
      );
    }

    // Strapi не имеет встроенного endpoint для смены пароля
    // В реальном приложении нужно создать кастомный endpoint в Strapi
    throw UnimplementedError('Password change not yet implemented for Strapi. Please create custom endpoint.');
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

  /// Проверка валидности токена через Strapi API
  Future<bool> isTokenValid() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      // Пытаемся проверить токен через Strapi API
      try {
        await _strapiService.getCurrentUser(token);
        return true; // Токен валиден
      } catch (e) {
        // Если ошибка 401, токен невалиден
        if (e is ApiException && e.statusCode == 401) {
          // Strapi не имеет встроенного refresh token механизма
          // JWT токены в Strapi имеют длительный срок действия
          return false;
        }
        return false;
      }
    } catch (e) {
      AppLogger.warning('Token validation failed: $e');
      return false;
    }
  }

  /// Обновление access token через refresh token
  /// 
  /// Примечание: Strapi не имеет встроенного refresh token механизма
  /// JWT токены в Strapi имеют длительный срок действия
  /// Если токен истек, пользователю нужно залогиниться заново
  Future<bool> refreshAccessToken() async {
    // Strapi не поддерживает refresh token из коробки
    // JWT токены имеют длительный срок действия
    AppLogger.warning('Token refresh: Strapi does not support refresh tokens');
    return false;
  }

  /// Конвертация Strapi пользователя в User модель
  User _convertStrapiUserToUser(Map<String, dynamic> strapiUser) {
    return User(
      id: strapiUser['id'] ?? 0,
      name: strapiUser['username'] ?? '',
      firstName: strapiUser['firstName'] ?? '',
      email: strapiUser['email'] ?? '',
      role: strapiUser['role']?['name'] ?? 'authenticated',
      avatarUrl: strapiUser['avatar'] != null 
          ? strapiUser['avatar']['url'] as String?
          : null,
    );
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

  /// Вход в систему через Strapi
  /// 
  /// Возвращает LoginResponse с токеном и данными пользователя
  Future<LoginResponse> login(String identifier, String password) async {
    try {
      final response = await _strapiService.login(identifier, password);
      final jwt = response['jwt'] as String;
      final userData = response['user'] as Map<String, dynamic>;
      
      // Сохраняем токен (Strapi использует только JWT, без refresh token)
      await saveToken(jwt);
      
      // Конвертируем Strapi пользователя в User модель
      final user = _convertStrapiUserToUser(userData);
      await saveUser(user);
      
      return LoginResponse(
        token: jwt,
        refreshToken: null, // Strapi не использует refresh token
        user: user,
      );
    } catch (e) {
      AppLogger.error('Login failed: $e');
      rethrow;
    }
  }

  /// Регистрация нового пользователя через Strapi
  /// 
  /// Возвращает LoginResponse с JWT токеном и данными пользователя
  /// Strapi автоматически возвращает JWT после регистрации
  Future<LoginResponse> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _strapiService.register(
        username: username,
        email: email,
        password: password,
      );
      
      final jwt = response['jwt'] as String;
      final userData = response['user'] as Map<String, dynamic>;
      
      // Сохраняем токен (Strapi использует только JWT, без refresh token)
      await saveToken(jwt);
      
      // Конвертируем Strapi пользователя в User модель
      final user = _convertStrapiUserToUser(userData);
      await saveUser(user);
      
      return LoginResponse(
        token: jwt,
        refreshToken: null, // Strapi не использует refresh token
        user: user,
      );
    } catch (e) {
      AppLogger.error('Registration failed: $e');
      rethrow;
    }
  }
}

