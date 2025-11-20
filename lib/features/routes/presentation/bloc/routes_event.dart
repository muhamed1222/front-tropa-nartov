part of 'routes_bloc.dart';

abstract class RoutesEvent extends Equatable {
  const RoutesEvent();

  @override
  List<Object> get props => [];
}

class LoadRoutes extends RoutesEvent {
  final bool forceRefresh;
  
  const LoadRoutes({this.forceRefresh = false});
  
  @override
  List<Object> get props => [forceRefresh];
}

class ApplyFilters extends RoutesEvent {
  final RouteFilters filters;
  
  const ApplyFilters(this.filters);
  
  @override
  List<Object> get props => [filters];
}

class ApplySorting extends RoutesEvent {
  final String sortType;
  
  const ApplySorting(this.sortType);
  
  @override
  List<Object> get props => [sortType];
}

class SearchRoutes extends RoutesEvent {
  final String query;
  
  const SearchRoutes(this.query);
  
  @override
  List<Object> get props => [query];
}

class ToggleFavorite extends RoutesEvent {
  final int routeId;
  
  const ToggleFavorite(this.routeId);
  
  @override
  List<Object> get props => [routeId];
}

class ResetFilters extends RoutesEvent {
  const ResetFilters();
}
