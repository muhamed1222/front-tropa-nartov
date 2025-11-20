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
  bool _requiresAuth(String path) {
    // Список путей, которые НЕ требуют авторизации
    final publicPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/forgot-password',
      '/auth/reset-password',
      '/places',
      '/routes',
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

