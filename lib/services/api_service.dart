import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_models.dart';
import 'auth_service.dart';
import '../core/errors/api_error_handler.dart';
import '../config/app_config.dart';

class ApiService {
  static String get baseUrl => AppConfig.baseUrl;

  // Выполнение запроса с таймаутом
  static Future<http.Response> _executeWithTimeout(
    Future<http.Response> Function() request,
  ) async {
    return await request().timeout(
      AppConfig.receiveTimeout,
      onTimeout: () {
        throw ApiException(
          message: 'Превышено время ожидания ответа от сервера. Проверьте подключение к интернету.',
          statusCode: null,
          originalMessage: 'Request timeout',
        );
      },
    );
  }

  static Future<LoginResponse> login(String email, String password) async {
    try {
      final url = '$baseUrl/auth/login';
      
      final response = await _executeWithTimeout(() async {
        return await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': email,
            'password': password,
          }),
        );
      });

      ApiErrorHandler.handleResponse(response);
      return LoginResponse.fromJson(json.decode(response.body));
    } catch (e) {
      throw ApiErrorHandler.handleException(e);
    }
  }

  static Future<RegisterResponse> register(String name, String email, String password) async {
    final requestBody = {
      'first_name': name,
      'email': email,
      'password': password,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode == 201) {
      return RegisterResponse.fromJson(json.decode(response.body));
    } else {
      // Детальная обработка ошибок
      try {
        final error = ApiError.fromJson(json.decode(response.body));
        throw Exception(error.error);
      } catch (e) {
        // Если не удалось распарсить ошибку, используем стандартное сообщение
        throw Exception('Ошибка регистрации: ${response.statusCode} - ${response.body}');
      }
    }
  }

  // Обновление токена через refresh token
  static Future<LoginResponse> refreshToken(String refreshToken) async {
    try {
      final url = '$baseUrl/auth/refresh';
      
      final response = await _executeWithTimeout(() async {
        return await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'refresh_token': refreshToken,
          }),
        );
      });

      ApiErrorHandler.handleResponse(response);
      return LoginResponse.fromJson(json.decode(response.body));
    } catch (e) {
      throw ApiErrorHandler.handleException(e);
    }
  }

  // Получение профиля пользователя
  static Future<User> getProfile(String token) async {
    try {
      final response = await _executeWithTimeout(() async {
        return await http.get(
          Uri.parse('$baseUrl/auth/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      });

      ApiErrorHandler.handleResponse(response);
      final Map<String, dynamic> data = json.decode(response.body);
      return User.fromJson(data);
    } catch (e) {
      throw ApiErrorHandler.handleException(e);
    }
  }

  // Обновление профиля пользователя
  static Future<User> updateProfile(String token, String firstName, String lastName, String email) async {
    try {
      final response = await _executeWithTimeout(() async {
        return await http.put(
          Uri.parse('$baseUrl/auth/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'first_name': firstName,
            'last_name': lastName,
            'email': email,
          }),
        );
      });

      ApiErrorHandler.handleResponse(response);
      final Map<String, dynamic> data = json.decode(response.body);
      return User.fromJson(data);
    } catch (e) {
      throw ApiErrorHandler.handleException(e);
    }
  }

  static Future<List<Place>> getPlaces() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/places'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final List<Place> places = data.map((item) {
          return Place.fromJson(item);
        }).toList();

        return places;
      } else {
        throw Exception('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<AppRoute>> getRoutes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/routes'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;

        if (responseBody.isEmpty) {
          return [];
        }

        final List<dynamic> data = json.decode(responseBody);

        final routes = <AppRoute>[];
        for (var item in data) {
          try {
            final route = AppRoute.fromJson(item);
            routes.add(route);
          } catch (e) {
            // Игнорируем ошибки парсинга отдельных элементов
          }
        }

        return routes;
      } else {
        throw Exception('Failed to load routes: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ping'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers ?? {'Content-Type': 'application/json'},
    );
    return response;
  }

  static Future<http.Response> getWithAuth(String endpoint, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  static Future<http.Response> postWithAuth(String endpoint, String token, {Object? body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body != null ? json.encode(body) : null,
    );
    return response;
  }

  static Future<http.Response> putWithAuth(String endpoint, String token, {Object? body}) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body != null ? json.encode(body) : null,
    );
    return response;
  }

  static Future<void> deleteAccount(String token) async {
    try {
      final response = await _executeWithTimeout(() async {
        return await http.delete(
          Uri.parse('$baseUrl/auth/delete-account'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      });

      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handleException(e);
    }
  }

  static Future<void> changePassword(String oldPassword, String newPassword) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Не авторизован');
    }

    try {
      final response = await _executeWithTimeout(() async {
        return await http.put(
          Uri.parse('$baseUrl/auth/change-password'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'old_password': oldPassword,
            'new_password': newPassword,
          }),
        );
      });

      ApiErrorHandler.handleResponse(response);
    } catch (e) {
      throw ApiErrorHandler.handleException(e);
    }
  }

  // === ВОССТАНОВЛЕНИЕ ПАРОЛЯ ===
  
  /// Запрос на отправку кода восстановления пароля
  /// Отправляет код на указанный email
  static Future<void> forgotPassword(String email) async {
    try {
      final response = await _executeWithTimeout(() async {
        return await http.post(
          Uri.parse('$baseUrl/auth/forgot-password'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'email': email.trim()}),
        );
      });

      ApiErrorHandler.handleResponse(response);
      // Успешный ответ (200) - код отправлен
    } catch (e) {
      throw ApiErrorHandler.handleException(e);
    }
  }

  /// Проверка кода восстановления пароля
  /// Проверяет, что код действителен
  /// Возвращает void при успехе, выбрасывает исключение при ошибке
  static Future<void> verifyResetCode(String token) async {
    try {
      final response = await _executeWithTimeout(() async {
        return await http.post(
          Uri.parse('$baseUrl/auth/verify-reset-code'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'token': token.trim()}),
        );
      });

      ApiErrorHandler.handleResponse(response);
      // Успешный ответ (200) - код подтвержден
    } catch (e) {
      throw ApiErrorHandler.handleException(e);
    }
  }

  /// Сброс пароля с использованием токена восстановления
  /// Устанавливает новый пароль для пользователя
  static Future<void> resetPassword(String token, String newPassword) async {
    try {
      final response = await _executeWithTimeout(() async {
        return await http.post(
          Uri.parse('$baseUrl/auth/reset-password'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'token': token.trim(),
            'password': newPassword.trim(),
          }),
        );
      });

      ApiErrorHandler.handleResponse(response);
      // Успешный ответ (200) - пароль успешно сброшен
    } catch (e) {
      throw ApiErrorHandler.handleException(e);
    }
  }

  static Future<List<Review>> getReviewsForPlace(int placeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/place/$placeId'),
        headers: {'Content-Type': 'application/json'},
      );


      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final List<Review> reviews = data.map((item) {
          return Review.fromJson(item);
        }).toList();

        return reviews;
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Review> addReview({
    required int placeId,
    required String text,
    required int rating,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'place_id': placeId,
          'text': text,
          'rating': rating,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        return Review.fromJson(data['review'] ?? data);
      } else {
        final error = ApiError.fromJson(json.decode(response.body));
        throw Exception(error.error);
      }
    } catch (e) {
      rethrow;
    }
  }
  // Получить избранные места
  static Future<List<Place>> getFavoritePlaces(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favorites/places'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Place.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load favorite places: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

// Добавить место в избранное
  static Future<void> addToFavorites(int placeId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/favorites/places/$placeId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final error = ApiError.fromJson(json.decode(response.body));
      throw Exception(error.error);
    }
  }

