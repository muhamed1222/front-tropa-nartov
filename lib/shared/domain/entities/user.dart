class User {
  final int id;
  final String name;
  final String email;
  final String passwordHash;
  final String avatar;
  final String role;
  final List<int> passedPlacesIds;
  final List<int> passedRoutesIds;
  final List<int> favoritePlacesIds;
  final List<int> favoriteRoutesIds;
  final List<int> reviewsIds;   
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.avatar,
    required this.role,
    required this.passedPlacesIds,
    required this.passedRoutesIds,
    required this.favoritePlacesIds,
    required this.favoriteRoutesIds,
    required this.reviewsIds,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}
