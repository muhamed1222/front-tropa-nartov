import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/app_config.dart';
import '../../config/environment_config.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import 'retry_interceptor.dart';
import 'token_refresh_interceptor.dart';

/// Создает настроенный экземпляр Dio с interceptors
/// 
/// ✅ МИГРАЦИЯ: Теперь использует только Strapi baseUrl
Dio createDio({
  String? baseUrl,
  Duration? connectTimeout,
  Duration? receiveTimeout,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? EnvironmentConfig.strapiBaseUrl, // ✅ МИГРАЦИЯ: Используем Strapi
      connectTimeout: connectTimeout ?? AppConfig.connectTimeout,
      receiveTimeout: receiveTimeout ?? AppConfig.receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  // Порядок interceptors важен!
  // 1. Auth interceptor - добавляет токен к запросам
  dio.interceptors.add(AuthInterceptor());
  
  // 2. Token refresh interceptor - обновляет токен при 401
  dio.interceptors.add(TokenRefreshInterceptor(dio: dio));
  
  // 3. Retry interceptor - повторяет запросы при сетевых ошибках
  dio.interceptors.add(RetryInterceptor());
  
  // 4. Error interceptor - централизованная обработка ошибок
  dio.interceptors.add(ErrorInterceptor());
  
  // 5. Logging interceptor - только в debug режиме
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        error: true,
      ),
    );
  }

  return dio;
}
