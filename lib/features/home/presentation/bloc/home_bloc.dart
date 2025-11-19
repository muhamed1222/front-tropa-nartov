import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:tropanartov/features/home/domain/entities/place.dart';
import 'package:tropanartov/features/home/domain/usecases/get_places.dart';
import 'package:tropanartov/features/home/domain/usecases/get_current_position.dart';
import 'package:tropanartov/features/map/data/services/osrm_service.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetPlaces getPlaces;
  final GetCurrentPosition getCurrentPosition;
  final OsrmService osrmService;

  DateTime? _lastSelectPlaceTime;

  HomeBloc({
    required this.getPlaces,
    required this.getCurrentPosition,
    required this.osrmService,
  }) : super(const HomeState()) {
    on<LoadMainData>(_onLoadMainData);
    on<SelectPlace>(_onSelectPlace);
    on<ClearPlaceSelection>(_onClearPlaceSelection);
    on<ClosePlaceDetails>(_onClosePlaceDetails);
    on<CalculateRoute>(_onCalculateRoute);
    on<ClearRoute>(_onClearRoute);
    on<AddRoutePoint>(_onAddRoutePoint);
    on<BuildRoute>(_onBuildRoute);
  }

  Future<void> _onLoadMainData(LoadMainData event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Загружаем места
      debugPrint('HomeBloc: Начинаю загрузку мест...');
      final places = await getPlaces.call();
      debugPrint('HomeBloc: Загружено мест: ${places.length}');
      
      if (places.isEmpty) {
        debugPrint('⚠️ HomeBloc: Сервер вернул пустой список мест!');
        debugPrint('⚠️ Проверьте, что сервер запущен и в базе данных есть места');
      } else {
        final placesWithCoords = places.where((p) => 
          p.latitude != 0.0 && p.longitude != 0.0 &&
          p.latitude.abs() <= 90.0 && p.longitude.abs() <= 180.0
        ).length;
        debugPrint('HomeBloc: Мест с валидными координатами: $placesWithCoords из ${places.length}');
      }
      
      // Загружаем позицию
      debugPrint('HomeBloc: Загружаю текущую позицию...');
      final position = await getCurrentPosition.call();
      final myLocation = position != null ? LatLng(position.latitude, position.longitude) : null;
      
      if (myLocation != null) {
        debugPrint('HomeBloc: Позиция получена: lat=${myLocation.latitude}, lng=${myLocation.longitude}');
      } else {
        debugPrint('⚠️ HomeBloc: Не удалось получить позицию пользователя');
      }

      emit(state.copyWith(places: places, myLocation: myLocation, isLoading: false));
    } catch (e, stackTrace) {
      debugPrint('❌ HomeBloc: Ошибка загрузки данных: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      emit(state.copyWith(error: 'Ошибка загрузки данных: $e', isLoading: false));
    }
  }

  // При выборе места
  void _onSelectPlace(SelectPlace event, Emitter<HomeState> emit) {
    final now = DateTime.now();

    // Защита от множественных нажатий (не чаще чем раз в 500ms)
    if (_lastSelectPlaceTime != null &&
        now.difference(_lastSelectPlaceTime!).inMilliseconds < 500) {
      return;
    }
    _lastSelectPlaceTime = now;

    // Если уже выбрано это же место и детали открыты - ничего не делаем
    if (state.selectedPlace?.id == event.place.id && state.showPlaceDetails) {
      return;
    }

    emit(state.copyWith(
      selectedPlace: event.place,
      showPlaceDetails: true,
    ));
  }

  // Очистка выбора места
  void _onClearPlaceSelection(ClearPlaceSelection event, Emitter<HomeState> emit) {
    emit(state.copyWith(
      selectedPlace: null,
      showPlaceDetails: false,
    ));
  }

  // Добавление точки маршрута
  void _onAddRoutePoint(AddRoutePoint event, Emitter<HomeState> emit) {
    // ИСПРАВЛЕНИЕ: Теперь добавляем только одну точку - место назначения
    // Маршрут всегда будет от моего местоположения до выбранного места
    List<Place> newRoutePoints = [event.place];

    emit(state.copyWith(
      routePoints: newRoutePoints,
      routeCoordinates: null, // Сбрасываем старый маршрут
      isRouteBuilt: false, // Сбрасываем флаг построенного маршрута
    ));

    // ИСПРАВЛЕНИЕ: Сразу строим маршрут от моего местоположения до выбранной точки
    if (state.myLocation != null) {
      add(CalculateRoute(
        state.myLocation!, // Стартовая точка - мое местоположение
        LatLng(event.place.latitude, event.place.longitude), // Конечная точка - выбранное место
        startName: 'Мое местоположение', // Фиксированное название стартовой точки
        endName: event.place.name, // Название конечной точки
      ));
    } else {
      // Если местоположение не определено, показываем ошибку
      emit(state.copyWith(error: 'Не удалось определить ваше местоположение'));
    }
  }

  // Закрываем детали места
  void _onClosePlaceDetails(ClosePlaceDetails event, Emitter<HomeState> emit) {
    emit(state.copyWith(
      showPlaceDetails: false,
      selectedPlace: null,
    ));
  }

  Future<void> _onCalculateRoute(CalculateRoute event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final routeCoordinates = await osrmService.getRoute(event.start, event.end);

      // Генерируем примерные времена (в реальном приложении получаем из OSRM)
      final walkingTime = _generateWalkingTime();
      final drivingTime = _generateDrivingTime();

      emit(state.copyWith(
        routeCoordinates: routeCoordinates,
        isLoading: false,
        routeStartName: event.startName,
        routeEndName: event.endName,
        walkingTime: walkingTime,
        drivingTime: drivingTime,
      ));

      // После успешного построения маршрута показываем информацию о маршруте
      add(const BuildRoute());
    } catch (e) {
      emit(state.copyWith(error: 'Ошибка построения маршрута: $e', isLoading: false));
    }
  }

  void _onClearRoute(ClearRoute event, Emitter<HomeState> emit) {
    // Создаем полностью новое состояние с очищенными данными маршрута
    emit(HomeState(
      places: state.places,
      myLocation: state.myLocation,
      selectedPlace: state.selectedPlace,
      isLoading: false, // Убедимся что загрузка выключена
      error: state.error,
      showPlaceDetails: state.showPlaceDetails,
      // Очищаем все данные маршрута:
      routeCoordinates: null,
      routePoints: const [],
      isRouteBuilt: false,
      routeStartName: null,
      routeEndName: null,
      walkingTime: null,
      drivingTime: null,
    ));
  }

  void _onBuildRoute(BuildRoute event, Emitter<HomeState> emit) {
    emit(state.copyWith(
      isRouteBuilt: true,
      showPlaceDetails: false, // Закрываем детали места при показе маршрута
      selectedPlace: null,
    ));
  }

  // Вспомогательные методы для генерации времени (заглушки)
  String _generateWalkingTime() {
    // В реальном приложении получаем из OSRM
    return '2 мин';
  }

  String _generateDrivingTime() {
    // В реальном приложении получаем из OSRM
    return '12 минут';
  }
}