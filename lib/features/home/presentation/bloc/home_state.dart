part of 'home_bloc.dart';

class HomeState extends Equatable {
  final List<Place> places;
  final LatLng? myLocation;
  final Place? selectedPlace;
  final bool isLoading;
  final String? error;
  final bool showPlaceDetails;
  final List<LatLng>? routeCoordinates;
  final List<Place> routePoints; // Точки маршрута (максимум 2)
  final bool isRouteBuilt; // Флаг что маршрут построен
  final String? routeStartName; // Название начальной точки
  final String? routeEndName; // Название конечной точки
  final String? walkingTime; // Время пешком
  final String? drivingTime; // Время на машине

  const HomeState({
    this.places = const [],
    this.myLocation,
    this.selectedPlace,
    this.isLoading = false,
    this.error,
    this.showPlaceDetails = false,
    this.routeCoordinates,
    this.routePoints = const [],
    this.isRouteBuilt = false,
    this.routeStartName,
    this.routeEndName,
    this.walkingTime,
    this.drivingTime,
  });

  HomeState copyWith({
    List<Place>? places,
    LatLng? myLocation,
    Place? selectedPlace,
    bool? isLoading,
    String? error,
    bool? showPlaceDetails,
    List<LatLng>? routeCoordinates,
    List<Place>? routePoints,
    bool? isRouteBuilt,
    String? routeStartName,
    String? routeEndName,
    String? walkingTime,
    String? drivingTime,
  }) {
    return HomeState(
      places: places ?? this.places,
      myLocation: myLocation ?? this.myLocation,
      selectedPlace: selectedPlace ?? this.selectedPlace,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      showPlaceDetails: showPlaceDetails ?? this.showPlaceDetails,
      routeCoordinates: routeCoordinates ?? this.routeCoordinates,
      routePoints: routePoints ?? this.routePoints,
      isRouteBuilt: isRouteBuilt ?? this.isRouteBuilt,
      routeStartName: routeStartName ?? this.routeStartName,
      routeEndName: routeEndName ?? this.routeEndName,
      walkingTime: walkingTime ?? this.walkingTime,
      drivingTime: drivingTime ?? this.drivingTime,
    );
  }

  @override
  List<Object?> get props => [
    places,
    myLocation,
    selectedPlace,
    isLoading,
    error,
    showPlaceDetails,
    routeCoordinates,
    routePoints,
    isRouteBuilt,
    routeStartName,
    routeEndName,
    walkingTime,
    drivingTime,
  ];
}