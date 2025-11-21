import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../models/api_models.dart';
import '../../../../services/auth_service_instance.dart';
import '../../../../services/strapi_service.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/utils/filter_mixin.dart';
import '../../../../core/utils/logger.dart';
import '../../data/datasources/routes_strapi_datasource.dart';

part 'routes_event.dart';
part 'routes_state.dart';

class RoutesBloc extends Bloc<RoutesEvent, RoutesState> with FilterMixin {
  static const List<String> sortingItems = [
    'Сначала популярные',
    'Сначала с высоким рейтингом',
    'Сначала новые',
  ];

  final StrapiService _strapiService;
  final AuthService _authService;
  final RoutesStrapiDatasource _strapiDatasource;

  // Кеширование данных
  List<AppRoute>? _cachedRoutes;
  Map<int, bool>? _cachedFavoriteStatus;
  Map<int, List<String>>? _cachedRouteImages;
  DateTime? _lastRoutesLoad;

  RoutesBloc({
    required StrapiService strapiService,
    required AuthService authService,
    RoutesStrapiDatasource? strapiDatasource,
  })  : _strapiService = strapiService,
        _authService = authService,
        _strapiDatasource = strapiDatasource ?? RoutesStrapiDatasource(),
        super(RoutesInitial()) {
    on<LoadRoutes>(_onLoadRoutes);
    on<ApplyFilters>(_onApplyFilters, transformer: _debounceFilter(const Duration(milliseconds: 300)));
    on<ApplySorting>(_onApplySorting);
    on<SearchRoutes>(_onSearchRoutes, transformer: _debounceSearch(const Duration(milliseconds: 500)));
    on<ToggleFavorite>(_onToggleFavorite);
    on<ResetFilters>(_onResetFilters);
  }

  /// Дебаунс для поиска (500ms)
  EventTransformer<SearchRoutes> _debounceSearch(Duration duration) {
    return (events, mapper) {
      return events.debounceTime(duration).asyncExpand(mapper);
    };
  }

  /// Дебаунс для фильтров (300ms)
  EventTransformer<ApplyFilters> _debounceFilter(Duration duration) {
    return (events, mapper) {
      return events.debounceTime(duration).asyncExpand(mapper);
    };
  }

  Future<void> _onLoadRoutes(LoadRoutes event, Emitter<RoutesState> emit) async {
    // Проверяем кеш перед загрузкой
    if (!event.forceRefresh &&
        _cachedRoutes != null &&
        _lastRoutesLoad != null &&
        DateTime.now().difference(_lastRoutesLoad!) < AppDesignSystem.routesCacheDuration) {
      // Используем кешированные данные
      final filters = const RouteFilters();
      final sortType = sortingItems.first;
      final filteredRoutes = _applyFiltersAndSorting(
        _cachedRoutes!,
        filters,
        sortType,
        '',
      );
      
      emit(RoutesLoaded(
        routes: _cachedRoutes!,
        filteredRoutes: filteredRoutes,
        favoriteStatus: _cachedFavoriteStatus ?? {},
        routeImages: _cachedRouteImages ?? {},
        filters: filters,
        sortType: sortType,
      ));
      return;
    }

    emit(RoutesLoading());
    
    try {
      // Загружаем маршруты из Strapi
      AppLogger.debug('📡 Загрузка маршрутов из Strapi...');
      final routes = await _strapiDatasource.getRoutesFromStrapi();
      AppLogger.debug('✅ Загружено маршрутов из Strapi: ${routes.length}');
      
      // Загружаем изображения для маршрутов (быстро, синхронно)
      final routeImages = _loadRouteImages(routes);
      
      // Кешируем данные
      _cachedRoutes = routes;
      _cachedRouteImages = routeImages;
      _lastRoutesLoad = DateTime.now();
      
      // Применяем фильтры и сортировку
      final filters = const RouteFilters();
      final sortType = sortingItems.first;
      final filteredRoutes = _applyFiltersAndSorting(routes, filters, sortType, '');
      
      // Показываем маршруты сразу без статусов избранного (оптимистичное отображение)
      emit(RoutesLoaded(
        routes: routes,
        filteredRoutes: filteredRoutes,
        favoriteStatus: {}, // Временно пустой, обновим асинхронно
        routeImages: routeImages,
        filters: filters,
        sortType: sortType,
      ));
      
      // Загружаем статусы избранного в фоне и обновляем UI
      // Не используем await, чтобы не блокировать основной поток
      // Проверяем emit.isDone перед вызовом emit в фоновом методе
      _loadFavoriteStatusesInBackground(routes, emit);
    } catch (e) {
      emit(RoutesError('Ошибка загрузки маршрутов: ${e.toString()}'));
    }
  }

