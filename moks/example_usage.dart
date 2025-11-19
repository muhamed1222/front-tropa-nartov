// Примеры использования моковых данных
// Этот файл содержит готовые функции для работы с моками

import 'mock_data.dart';
import 'models.dart';

/// Получить место по ID
Place? getPlaceById(String id) {
  try {
    return mockPlaces.firstWhere((place) => place.id == id);
  } catch (e) {
    return null;
  }
}

/// Получить маршрут по ID
Route? getRouteById(String id) {
  try {
    return mockRoutes.firstWhere((route) => route.id == id);
  } catch (e) {
    return null;
  }
}

/// Получить пользователя по ID
User? getUserById(String id) {
  try {
    return mockUsers.firstWhere((user) => user.id == id);
  } catch (e) {
    return null;
  }
}

/// Получить главное изображение места
ImageModel? getMainPlaceImage(String placeId) {
  final place = getPlaceById(placeId);
  if (place == null) return null;

  try {
    return place.images.firstWhere((img) => img.isMain);
  } catch (e) {
    // Если главного нет, вернуть первое доступное
    return place.images.isNotEmpty ? place.images.first : null;
  }
}

/// Получить все изображения места
List<ImageModel> getPlaceImages(String placeId) {
  final place = getPlaceById(placeId);
  return place?.images ?? [];
}

/// Получить главное изображение маршрута
ImageModel? getMainRouteImage(String routeId) {
  try {
    return mockRouteImages.firstWhere(
      (img) => img.routeId == routeId && img.isMain,
    );
  } catch (e) {
    try {
      return mockRouteImages.firstWhere((img) => img.routeId == routeId);
    } catch (e) {
      return null;
    }
  }
}

/// Получить все изображения маршрута
List<ImageModel> getRouteImages(String routeId) {
  return mockRouteImages.where((img) => img.routeId == routeId).toList();
}

/// Получить остановки маршрута с данными о местах
List<Map<String, dynamic>> getRouteStopsWithPlaces(String routeId) {
  final stops = mockRouteStops.where((stop) => stop.routeId == routeId).toList()..sort((a, b) => a.orderNum.compareTo(b.orderNum));

  return stops.map((stop) {
    final place = getPlaceById(stop.placeId);
    return {
      'stop': stop,
      'place': place,
    };
  }).toList();
}

/// Получить отзывы места с данными пользователей
List<Map<String, dynamic>> getPlaceReviewsWithUsers(String placeId) {
  final reviews =
      mockReviews.where((review) => review.placeId == placeId && review.isActive).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return reviews.map((review) {
    final user = getUserById(review.authorId);
    return {
      'review': review,
      'user': user,
    };
  }).toList();
}

/// Получить отзывы маршрута с данными пользователей
List<Map<String, dynamic>> getRouteReviewsWithUsers(String routeId) {
  final reviews =
      mockReviews.where((review) => review.routeId == routeId && review.isActive).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return reviews.map((review) {
    final user = getUserById(review.authorId);
    return {
      'review': review,
      'user': user,
    };
  }).toList();
}

/// Получить теги места
List<Tag> getPlaceTags(String placeId) {
  final tagIds = mockPlaceTags.where((pt) => pt.placeId == placeId).map((pt) => pt.tagId).toSet();

  return mockTags.where((tag) => tagIds.contains(tag.id)).toList();
}

/// Получить теги маршрута
List<Tag> getRouteTags(String routeId) {
  final tagIds = mockRouteTags.where((rt) => rt.routeId == routeId).map((rt) => rt.tagId).toSet();

  return mockTags.where((tag) => tagIds.contains(tag.id)).toList();
}

/// Получить избранные места пользователя
List<Place> getUserFavoritePlaces(String userId) {
  final favoriteIds = mockFavoritePlaces.where((fav) => fav.userId == userId).map((fav) => fav.placeId).toSet();

  return mockPlaces.where((place) => favoriteIds.contains(place.id)).toList();
}

