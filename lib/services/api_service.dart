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
      // print('=== LOGIN REQUEST ===');
      // print('URL: $url');
      // print('Email: $email');
      
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

      // print('=== LOGIN RESPONSE ===');
      // print('Status: ${response.statusCode}');
      // print('Body: ${response.body}');

      ApiErrorHandler.handleResponse(response);
      return LoginResponse.fromJson(json.decode(response.body));
    } catch (e) {
      // print('=== LOGIN ERROR ===');
      // print('Error: $e');
      // print('Error type: ${e.runtimeType}');
      throw ApiErrorHandler.handleException(e);
    }
  }

  static Future<RegisterResponse> register(String name, String email, String password) async {
    // ДОБАВЛЕНО: Отладочная информация
    // print('=== REGISTER DEBUG ===');
    // print('Name: $name');
    // print('Email: $email');
    // print('Password: ${'*' * password.length}');

    final requestBody = {
      'first_name': name, // ИСПРАВЛЕНО: отправляем как first_name
      'email': email,
      'password': password,
    };

    // print('Request body: $requestBody');

    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    // print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');
    // print('====================');

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

  // Получение профиля пользователя
  static Future<User> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      final error = ApiError.fromJson(json.decode(response.body));
      throw Exception(error.error);
    }
  }

  // Обновление профиля пользователя
  static Future<User> updateProfile(String token, String firstName, String lastName, String email) async {
    final response = await http.put(
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

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      final error = ApiError.fromJson(json.decode(response.body));
      throw Exception(error.error);
    }
  }

  static Future<List<Place>> getPlaces() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/places'),
        headers: {'Content-Type': 'application/json'},
      );

      // print('=== PLACES API DEBUG ===');
      // print('Status code: ${response.statusCode}');
      // print('Response body: ${response.body}');
      // print('========================');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Детальный отладочный вывод
        // print('=== PLACES PARSING DEBUG ===');
        // print('Number of items: ${data.length}');
        if (data.isNotEmpty) {
          // print('First item structure:');
          final firstItem = data.first;
          if (firstItem is Map) {
            firstItem.forEach((key, value) {
              // print('  $key: $value (type: ${value.runtimeType})');
            });
          }

          // Проверяем парсинг первого элемента
          // print('Testing Place.fromJson with first item:');
          // try {
            // final testPlace = Place.fromJson(firstItem);
            // print('Parsed place - ID: ${testPlace.id}, Name: "${testPlace.name}"');
          // } catch (e) {
            // print('Error parsing first item: $e');
          // }
        }

        final List<Place> places = data.map((item) {
          // print('Parsing item: $item');
          final place = Place.fromJson(item);
          // print('Result - ID: ${place.id}, Name: "${place.name}"');
          return place;
        }).toList();

        // for (var i = 0; i < places.length; i++) {
        //   print('Place $i: ID=${places[i].id}, Name="${places[i].name}"');
        // }

        return places;
      } else {
        throw Exception('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error in getPlaces: $e');
      rethrow;
    }
  }

  // ИЗМЕНЕНО: Route -> AppRoute с улучшенной отладкой
  static Future<List<AppRoute>> getRoutes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/routes'),
        headers: {'Content-Type': 'application/json'},
      );

      // print('=== ROUTES API DEBUG ===');
      // print('Status code: ${response.statusCode}');
      // print('Response body: ${response.body}');
      // print('========================');

      if (response.statusCode == 200) {
        final responseBody = response.body;

        // Проверяем, что ответ не null
        if (responseBody.isEmpty) {

          return [];
        }

        final List<dynamic> data = json.decode(responseBody);
        // print('Parsed ${data.length} routes from API');

        final routes = <AppRoute>[];
        for (var item in data) {
          try {
            // print('Parsing route item: $item');
            final route = AppRoute.fromJson(item);
            // print('Successfully parsed route: ${route.name}');
            routes.add(route);
          } catch (e) {
            // print('Error parsing route: $e');
            // print('Problematic item: $item');
          }
        }

        // print('Successfully parsed ${routes.length} routes');
        return routes;
      } else {
        throw Exception('Failed to load routes: ${response.statusCode}');
      }
    } catch (e) {
      // print('Exception in getRoutes: $e');
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
    final response = await http.delete(
      Uri.parse('$baseUrl/auth/delete-account'),
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

  static Future<void> changePassword(String oldPassword, String newPassword) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Не авторизован');
    }

    final response = await http.put(
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

    if (response.statusCode == 200) {
      return;
    } else {
      final error = ApiError.fromJson(json.decode(response.body));
      throw Exception(error.error);
    }
  }

  static Future<List<Review>> getReviewsForPlace(int placeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/place/$placeId'),
        headers: {'Content-Type': 'application/json'},
      );

      // print('=== REVIEWS API DEBUG ===');
      // print('Status code: ${response.statusCode}');
      // print('Response body: ${response.body}');
      // print('========================');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // print('=== REVIEWS PARSING DEBUG ===');
        // print('Number of reviews: ${data.length}');
        if (data.isNotEmpty) {
          // print('First review FULL structure:');
          final firstItem = data.first;
          if (firstItem is Map) {
            firstItem.forEach((key, value) {
              // print('  $key: $value (type: ${value.runtimeType})');
              // Детальный вывод структуры user
              if (key == 'user' && value is Map) {
                // print('  User structure:');
                value.forEach((userKey, userValue) {
                  // print('    $userKey: $userValue (type: ${userValue.runtimeType})');
                });
              }
            });
          }
        }

        final List<Review> reviews = data.map((item) {
          // print('Parsing review item: $item');
          final review = Review.fromJson(item);
          // print('Parsed review - Author: "${review.authorName}", Rating: ${review.rating}');
          return review;
        }).toList();

        // for (var i = 0; i < reviews.length; i++) {
        //   print('Review $i: Author="${reviews[i].authorName}", Rating=${reviews[i].rating}, Text="${reviews[i].text}"');
        // }

        return reviews;
      } else {
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error in getReviewsForPlace: $e');
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

      // print('=== ADD REVIEW DEBUG ===');
      // print('Status code: ${response.statusCode}');
      // print('Response body: ${response.body}');
      // print('Request: place_id=$placeId, text=$text, rating=$rating');
      // print('========================');

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        // // Проверяем структуру ответа
        // print('=== ADD REVIEW RESPONSE STRUCTURE ===');
        data.forEach((key, value) {
          // print('  $key: $value (type: ${value.runtimeType})');
        });

        return Review.fromJson(data['review'] ?? data);
      } else {
        final error = ApiError.fromJson(json.decode(response.body));
        throw Exception(error.error);
      }
    } catch (e) {
      // print('Error in addReview: $e');
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
      // print('Error in getFavoritePlaces: $e');
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