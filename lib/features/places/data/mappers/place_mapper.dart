import 'package:tropanartov/models/api_models.dart' as api;
import 'package:tropanartov/features/home/domain/entities/place.dart' as domain;
import 'package:tropanartov/shared/domain/entities/image.dart' as shared_entities;
import 'package:tropanartov/shared/domain/entities/review.dart' as shared_entities;

/// Маппер для конвертации моделей Place
/// Преобразует Place из api_models в Place из home/domain/entities
class PlaceMapper {
  /// Конвертирует Place из api_models в Place из home/domain/entities
  static domain.Place fromApi(api.Place apiPlace) {
    return domain.Place(
      id: apiPlace.id,
      name: apiPlace.name,
      type: apiPlace.type,
      rating: apiPlace.rating,
      images: apiPlace.images.map((img) => shared_entities.Image(
        id: img.id.toString(),
        url: img.url,
        createdAt: img.createdAt,
        updatedAt: img.updatedAt,
      )).toList(),
      address: apiPlace.address,
      hours: apiPlace.hours,
      weekend: apiPlace.weekend,
      entry: apiPlace.entry,
      contacts: apiPlace.contacts,
      contactsEmail: apiPlace.contactsEmail,
      history: apiPlace.history,
      latitude: apiPlace.latitude,
      longitude: apiPlace.longitude,
      reviews: apiPlace.reviews.map((review) {
        // Конвертируем Review из api_models в shared_entities.Review
        return shared_entities.Review(
          id: review.id,
          text: review.text,
          authorId: review.userId ?? 0,
          authorName: review.authorName,
          authorAvatar: review.authorAvatar ?? '',
          rating: review.rating,
          createdAt: review.createdAt,
          updatedAt: review.updatedAt,
          isActive: review.isActive,
          placeId: review.placeId ?? 0, // Для отзывов маршрутов используем 0
        );
      }).toList(),
      description: apiPlace.description,
      overview: apiPlace.overview,
    );
  }

  /// Конвертирует список Place из api_models в список Place из home/domain/entities
  static List<domain.Place> fromApiList(List<api.Place> apiPlaces) {
    return apiPlaces.map((apiPlace) => fromApi(apiPlace)).toList();
  }
}

