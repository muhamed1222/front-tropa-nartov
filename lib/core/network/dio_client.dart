import 'package:dio/dio.dart';

Dio createDio({
  required String baseUrl,
  Duration connectTimeout = const Duration(seconds: 8),
  Duration receiveTimeout = const Duration(seconds: 12),
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  // Пример перехватчика
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: false,
      responseHeader: false,
    ),
  );

  return dio;
}
