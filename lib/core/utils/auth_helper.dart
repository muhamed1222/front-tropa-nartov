import '../../services/auth_service.dart';

/// Хелпер для унификации проверок авторизации
/// 
/// Используется в виджетах и BLoC для единообразной проверки авторизации
class AuthHelper {
  /// Проверяет, авторизован ли пользователь
  /// 
  /// Возвращает токен если пользователь авторизован, иначе null
  static Future<String?> getTokenIfAuthenticated() async {
    try {
      return await AuthService.getToken();
    } catch (e) {
      return null;
    }
  }

  /// Проверяет, авторизован ли пользователь
  /// 
  /// Возвращает true если пользователь авторизован, иначе false
  static Future<bool> isAuthenticated() async {
    try {
      return await AuthService.isLoggedIn();
    } catch (e) {
      return false;
    }
  }

  /// Проверяет авторизацию и выбрасывает исключение, если пользователь не авторизован
  /// 
  /// Возвращает токен если пользователь авторизован
  /// Выбрасывает [AuthException] если пользователь не авторизован
  static Future<String> requireAuthentication() async {
    final token = await getTokenIfAuthenticated();
    if (token == null) {
      throw AuthException('Для выполнения этого действия необходимо войти в аккаунт');
    }
    return token;
  }
}

/// Исключение для ошибок авторизации
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

