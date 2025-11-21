import 'package:dio/dio.dart';
import '../shared/domain/entities/area.dart';
import '../shared/domain/entities/category.dart';
import '../shared/domain/entities/tag.dart';
import 'auth_service.dart';
import '../models/api_models.dart';

/// Сервис для работы с Strapi CMS
class StrapiService {
  final Dio _dio;
  final String baseUrl;

  StrapiService({
    required this.baseUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  // ==================== Утилиты ====================

  /// Получить userId текущего пользователя
  /// Возвращает null если пользователь не авторизован
  Future<String?> getCurrentUserId() async {
    try {
      final user = await AuthService.getUser();
      return user?.id.toString();
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  // ==================== Авторизация ====================

  /// Вход в систему через Strapi
  /// 
  /// Использует Strapi локальную авторизацию: /api/auth/local
  /// 
  /// Возвращает JWT токен и данные пользователя
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/local',
        data: {
          'identifier': identifier, // email или username
          'password': password,
        },
      );

      return {
        'jwt': response.data['jwt'] as String,
        'user': response.data['user'] as Map<String, dynamic>,
      };
    } catch (e) {
      print('Error logging in: $e');
      rethrow;
    }
  }

  /// Регистрация нового пользователя через Strapi
  /// 
  /// Использует Strapi локальную регистрацию: /api/auth/local/register
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/local/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      return {
        'jwt': response.data['jwt'] as String,
        'user': response.data['user'] as Map<String, dynamic>,
      };
    } catch (e) {
      print('Error registering: $e');
      rethrow;
    }
  }

  /// Получить текущего пользователя через Strapi
  /// 
  /// Использует Strapi endpoint: /api/users/me
  /// Требует JWT токен в заголовках
  Future<Map<String, dynamic>> getCurrentUser(String jwt) async {
    try {
      final response = await _dio.get(
        '/api/users/me',
        options: Options(
          headers: {'Authorization': 'Bearer $jwt'},
        ),
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('Error getting current user: $e');
      rethrow;
    }
  }

  /// Обновить профиль пользователя через Strapi
  /// 
  /// Использует Strapi endpoint: /api/users/:id
  /// Требует JWT токен в заголовках
  Future<Map<String, dynamic>> updateUser({
    required int userId,
    required String jwt,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (email != null) data['email'] = email;
      if (username != null) data['username'] = username;
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;

      final response = await _dio.put(
        '/api/users/$userId',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $jwt'},
        ),
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  /// Загрузить аватар через Strapi Media Library
  /// 
  /// Использует Strapi endpoint: /api/upload
  /// Требует JWT токен в заголовках
  /// 
  /// Примечание: Для работы нужно настроить связь avatar в коллекции User в Strapi
  Future<Map<String, dynamic>> uploadAvatar({
    required String filePath,
    required String jwt,
    required int userId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(filePath),
        'ref': 'plugin::users-permissions.user',
        'refId': userId.toString(),
        'field': 'avatar',
      });

      final response = await _dio.post(
        '/api/upload',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $jwt'},
        ),
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('Error uploading avatar: $e');
      rethrow;
    }
  }

  /// Удалить аватар через Strapi Media Library
  /// 
  /// Использует Strapi endpoint: /api/upload/files/:id
  /// Требует JWT токен в заголовках
  /// 
  /// Примечание: fileId можно получить из данных пользователя (user.avatar.id)
  Future<void> deleteAvatar({
    required int fileId,
    required String jwt,
  }) async {
    try {
      await _dio.delete(
        '/api/upload/files/$fileId',
        options: Options(
          headers: {'Authorization': 'Bearer $jwt'},
        ),
      );
    } catch (e) {
      print('Error deleting avatar: $e');
      rethrow;
    }
  }

  /// Восстановление пароля через Strapi
  /// 
  /// Использует Strapi endpoint: /api/auth/forgot-password
  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post(
        '/api/auth/forgot-password',
        data: {'email': email},
      );
    } catch (e) {
      print('Error requesting password reset: $e');
      rethrow;
    }
  }

  /// Сброс пароля через Strapi
  /// 
  /// Использует Strapi endpoint: /api/auth/reset-password
  Future<void> resetPassword({
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _dio.post(
        '/api/auth/reset-password',
        data: {
          'code': code,
          'password': password,
          'passwordConfirmation': passwordConfirmation,
        },
      );
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }

  // ==================== Категории ====================
  
  /// Получить все категории
  Future<List<PlaceCategory>> getCategories() async {
    try {
      final response = await _dio.get('/api/categories');
      
      final data = response.data['data'] as List;
      return data.map((item) {
        final attrs = item['attributes'];
        return PlaceCategory(
          id: item['id'],
          name: attrs['name'] ?? '',
          description: '', // В Strapi нет description
          isActive: attrs['is_active'] ?? true,
        );
      }).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  // ==================== Районы ====================
  
  /// Получить все районы
  Future<List<PlaceArea>> getAreas() async {
    try {
      final response = await _dio.get('/api/areas');
      
      final data = response.data['data'] as List;
      return data.map((item) {
        final attrs = item['attributes'];
        return PlaceArea(
          id: item['id'],
          name: attrs['name'] ?? '',
          description: '', // В Strapi нет description
          isActive: attrs['is_active'] ?? true,
        );
      }).toList();
    } catch (e) {
      print('Error fetching areas: $e');
      rethrow;
    }
  }

  // ==================== Теги ====================
  
  /// Получить все теги
  Future<List<Tag>> getTags() async {
    try {
      final response = await _dio.get('/api/tags');
      
      final data = response.data['data'] as List;
      return data.map((item) {
        final attrs = item['attributes'];
        return Tag(
          id: item['id'],
          name: attrs['name'] ?? '',
          description: '', // В Strapi нет description
          isActive: attrs['is_active'] ?? true,
        );
      }).toList();
    } catch (e) {
      print('Error fetching tags: $e');
      rethrow;
    }
  }

  // ==================== Типы маршрутов ====================
  
  /// Получить все типы маршрутов
  Future<List<RouteType>> getRouteTypes() async {
    try {
      final response = await _dio.get('/api/route-types');
      
      final data = response.data['data'] as List;
      return data.map((item) {
        final attrs = item['attributes'];
        return RouteType(
          id: item['id'],
          name: attrs['name'] ?? '',
          slug: attrs['slug'] ?? '',
          isActive: attrs['is_active'] ?? true,
        );
      }).toList();
    } catch (e) {
      print('Error fetching route types: $e');
      rethrow;
    }
  }

  // ==================== Места ====================
  
  /// Получить все места с полной информацией
  Future<List<StrapiPlace>> getPlaces({
    List<int>? categoryIds,
    List<int>? areaIds,
    List<int>? tagIds,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'populate': '*',
      };
      
      // Добавляем фильтры если указаны
      if (categoryIds != null && categoryIds.isNotEmpty) {
        queryParams['filters[categories][id][\$in]'] = categoryIds.join(',');
      }
      if (areaIds != null && areaIds.isNotEmpty) {
        queryParams['filters[area][id][\$in]'] = areaIds.join(',');
      }
      if (tagIds != null && tagIds.isNotEmpty) {
        queryParams['filters[tags][id][\$in]'] = tagIds.join(',');
      }
      
      // Добавляем populate для загрузки изображений и связей
      queryParams['populate'] = '*';
      
      final response = await _dio.get(
        '/api/places',
        queryParameters: queryParams,
      );
      
      final data = response.data['data'] as List;
      return data.map((item) => StrapiPlace.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching places: $e');
      rethrow;
    }
  }

  /// Получить место по ID
  Future<StrapiPlace> getPlaceById(int id) async {
    try {
      final response = await _dio.get(
        '/api/places/$id',
        queryParameters: {'populate': '*'},
      );
      
      return StrapiPlace.fromJson(response.data['data']);
    } catch (e) {
      print('Error fetching place $id: $e');
      rethrow;
    }
  }

  // ==================== Маршруты ====================
  
  /// Получить все маршруты
  Future<List<StrapiRoute>> getRoutes({
    List<int>? routeTypeIds,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'populate': '*',
      };
      
      if (routeTypeIds != null && routeTypeIds.isNotEmpty) {
        queryParams['filters[route_type][id][\$in]'] = routeTypeIds.join(',');
      }
      
      final response = await _dio.get(
        '/api/routes',
        queryParameters: queryParams,
      );
      
      final data = response.data['data'] as List;
      return data.map((item) => StrapiRoute.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching routes: $e');
      rethrow;
    }
  }

  /// Получить маршрут по ID
  Future<StrapiRoute> getRouteById(int id) async {
    try {
      final response = await _dio.get(
        '/api/routes/$id',
        queryParameters: {
          'populate[places][populate]': '*',
          'populate[route_type]': '*',
        },
      );
      
      return StrapiRoute.fromJson(response.data['data']);
    } catch (e) {
      print('Error fetching route $id: $e');
      rethrow;
    }
  }

  // ==================== Проверка соединения ====================
  
  /// Проверить доступность Strapi API
  Future<bool> checkConnection() async {
    try {
      final response = await _dio.get('/api/categories');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================== Отзывы ====================

  /// Создать отзыв для места или маршрута
  Future<StrapiReview> createReview({
    required int rating,
    String? text,
    int? placeId,
    int? routeId,
    String? ipAddress,
  }) async {
    try {
      // Формируем данные для отправки
      final Map<String, dynamic> data = {
        'data': {
          'rating': rating,
          'text': text ?? '',
        }
      };

      // Добавляем связь с местом, если указано
      if (placeId != null) {
        data['data']['place'] = placeId;
      }

      // Добавляем связь с маршрутом, если указано
      if (routeId != null) {
        data['data']['route'] = routeId;
      }

      // Добавляем IP адрес, если указан
      if (ipAddress != null) {
        data['data']['ip_address'] = ipAddress;
      }

      print('[DEBUG] Creating review with data: $data');

      final response = await _dio.post(
        '/api/reviews',
        data: data,
      );

      print('[DEBUG] Review created successfully: ${response.data}');

      return StrapiReview.fromJson(response.data['data']);
    } catch (e) {
      print('[ERROR] Error creating review: $e');
      rethrow;
    }
  }

  /// Получить отзывы для конкретного места
  Future<List<StrapiReview>> getPlaceReviews(int placeId) async {
    try {
      print('[DEBUG] Loading reviews for place $placeId from Strapi...');
      
      final response = await _dio.get(
        '/api/reviews',
        queryParameters: {
          'filters[place][id][\$eq]': placeId,
          'sort': 'createdAt:desc', // Новые отзывы первыми
          'populate': '*',
        },
      );

      final data = response.data['data'] as List;
      final reviews = data.map((item) => StrapiReview.fromJson(item)).toList();
      
      print('[DEBUG] Loaded ${reviews.length} reviews for place $placeId');
      
      return reviews;
    } catch (e) {
      print('[ERROR] Error loading reviews for place $placeId: $e');
      rethrow;
    }
  }

  /// Получить отзывы для конкретного маршрута
  Future<List<StrapiReview>> getRouteReviews(int routeId) async {
    try {
      print('[DEBUG] Loading reviews for route $routeId from Strapi...');
      
      final response = await _dio.get(
        '/api/reviews',
        queryParameters: {
          'filters[route][id][\$eq]': routeId,
          'sort': 'createdAt:desc', // Новые отзывы первыми
          'populate': '*',
        },
      );

      final data = response.data['data'] as List;
      final reviews = data.map((item) => StrapiReview.fromJson(item)).toList();
      
      print('[DEBUG] Loaded ${reviews.length} reviews for route $routeId');
      
      return reviews;
    } catch (e) {
      print('[ERROR] Error loading reviews for route $routeId: $e');
      rethrow;
    }
  }

  // ==================== Избранное ====================

  /// Получить избранное пользователя
  Future<List<StrapiFavorite>> getFavorites(String userId) async {
    try {
      final response = await _dio.get(
        '/api/favorites',
        queryParameters: {
          'filters[user_id][\$eq]': userId,
          'populate': '*', // Запрашиваем связанные данные
        },
      );
      final data = response.data['data'] as List;
      return data.map((item) => StrapiFavorite.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching favorites: $e');
      rethrow;
    }
  }

  /// Получить избранные места пользователя с полными данными
  Future<List<StrapiPlace>> getFavoritePlaces(String userId) async {
    try {
      // Получаем избранное с полными данными мест
      final favorites = await getFavorites(userId);
      final places = favorites
          .where((f) => f.place != null)
          .map((f) => f.place!)
          .toList();

      return places;
    } catch (e) {
      print('Error fetching favorite places: $e');
      rethrow;
    }
  }

  /// Получить избранные маршруты пользователя с полными данными
  Future<List<StrapiRoute>> getFavoriteRoutes(String userId) async {
    try {
      // Получаем избранное с полными данными маршрутов
      final favorites = await getFavorites(userId);
      final routes = favorites
          .where((f) => f.route != null)
          .map((f) => f.route!)
          .toList();

      return routes;
    } catch (e) {
      print('Error fetching favorite routes: $e');
      rethrow;
    }
  }

  /// Проверить, добавлено ли место/маршрут в избранное
  Future<bool> isFavorite(String userId, {int? placeId, int? routeId}) async {
    try {
      final Map<String, dynamic> queryParams = {
        'filters[user_id][\$eq]': userId,
      };
      if (placeId != null) {
        queryParams['filters[place][id][\$eq]'] = placeId;
      }
      if (routeId != null) {
        queryParams['filters[route][id][\$eq]'] = routeId;
      }

      final response = await _dio.get(
        '/api/favorites',
        queryParameters: queryParams,
      );
      final data = response.data['data'] as List;
      return data.isNotEmpty;
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  /// Добавить в избранное
  Future<StrapiFavorite> addToFavorites({
    required String userId,
    int? placeId,
    int? routeId,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'user_id': userId,
      };
      if (placeId != null) {
        data['place'] = placeId;
      }
      if (routeId != null) {
        data['route'] = routeId;
      }

      final response = await _dio.post(
        '/api/favorites',
        data: {'data': data},
      );
      return StrapiFavorite.fromJson(response.data['data']);
    } catch (e) {
      print('Error adding to favorites: $e');
      rethrow;
    }
  }

  /// Удалить из избранного
  Future<void> removeFromFavorites(int favoriteId) async {
    try {
      await _dio.delete('/api/favorites/$favoriteId');
    } catch (e) {
      print('Error removing from favorites: $e');
      rethrow;
    }
  }

  /// Удалить из избранного по place/route ID
  Future<void> removeFromFavoritesByPlaceOrRoute({
    required String userId,
    int? placeId,
    int? routeId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'filters[user_id][\$eq]': userId,
      };
      if (placeId != null) {
        queryParams['filters[place][id][\$eq]'] = placeId;
      }
      if (routeId != null) {
        queryParams['filters[route][id][\$eq]'] = routeId;
      }

      final response = await _dio.get(
        '/api/favorites',
        queryParameters: queryParams,
      );
      final data = response.data['data'] as List;
      
      // Удаляем все найденные записи
      for (var item in data) {
        await _dio.delete('/api/favorites/${item['id']}');
      }
    } catch (e) {
      print('Error removing from favorites: $e');
      rethrow;
    }
  }

  /// Получить статусы избранного для списка маршрутов (bulk)
  /// Возвращает Map<routeId, isFavorite>
  Future<Map<int, bool>> getFavoriteStatusesForRoutes(
    List<int> routeIds,
    String userId,
  ) async {
    try {
      // Получаем все избранные маршруты пользователя
      final favorites = await getFavorites(userId);
      
      // Создаем Set из ID избранных маршрутов для быстрого поиска
      final favoriteRouteIds = favorites
          .where((f) => f.route != null)
          .map((f) => f.route!.id)
          .toSet();
      
      // Создаем карту статусов для всех запрошенных маршрутов
      return {
        for (var routeId in routeIds) routeId: favoriteRouteIds.contains(routeId)
      };
    } catch (e) {
      print('Error getting favorite statuses for routes: $e');
      // В случае ошибки возвращаем все как false
      return {for (var routeId in routeIds) routeId: false};
    }
  }

  /// Добавить маршрут в избранное
  Future<StrapiFavorite> addRouteToFavorites(int routeId, String userId) async {
    return addToFavorites(userId: userId, routeId: routeId);
  }

  /// Удалить маршрут из избранного
  Future<void> removeRouteFromFavorites(int routeId, String userId) async {
    return removeFromFavoritesByPlaceOrRoute(userId: userId, routeId: routeId);
  }

  // ==================== История посещений ====================

  /// Получить историю посещений пользователя
  Future<List<StrapiVisitedPlace>> getVisitedPlaces(String userId) async {
    try {
      final response = await _dio.get(
        '/api/visited-places',
        queryParameters: {
          'filters[user_id][\$eq]': userId,
          'populate': '*', // Запрашиваем связанные данные
          'sort': 'visited_at:desc', // Сортируем по дате посещения, новые первыми
        },
      );
      final data = response.data['data'] as List;
      return data.map((item) => StrapiVisitedPlace.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching visited places: $e');
      rethrow;
    }
  }

  /// Добавить место/маршрут в историю посещений
  Future<StrapiVisitedPlace> addVisitedPlace({
    required String userId,
    int? placeId,
    int? routeId,
    DateTime? visitedAt,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'user_id': userId,
      };
      if (placeId != null) {
        data['place'] = placeId;
      }
      if (routeId != null) {
        data['route'] = routeId;
      }
      if (visitedAt != null) {
        data['visited_at'] = visitedAt.toIso8601String();
      } else {
        data['visited_at'] = DateTime.now().toIso8601String();
      }

      final response = await _dio.post(
        '/api/visited-places',
        data: {'data': data},
      );
      return StrapiVisitedPlace.fromJson(response.data['data']);
    } catch (e) {
      print('Error adding visited place: $e');
      rethrow;
    }
  }

  /// Проверить, посещал ли пользователь место/маршрут
  Future<bool> hasVisited(String userId, {int? placeId, int? routeId}) async {
    try {
      final Map<String, dynamic> queryParams = {
        'filters[user_id][\$eq]': userId,
      };
      if (placeId != null) {
        queryParams['filters[place][id][\$eq]'] = placeId;
      }
      if (routeId != null) {
        queryParams['filters[route][id][\$eq]'] = routeId;
      }

      final response = await _dio.get(
        '/api/visited-places',
        queryParameters: queryParams,
      );
      final data = response.data['data'] as List;
      return data.isNotEmpty;
    } catch (e) {
      print('Error checking visited place: $e');
      return false;
    }
  }

  /// Получить статусы посещений для списка мест (bulk)
  /// Возвращает Map<placeId, hasVisited>
  Future<Map<int, bool>> getPlacesVisitStatus(
    List<int> placeIds,
    String userId,
  ) async {
    try {
      // Получаем все посещенные места пользователя
      final visited = await getVisitedPlaces(userId);
      
      // Создаем Set из ID посещенных мест для быстрого поиска
      final visitedPlaceIds = visited
          .where((v) => v.place != null)
          .map((v) => v.place!.id)
          .toSet();
      
      // Создаем карту статусов для всех запрошенных мест
      return {
        for (var placeId in placeIds) placeId: visitedPlaceIds.contains(placeId)
      };
    } catch (e) {
      print('Error getting places visit status: $e');
      // В случае ошибки возвращаем все как false
      return {for (var placeId in placeIds) placeId: false};
    }
  }
}

// ==================== Модели данных ====================

/// Тип маршрута
class RouteType {
  final int id;
  final String name;
  final String slug;
  final bool isActive;

  RouteType({
    required this.id,
    required this.name,
    required this.slug,
    required this.isActive,
  });
}

/// Место из Strapi
class StrapiPlace {
  final int id;
  final String name;
  final String slug;
  final List<String> imageUrls;
  final String? history;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? workingHours;
  final String? phone;
  final String? website;
  final bool isActive;
  final PlaceArea? area;
  final List<PlaceCategory> categories;
  final List<Tag> tags;

  StrapiPlace({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrls = const [],
    this.history,
    this.address,
    this.latitude,
    this.longitude,
    this.workingHours,
    this.phone,
    this.website,
    required this.isActive,
    this.area,
    this.categories = const [],
    this.tags = const [],
  });

  factory StrapiPlace.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'];
    
    // Получаем URLs изображений
    final imageUrls = <String>[];
    if (attrs['images']?['data'] != null) {
      final imagesData = attrs['images']['data'];
      if (imagesData is List) {
        for (var imageItem in imagesData) {
          final url = imageItem['attributes']?['url'];
          if (url != null) {
            imageUrls.add(url);
          }
        }
      }
    }
    
    // Получаем район
    PlaceArea? area;
    if (attrs['area']?['data'] != null) {
      final areaData = attrs['area']['data'];
      final areaAttrs = areaData['attributes'];
      area = PlaceArea(
        id: areaData['id'],
        name: areaAttrs['name'] ?? '',
        description: '',
        isActive: areaAttrs['is_active'] ?? true,
      );
    }
    
    // Получаем категории
    final categories = <PlaceCategory>[];
    if (attrs['categories']?['data'] != null) {
      final categoriesData = attrs['categories']['data'] as List;
      for (var cat in categoriesData) {
        final catAttrs = cat['attributes'];
        categories.add(PlaceCategory(
          id: cat['id'],
          name: catAttrs['name'] ?? '',
          description: '',
          isActive: catAttrs['is_active'] ?? true,
        ));
      }
    }
    
    // Получаем теги
    final tags = <Tag>[];
    if (attrs['tags']?['data'] != null) {
      final tagsData = attrs['tags']['data'] as List;
      for (var tag in tagsData) {
        final tagAttrs = tag['attributes'];
        tags.add(Tag(
          id: tag['id'],
          name: tagAttrs['name'] ?? '',
          description: '',
          isActive: tagAttrs['is_active'] ?? true,
        ));
      }
    }
    
    return StrapiPlace(
      id: json['id'],
      name: attrs['name'] ?? '',
      slug: attrs['slug'] ?? '',
      imageUrls: imageUrls,
      history: attrs['history'],
      address: attrs['address'],
      latitude: attrs['latitude']?.toDouble(),
      longitude: attrs['longitude']?.toDouble(),
      workingHours: attrs['working_hours'],
      phone: attrs['phone'],
      website: attrs['website'],
      isActive: attrs['is_active'] ?? true,
      area: area,
      categories: categories,
      tags: tags,
    );
  }
}

/// Маршрут из Strapi
class StrapiRoute {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final bool isActive;
  final RouteType? routeType;
  final List<StrapiPlace> places;

  StrapiRoute({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.isActive,
    this.routeType,
    this.places = const [],
  });

  factory StrapiRoute.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'];
    
    // Получаем тип маршрута
    RouteType? routeType;
    if (attrs['route_type']?['data'] != null) {
      final typeData = attrs['route_type']['data'];
      final typeAttrs = typeData['attributes'];
      routeType = RouteType(
        id: typeData['id'],
        name: typeAttrs['name'] ?? '',
        slug: typeAttrs['slug'] ?? '',
        isActive: typeAttrs['is_active'] ?? true,
      );
    }
    
    // Получаем места
    final places = <StrapiPlace>[];
    if (attrs['places']?['data'] != null) {
      final placesData = attrs['places']['data'] as List;
      for (var place in placesData) {
        places.add(StrapiPlace.fromJson(place));
      }
    }
    
    return StrapiRoute(
      id: json['id'],
      name: attrs['name'] ?? '',
      slug: attrs['slug'] ?? '',
      description: attrs['description'],
      isActive: attrs['is_active'] ?? true,
      routeType: routeType,
      places: places,
    );
  }
}

/// Отзыв из Strapi
class StrapiReview {
  final int id;
  final int rating;
  final String text;
  final String? ipAddress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;

  StrapiReview({
    required this.id,
    required this.rating,
    required this.text,
    this.ipAddress,
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
  });

  factory StrapiReview.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'];
    return StrapiReview(
      id: json['id'],
      rating: attrs['rating'] ?? 0,
      text: attrs['text'] ?? '',
      ipAddress: attrs['ip_address'],
      createdAt: DateTime.parse(attrs['createdAt']),
      updatedAt: DateTime.parse(attrs['updatedAt']),
      publishedAt: attrs['publishedAt'] != null 
          ? DateTime.parse(attrs['publishedAt']) 
          : null,
    );
  }
}

/// Избранное из Strapi
class StrapiFavorite {
  final int id;
  final String userId;
  final StrapiPlace? place; // Изменено с placeId на place
  final StrapiRoute? route; // Изменено с routeId на route
  final DateTime createdAt;
  final DateTime updatedAt;

  StrapiFavorite({
    required this.id,
    required this.userId,
    this.place,
    this.route,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StrapiFavorite.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'];
    
    // Парсим place если есть
    StrapiPlace? place;
    if (attrs['place']?['data'] != null) {
      place = StrapiPlace.fromJson(attrs['place']['data']);
    }
    
    // Парсим route если есть
    StrapiRoute? route;
    if (attrs['route']?['data'] != null) {
      route = StrapiRoute.fromJson(attrs['route']['data']);
    }
    
    return StrapiFavorite(
      id: json['id'],
      userId: attrs['user_id'] ?? '',
      place: place,
      route: route,
      createdAt: DateTime.parse(attrs['createdAt']),
      updatedAt: DateTime.parse(attrs['updatedAt']),
    );
  }
}

/// История посещений из Strapi
class StrapiVisitedPlace {
  final int id;
  final String userId;
  final StrapiPlace? place; // Изменено с placeId на place
  final StrapiRoute? route; // Изменено с routeId на route
  final DateTime? visitedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  StrapiVisitedPlace({
    required this.id,
    required this.userId,
    this.place,
    this.route,
    this.visitedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StrapiVisitedPlace.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'];
    
    // Парсим place если есть
    StrapiPlace? place;
    if (attrs['place']?['data'] != null) {
      place = StrapiPlace.fromJson(attrs['place']['data']);
    }
    
    // Парсим route если есть
    StrapiRoute? route;
    if (attrs['route']?['data'] != null) {
      route = StrapiRoute.fromJson(attrs['route']['data']);
    }
    
    return StrapiVisitedPlace(
      id: json['id'],
      userId: attrs['user_id'] ?? '',
      place: place,
      route: route,
      visitedAt: attrs['visited_at'] != null 
          ? DateTime.parse(attrs['visited_at']) 
          : null,
      createdAt: DateTime.parse(attrs['createdAt']),
      updatedAt: DateTime.parse(attrs['updatedAt']),
    );
  }
}

