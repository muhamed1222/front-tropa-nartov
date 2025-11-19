class User {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final String avatar;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.avatar,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}
