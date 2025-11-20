// Модели для API ответов
import 'package:tropanartov/features/home/domain/entities/place.dart' as home;
import 'package:tropanartov/shared/domain/entities/image.dart' as shared;
import 'package:tropanartov/shared/domain/entities/review.dart' as shared;

class LoginResponse {
  final String token;
  final String? refreshToken; // Опциональный refresh token
  final User user;

  LoginResponse({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? json['access_token'] ?? '',
      refreshToken: json['refresh_token'] as String?,
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final int id;
  final String name;
  final String firstName;
  final String email;
  final String role;
  final String? avatarUrl; // УБЕДИТЕСЬ ЧТО ЭТО ПОЛЕ ЕСТЬ

  User({
    required this.id,
    required this.name,
    required this.firstName,
    required this.email,
    required this.role,
    this.avatarUrl, // И ЗДЕСЬ
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      firstName: json['first_name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      avatarUrl: json['avatar_url'], // И ЗДЕСЬ
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'first_name': firstName,
      'email': email,
      'role': role,
      'avatar_url': avatarUrl,             // ДОБАВЛЕНО
    };
  }

  // Геттер для полного имени
  String get fullName {
    if (name.isNotEmpty && firstName.isNotEmpty) {
      return '$name $firstName';
    } else if (name.isNotEmpty) {
      return name;
    } else {
      return 'Пользователь';
    }
  }
}

class RegisterResponse {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;

  RegisterResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
    );
  }
}

class ApiError {
  final String error;

  ApiError({required this.error});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(error: json['error'] ?? 'Unknown error');
  }
}

class AppRoute {
  final int id;
  final String name;
  final String description;
  final String? overview;
  final String? history;
  final double distance;
  final double? duration;
  final int typeId;
  final int areaId;
  final double rating;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;
  final String? typeName;
  final String? areaName;

  AppRoute({
    required this.id,
    required this.name,
    required this.description,
    this.overview,
    this.history,
    required this.distance,
    this.duration,
    required this.typeId,
    required this.areaId,
    required this.rating,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.typeName,
    this.areaName,
  });

