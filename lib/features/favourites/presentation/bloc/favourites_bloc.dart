import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../models/api_models.dart';
import '../../../../services/api_service_dio.dart';
import '../../../../services/auth_service_instance.dart';
import '../../../../core/constants/app_design_system.dart';

part 'favourites_event.dart';
part 'favourites_state.dart';

class FavouritesBloc extends Bloc<FavouritesEvent, FavouritesState> {
  final ApiServiceDio _apiService;
  final AuthService _authService;

  // Кеширование данных
  List<Place>? _cachedFavoritePlaces;
  List<AppRoute>? _cachedFavoriteRoutes;
  DateTime? _lastFavoritesLoad;

  FavouritesBloc({
    required ApiServiceDio apiService,
    required AuthService authService,
  })  : _apiService = apiService,
        _authService = authService,
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
      final places = await _apiService.getFavoritePlaces(token);
      
      // Кешируем данные
      _cachedFavoritePlaces = places;
      _lastFavoritesLoad = DateTime.now();
      
      if (state is FavouritesLoaded) {
        final prevState = state as FavouritesLoaded;
        emit(prevState.copyWith(
          favoritePlaces: places,
          isLoading: false,
        ));
      } else {
        emit(FavouritesLoaded(
          favoritePlaces: places,
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
      final routes = await _apiService.getFavoriteRoutes(token);
      
      // Кешируем данные
      _cachedFavoriteRoutes = routes;
      _lastFavoritesLoad = DateTime.now();
      
      if (state is FavouritesLoaded) {
        final prevState = state as FavouritesLoaded;
        emit(prevState.copyWith(
          favoriteRoutes: routes,
          isLoading: false,
        ));
      } else {
        emit(FavouritesLoaded(
          favoritePlaces: _cachedFavoritePlaces ?? const [],
          favoriteRoutes: routes,
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
    final token = await _authService.getToken();
    
    if (token == null) {
      emit(FavouritesError('Необходима авторизация для удаления из избранного'));
      return;
    }

    try {
      final place = currentState.favoritePlaces[event.index];
      await _apiService.removePlaceFromFavorites(place.id, token);
      
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
    final token = await _authService.getToken();
    
    if (token == null) {
      emit(FavouritesError('Необходима авторизация для удаления из избранного'));
      return;
    }

    try {
      final route = currentState.favoriteRoutes[event.index];
      await _apiService.removeRouteFromFavorites(route.id, token);
      
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

