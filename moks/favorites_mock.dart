import 'models.dart';

// Избранные места пользователей
final List<FavoritePlace> mockFavoritePlaces = [
  // Пользователь 1
  FavoritePlace(
    userId: '1',
    placeId: '1', // Чегемские водопады
    createdAt: DateTime(2024, 8, 15),
  ),
  FavoritePlace(
    userId: '1',
    placeId: '2', // Голубые озера
    createdAt: DateTime(2024, 8, 16),
  ),
  FavoritePlace(
    userId: '1',
    placeId: '4', // Канатная дорога
    createdAt: DateTime(2024, 9, 10),
  ),
  
  // Пользователь 2
  FavoritePlace(
    userId: '2',
    placeId: '1',
    createdAt: DateTime(2024, 8, 20),
  ),
  FavoritePlace(
    userId: '2',
    placeId: '5', // Ресторан Сосруко
    createdAt: DateTime(2024, 9, 8),
  ),
  
  // Пользователь 3
  FavoritePlace(
    userId: '3',
    placeId: '2',
    createdAt: DateTime(2024, 8, 22),
  ),
  FavoritePlace(
    userId: '3',
    placeId: '3', // Национальный музей
    createdAt: DateTime(2024, 9, 5),
  ),
  
  // Пользователь 4
  FavoritePlace(
    userId: '4',
    placeId: '2',
    createdAt: DateTime(2024, 9, 1),
  ),
  FavoritePlace(
    userId: '4',
    placeId: '5',
    createdAt: DateTime(2024, 9, 15),
  ),
  
  // Пользователь 5
  FavoritePlace(
    userId: '5',
    placeId: '4',
    createdAt: DateTime(2024, 9, 10),
  ),
];

// Избранные маршруты пользователей
final List<FavoriteRoute> mockFavoriteRoutes = [
  // Пользователь 1
  FavoriteRoute(
    userId: '1',
    routeId: '1', // К подножию Эльбруса
    createdAt: DateTime(2024, 9, 16),
  ),
  
  // Пользователь 2
  FavoriteRoute(
    userId: '2',
    routeId: '1',
    createdAt: DateTime(2024, 9, 20),
  ),
  
  // Пользователь 3
  FavoriteRoute(
    userId: '3',
    routeId: '2', // Водопады Чегема
    createdAt: DateTime(2024, 9, 14),
  ),
  FavoriteRoute(
    userId: '3',
    routeId: '4', // Голубые озера
    createdAt: DateTime(2024, 9, 17),
  ),
  
  // Пользователь 4
  FavoriteRoute(
    userId: '4',
    routeId: '3', // Исторический центр
    createdAt: DateTime(2024, 9, 9),
  ),
  
  // Пользователь 5
  FavoriteRoute(
    userId: '5',
    routeId: '4',
    createdAt: DateTime(2024, 9, 17),
  ),
];

// Пройденные места
final List<PassedPlace> mockPassedPlaces = [
  // Пользователь 1
  PassedPlace(
    userId: '1',
    placeId: '1',
    passedAt: DateTime(2024, 8, 15),
  ),
  PassedPlace(
    userId: '1',
    placeId: '2',
    passedAt: DateTime(2024, 8, 16),
  ),
  
  // Пользователь 2
  PassedPlace(
    userId: '2',
    placeId: '1',
    passedAt: DateTime(2024, 8, 20),
  ),
  
  // Пользователь 3
  PassedPlace(
    userId: '3',
    placeId: '2',
    passedAt: DateTime(2024, 8, 22),
  ),
  PassedPlace(
    userId: '3',
    placeId: '3',
    passedAt: DateTime(2024, 9, 5),
  ),
  PassedPlace(
    userId: '3',
    placeId: '5',
    passedAt: DateTime(2024, 9, 8),
  ),
  
  // Пользователь 4
  PassedPlace(
    userId: '4',
    placeId: '2',
    passedAt: DateTime(2024, 9, 1),
  ),
  PassedPlace(
    userId: '4',
    placeId: '5',
    passedAt: DateTime(2024, 9, 15),
  ),
  
  // Пользователь 5
  PassedPlace(
    userId: '5',
    placeId: '3',
    passedAt: DateTime(2024, 9, 5),
  ),
];

// Пройденные маршруты
final List<PassedRoute> mockPassedRoutes = [
  // Пользователь 3
  PassedRoute(
    userId: '3',
    routeId: '2',
    passedAt: DateTime(2024, 9, 14),
  ),
  PassedRoute(
    userId: '3',
    routeId: '3',
    passedAt: DateTime(2024, 9, 9),
  ),
  
  // Пользователь 4
  PassedRoute(
    userId: '4',
    routeId: '3',
    passedAt: DateTime(2024, 9, 9),
  ),
  
  // Пользователь 5
  PassedRoute(
    userId: '5',
    routeId: '4',
    passedAt: DateTime(2024, 9, 17),
  ),
];