part of 'home_bloc.dart';

@immutable
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadMainData extends HomeEvent {
  const LoadMainData();
}

class SelectPlace extends HomeEvent {
  final Place place;

  const SelectPlace(this.place);

  @override
  List<Object?> get props => [place];
}

// ДОБАВЛЕНО: Событие для очистки выбора места
class ClearPlaceSelection extends HomeEvent {
  const ClearPlaceSelection();
}

class ClosePlaceDetails extends HomeEvent {
  const ClosePlaceDetails();
}

class CalculateRoute extends HomeEvent {
  final LatLng start;
  final LatLng end;
  final String? startName;
  final String? endName;

  const CalculateRoute(this.start, this.end, {this.startName, this.endName});

  @override
  List<Object?> get props => [start, end, startName, endName];
}

class ClearRoute extends HomeEvent {
  const ClearRoute();
}

class AddRoutePoint extends HomeEvent {
  final Place place;

  const AddRoutePoint(this.place);

  @override
  List<Object?> get props => [place];
}

// Новое событие для показа информации о маршруте
class BuildRoute extends HomeEvent {
  const BuildRoute();
}