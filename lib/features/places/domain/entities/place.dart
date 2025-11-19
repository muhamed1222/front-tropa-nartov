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
  final String? contactsemail;
  final String history;
  final double latitude;
  final double longitude;
  final List<Review> reviews;

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
    this.contactsemail,
    required this.history,
    required this.latitude,
    required this.longitude,
    required this.reviews,
  });

  // Добавляем метод fromJson
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      images: (json['images'] as List<dynamic>?)
          ?.map((imageJson) => Image.fromJson(imageJson))
          .toList() ?? [],
      address: json['address'] ?? '',
      hours: json['hours'] ?? '',
      weekend: json['weekend'],
      entry: json['entry'],
      contacts: json['contacts'] ?? '',
      contactsemail: json['contacts_email'],
      history: json['history'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((reviewJson) => Review.fromJson(reviewJson))
          .toList() ?? [],
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
      'contacts_email': contactsemail,
      'history': history,
      'latitude': latitude,
      'longitude': longitude,
      'reviews': reviews.map((review) => review.toJson()).toList(),
    };
  }
}