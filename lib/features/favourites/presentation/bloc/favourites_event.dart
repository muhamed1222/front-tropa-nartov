part of 'favourites_bloc.dart';

abstract class FavouritesEvent extends Equatable {
  const FavouritesEvent();

  @override
  List<Object> get props => [];
}

class LoadFavoritePlaces extends FavouritesEvent {
  final bool forceRefresh;
  
  const LoadFavoritePlaces({this.forceRefresh = false});
  
  @override
  List<Object> get props => [forceRefresh];
}

class LoadFavoriteRoutes extends FavouritesEvent {
  final bool forceRefresh;
  
  const LoadFavoriteRoutes({this.forceRefresh = false});
  
  @override
  List<Object> get props => [forceRefresh];
}

class SwitchTab extends FavouritesEvent {
  final int tabIndex; // 0 - места, 1 - маршруты
  
  const SwitchTab(this.tabIndex);
  
  @override
  List<Object> get props => [tabIndex];
}

class RemovePlaceFromFavorites extends FavouritesEvent {
  final int index;
  
  const RemovePlaceFromFavorites(this.index);
  
  @override
  List<Object> get props => [index];
}

class RemoveRouteFromFavorites extends FavouritesEvent {
  final int index;
  
  const RemoveRouteFromFavorites(this.index);
  
  @override
  List<Object> get props => [index];
}

class RefreshFavorites extends FavouritesEvent {
  const RefreshFavorites();
}

