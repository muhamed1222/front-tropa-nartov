import 'package:tropanartov/models/api_models.dart';
import '../../../services/auth_service.dart';
import '../../../services/republic_service.dart';
import '../../../services/strapi_service.dart';
import '../../../core/utils/logger.dart';
import '../../../core/constants/app_design_system.dart';
import '../../../core/di/injection_container.dart' as di;
import '../../places/data/datasources/places_strapi_datasource.dart';

/// Класс для управления состоянием профиля
/// Инкапсулирует логику загрузки и кэширования данных профиля
class ProfileStateManager {
  // Данные профиля
  User? _user;
  DateTime? _lastProfileLoad;

  // Избранное
  List<Place> _favoritePlaces = [];
  DateTime? _lastFavoritesLoad;
  String? _favoritesError;

  // Статистика
  int _visitedPlaces = 0;
  int _completedRoutes = 0;
  int _totalPlaces = 0;
  int _totalRoutes = 0;
  DateTime? _lastStatisticsLoad;
  String? _statisticsError;

  // История активности
  List<ActivityItem>? _sortedActivities;
  DateTime? _lastHistoryLoad;
  String? _historyError;

  // Выбранная республика
  String? _selectedRepublic;

  // Геттеры
  User? get user => _user;
  List<Place> get favoritePlaces => _favoritePlaces;
  int get visitedPlaces => _visitedPlaces;
  int get completedRoutes => _completedRoutes;
  int get totalPlaces => _totalPlaces;
  int get totalRoutes => _totalRoutes;
  List<ActivityItem>? get sortedActivities => _sortedActivities;
  String? get selectedRepublic => _selectedRepublic;
  String? get favoritesError => _favoritesError;
  String? get statisticsError => _statisticsError;
  String? get historyError => _historyError;

  /// Загрузка профиля пользователя
  Future<User?> loadUserProfile({bool forceRefresh = false}) async {
    // Проверяем кэш
    if (!forceRefresh &&
        _user != null &&
        _lastProfileLoad != null &&
        DateTime.now().difference(_lastProfileLoad!) <
            AppDesignSystem.profileCacheDuration) {
      return _user;
    }

    try {
      final authService = di.sl<AuthService>();
      final user = await authService.getProfile();
      _user = user;
      _lastProfileLoad = DateTime.now();
      return user;
    } catch (e, stackTrace) {
      AppLogger.loadError('User Profile', e, stackTrace);
      rethrow;
    }
  }

  /// Загрузка избранных мест из Strapi
  Future<List<Place>> loadFavoritePlaces({bool forceRefresh = false}) async {
    // Проверяем кэш
    if (!forceRefresh &&
        _favoritePlaces.isNotEmpty &&
        _lastFavoritesLoad != null &&
        DateTime.now().difference(_lastFavoritesLoad!) <
            AppDesignSystem.profileCacheDuration) {
      return _favoritePlaces;
    }

    try {
      final strapiService = di.sl<StrapiService>();
      final placesDatasource = PlacesStrapiDatasource();
      
      // Получаем userId
      final userId = await strapiService.getCurrentUserId();
      if (userId == null) {
        _favoritesError = 'Необходима авторизация';
        return [];
      }

      // Получаем избранные места из Strapi
      final strapiPlaces = await strapiService.getFavoritePlaces(userId);
      
      // Конвертируем StrapiPlace в api_models.Place
      final placesList = <Place>[];
      for (final strapiPlace in strapiPlaces) {
        try {
          // Загружаем полные данные места
          final fullPlace = await strapiService.getPlaceById(strapiPlace.id);
          // Конвертируем через datasource
          final allPlaces = await placesDatasource.getPlacesFromStrapi();
          final place = allPlaces.firstWhere((p) => p.id == fullPlace.id);
          placesList.add(place);
        } catch (e) {
          // Пропускаем места, которые не удалось загрузить
          AppLogger.warning('Error loading favorite place ${strapiPlace.id}: $e');
        }
      }
      
      _favoritePlaces = placesList;
      _lastFavoritesLoad = DateTime.now();
      _favoritesError = null;
      return placesList;
    } catch (e, stackTrace) {
      AppLogger.loadError('Favorite Places', e, stackTrace);
      _favoritesError = 'Ошибка загрузки избранного';
      rethrow;
    }
  }

