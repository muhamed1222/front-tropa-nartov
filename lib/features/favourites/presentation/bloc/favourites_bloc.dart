import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../models/api_models.dart';
import '../../../../services/auth_service_instance.dart';
import '../../../../services/strapi_service.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../places/data/datasources/places_strapi_datasource.dart';
import '../../../routes/data/datasources/routes_strapi_datasource.dart';

part 'favourites_event.dart';
part 'favourites_state.dart';

class FavouritesBloc extends Bloc<FavouritesEvent, FavouritesState> {
  final AuthService _authService;
  final StrapiService _strapiService;
  final PlacesStrapiDatasource _placesDatasource;
  final RoutesStrapiDatasource _routesDatasource;

  // Кеширование данных
  List<Place>? _cachedFavoritePlaces;
  List<AppRoute>? _cachedFavoriteRoutes;
  DateTime? _lastFavoritesLoad;

  FavouritesBloc({
    required AuthService authService,
    StrapiService? strapiService,
    PlacesStrapiDatasource? placesDatasource,
    RoutesStrapiDatasource? routesDatasource,
  })  : _authService = authService,
        _strapiService = strapiService ?? di.sl<StrapiService>(),
        _placesDatasource = placesDatasource ?? PlacesStrapiDatasource(),
        _routesDatasource = routesDatasource ?? RoutesStrapiDatasource(),
        super(FavouritesInitial()) {
    on<LoadFavoritePlaces>(_onLoadFavoritePlaces);
    on<LoadFavoriteRoutes>(_onLoadFavoriteRoutes);
    on<SwitchTab>(_onSwitchTab);
    on<RemovePlaceFromFavorites>(_onRemovePlaceFromFavorites);
    on<RemoveRouteFromFavorites>(_onRemoveRouteFromFavorites);
    on<RefreshFavorites>(_onRefreshFavorites);
  }

