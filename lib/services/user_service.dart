import 'api_service.dart';
import 'auth_service_instance.dart';
import '../models/api_models.dart';

/// UserService как instance-based класс для поддержки DI
class UserService {
  final ApiServiceDio _apiService;
  final AuthService _authService;

  UserService({
    required ApiServiceDio apiService,
    required AuthService authService,
  })  : _apiService = apiService,
        _authService = authService;

  /// Получение токена через AuthService
  Future<String?> getToken() async {
    return await _authService.getToken();
  }

  /// Получение данных профиля пользователя
  Future<User> getUserProfile() async {
    return await _apiService.getProfile(null); // null - AuthInterceptor добавит токен автоматически
  }

  /// Получение email текущего пользователя (для проверки пароля)
  Future<String?> getCurrentUserEmail() async {
    try {
      final user = await getUserProfile();
      return user.email;
    } catch (e) {
      return null;
    }
  }
}