  factory AppRoute.fromJson(Map<String, dynamic> json) {

    return AppRoute(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? 'Без названия',
      description: json['description']?.toString() ?? 'Описание отсутствует',
      overview: json['overview']?.toString(),
      history: json['history']?.toString(),
      distance: _parseDouble(json['distance']),
      duration: json['duration'] != null ? _parseDouble(json['duration']) : null,
      typeId: _parseInt(json['type_id']),
      areaId: _parseInt(json['area_id']),
      rating: _parseDouble(json['rating']),
      isActive: json['is_active'] ?? true,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      imageUrl: json['image_url']?.toString(),
      typeName: json['type_name']?.toString(),
      areaName: json['area_name']?.toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDate(dynamic dateString) {
    try {
      if (dateString == null) return DateTime.now();
      if (dateString is DateTime) return dateString;
      return DateTime.parse(dateString.toString());
    } catch (e) {
      // print('Ошибка парсинга даты: $dateString, ошибка: $e');
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'overview': overview,
      'history': history,
      'distance': distance,
      'duration': duration,
      'type_id': typeId,
      'area_id': areaId,
      'rating': rating,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'image_url': imageUrl,
      'type_name': typeName,
      'area_name': areaName,
    };
  }

  String get formattedDuration {
    if (duration == null) return 'Не указано';
    if (duration! < 1) return '${(duration! * 60).round()} мин';
    if (duration! < 24) return '${duration!.toStringAsFixed(1)} ч';
    return '${(duration! / 24).toStringAsFixed(1)} дн';
  }

  String get formattedDistance {
    return '${distance.toStringAsFixed(1)} км';
  }

  String get formattedRating {
    return rating.toStringAsFixed(1);
  }

  get images => null;
}

class Place {
  final int id;
  final String name;
  final String type;
  final double rating;
  final List<Image> images;
  final String address;
  final String hours;
  final String? weekend;
  final String? entry;
  final String contacts;
  final String? contactsEmail;
  final String history;
  final double latitude;
  final double longitude;
  final List<Review> reviews;
  final String description;
  final String overview;
  final int typeId;
  final int areaId;
  final bool isActive;
  final DateTime createdAt; // ДОБАВЛЕНО

  const Place({
    required this.id,
    required this.name,
    required this.type,
    required this.rating,
    required this.images,
    required this.address,
    required this.hours,
    this.weekend,
    this.entry,
    required this.contacts,
    this.contactsEmail,
    required this.history,
    required this.latitude,
    required this.longitude,
    required this.reviews,
    required this.description,
    required this.overview,
    required this.typeId,
    required this.areaId,
    required this.isActive,
    required this.createdAt, // ДОБАВЛЕНО
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    // print('=== PLACE.FROMJSON DEBUG ===');
    // print('Input JSON keys: ${json.keys.toList()}');
    // print('ID: ${json['id']} (type: ${json['id']?.runtimeType})');
    // print('Name: ${json['name']}');
    // print('Description: ${json['description']}');
    // print('Address: ${json['address']}');
    // print('Latitude: ${json['latitude']}');
    // print('Longitude: ${json['longitude']}');
    // print('Rating: ${json['rating']}');
    // print('TypeID: ${json['type_id']}');
    // print('AreaID: ${json['area_id']}');
    // print('CreatedAt: ${json['created_at']}');
    // print('============================');

    return Place(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? 'Без названия',
      type: json['type']?.toString() ?? '',
      rating: _parseDouble(json['rating']),
      images: _parseImages(json['images']),
      address: json['address']?.toString() ?? '',
      hours: json['hours']?.toString() ?? '',
      weekend: json['weekend']?.toString(),
      entry: json['entry']?.toString(),
      contacts: json['contacts']?.toString() ?? '',
      contactsEmail: json['contacts_email']?.toString(),
      history: json['history']?.toString() ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      reviews: _parseReviews(json['reviews']),
      description: json['description']?.toString() ?? '',
      overview: json['overview']?.toString() ?? '',
      typeId: _parseInt(json['type_id']),
      areaId: _parseInt(json['area_id']),
      isActive: json['is_active'] ?? true,
      createdAt: _parseDate(json['created_at']), // ДОБАВЛЕНО
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDate(dynamic dateString) {
    try {
      if (dateString == null) return DateTime.now();
      if (dateString is DateTime) return dateString;
      return DateTime.parse(dateString.toString());
    } catch (e) {
      // print('Ошибка парсинга даты: $dateString, ошибка: $e');
      return DateTime.now();
    }
  }

  static List<Image> _parseImages(dynamic images) {
    if (images is List) {
      return images.map((imageJson) => Image.fromJson(imageJson)).toList();
    }
    return [];
  }

  static List<Review> _parseReviews(dynamic reviews) {
    if (reviews is List) {
      return reviews.map((reviewJson) => Review.fromJson(reviewJson)).toList();
    }
    return [];
  }

  // Конвертация в Place из home/domain/entities/place.dart
  home.Place toEntity() {
    return home.Place(
      id: id,
      name: name,
      type: type,
      rating: rating,
      images: images.map((img) => img.toEntity()).toList(),
      address: address,
      hours: hours,
      weekend: weekend,
      entry: entry,
      contacts: contacts,
      contactsEmail: contactsEmail,
      history: history,
      latitude: latitude,
      longitude: longitude,
      reviews: reviews.map((rev) => rev.toEntity()).toList(),
      description: description,
      overview: overview,
    );
  }

  // Для отладки можно добавить метод toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'rating': rating,
      'images': images.map((image) => image.toJson()).toList(),
      'address': address,
      'hours': hours,
      'weekend': weekend,
      'entry': entry,
      'contacts': contacts,
      'contacts_email': contactsEmail,
      'history': history,
      'latitude': latitude,
      'longitude': longitude,
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'description': description,
      'overview': overview,
      'type_id': typeId,
      'area_id': areaId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(), // ДОБАВЛЕНО
    };
  }

  // Добавляем геттер для короткого описания (используется в PlacesMainWidget)
  String get shortDescription {
    if (description.length > 100) {
      return '${description.substring(0, 100)}...';
    }
    return description;
  }

  String get formattedRating {
    return rating.toStringAsFixed(1);
  }
}

class Image {
  final String id;
  final String url;
  final String createdAt;
  final String updatedAt;

  const Image({
    required this.id,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
  });

  // Добавляем метод fromJson
  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
      id: json['ID']?.toString() ?? json['id']?.toString() ?? '',
      url: json['URL'] ?? json['url'] ?? '',
      createdAt: json['CreatedAt'] ?? json['created_at'] ?? '',
      updatedAt: json['UpdatedAt'] ?? json['updated_at'] ?? '',
    );
  }

  // Метод toJson для отладки
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Конвертация в Image из shared/domain/entities/image.dart
  shared.Image toEntity() {
    return shared.Image(
      id: id,
      url: url,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class Review {
  final int id;
  final String text;
  final int rating;
  final String createdAt;
  final String updatedAt;
  final bool isActive;
  final int placeId;
  final String authorName;
  final String? authorAvatar;
  final int? userId;

  const Review({
    required this.id,
    required this.text,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.placeId,
    required this.authorName,
    this.authorAvatar,
    this.userId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // print('=== REVIEW.FROMJSON DEBUG ===');
    // print('Review JSON keys: ${json.keys.toList()}');
    // print('User data: ${json['User']}');
    // print('User ID: ${json['UserID']}');
    // print('Rating: ${json['Rating']}');
    // print('Text: ${json['Text']}');
    // print('=============================');

    // Пробуем разные варианты получения имени автора
    String authorName = 'Анонимный пользователь';

    // Вариант 1: из поля User (объект) с заглавной буквы
    if (json['User'] is Map) {
      final user = json['User'];
      if (user['name'] != null && user['name'].toString().isNotEmpty) {
        authorName = user['name'].toString();
      } else if (user['Name'] != null && user['Name'].toString().isNotEmpty) {
        authorName = user['Name'].toString();
      } else if (user['first_name'] != null && user['first_name'].toString().isNotEmpty) {
        authorName = user['first_name'].toString();
      }
    }
    // Вариант 2: из поля user (строчные буквы)
    else if (json['user'] is Map) {
      final user = json['user'];
      if (user['name'] != null && user['name'].toString().isNotEmpty) {
        authorName = user['name'].toString();
      } else if (user['Name'] != null && user['Name'].toString().isNotEmpty) {
        authorName = user['Name'].toString();
      } else if (user['first_name'] != null && user['first_name'].toString().isNotEmpty) {
        authorName = user['first_name'].toString();
      }
    }

    // Парсим рейтинг (пробуем разные варианты ключей)
    int parsedRating = 0;
    if (json['Rating'] != null) {
      if (json['Rating'] is int) {
        parsedRating = json['Rating'];
      } else if (json['Rating'] is String) {
        parsedRating = int.tryParse(json['Rating']) ?? 0;
      } else if (json['Rating'] is double) {
        parsedRating = json['Rating'].toInt();
      }
    } else if (json['rating'] != null) {
      if (json['rating'] is int) {
        parsedRating = json['rating'];
      } else if (json['rating'] is String) {
        parsedRating = int.tryParse(json['rating']) ?? 0;
      } else if (json['rating'] is double) {
        parsedRating = json['rating'].toInt();
      }
    }

    // Парсим текст (пробуем разные варианты ключей)
    String text = '';
    if (json['Text'] != null && json['Text'].toString().isNotEmpty) {
      text = json['Text'].toString();
    } else if (json['text'] != null && json['text'].toString().isNotEmpty) {
      text = json['text'].toString();
    }

    return Review(
      id: _parseInt(json['ID'] ?? json['id']),
      text: text,
      rating: parsedRating,
      createdAt: json['CreatedAt']?.toString() ?? json['created_at']?.toString() ?? '',
      updatedAt: json['UpdatedAt']?.toString() ?? json['updated_at']?.toString() ?? '',
      isActive: json['IsActive'] ?? json['is_active'] ?? true,
      placeId: _parseInt(json['PlaceID'] ?? json['place_id']),
      authorName: authorName,
      authorAvatar: json['User']?['avatar_url']?.toString() ?? json['user']?['avatar_url']?.toString(),
      userId: _parseInt(json['UserID'] ?? json['user_id']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'rating': rating,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_active': isActive,
      'place_id': placeId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'user_id': userId,
    };
  }

  // Конвертация в Review из shared/domain/entities/review.dart
  shared.Review toEntity() {
    return shared.Review(
      id: id,
      text: text,
      authorId: userId ?? 0,
      authorName: authorName,
      authorAvatar: authorAvatar ?? '',
      rating: rating,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      placeId: placeId,
    );
  }

  // Форматирование даты для отображения
  String get formattedDate {
    try {
      final date = DateTime.parse(createdAt);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return createdAt;
    }
  }
}

// Модель для фильтров маршрутов
class RouteFilters {
  final List<String> selectedTypes;
  final double minDistance;
  final double maxDistance;

  const RouteFilters({
    this.selectedTypes = const [],
    this.minDistance = 1.0,
    this.maxDistance = 30.0,
  });

  RouteFilters copyWith({
    List<String>? selectedTypes,
    double? minDistance,
    double? maxDistance,
  }) {
    return RouteFilters(
      selectedTypes: selectedTypes ?? this.selectedTypes,
      minDistance: minDistance ?? this.minDistance,
      maxDistance: maxDistance ?? this.maxDistance,
    );
  }

  // Проверка, применены ли какие-либо фильтры
  bool get hasActiveFilters {
    return selectedTypes.isNotEmpty || minDistance > 1.0 || maxDistance < 30.0;
  }

  // Сброс фильтров к значениям по умолчанию
  RouteFilters reset() {
    return const RouteFilters();
  }
}
// Модель для фильтров мест
class PlaceFilters {
  final List<int> selectedCategories;
  final List<int> selectedAreas;
  final List<int> selectedTags;

  const PlaceFilters({
    this.selectedCategories = const [],
    this.selectedAreas = const [],
    this.selectedTags = const [],
  });

  PlaceFilters copyWith({
    List<int>? selectedCategories,
    List<int>? selectedAreas,
    List<int>? selectedTags,
  }) {
    return PlaceFilters(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedAreas: selectedAreas ?? this.selectedAreas,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }

  // Проверка, применены ли какие-либо фильтры
  bool get hasActiveFilters {
    return selectedCategories.isNotEmpty ||
        selectedAreas.isNotEmpty ||
        selectedTags.isNotEmpty;
  }

  // Сброс фильтров к значениям по умолчанию
  PlaceFilters reset() {
    return const PlaceFilters();
  }
}

// Модели для истории активности пользователя

class PlaceActivity {
  final int placeId;
  final Place place;
  final DateTime passedAt;

  PlaceActivity({
    required this.placeId,
    required this.place,
    required this.passedAt,
  });

  factory PlaceActivity.fromJson(Map<String, dynamic> json) {
    return PlaceActivity(
      placeId: json['place_id'] as int? ?? 0,
      place: Place.fromJson(json['place'] as Map<String, dynamic>),
      passedAt: _parseActivityDate(json['passed_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'place': place.toJson(),
      'passed_at': passedAt.toIso8601String(),
    };
  }
}

class RouteActivity {
  final int routeId;
  final AppRoute route;
  final DateTime passedAt;

  RouteActivity({
    required this.routeId,
    required this.route,
    required this.passedAt,
  });

  factory RouteActivity.fromJson(Map<String, dynamic> json) {
    return RouteActivity(
      routeId: json['route_id'] as int? ?? 0,
      route: AppRoute.fromJson(json['route'] as Map<String, dynamic>),
      passedAt: _parseActivityDate(json['passed_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'route': route.toJson(),
      'passed_at': passedAt.toIso8601String(),
    };
  }
}

class ActivityHistory {
  final List<PlaceActivity> places;
  final List<RouteActivity> routes;

  ActivityHistory({
    required this.places,
    required this.routes,
  });

  factory ActivityHistory.fromJson(Map<String, dynamic> json) {
    return ActivityHistory(
      places: (json['places'] as List<dynamic>?)
              ?.map((item) => PlaceActivity.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      routes: (json['routes'] as List<dynamic>?)
              ?.map((item) => RouteActivity.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'places': places.map((p) => p.toJson()).toList(),
      'routes': routes.map((r) => r.toJson()).toList(),
    };
  }
}

// Вспомогательная функция для парсинга дат из ISO формата
DateTime _parseActivityDate(dynamic dateString) {
  try {
    if (dateString == null) return DateTime.now();
    if (dateString is DateTime) return dateString;
    return DateTime.parse(dateString.toString());
  } catch (e) {
    return DateTime.now();
  }
}