  Future<void> _onLoadFavoritePlaces(
    LoadFavoritePlaces event,
    Emitter<FavouritesState> emit,
  ) async {
    final token = await _authService.getToken();
    if (token == null) {
      // Если нет токена, просто показываем пустой список
      emit(FavouritesLoaded(
        favoritePlaces: const [],
        favoriteRoutes: const [],
        selectedTabIndex: 0,
        isLoading: false,
      ));
      return;
    }

    // Проверяем кеш перед загрузкой
    if (!event.forceRefresh &&
        _cachedFavoritePlaces != null &&
        _lastFavoritesLoad != null &&
        DateTime.now().difference(_lastFavoritesLoad!) < AppDesignSystem.favoritesCacheDuration) {
      // Используем кешированные данные
      if (state is FavouritesLoaded) {
        final prevState = state as FavouritesLoaded;
        emit(prevState.copyWith(
          favoritePlaces: _cachedFavoritePlaces!,
          isLoading: false,
        ));
      } else {
        emit(FavouritesLoaded(
          favoritePlaces: _cachedFavoritePlaces!,
          favoriteRoutes: _cachedFavoriteRoutes ?? const [],
          selectedTabIndex: 0,
          isLoading: false,
        ));
      }
      return;
    }

    final currentState = state;
    if (currentState is FavouritesLoaded && currentState.selectedTabIndex == 0) {
      emit(currentState.copyWith(isLoading: true));
    } else if (state is! FavouritesLoaded) {
      emit(FavouritesLoading());
    }

    try {
      // Получаем userId
      final userId = await _strapiService.getCurrentUserId();
      if (userId == null) {
        emit(FavouritesError('Необходима авторизация для просмотра избранного'));
        return;
      }

      // Получаем избранные места из Strapi
      final strapiPlaces = await _strapiService.getFavoritePlaces(userId);
      
      // Конвертируем StrapiPlace в api_models.Place
      final placesList = <Place>[];
      for (final strapiPlace in strapiPlaces) {
        try {
          // Загружаем полные данные места
          final fullPlace = await _strapiService.getPlaceById(strapiPlace.id);
          // Конвертируем через datasource
          final allPlaces = await _placesDatasource.getPlacesFromStrapi();
          final place = allPlaces.firstWhere((p) => p.id == fullPlace.id);
          placesList.add(place);
        } catch (e) {
          // Пропускаем места, которые не удалось загрузить
          print('Error loading favorite place ${strapiPlace.id}: $e');
        }
      }
      
      // Кешируем данные
      _cachedFavoritePlaces = placesList;
      _lastFavoritesLoad = DateTime.now();
      
      if (state is FavouritesLoaded) {
        final prevState = state as FavouritesLoaded;
        emit(prevState.copyWith(
          favoritePlaces: placesList,
          isLoading: false,
        ));
      } else {
        emit(FavouritesLoaded(
          favoritePlaces: placesList,
          favoriteRoutes: _cachedFavoriteRoutes ?? const [],
          selectedTabIndex: 0,
          isLoading: false,
        ));
      }
    } catch (e) {
      if (state is FavouritesLoaded) {
        final prevState = state as FavouritesLoaded;
        emit(prevState.copyWith(isLoading: false));
      } else {
        emit(FavouritesError('Не удалось загрузить избранные места: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLoadFavoriteRoutes(
    LoadFavoriteRoutes event,
    Emitter<FavouritesState> emit,
  ) async {
    final token = await _authService.getToken();
    if (token == null) {
      // Если нет токена, просто показываем пустой список
      emit(FavouritesLoaded(
        favoritePlaces: const [],
        favoriteRoutes: const [],
        selectedTabIndex: 1,
        isLoading: false,
      ));
      return;
    }

    // Проверяем кеш перед загрузкой
    if (!event.forceRefresh &&
        _cachedFavoriteRoutes != null &&
        _lastFavoritesLoad != null &&
        DateTime.now().difference(_lastFavoritesLoad!) < AppDesignSystem.favoritesCacheDuration) {
      // Используем кешированные данные
      if (state is FavouritesLoaded) {
        final prevState = state as FavouritesLoaded;
        emit(prevState.copyWith(
          favoriteRoutes: _cachedFavoriteRoutes!,
          isLoading: false,
        ));
      } else {
        emit(FavouritesLoaded(
          favoritePlaces: _cachedFavoritePlaces ?? const [],
          favoriteRoutes: _cachedFavoriteRoutes!,
          selectedTabIndex: 1,
          isLoading: false,
        ));
      }
      return;
    }

    final currentState = state;
    if (currentState is FavouritesLoaded && currentState.selectedTabIndex == 1) {
      emit(currentState.copyWith(isLoading: true));
    } else if (state is! FavouritesLoaded) {
      emit(FavouritesLoading());
    }

    try {
      // Получаем userId
      final userId = await _strapiService.getCurrentUserId();
      if (userId == null) {
        emit(FavouritesError('Необходима авторизация для просмотра избранного'));
        return;
      }

      // Получаем избранные маршруты из Strapi
      final strapiRoutes = await _strapiService.getFavoriteRoutes(userId);
      
      // Конвертируем StrapiRoute в api_models.AppRoute
      final routesList = <AppRoute>[];
      for (final strapiRoute in strapiRoutes) {
        try {
          // Загружаем полные данные маршрута
          final fullRoute = await _strapiService.getRouteById(strapiRoute.id);
          // Конвертируем через datasource
          final allRoutes = await _routesDatasource.getRoutesFromStrapi();
          final route = allRoutes.firstWhere((r) => r.id == fullRoute.id);
          routesList.add(route);
        } catch (e) {
          // Пропускаем маршруты, которые не удалось загрузить
          print('Error loading favorite route ${strapiRoute.id}: $e');
        }
      }
      
      // Кешируем данные
      _cachedFavoriteRoutes = routesList;
      _lastFavoritesLoad = DateTime.now();
      
      if (state is FavouritesLoaded) {
        final prevState = state as FavouritesLoaded;
        emit(prevState.copyWith(
          favoriteRoutes: routesList,
          isLoading: false,
        ));
      } else {
        emit(FavouritesLoaded(
          favoritePlaces: _cachedFavoritePlaces ?? const [],
          favoriteRoutes: routesList,
          selectedTabIndex: 1,
          isLoading: false,
        ));
      }
    } catch (e) {
      if (state is FavouritesLoaded) {
        final prevState = state as FavouritesLoaded;
        emit(prevState.copyWith(isLoading: false));
      } else {
        emit(FavouritesError('Не удалось загрузить избранные маршруты: ${e.toString()}'));
      }
    }
  }

  void _onSwitchTab(SwitchTab event, Emitter<FavouritesState> emit) {
    if (state is! FavouritesLoaded) return;
    
    final currentState = state as FavouritesLoaded;
    emit(currentState.copyWith(selectedTabIndex: event.tabIndex));
    
    // Загружаем данные для выбранной вкладки только если их нет в кеше или они устарели
    // Не используем forceRefresh, чтобы не делать лишние запросы при переключении табов
    if (event.tabIndex == 0) {
      add(const LoadFavoritePlaces(forceRefresh: false));
    } else {
      add(const LoadFavoriteRoutes(forceRefresh: false));
    }
  }

  Future<void> _onRemovePlaceFromFavorites(
    RemovePlaceFromFavorites event,
    Emitter<FavouritesState> emit,
  ) async {
    if (state is! FavouritesLoaded) return;
    
    final currentState = state as FavouritesLoaded;
    
    // Получаем userId
    final userId = await _strapiService.getCurrentUserId();
    if (userId == null) {
      emit(FavouritesError('Необходима авторизация для удаления из избранного'));
      return;
    }

    try {
      final place = currentState.favoritePlaces[event.index];
      
      // Удаляем из избранного через Strapi
      await _strapiService.removeFromFavoritesByPlaceOrRoute(
        userId: userId,
        placeId: place.id,
      );
      
      final updatedPlaces = List<Place>.from(currentState.favoritePlaces);
      updatedPlaces.removeAt(event.index);
      
      // Обновляем кеш
      _cachedFavoritePlaces = updatedPlaces;
      
      emit(currentState.copyWith(favoritePlaces: updatedPlaces));
    } catch (e) {
      emit(FavouritesError('Не удалось удалить место из избранного: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveRouteFromFavorites(
    RemoveRouteFromFavorites event,
    Emitter<FavouritesState> emit,
  ) async {
    if (state is! FavouritesLoaded) return;
    
    final currentState = state as FavouritesLoaded;
    
    // Получаем userId
    final userId = await _strapiService.getCurrentUserId();
    if (userId == null) {
      emit(FavouritesError('Необходима авторизация для удаления из избранного'));
      return;
    }

    try {
      final route = currentState.favoriteRoutes[event.index];
      
      // Удаляем из избранного через Strapi
      await _strapiService.removeFromFavoritesByPlaceOrRoute(
        userId: userId,
        routeId: route.id,
      );
      
      final updatedRoutes = List<AppRoute>.from(currentState.favoriteRoutes);
      updatedRoutes.removeAt(event.index);
      
      // Обновляем кеш
      _cachedFavoriteRoutes = updatedRoutes;
      
      emit(currentState.copyWith(favoriteRoutes: updatedRoutes));
    } catch (e) {
      emit(FavouritesError('Не удалось удалить маршрут из избранного: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshFavorites(
    RefreshFavorites event,
    Emitter<FavouritesState> emit,
  ) async {
    // При явном обновлении (pull-to-refresh) всегда перезагружаем данные
    if (state is! FavouritesLoaded) {
      // Если состояние не загружено, загружаем оба таба
      add(const LoadFavoritePlaces(forceRefresh: true));
      add(const LoadFavoriteRoutes(forceRefresh: true));
      return;
    }
    
    final currentState = state as FavouritesLoaded;
    if (currentState.selectedTabIndex == 0) {
      add(const LoadFavoritePlaces(forceRefresh: true));
    } else {
      add(const LoadFavoriteRoutes(forceRefresh: true));
    }
  }
}