  /// Загрузка статистики из Strapi
  Future<Map<String, int>> loadStatistics({bool forceRefresh = false}) async {
    // Проверяем кэш
    if (!forceRefresh &&
        _lastStatisticsLoad != null &&
        DateTime.now().difference(_lastStatisticsLoad!) <
            AppDesignSystem.profileCacheDuration &&
        _visitedPlaces > 0) {
      return {
        'visitedPlaces': _visitedPlaces,
        'completedRoutes': _completedRoutes,
        'totalPlaces': _totalPlaces,
        'totalRoutes': _totalRoutes,
      };
    }

    try {
      final strapiService = di.sl<StrapiService>();
      
      // Получаем userId
      final userId = await strapiService.getCurrentUserId();
      if (userId == null) {
        _statisticsError = 'Необходима авторизация';
        return {};
      }

      // Загружаем данные из Strapi параллельно
      final results = await Future.wait([
        strapiService.getVisitedPlaces(userId),
        strapiService.getPlaces(),
        strapiService.getRoutes(),
      ]);

      final visitedItems = results[0] as List;
      final allPlaces = results[1] as List;
      final allRoutes = results[2] as List;

      // Считаем уникальные посещенные места и маршруты
      final visitedPlaceIds = <int>{};
      final visitedRouteIds = <int>{};
      
      for (var item in visitedItems) {
        if (item.place != null) {
          visitedPlaceIds.add(item.place!.id);
        }
        if (item.route != null) {
          visitedRouteIds.add(item.route!.id);
        }
      }

      _visitedPlaces = visitedPlaceIds.length;
      _completedRoutes = visitedRouteIds.length;
      _totalPlaces = allPlaces.length;
      _totalRoutes = allRoutes.length;
      _lastStatisticsLoad = DateTime.now();
      _statisticsError = null;

      return {
        'visitedPlaces': _visitedPlaces,
        'completedRoutes': _completedRoutes,
        'totalPlaces': _totalPlaces,
        'totalRoutes': _totalRoutes,
      };
    } catch (e, stackTrace) {
      AppLogger.loadError('User Statistics', e, stackTrace);
      _statisticsError = 'Ошибка загрузки статистики';
      // Возвращаем пустую статистику вместо rethrow для более мягкой обработки
      return {
        'visitedPlaces': 0,
        'completedRoutes': 0,
        'totalPlaces': 0,
        'totalRoutes': 0,
      };
    }
  }

  /// Загрузка истории активности из Strapi
  Future<List<ActivityItem>> loadActivityHistory({bool forceRefresh = false}) async {
    // Проверяем кэш
    if (!forceRefresh &&
        _sortedActivities != null &&
        _lastHistoryLoad != null &&
        DateTime.now().difference(_lastHistoryLoad!) <
            AppDesignSystem.profileCacheDuration) {
      return _sortedActivities!;
    }

    try {
      final strapiService = di.sl<StrapiService>();
      
      // Получаем userId
      final userId = await strapiService.getCurrentUserId();
      if (userId == null) {
        _historyError = 'Необходима авторизация';
        return [];
      }

      // Загружаем историю посещений из Strapi
      final visitedItems = await strapiService.getVisitedPlaces(userId);
      
      // Конвертируем в ActivityItem
      final allActivities = <ActivityItem>[];
      for (var item in visitedItems) {
        // item.place - это StrapiPlace?, нужно проверить его существование
        if (item.place != null && item.visitedAt != null) {
          // Конвертируем StrapiPlace в Place (api_models) через datasource
          try {
            final placesDatasource = PlacesStrapiDatasource(strapiService: strapiService);
            final allPlaces = await placesDatasource.getPlacesFromStrapi();
            // item.place - это StrapiPlace объект, берем его id
            final placeId = item.place!.id;
            final place = allPlaces.firstWhere((p) => p.id == placeId);
            
            // Создаем PlaceActivity и оборачиваем в PlaceActivityItem
            final placeActivity = PlaceActivity(
              placeId: place.id,
              place: place,
              passedAt: item.visitedAt!,
            );
            allActivities.add(PlaceActivityItem(placeActivity));
          } catch (e) {
            AppLogger.warning('Error converting visited place ${item.place!.id}: $e');
          }
        }
        
        // item.route - это StrapiRoute?, нужно проверить его существование
        if (item.route != null && item.visitedAt != null) {
          // TODO: Конвертировать StrapiRoute в AppRoute и добавить в историю
          AppLogger.warning('Route history not yet implemented for route ${item.route!.id}');
        }
      }

      // Сортируем по дате (новые первыми)
      allActivities.sort((a, b) => b.passedAt.compareTo(a.passedAt));

      _sortedActivities = allActivities;
      _lastHistoryLoad = DateTime.now();
      _historyError = null;
      return allActivities;
    } catch (e, stackTrace) {
      AppLogger.loadError('Activity History', e, stackTrace);
      _historyError = 'Ошибка загрузки истории активности';
      // Возвращаем пустой список вместо rethrow для более мягкой обработки
      return [];
    }
  }

