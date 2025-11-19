import 'package:tropanartov/shared/domain/entities/image.dart';
import 'package:tropanartov/shared/domain/entities/review.dart';

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
    required this.contactsEmail,
    required this.history,
    required this.latitude,
    required this.longitude,
    required this.reviews,
    required this.description,
    required this.overview,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    print('=== PLACE.FROMJSON DEBUG ===');
    print('Input JSON keys: ${json.keys.toList()}');
    print('Name: ${json['name']}');
    print('Images field: ${json['images']}');
    print('Images type: ${json['images']?.runtimeType}');

    final place = Place(
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
      contactsEmail: json['contacts_email']?.toString() ?? '',
      history: json['history']?.toString() ?? '',
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      reviews: _parseReviews(json['reviews']),
      description: json['description']?.toString() ?? '',
      overview: json['overview']?.toString() ?? '',
    );

    print('Final place images count: ${place.images.length}');
    if (place.images.isNotEmpty) {
      print('First image URL: "${place.images.first.url}"');
    }
    print('============================');

    return place;
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

  static List<Image> _parseImages(dynamic images) {
    print('=== DEBUG _parseImages ===');
    print('Input images type: ${images.runtimeType}');
    print('Input images value: $images');

    if (images is List) {
      final parsedImages = images.map((imageJson) {
        print('Processing image JSON: $imageJson');
        final image = Image.fromJson(imageJson);
        print('Parsed image URL: ${image.url}');
        return image;
      }).toList();

      print('Total parsed images: ${parsedImages.length}');
      print('========================');
      return parsedImages;
    }

    print('Images is not a List, returning empty list');
    print('========================');
    return [];
  }

  static List<Review> _parseReviews(dynamic reviews) {
    if (reviews is List) {
      return reviews.map((reviewJson) => Review.fromJson(reviewJson)).toList();
    }
    return [];
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
    };
  }

  // Добавляем геттер для короткого описания (используется в PlacesMainWidget)
  String get shortDescription {
    return description.length > 100
        ? '${description.substring(0, 100)}...'
        : description;
  }
}