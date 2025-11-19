import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class UserService {
  static String get baseUrl => AppConfig.baseUrl;

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Получение данных профиля пользователя
  static Future<Map<String, dynamic>> getUserProfile() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Пользователь не авторизован');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Ошибка загрузки профиля: ${response.statusCode}');
    }
  }

  // Получение email текущего пользователя (для проверки пароля)
  static Future<String?> getCurrentUserEmail() async {
    try {
      final profile = await getUserProfile();
      return profile['email'] as String?;
    } catch (e) {
      return null;
    }
  }
}