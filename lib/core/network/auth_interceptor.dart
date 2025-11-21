import 'package:dio/dio.dart';
import '../../services/auth_service.dart';

/// Interceptor для автоматической подстановки токена в заголовки запросов
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Пропускаем запросы, которые не требуют авторизации
    if (_requiresAuth(options.path)) {
      final token = await AuthService.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return handler.next(options);
  }

  /// Проверяет, требует ли endpoint авторизации
  /// 
  /// ✅ МИГРАЦИЯ: Обновлено для Strapi API
  bool _requiresAuth(String path) {
    // Список путей, которые НЕ требуют авторизации (Strapi API)
    final publicPaths = [
      '/api/auth/local',              // Вход
      '/api/auth/local/register',     // Регистрация
      '/api/auth/forgot-password',     // Восстановление пароля
      '/api/auth/reset-password',      // Сброс пароля
      '/api/places',                   // Места (публичные)
      '/api/routes',                   // Маршруты (публичные)
      '/api/categories',               // Категории (публичные)
      '/api/areas',                    // Районы (публичные)
      '/api/tags',                     // Теги (публичные)
      '/api/route-types',              // Типы маршрутов (публичные)
    ];

    // Проверяем, не является ли путь публичным
    for (final publicPath in publicPaths) {
      if (path.contains(publicPath)) {
        return false;
      }
    }

    // Все остальные пути требуют авторизации
    return true;
  }
}

