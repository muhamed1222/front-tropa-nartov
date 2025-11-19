class Review {
  final int id;
  final String text;
  final int authorId;
  final String authorName;
  final String authorAvatar;
  final int rating;
  final String createdAt;
  final String updatedAt;
  final bool isActive;
  final int placeId;

  const Review({
    required this.id,
    required this.text,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.placeId,
  });

  // Добавляем метод fromJson
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      authorId: json['user_id'] ?? 0,
      authorName: json['user']?['name'] ?? 'Аноним',
      authorAvatar: json['user']?['avatar_url'] ?? '',
      rating: json['rating'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      isActive: json['is_active'] ?? true,
      placeId: json['place_id'] ?? 0,
    );
  }

  // Метод toJson для отладки
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author_id': authorId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'rating': rating,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_active': isActive,
      'place_id': placeId,
    };
  }
}