/// Получить избранные маршруты пользователя
List<Route> getUserFavoriteRoutes(String userId) {
  final favoriteIds = mockFavoriteRoutes.where((fav) => fav.userId == userId).map((fav) => fav.routeId).toSet();

  return mockRoutes.where((route) => favoriteIds.contains(route.id)).toList();
}

/// Проверить, является ли место избранным для пользователя
bool isPlaceFavorite(int userId, String placeId) {
  return mockFavoritePlaces.any(
    (fav) => fav.userId == fav.userId && fav.placeId == placeId,
  );
}

/// Проверить, является ли маршрут избранным для пользователя
bool isRouteFavorite(int userId, String routeId) {
  return mockFavoriteRoutes.any(
    (fav) => fav.userId == fav.userId && fav.routeId == routeId,
  );
}

/// Получить пройденные места пользователя
List<Place> getUserPassedPlaces(String userId) {
  final passedIds = mockPassedPlaces.where((passed) => passed.userId == userId).map((passed) => passed.placeId).toSet();

  return mockPlaces.where((place) => passedIds.contains(place.id)).toList();
}

/// Получить пройденные маршруты пользователя
List<Route> getUserPassedRoutes(String userId) {
  final passedIds = mockPassedRoutes.where((passed) => passed.userId == userId).map((passed) => passed.routeId).toSet();

  return mockRoutes.where((route) => passedIds.contains(route.id)).toList();
}

/// Проверить, посетил ли пользователь место
bool hasUserPassedPlace(int userId, String placeId) {
  return mockPassedPlaces.any(
    (passed) => passed.userId == passed.userId && passed.placeId == placeId,
  );
}

/// Проверить, прошел ли пользователь маршрут
bool hasUserPassedRoute(int userId, String routeId) {
  return mockPassedRoutes.any(
    (passed) => passed.userId == passed.userId && passed.routeId == routeId,
  );
}

/// Фильтровать места по типу
List<Place> getPlacesByType(int typeId) {
  return mockPlaces.where((place) => place.typeId == typeId).toList();
}

/// Фильтровать места по категории
List<Place> getPlacesByCategory(int categoryId) {
  return mockPlaces.where((place) => place.categoryId == categoryId).toList();
}

/// Фильтровать места по району
List<Place> getPlacesByArea(int areaId) {
  return mockPlaces.where((place) => place.areaId == areaId).toList();
}

/// Фильтровать места по тегу
List<Place> getPlacesByTag(int tagId) {
  final placeIds = mockPlaceTags.where((pt) => pt.tagId == tagId).map((pt) => pt.placeId).toSet();

  return mockPlaces.where((place) => placeIds.contains(place.id)).toList();
}

/// Фильтровать маршруты по типу
List<Route> getRoutesByType(int typeId) {
  return mockRoutes.where((route) => route.typeId == typeId).toList();
}

/// Фильтровать маршруты по району
List<Route> getRoutesByArea(int areaId) {
  return mockRoutes.where((route) => route.areaId == areaId).toList();
}

/// Фильтровать маршруты по тегу
List<Route> getRoutesByTag(int tagId) {
  final routeIds = mockRouteTags.where((rt) => rt.tagId == tagId).map((rt) => rt.routeId).toSet();

  return mockRoutes.where((route) => routeIds.contains(route.id)).toList();
}

/// Получить места с рейтингом выше заданного
List<Place> getPlacesByMinRating(double minRating) {
  return mockPlaces.where((place) => place.rating >= minRating).toList()..sort((a, b) => b.rating.compareTo(a.rating));
}

/// Получить маршруты с рейтингом выше заданного
List<Route> getRoutesByMinRating(double minRating) {
  return mockRoutes.where((route) => route.rating >= minRating).toList()..sort((a, b) => b.rating.compareTo(a.rating));
}

/// Получить топ N мест по рейтингу
List<Place> getTopPlaces(int count) {
  final sorted = List<Place>.from(mockPlaces)..sort((a, b) => b.rating.compareTo(a.rating));
  return sorted.take(count).toList();
}

/// Получить топ N маршрутов по рейтингу
List<Route> getTopRoutes(int count) {
  final sorted = List<Route>.from(mockRoutes)..sort((a, b) => b.rating.compareTo(a.rating));
  return sorted.take(count).toList();
}