  /// Загружает статусы избранного в фоне и обновляет UI
  Future<void> _loadFavoriteStatusesInBackground(
    List<AppRoute> routes,
    Emitter<RoutesState> emit,
  ) async {
    try {
      final favoriteStatus = await _loadFavoriteStatuses(routes);
      
      // Кешируем статусы избранного
      _cachedFavoriteStatus = favoriteStatus;
      
      // Обновляем состояние, если оно все еще RoutesLoaded и emit еще активен
      if (!emit.isDone && state is RoutesLoaded) {
        final currentState = state as RoutesLoaded;
        emit(currentState.copyWith(
          favoriteStatus: favoriteStatus,
        ));
      }
    } catch (e) {
      // Ошибка загрузки статусов избранного не критична
      // Пользователь все равно видит маршруты
      AppLogger.warning('Failed to load favorite statuses: $e');
      
      // Устанавливаем все статусы как false при ошибке
      final emptyStatus = {for (final route in routes) route.id: false};
      _cachedFavoriteStatus = emptyStatus;
      
      if (!emit.isDone && state is RoutesLoaded) {
        final currentState = state as RoutesLoaded;
        emit(currentState.copyWith(
          favoriteStatus: emptyStatus,
        ));
      }
    }
  }

  Future<Map<int, bool>> _loadFavoriteStatuses(List<AppRoute> routes) async {
    try {
      // Получаем userId из Strapi
      final userId = await _strapiService.getCurrentUserId();
      if (userId == null) {
        // Если нет userId, все маршруты не в избранном
        return {for (final route in routes) route.id: false};
      }

      // Загружаем статусы избранного одним запросом
      final routeIds = routes.map((route) => route.id).toList();
      return await _strapiService.getFavoriteStatusesForRoutes(routeIds, userId);
    } catch (e) {
      // В случае ошибки возвращаем все как false
      return {for (final route in routes) route.id: false};
    }
  }

  Map<int, List<String>> _loadRouteImages(List<AppRoute> routes) {
    final routeImages = <int, List<String>>{};
    for (final route in routes) {
      if (route.imageUrl != null && route.imageUrl!.isNotEmpty) {
        routeImages[route.id] = [route.imageUrl!];
      } else {
        routeImages[route.id] = [];
      }
    }
    return routeImages;
  }

  void _onApplyFilters(ApplyFilters event, Emitter<RoutesState> emit) {
    if (state is! RoutesLoaded) return;
    
    final currentState = state as RoutesLoaded;
    final filteredRoutes = _applyFiltersAndSorting(
      currentState.routes,
      event.filters,
      currentState.sortType,
      currentState.searchQuery,
    );
    
    emit(currentState.copyWith(
      filters: event.filters,
      filteredRoutes: filteredRoutes,
    ));
  }

  void _onApplySorting(ApplySorting event, Emitter<RoutesState> emit) {
    if (state is! RoutesLoaded) return;
    
    final currentState = state as RoutesLoaded;
    final filteredRoutes = _applyFiltersAndSorting(
      currentState.routes,
      currentState.filters,
      event.sortType,
      currentState.searchQuery,
    );
    
    emit(currentState.copyWith(
      sortType: event.sortType,
      filteredRoutes: filteredRoutes,
    ));
  }