  /// Удаление из избранного (Strapi)
  Future<void> removeFromFavorites(int index) async {
    if (index < 0 || index >= _favoritePlaces.length) {
      throw Exception('Неверный индекс');
    }
    
    final place = _favoritePlaces[index];
    
    try {
      final strapiService = di.sl<StrapiService>();
      
      // Получаем userId
      final userId = await strapiService.getCurrentUserId();
      if (userId == null) {
        throw Exception('Необходима авторизация');
      }

      // Удаляем из Strapi
      await strapiService.removeFromFavoritesByPlaceOrRoute(
        userId: userId,
        placeId: place.id,
      );
      
      _favoritePlaces.removeAt(index);
      // Инвалидируем кэш избранного
      _lastFavoritesLoad = null;
    } catch (e, stackTrace) {
      AppLogger.error('Remove from favorites', e, stackTrace);
      rethrow;
    }
  }

  /// Загрузка выбранной республики
  Future<String?> loadSelectedRepublic() async {
    try {
      final selected = await RepublicService.getSelectedRepublicOrDefault();
      _selectedRepublic = selected;
      return selected;
    } catch (e, stackTrace) {
      AppLogger.error('Load selected republic', e, stackTrace);
      return null;
    }
  }

  /// Очистка кэша
  void clearCache() {
    _lastProfileLoad = null;
    _lastFavoritesLoad = null;
    _lastStatisticsLoad = null;
    _lastHistoryLoad = null;
  }

  /// Инвалидация кэша профиля
  void invalidateProfileCache() {
    _lastProfileLoad = null;
  }

  /// Инвалидация кэша избранного
  void invalidateFavoritesCache() {
    _lastFavoritesLoad = null;
  }

  /// Инвалидация кэша статистики
  void invalidateStatisticsCache() {
    _lastStatisticsLoad = null;
  }

  /// Инвалидация кэша истории
  void invalidateHistoryCache() {
    _lastHistoryLoad = null;
  }

  /// Инвалидация всех кэшей
  void invalidateAllCaches() {
    clearCache();
  }

  /// Обновление пользователя после редактирования
  void updateUser(User user) {
    _user = user;
    _lastProfileLoad = DateTime.now();
  }

  /// Состояния загрузки
  bool get isLoadingProfile => _user == null && _lastProfileLoad == null;
  bool get isLoadingFavorites => _favoritePlaces.isEmpty && _lastFavoritesLoad == null;
  bool get isLoadingStatistics => _visitedPlaces == 0 && _lastStatisticsLoad == null;
  bool get isLoadingHistory => _sortedActivities == null && _lastHistoryLoad == null;

  /// Сброс состояния
  void reset() {
    _user = null;
    _favoritePlaces = [];
    _visitedPlaces = 0;
    _completedRoutes = 0;
    _totalPlaces = 0;
    _totalRoutes = 0;
    _sortedActivities = null;
    _selectedRepublic = null;
    _favoritesError = null;
    _statisticsError = null;
    _historyError = null;
    clearCache();
  }
}

// Вспомогательные классы для типобезопасного хранения активности
sealed class ActivityItem {
  final DateTime passedAt;
  final String title;

  ActivityItem({required this.passedAt, required this.title});
}

class PlaceActivityItem extends ActivityItem {
  final PlaceActivity placeActivity;

  PlaceActivityItem(this.placeActivity)
      : super(
          passedAt: placeActivity.passedAt,
          title: placeActivity.place.name,
        );
}

class RouteActivityItem extends ActivityItem {
  final RouteActivity routeActivity;

  RouteActivityItem(this.routeActivity)
      : super(
          passedAt: routeActivity.passedAt,
          title: routeActivity.route.name,
        );
}