/// Поиск мест по названию
List<Place> searchPlaces(String query) {
  final lowerQuery = query.toLowerCase();
  return mockPlaces.where((place) => place.name.toLowerCase().contains(lowerQuery) || place.description.toLowerCase().contains(lowerQuery)).toList();
}

/// Поиск маршрутов по названию
List<Route> searchRoutes(String query) {
  final lowerQuery = query.toLowerCase();
  return mockRoutes.where((route) => route.name.toLowerCase().contains(lowerQuery) || route.description.toLowerCase().contains(lowerQuery)).toList();
}

/// Получить статистику пользователя
Map<String, int> getUserStatistics(int userId) {
  return {
    'favoritePlaces': mockFavoritePlaces.where((f) => f.userId == f.userId).length,
    'favoriteRoutes': mockFavoriteRoutes.where((f) => f.userId == f.userId).length,
    'passedPlaces': mockPassedPlaces.where((p) => p.userId == p.userId).length,
    'passedRoutes': mockPassedRoutes.where((p) => p.userId == p.userId).length,
    'reviews': mockReviews.where((r) => r.authorId == r.id).length,
  };
}

/// Получить полную информацию о месте
Map<String, dynamic> getFullPlaceInfo(String placeId) {
  final place = getPlaceById(placeId);
  if (place == null) return {};

  final type = mockTypesOfPlaces.firstWhere((t) => t.id == place.typeId);
  final category = mockCategoriesOfPlaces.firstWhere((c) => c.id == place.categoryId);
  final area = mockAreasOfPlaces.firstWhere((a) => a.id == place.areaId);
  final images = getPlaceImages(placeId);
  final tags = getPlaceTags(placeId);
  final reviews = getPlaceReviewsWithUsers(placeId);

  return {
    'place': place,
    'type': type,
    'category': category,
    'area': area,
    'images': images,
    'tags': tags,
    'reviews': reviews,
  };
}

/// Получить полную информацию о маршруте
  Map<String, dynamic> getFullRouteInfo(String routeId) {
  final route = getRouteById(routeId);
  if (route == null) return {};

  final type = mockTypesOfRoutes.firstWhere((t) => t.id == route.typeId);
  final area = mockAreasOfRoutes.firstWhere((a) => a.id == route.areaId);
  final images = getRouteImages(routeId);
  final tags = getRouteTags(routeId);
  final stops = getRouteStopsWithPlaces(routeId);
  final reviews = getRouteReviewsWithUsers(routeId);

  return {
    'route': route,
    'type': type,
    'area': area,
    'images': images,
    'tags': tags,
    'stops': stops,
    'reviews': reviews,
  };
}

// Пример использования в main:
// void exampleUsage() {
  //
  // final topPlaces = getTopPlaces(3);
  // for (var place in topPlaces) {
  //   print('  ${place.name} - ${place.rating}⭐');
  // }

  // Получить информацию о месте
  // print('Полная информация о месте #1:');
  // final placeInfo = getFullPlaceInfo('1');
  // final place = placeInfo['place'] as Place;
  // final placeImages = placeInfo['images'] as List<ImageModel>;
  // final placeTags = placeInfo['tags'] as List<Tag>;
  // print('  Название: ${place.name}');
  // print('  Рейтинг: ${place.rating}⭐');
  // print('  Изображений: ${placeImages.length}');
  // print('  Тегов: ${placeTags.length}');

  // // Статистика пользователя
  // print('Статистика пользователя #1:');
  // final stats = getUserStatistics(1);
  // print('  Избранных мест: ${stats['favoritePlaces']}');
  // print('  Избранных маршрутов: ${stats['favoriteRoutes']}');
  // print('  Посещенных мест: ${stats['passedPlaces']}');
  // print('  Пройденных маршрутов: ${stats['passedRoutes']}');
  // print('  Отзывов: ${stats['reviews']}');


  // // Поиск
  // print('Поиск мест по слову "водопад":');
  // final searchResults = searchPlaces('водопад');
  // for (var place in searchResults) {
  //   print('  ${place.name}');
  // }
// }
