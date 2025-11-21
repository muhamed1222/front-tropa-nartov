import 'package:tropanartov/models/api_models.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service_static.dart';
import '../../../services/republic_service.dart';
import '../../../core/utils/logger.dart';
import '../../../core/constants/app_design_system.dart';

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
      final token = await AuthService.getToken();
      if (token == null) {
        // Возвращаем null вместо исключения, если нет токена
        return null;
      }
      final user = await ApiService.getProfile(token);
      _user = user;
      _lastProfileLoad = DateTime.now();
      return user;
    } catch (e, stackTrace) {
      AppLogger.loadError('User Profile', e, stackTrace);
      rethrow;
    }
  }

  /// Загрузка избранных мест
  Future<List<Place>> loadFavoritePlaces({bool forceRefresh = false}) async {
    // Проверяем кэш
    if (!forceRefresh &&
        _favoritePlaces.isNotEmpty &&
        _lastFavoritesLoad != null &&
        DateTime.now().difference(_lastFavoritesLoad!) <
            AppDesignSystem.profileCacheDuration) {
      return _favoritePlaces;
    }

    final token = await AuthService.getToken();
    if (token == null) {
      _favoritesError = 'Необходима авторизация';
      return [];
    }

    try {
      final places = await ApiService.getFavoritePlaces(token);
      _favoritePlaces = places;
      _lastFavoritesLoad = DateTime.now();
      _favoritesError = null;
      return places;
    } catch (e, stackTrace) {
      AppLogger.loadError('Favorite Places', e, stackTrace);
      _favoritesError = 'Ошибка загрузки избранного';
      rethrow;
    }
  }

  /// Загрузка статистики
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

    final token = await AuthService.getToken();
    if (token == null) {
      _statisticsError = 'Необходима авторизация';
      return {};
    }

    try {
      // Загружаем статистику пользователя и общее количество параллельно
      final results = await Future.wait([
        ApiService.getUserStatistics(token),
        ApiService.getPlaces(),
        ApiService.getRoutes(),
      ]);

      final statistics = results[0] as Map<String, int>;
      final allPlaces = results[1] as List<Place>;
      final allRoutes = results[2] as List<AppRoute>;

      _visitedPlaces = statistics['visitedPlaces'] ?? 0;
      _completedRoutes = statistics['completedRoutes'] ?? 0;
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
      rethrow;
    }
  }

  /// Загрузка истории активности
  Future<List<ActivityItem>> loadActivityHistory({bool forceRefresh = false}) async {
    // Проверяем кэш
    if (!forceRefresh &&
        _sortedActivities != null &&
        _lastHistoryLoad != null &&
        DateTime.now().difference(_lastHistoryLoad!) <
            AppDesignSystem.profileCacheDuration) {
      return _sortedActivities!;
    }

    final token = await AuthService.getToken();
    if (token == null) {
      _historyError = 'Необходима авторизация';
      return [];
    }

    try {
      final history = await ApiService.getUserActivityHistory(token);
      // Объединяем и сортируем сразу при загрузке (оптимизированная версия)
      final allActivities = <ActivityItem>[
        ...history.places.map((p) => PlaceActivityItem(p)),
        ...history.routes.map((r) => RouteActivityItem(r)),
      ]..sort((a, b) => b.passedAt.compareTo(a.passedAt));

      _sortedActivities = allActivities;
      _lastHistoryLoad = DateTime.now();
      _historyError = null;
      return allActivities;
    } catch (e, stackTrace) {
      AppLogger.loadError('Activity History', e, stackTrace);
      _historyError = 'Ошибка загрузки истории активности';
      rethrow;
    }
  }

  /// Удаление из избранного
  Future<void> removeFromFavorites(int index) async {
    if (index < 0 || index >= _favoritePlaces.length) {
      throw Exception('Неверный индекс');
    }
    
    final place = _favoritePlaces[index];
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Необходима авторизация');
    }

    try {
      await ApiService.removeFromFavorites(place.id, token);
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