// Удалить место из избранного
  static Future<void> removeFromFavorites(int placeId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/favorites/places/$placeId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final error = ApiError.fromJson(json.decode(response.body));
      throw Exception(error.error);
    }
  }

  // Проверить статус избранного
  static Future<bool> isPlaceFavorite(int placeId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favorites/places/$placeId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['is_favorite'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      // print('Error checking favorite status: $e');
      return false;
    }
  }

  // === ИЗБРАННЫЕ МАРШРУТЫ ===
  // Получить избранные маршруты
  static Future<List<AppRoute>> getFavoriteRoutes(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favorites/routes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      ApiErrorHandler.handleResponse(response);
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => AppRoute.fromJson(json)).toList();
    } catch (e) {
      // print('Error in getFavoriteRoutes: $e');
      rethrow;
    }
  }

  // Добавить маршрут в избранное
  static Future<void> addRouteToFavorites(int routeId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/favorites/routes/$routeId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final error = ApiError.fromJson(json.decode(response.body));
      throw Exception(error.error);
    }
  }

  // Удалить маршрут из избранного
  static Future<void> removeRouteFromFavorites(int routeId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/favorites/routes/$routeId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final error = ApiError.fromJson(json.decode(response.body));
      throw Exception(error.error);
    }
  }

  // Проверить статус избранного маршрута
  static Future<bool> isRouteFavorite(int routeId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favorites/routes/$routeId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['is_favorite'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      // print('Error checking favorite status: $e');
      return false;
    }
  }

  // Получить статусы избранного для нескольких маршрутов одним запросом
  // Альтернативный вариант: если бэкенд не поддерживает массовый запрос,
  // можно сделать параллельные запросы вместо последовательных
  static Future<Map<int, bool>> getFavoriteStatusesForRoutes(
    List<int> routeIds,
    String token,
  ) async {
    if (routeIds.isEmpty) {
      return {};
    }

    try {
      // Попытка использовать массовый endpoint (если он есть)
      final response = await http.post(
        Uri.parse('$baseUrl/favorites/routes/statuses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'ids': routeIds}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<int, bool> statuses = {};
        
        // Ожидаем формат: { "1": true, "5": false, "12": true }
        // или формат: [{ "route_id": 1, "is_favorite": true }, ...]
        if (data['statuses'] != null && data['statuses'] is Map) {
          final statusesMap = data['statuses'] as Map<String, dynamic>;
          statusesMap.forEach((key, value) {
            final id = int.tryParse(key);
            if (id != null && value is bool) {
              statuses[id] = value;
            }
          });
        } else if (data is Map) {
          // Если ответ уже Map<int, bool> или Map<String, bool>
          data.forEach((key, value) {
            final id = int.tryParse(key.toString());
            if (id != null && value is bool) {
              statuses[id] = value;
            }
          });
        }
        
        // Заполняем отсутствующие ID как false
        for (final id in routeIds) {
          statuses.putIfAbsent(id, () => false);
        }
        
        return statuses;
      } else {
        // Если массовый endpoint не поддерживается, делаем параллельные запросы
        return await _loadFavoriteStatusesInParallel(routeIds, token);
      }
    } catch (e) {
      // Если ошибка, делаем параллельные запросы
      return await _loadFavoriteStatusesInParallel(routeIds, token);
    }
  }

  // Загрузить статусы избранного параллельными запросами
  // Это быстрее последовательных запросов в цикле
  static Future<Map<int, bool>> _loadFavoriteStatusesInParallel(
    List<int> routeIds,
    String token,
  ) async {
    final Map<int, bool> statuses = {};
    
    // Выполняем все запросы параллельно
    final futures = routeIds.map((routeId) async {
      try {
        final isFavorite = await isRouteFavorite(routeId, token);
        return MapEntry(routeId, isFavorite);
      } catch (e) {
        return MapEntry(routeId, false);
      }
    }).toList();
    
    final results = await Future.wait(futures);
    
    for (final entry in results) {
      statuses[entry.key] = entry.value;
    }
    
    return statuses;
  }

  // Получить статистику пользователя
  static Future<Map<String, int>> getUserStatistics(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/statistics'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'visitedPlaces': data['visited_places'] ?? 0,
          'completedRoutes': data['completed_routes'] ?? 0,
        };
      } else {
        // Если эндпоинт не существует, возвращаем 0
        return {
          'visitedPlaces': 0,
          'completedRoutes': 0,
        };
      }
    } catch (e) {
      // print('Error getting user statistics: $e');
      // Если эндпоинт не существует, возвращаем 0
      return {
        'visitedPlaces': 0,
        'completedRoutes': 0,
      };
    }
  }

  // Получить всю историю активности пользователя
  static Future<ActivityHistory> getUserActivityHistory(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/activity'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ActivityHistory.fromJson(data);
      } else {
        throw Exception('Failed to load activity history: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error getting user activity history: $e');
      rethrow;
    }
  }

  // Получить историю посещенных мест
  static Future<List<PlaceActivity>> getUserPlacesHistory(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/activity/places'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => PlaceActivity.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load places history: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error getting user places history: $e');
      rethrow;
    }
  }

  // Получить историю пройденных маршрутов
  static Future<List<RouteActivity>> getUserRoutesHistory(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/activity/routes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => RouteActivity.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load routes history: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error getting user routes history: $e');
      rethrow;
    }
  }
}