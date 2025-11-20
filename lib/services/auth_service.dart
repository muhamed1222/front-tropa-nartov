import '../core/di/injection_container.dart';
import '../models/api_models.dart';
import 'auth_service_instance.dart' as instance_module;

/// Wrapper для обратной совместимости с static методами
/// 
/// Внутри использует instance-based AuthService через DI
/// Постепенно все использования должны быть обновлены на использование DI напрямую
class AuthService {
  static instance_module.AuthService get _instance => sl<instance_module.AuthService>();

  static Future<void> saveToken(String token) => _instance.saveToken(token);
  static Future<void> saveRefreshToken(String refreshToken) => _instance.saveRefreshToken(refreshToken);
  static Future<String?> getToken() => _instance.getToken();
  static Future<String?> getRefreshToken() => _instance.getRefreshToken();
  static Future<void> saveUser(User user) => _instance.saveUser(user);
  static Future<User?> getUser() => _instance.getUser();
  static Future<User> getProfile() => _instance.getProfile();
  static Future<User> updateProfile(String firstName, String lastName, String email) => _instance.updateProfile(firstName, lastName, email);
  static Future<void> logout() => _instance.logout();
  static Future<bool> isLoggedIn() => _instance.isLoggedIn();
  static Future<void> deleteAccount() => _instance.deleteAccount();
  static Future<bool> verifyPassword(String password) => _instance.verifyPassword(password);
  static Future<void> changePassword(String oldPassword, String newPassword) => _instance.changePassword(oldPassword, newPassword);
  static Future<void> forceLogout() => _instance.forceLogout();
  static Future<bool> isTokenValid() => _instance.isTokenValid();
  static Future<bool> refreshAccessToken() => _instance.refreshAccessToken();
  static Future<void> saveLastEmail(String email) => _instance.saveLastEmail(email);
  static Future<String?> getLastEmail() => _instance.getLastEmail();
}