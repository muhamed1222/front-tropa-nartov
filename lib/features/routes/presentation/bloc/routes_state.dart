part of 'routes_bloc.dart';

abstract class RoutesState extends Equatable {
  const RoutesState();  
  
  @override
  List<Object> get props => [];
}

class RoutesInitial extends RoutesState {}

class RoutesLoading extends RoutesState {}

class RoutesLoaded extends RoutesState {
  final List<AppRoute> routes;
  final List<AppRoute> filteredRoutes;
  final Map<int, bool> favoriteStatus;
  final Map<int, List<String>> routeImages;
  final RouteFilters filters;
  final String sortType;
  final String searchQuery;
  final bool isLoading;
  
  const RoutesLoaded({
    required this.routes,
    required this.filteredRoutes,
    required this.favoriteStatus,
    required this.routeImages,
    required this.filters,
    required this.sortType,
    this.searchQuery = '',
    this.isLoading = false,
  });
  
  RoutesLoaded copyWith({
    List<AppRoute>? routes,
    List<AppRoute>? filteredRoutes,
    Map<int, bool>? favoriteStatus,
    Map<int, List<String>>? routeImages,
    RouteFilters? filters,
    String? sortType,
    String? searchQuery,
    bool? isLoading,
  }) {
    return RoutesLoaded(
      routes: routes ?? this.routes,
      filteredRoutes: filteredRoutes ?? this.filteredRoutes,
      favoriteStatus: favoriteStatus ?? this.favoriteStatus,
      routeImages: routeImages ?? this.routeImages,
      filters: filters ?? this.filters,
      sortType: sortType ?? this.sortType,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
  
  @override
  List<Object> get props => [
    routes,
    filteredRoutes,
    favoriteStatus,
    routeImages,
    filters,
    sortType,
    searchQuery,
    isLoading,
  ];
}

class RoutesError extends RoutesState {
  final String message;
  
  const RoutesError(this.message);
  
  @override
  List<Object> get props => [message];
}
