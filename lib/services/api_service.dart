import 'package:dio/dio.dart';
import '../models/api_models.dart';
import '../core/errors/api_error_handler.dart' show ApiException;
import '../core/network/dio_client.dart';
import '../core/utils/logger.dart';

/// ApiService на базе Dio
/// 
/// Примечание: Эта версия использует Dio вместо http пакета
/// и является instance-based классом для поддержки DI
class ApiServiceDio {
  final Dio _dio;

  ApiServiceDio({Dio? dio}) : _dio = dio ?? createDio();

  /// Выполняет запрос и обрабатывает ошибки
  Future<T> _executeRequest<T>(
    Future<Response> Function() request,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await request();
      
      // Dio автоматически декодирует JSON в зависимости от responseType
      // По умолчанию это Map<String, dynamic> или List
      final data = response.data;
      
      if (data is Map<String, dynamic>) {
        return fromJson(data);
      } else if (data is List) {
        // Для списков - это не подходит, но оставим для совместимости
        throw ApiException(
          message: 'Unexpected response format',
          statusCode: response.statusCode,
          originalMessage: 'Expected single object, got list',
        );
      } else {
        throw ApiException(
          message: 'Unexpected response format',
          statusCode: response.statusCode,
          originalMessage: 'Invalid response data type',
        );
      }
    } on DioException catch (e) {
      // Преобразуем DioException в ApiException
      throw _handleDioException(e);
    } catch (e) {
      AppLogger.error('API request failed: $e');
      throw ApiException(
        message: 'Неизвестная ошибка',
        statusCode: null,
        originalMessage: e.toString(),
      );
    }
  }

  /// Выполняет запрос и возвращает список объектов
  Future<List<T>> _executeListRequest<T>(
    Future<Response> Function() request,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await request();
      final data = response.data;
      
      if (data is List) {
        return data
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map<String, dynamic> && data.containsKey('data')) {
        // Если ответ обернут в объект с ключом 'data'
        final listData = data['data'] as List;
        return listData
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(
          message: 'Unexpected response format',
          statusCode: response.statusCode,
          originalMessage: 'Expected list, got ${data.runtimeType}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      AppLogger.error('API list request failed: $e');
      throw ApiException(
        message: 'Неизвестная ошибка',
        statusCode: null,
        originalMessage: e.toString(),
      );
    }
  }

  /// Обрабатывает DioException и преобразует в ApiException
  ApiException _handleDioException(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final responseData = e.response!.data;

      String message;
      if (responseData is Map && responseData.containsKey('error')) {
        message = responseData['error'].toString();
      } else if (responseData is Map && responseData.containsKey('message')) {
        message = responseData['message'].toString();
      } else {
        message = 'Ошибка сервера: $statusCode';
      }

      return ApiException(
        message: message,
        statusCode: statusCode,
        originalMessage: e.message ?? 'Unknown error',
      );
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        message: 'Превышено время ожидания ответа от сервера. Проверьте подключение к интернету.',
        statusCode: null,
        originalMessage: 'Request timeout',
      );
    } else if (e.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'Не удалось подключиться к серверу. Проверьте подключение к интернету.',
        statusCode: null,
        originalMessage: 'Connection error',
      );
    } else {
      return ApiException(
        message: e.message ?? 'Неизвестная ошибка',
        statusCode: null,
        originalMessage: e.message ?? 'Unknown error',
      );
    }
  }

  // ========== Аутентификация ==========

  /// Вход в систему
  Future<LoginResponse> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return LoginResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Регистрация нового пользователя
  Future<RegisterResponse> register(String name, String email, String password) async {
    final response = await _dio.post(
      '/auth/register',
      data: {
        'first_name': name,
        'email': email,
        'password': password,
      },
    );

    return RegisterResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Обновление токена через refresh token
  Future<LoginResponse> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      '/auth/refresh',
      data: {
        'refresh_token': refreshToken,
      },
    );

    return LoginResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Получение профиля пользователя
  Future<User> getProfile(String? token) async {
    // Если token передан, добавляем его в заголовки (иначе AuthInterceptor добавит автоматически)
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;

    final response = await _dio.get(
      '/auth/profile',
      options: options,
    );

    return User.fromJson(response.data as Map<String, dynamic>);
  }

  /// Обновление профиля пользователя
  Future<User> updateProfile(String? token, String firstName, String lastName, String email) async {
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;

    final response = await _dio.put(
      '/auth/profile',
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      },
      options: options,
    );

    return User.fromJson(response.data as Map<String, dynamic>);
  }

  /// Изменение пароля
  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _dio.put(
      '/auth/change-password',
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );
  }

  /// Удаление аккаунта
  Future<void> deleteAccount(String? token) async {
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;

    await _dio.delete(
      '/auth/delete-account',
      options: options,
    );
  }

  // ========== Места (Places) ==========

  /// Получение списка мест
  Future<List<Place>> getPlaces() async {
    final response = await _dio.get('/places');
    
    // API возвращает {"data": [...]}
    final responseData = response.data;
    if (responseData is Map<String, dynamic> && responseData['data'] is List) {
      final data = responseData['data'] as List;
      return data
          .map((item) => Place.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    
    return [];
  }

  /// Получение деталей места по ID
  Future<Place> getPlaceById(int placeId) async {
    final response = await _dio.get('/places/$placeId');
    return Place.fromJson(response.data as Map<String, dynamic>);
  }

  // ========== Маршруты (Routes) ==========

  /// Получение списка маршрутов
  Future<List<AppRoute>> getRoutes({int? limit, int? offset}) async {
    final queryParameters = <String, dynamic>{};
    if (limit != null) queryParameters['limit'] = limit;
    if (offset != null) queryParameters['offset'] = offset;
    
    final response = await _dio.get(
      '/routes',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    
    final data = response.data;
    
    // Поддержка как старого формата (массив), так и нового (пагинация)
    List<dynamic> routesList;
    if (data is List) {
      // Старый формат - массив напрямую
      routesList = data;
    } else if (data is Map<String, dynamic> && data['data'] != null) {
      // Новый формат - пагинация с полем data
      routesList = data['data'] is List ? data['data'] : [];
    } else {
      return [];
    }
    
    return routesList
        .map((item) => AppRoute.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Получение деталей маршрута по ID (с местами)
  Future<AppRoute> getRouteById(int routeId) async {
    try {
      final response = await _dio.get('/routes/$routeId');
      return AppRoute.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      AppLogger.error('Failed to load route $routeId', e.error);
      rethrow;
    }
  }

  /// Создание нового маршрута
  Future<AppRoute> createRoute({
    required String name,
    required String description,
    String? overview,
    String? history,
    required double distance,
    double? duration,
    required int typeId,
    required int areaId,
    List<int>? categoryIds,
    required List<RouteStopData> stops,
    String? token,
  }) async {
    try {
      final options = token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null;

      final data = <String, dynamic>{
        'name': name,
        'description': description,
        'distance': distance,
        'type_id': typeId,
        'area_id': areaId,
        'stops': stops.map((stop) => {
          'place_id': stop.placeId,
          'order_num': stop.orderNum,
        }).toList(),
      };

      if (overview != null) data['overview'] = overview;
      if (history != null) data['history'] = history;
      if (duration != null) data['duration'] = duration;
      if (categoryIds != null && categoryIds.isNotEmpty) {
        data['category_ids'] = categoryIds;
      }

      final response = await _dio.post(
        '/routes',
        data: data,
        options: options,
      );

      // Возвращаем созданный маршрут
      final routeData = response.data['route'] as Map<String, dynamic>;
      return AppRoute.fromJson(routeData);
    } on DioException catch (e) {
      AppLogger.error('Failed to create route', e.error);
      if (e.response != null) {
        final errorMsg = e.response!.data['error']?.toString() ?? 'Ошибка создания маршрута';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  /// Получение статусов посещений для списка мест
  Future<Map<int, bool>> getPlacesVisitStatus(List<int> placeIds, String? token) async {
    if (placeIds.isEmpty) {
      return {};
    }

    try {
      final options = token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null;

      // Формируем query параметры: placeIds=1&placeIds=2&placeIds=3
      final queryParams = <String, dynamic>{
        'placeIds': placeIds.map((id) => id.toString()).toList(),
      };

      final response = await _dio.get(
        '/user/activity/places/statuses',
        queryParameters: queryParams,
        options: options,
      );

      // Преобразуем ответ из Map<String, bool> в Map<int, bool>
      final data = response.data as Map<String, dynamic>;
      final result = <int, bool>{};
      data.forEach((key, value) {
        final placeId = int.tryParse(key);
        if (placeId != null) {
          result[placeId] = value as bool;
        }
      });

      return result;
    } on DioException catch (e) {
      // Если пользователь не авторизован или endpoint не существует, возвращаем все false
      if (e.response?.statusCode == 401 || e.response?.statusCode == 404) {
        AppLogger.warning('Cannot get visit statuses: ${e.response?.statusCode}, returning all false');
        return {for (final id in placeIds) id: false};
      }
      AppLogger.error('Failed to load places visit status', e.error);
      // При ошибке возвращаем все false
      return {for (final id in placeIds) id: false};
    }
  }

  // ========== Избранное (Favorites) ==========

  /// Получение статуса избранного для мест
  Future<bool> isPlaceFavorite(int placeId, String? token) async {
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;

    try {
      final response = await _dio.get(
        '/favorites/places/$placeId',
        options: options,
      );
      return response.data['is_favorite'] as bool? ?? false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return false;
      }
      rethrow;
    }
  }

  /// Получение статуса избранного для маршрутов
  Future<bool> isRouteFavorite(int routeId, String? token) async {
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;

    try {
      final response = await _dio.get(
        '/favorites/routes/$routeId',
        options: options,
      );
      return response.data['is_favorite'] as bool? ?? false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return false;
      }
      rethrow;
    }
  }

  /// Получение статусов избранного для списка маршрутов (bulk)
  Future<Map<int, bool>> getFavoriteStatusesForRoutes(
    List<int> routeIds,
    String? token,
  ) async {
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;

    try {
      // Пытаемся использовать bulk endpoint
      final response = await _dio.post(
        '/favorites/routes/statuses',
        data: {'route_ids': routeIds},
        options: options,
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      final Map<int, bool> result = {};
      
      data.forEach((key, value) {
        final routeId = int.tryParse(key);
        if (routeId != null) {
          result[routeId] = value as bool? ?? false;
        }
      });
      
      return result;
    } on DioException catch (e) {
      // Если bulk endpoint не поддерживается, делаем параллельные запросы
      if (e.response?.statusCode == 404 || e.response?.statusCode == 405) {
        final futures = routeIds.map((routeId) async {
          try {
            final isFavorite = await isRouteFavorite(routeId, token);
            return MapEntry(routeId, isFavorite);
          } catch (e) {
            AppLogger.warning('Failed to get favorite status for route $routeId: $e');
            return MapEntry(routeId, false);
          }
        });
        
        final results = await Future.wait(futures);
        return Map.fromEntries(results);
      }
      rethrow;
    }
  }

  /// Добавление места в избранное
  Future<void> addPlaceToFavorites(int placeId, String? token) async {
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;

    await _dio.post(
      '/favorites/places/$placeId',
      options: options,
    );
  }

  /// Удаление места из избранного
  Future<void> removePlaceFromFavorites(int placeId, String? token) async {
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;

    await _dio.delete(
      '/favorites/places/$placeId',
      options: options,
    );
  }

  /// Добавление маршрута в избранное
  Future<void> addRouteToFavorites(int routeId, String? token) async {
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;

    await _dio.post(
      '/favorites/routes/$routeId',
      options: options,
    );
  }

  /// Удаление маршрута из избранного
  Future<void> removeRouteFromFavorites(int routeId, String? token) async {
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;

    await _dio.delete(
      '/favorites/routes/$routeId',
      options: options,
    );
  }

  /// Получение списка избранных мест
  Future<List<Place>> getFavoritePlaces(String? token) async {
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;

    final response = await _dio.get(
      '/favorites/places',
      options: options,
    );

    final data = response.data;
    if (data is List) {
      return data
          .map((item) => Place.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    
    return [];
  }

  /// Получение списка избранных маршрутов
  Future<List<AppRoute>> getFavoriteRoutes(String? token) async {
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;

    final response = await _dio.get(
      '/favorites/routes',
      options: options,
    );

    final data = response.data;
    if (data is List) {
      return data
          .map((item) => AppRoute.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    
    return [];
  }

  // ========== Отзывы (Reviews) ==========

  /// Добавление отзыва
  Future<void> addReview({
    int? placeId,
    int? routeId,
    required int rating,
    String? comment,
    String? token,
  }) async {
    if (placeId == null && routeId == null) {
      throw ArgumentError('Either placeId or routeId must be provided');
    }
    if (placeId != null && routeId != null) {
      throw ArgumentError('Only one of placeId or routeId should be provided');
    }

    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;

    final endpoint = placeId != null
        ? '/places/$placeId/reviews'
        : '/routes/$routeId/reviews';

    await _dio.post(
      endpoint,
      data: {
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
      options: options,
    );
  }

  // ========== Пользователь (User) ==========

  /// Получение статистики пользователя
  Future<Map<String, int>> getUserStatistics(String? token) async {
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;

    try {
      final response = await _dio.get(
        '/user/statistics',
        options: options,
      );
      return Map<String, int>.from(response.data as Map);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return {'visitedPlaces': 0, 'completedRoutes': 0};
      }
      rethrow;
    }
  }

  /// Получение истории активности пользователя
  Future<ActivityHistory> getUserActivityHistory(String? token) async {
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;

    final response = await _dio.get(
      '/user/activity',
      options: options,
    );
    return ActivityHistory.fromJson(response.data as Map<String, dynamic>);
  }

  /// Получение истории посещенных мест
  Future<List<PlaceActivity>> getUserPlacesHistory(String? token) async {
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;

    final response = await _dio.get(
      '/user/activity/places',
      options: options,
    );

    final data = response.data;
    if (data is List) {
      return data
          .map((item) => PlaceActivity.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    
    return [];
  }

  /// Получение истории пройденных маршрутов
  Future<List<RouteActivity>> getUserRoutesHistory(String? token) async {
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;

    final response = await _dio.get(
      '/user/activity/routes',
      options: options,
    );

    final data = response.data;
    if (data is List) {
      return data
          .map((item) => RouteActivity.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    
    return [];
  }

  // ========== Отзывы ==========

  /// Получение отзывов для места
  Future<List<Review>> getReviewsForPlace(int placeId) async {
    try {
      final response = await _dio.get('/reviews/place/$placeId');
      
      final data = response.data;
      if (data is List) {
        return data
            .map((item) => Review.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } on DioException catch (e) {
      AppLogger.error('Failed to load reviews for place $placeId', e.error);
      rethrow;
    }
  }

  /// Получение отзывов для маршрута
  Future<List<Review>> getReviewsForRoute(int routeId) async {
    try {
      final response = await _dio.get('/reviews/route/$routeId');
      
      final data = response.data;
      if (data is List) {
        return data
            .map((item) => Review.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } on DioException catch (e) {
      // Если эндпоинт не существует (404), просто возвращаем пустой список
      // Это нормально, если бэкенд еще не реализовал этот эндпоинт
      if (e.response?.statusCode == 404) {
        AppLogger.warning('Reviews endpoint for route $routeId not found (404), returning empty list');
        return [];
      }
      AppLogger.error('Failed to load reviews for route $routeId', e.error);
      rethrow;
    }
  }

  // ========== Утилиты ==========

  /// Проверка соединения с сервером
  Future<bool> checkConnection() async {
    try {
      await _dio.get('/ping');
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Получает список посещенных мест пользователя
  Future<List<Map<String, dynamic>>> getUserActivityPlaces(String token) async {
    try {
      final response = await _dio.get(
        '/user/activity/places',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      
      return [];
    } catch (e) {
      AppLogger.error('Error loading visited places: $e');
      return [];
    }
  }
}