  void _onSearchRoutes(SearchRoutes event, Emitter<RoutesState> emit) {
    if (state is! RoutesLoaded) return;
    
    final currentState = state as RoutesLoaded;
    final filteredRoutes = _applyFiltersAndSorting(
      currentState.routes,
      currentState.filters,
      currentState.sortType,
      event.query,
    );
    
    emit(currentState.copyWith(
      searchQuery: event.query,
      filteredRoutes: filteredRoutes,
    ));
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<RoutesState> emit) async {
    if (state is! RoutesLoaded) return;
    
    final currentState = state as RoutesLoaded;
    
    try {
      // Получаем userId из Strapi
      final userId = await _strapiService.getCurrentUserId();
      
      if (userId == null) {
        // Ошибка авторизации будет обработана на уровне UI через snackbar
        return;
      }

      // Сохраняем текущее состояние для отката в случае ошибки
      final currentStatus = currentState.favoriteStatus[event.routeId] ?? false;
      final newFavoriteStatus = Map<int, bool>.from(currentState.favoriteStatus);
      newFavoriteStatus[event.routeId] = !currentStatus;
      
      // Оптимистично обновляем UI
      emit(currentState.copyWith(
        favoriteStatus: newFavoriteStatus,
        isLoading: true,
      ));

      if (currentStatus) {
        await _strapiService.removeRouteFromFavorites(event.routeId, userId);
      } else {
        await _strapiService.addRouteToFavorites(event.routeId, userId);
      }
      
      // Обновляем кешированные статусы избранного
      _cachedFavoriteStatus = newFavoriteStatus;
      
      // Обновляем состояние после успешного запроса
      emit(currentState.copyWith(
        favoriteStatus: newFavoriteStatus,
        isLoading: false,
      ));
    } catch (e) {
      // Откатываем изменения при ошибке
      final newFavoriteStatus = Map<int, bool>.from(currentState.favoriteStatus);
      final currentStatus = currentState.favoriteStatus[event.routeId] ?? false;
      newFavoriteStatus[event.routeId] = currentStatus;
      emit(currentState.copyWith(
        favoriteStatus: newFavoriteStatus,
        isLoading: false,
      ));
      // Ошибка будет обработана на уровне UI через snackbar
      rethrow;
    }
  }

  void _onResetFilters(ResetFilters event, Emitter<RoutesState> emit) {
    if (state is! RoutesLoaded) return;
    
    final currentState = state as RoutesLoaded;
    final filters = const RouteFilters();
    final filteredRoutes = _applyFiltersAndSorting(
      currentState.routes,
      filters,
      currentState.sortType,
      currentState.searchQuery,
    );
    
    emit(currentState.copyWith(
      filters: filters,
      filteredRoutes: filteredRoutes,
    ));
  }

  List<AppRoute> _applyFiltersAndSorting(
    List<AppRoute> routes,
    RouteFilters filters,
    String sortType,
    String searchQuery,
  ) {
    // Сначала применяем поиск используя FilterMixin
    var filteredRoutes = filterBySearchQuery<AppRoute>(
      items: routes,
      searchQuery: searchQuery,
      getSearchableText: (route) => '${route.name} ${route.description}',
    );
    
    // Затем применяем фильтры
    filteredRoutes = _applyFilters(filteredRoutes, filters);
    
    // Затем применяем сортировку используя FilterMixin
    return sortListByString<AppRoute>(
      items: filteredRoutes,
      sortType: sortType,
      getRating: (route) => route.rating,
      getDate: (route) => route.createdAt,
      getName: (route) => route.name,
    );
  }

  List<AppRoute> _applyFilters(List<AppRoute> routes, RouteFilters filters) {
    return routes.where((route) {
      // Фильтр по типу маршрута
      if (filters.selectedTypes.isNotEmpty) {
        // Пока не реализовано, можно добавить позже
      }

      // Фильтр по дистанции
      if (route.distance < filters.minDistance || route.distance > filters.maxDistance) {
        return false;
      }

      return true;
    }).toList();
  }

  String getRouteImageUrl(AppRoute route, Map<int, List<String>> routeImages) {
    // Сначала проверяем imageUrl из модели
    if (route.imageUrl != null && route.imageUrl!.isNotEmpty) {
      return route.imageUrl!;
    }
    
    // Затем проверяем кеш
    final images = routeImages[route.id];
    if (images != null && images.isNotEmpty) {
      return images.first;
    }
    
    // Возвращаем пустую строку если нет изображений
    return '';
  }
}
