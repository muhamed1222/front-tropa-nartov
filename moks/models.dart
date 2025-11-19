// Модели данных для проекта "Тропа Нартов"
// Соответствуют структуре базы данных PostgreSQL

class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class TypeOfPlace {
  final int id;
  final String name;
  final String? description;

  TypeOfPlace({
    required this.id,
    required this.name,
    this.description,
  });

  factory TypeOfPlace.fromJson(Map<String, dynamic> json) {
    return TypeOfPlace(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class CategoryOfPlace {
  final int id;
  final String name;
  final String? description;

  CategoryOfPlace({
    required this.id,
    required this.name,
    this.description,
  });

  factory CategoryOfPlace.fromJson(Map<String, dynamic> json) {
    return CategoryOfPlace(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class AreaOfPlace {
  final int id;
  final String name;
  final String? description;

  AreaOfPlace({
    required this.id,
    required this.name,
    this.description,
  });

  factory AreaOfPlace.fromJson(Map<String, dynamic> json) {
    return AreaOfPlace(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class Tag {
  final int id;
  final String name;
  final String? description;

  Tag({
    required this.id,
    required this.name,
    this.description,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class Place {
  final String id;
  final String name;
  final String description; // Соответствует history в существующей модели
  final String address;
  final double latitude;
  final double longitude;
  final String hours; // Часы работы (соответствует openingHours)
  final String contacts; // Контакты как строка
  final String type; // Тип места как строка
  final double rating;
  final List<ImageModel> images; // Изображения
  final List<Review> reviews; // Отзывы
  final int typeId;
  final int categoryId;
  final int areaId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.hours,
    required this.contacts,
    required this.type,
    this.rating = 0.0,
    this.images = const [],
    this.reviews = const [],
    required this.typeId,
    required this.categoryId,
    required this.areaId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Геттер для совместимости с существующей моделью
  String get history => description;

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'].toString(),
      name: json['name'] as String,
      description: json['description'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      hours: json['hours'] as String? ?? json['opening_hours'] as String? ?? '',
      contacts: json['contacts'] as String? ?? '',
      type: json['type'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      images: (json['images'] as List<dynamic>?)?.map((img) => ImageModel.fromJson(img as Map<String, dynamic>)).toList() ?? [],
      reviews: (json['reviews'] as List<dynamic>?)?.map((review) => Review.fromJson(review as Map<String, dynamic>)).toList() ?? [],
      typeId: json['type_id'] as int? ?? 0,
      categoryId: json['category_id'] as int? ?? 0,
      areaId: json['area_id'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'hours': hours,
      'contacts': contacts,
      'type': type,
      'rating': rating,
      'images': images.map((img) => img.toJson()).toList(),
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'type_id': typeId,
      'category_id': categoryId,
      'area_id': areaId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class TypeOfRoute {
  final int id;
  final String name;
  final String? description;

  TypeOfRoute({
    required this.id,
    required this.name,
    this.description,
  });

  factory TypeOfRoute.fromJson(Map<String, dynamic> json) {
    return TypeOfRoute(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class AreaOfRoute {
  final int id;
  final String name;
  final String? description;

  AreaOfRoute({
    required this.id,
    required this.name,
    this.description,
  });

  factory AreaOfRoute.fromJson(Map<String, dynamic> json) {
    return AreaOfRoute(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class Route {
  final String id;
  final String name;
  final String description;
  final double length;
  final int typeId;
  final int areaId;
  final double rating;
  final List<RoutePoint> points;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Route({
    required this.id,
    required this.name,
    required this.description,
    required this.length,
    required this.typeId,
    required this.areaId,
    this.rating = 0.0,
    this.points = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      id: json['id'].toString(),
      name: json['name'] as String,
      description: json['description'] as String,
      length: (json['length'] as num).toDouble(),
      typeId: json['type_id'] as int,
      areaId: json['area_id'] as int,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      points: (json['points'] as List<dynamic>?)?.map((p) => RoutePoint.fromJson(p as Map<String, dynamic>)).toList() ?? [],
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'length': length,
      'type_id': typeId,
      'area_id': areaId,
      'rating': rating,
      'points': points.map((p) => p.toJson()).toList(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class RoutePoint {
  final double latitude;
  final double longitude;
  final int order;
  final String? name;

  const RoutePoint({
    required this.latitude,
    required this.longitude,
    required this.order,
    this.name,
  });

  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    return RoutePoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      order: json['order'] as int? ?? json['order_num'] as int? ?? 0,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'order': order,
      'name': name,
    };
  }
}

class RouteStop {
  final String id;
  final String routeId;
  final String placeId;
  final int orderNum;
  final DateTime createdAt;

  RouteStop({
    required this.id,
    required this.routeId,
    required this.placeId,
    required this.orderNum,
    required this.createdAt,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      id: json['id'].toString(),
      routeId: json['route_id'].toString(),
      placeId: json['place_id'].toString(),
      orderNum: json['order_num'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route_id': routeId,
      'place_id': placeId,
      'order_num': orderNum,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ImageModel {
  final String id;
  final String url;
  final bool isMain;
  final String? placeId;
  final String? routeId;
  final String createdAt;
  final String updatedAt;

  ImageModel({
    required this.id,
    required this.url,
    this.isMain = false,
    this.placeId,
    this.routeId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'].toString(),
      url: json['url'] as String,
      isMain: json['is_main'] as bool? ?? false,
      placeId: json['place_id']?.toString(),
      routeId: json['route_id']?.toString(),
      createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'is_main': isMain,
      'place_id': placeId,
      'route_id': routeId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class FavoritePlace {
  final String userId;
  final String placeId;
  final DateTime createdAt;

  FavoritePlace({
    required this.userId,
    required this.placeId,
    required this.createdAt,
  });

  factory FavoritePlace.fromJson(Map<String, dynamic> json) {
    return FavoritePlace(
      userId: json['user_id'].toString(),
      placeId: json['place_id'].toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'place_id': placeId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class FavoriteRoute {
  final String userId;
  final String routeId;
  final DateTime createdAt;

  FavoriteRoute({
    required this.userId,
    required this.routeId,
    required this.createdAt,
  });

  factory FavoriteRoute.fromJson(Map<String, dynamic> json) {
    return FavoriteRoute(
      userId: json['user_id'].toString(),
      routeId: json['route_id'].toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'route_id': routeId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PassedPlace {
  final String userId;
  final String placeId;
  final DateTime passedAt;

  PassedPlace({
    required this.userId,
    required this.placeId,
    required this.passedAt,
  });

  factory PassedPlace.fromJson(Map<String, dynamic> json) {
    return PassedPlace(
      userId: json['user_id'].toString(),
      placeId: json['place_id'].toString(),
      passedAt: DateTime.parse(json['passed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'place_id': placeId,
      'passed_at': passedAt.toIso8601String(),
    };
  }
}

class PassedRoute {
  final String userId;
  final String routeId;
  final DateTime passedAt;

  PassedRoute({
    required this.userId,
    required this.routeId,
    required this.passedAt,
  });

  factory PassedRoute.fromJson(Map<String, dynamic> json) {
    return PassedRoute(
      userId: json['user_id'].toString(),
      routeId: json['route_id'].toString(),
      passedAt: DateTime.parse(json['passed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'route_id': routeId,
      'passed_at': passedAt.toIso8601String(),
    };
  }
}

class PlaceTag {
  final String placeId;
  final int tagId;

  PlaceTag({
    required this.placeId,
    required this.tagId,
  });

  factory PlaceTag.fromJson(Map<String, dynamic> json) {
    return PlaceTag(
      placeId: json['place_id'].toString(),
      tagId: json['tag_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'tag_id': tagId,
    };
  }
}

class RouteTag {
  final String routeId;
  final int tagId;

  RouteTag({
    required this.routeId,
    required this.tagId,
  });

  factory RouteTag.fromJson(Map<String, dynamic> json) {
    return RouteTag(
      routeId: json['route_id'].toString(),
      tagId: json['tag_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'tag_id': tagId,
    };
  }
}

class Review {
  final String id;
  final String text;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String rating;
  final String createdAt;
  final String updatedAt;
  final String? placeId;
  final String? routeId;
  final int likes;
  final bool isActive;

  Review({
    required this.id,
    required this.text,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    this.placeId,
    this.routeId,
    this.likes = 0,
    this.isActive = true,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'].toString(),
      text: json['text'] as String,
      authorId: json['author_id']?.toString() ?? json['user_id']?.toString() ?? '',
      authorName: json['author_name'] as String? ?? json['authorName'] as String? ?? '',
      authorAvatar: json['author_avatar'] as String? ?? json['authorAvatar'] as String? ?? '',
      rating: json['rating'].toString(),
      createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      placeId: json['place_id']?.toString(),
      routeId: json['route_id']?.toString(),
      likes: json['likes'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

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
      'place_id': placeId,
      'route_id': routeId,
      'likes': likes,
      'is_active': isActive,
    };
  }
}
