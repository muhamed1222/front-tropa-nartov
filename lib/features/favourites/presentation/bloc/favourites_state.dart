part of 'favourites_bloc.dart';

abstract class FavouritesState extends Equatable {
  const FavouritesState();
  
  @override
  List<Object> get props => [];
}

class FavouritesInitial extends FavouritesState {}

class FavouritesLoading extends FavouritesState {}

class FavouritesLoaded extends FavouritesState {
  final List<Place> favoritePlaces;
  final List<AppRoute> favoriteRoutes;
  final int selectedTabIndex; // 0 - места, 1 - маршруты
  final bool isLoading;
  
  const FavouritesLoaded({
    required this.favoritePlaces,
    required this.favoriteRoutes,
    required this.selectedTabIndex,
    this.isLoading = false,
  });
  
  FavouritesLoaded copyWith({
    List<Place>? favoritePlaces,
    List<AppRoute>? favoriteRoutes,
    int? selectedTabIndex,
    bool? isLoading,
  }) {
    return FavouritesLoaded(
      favoritePlaces: favoritePlaces ?? this.favoritePlaces,
      favoriteRoutes: favoriteRoutes ?? this.favoriteRoutes,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      isLoading: isLoading ?? this.isLoading,
    );
  }
  
  @override
  List<Object> get props => [
    favoritePlaces,
    favoriteRoutes,
    selectedTabIndex,
    isLoading,
  ];
}

class FavouritesError extends FavouritesState {
  final String message;
  
  const FavouritesError(this.message);
  
  @override
  List<Object> get props => [message];
}

