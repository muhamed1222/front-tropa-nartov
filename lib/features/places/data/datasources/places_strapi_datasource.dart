import 'package:tropanartov/models/api_models.dart';
import 'package:tropanartov/services/strapi_service.dart';
import 'package:tropanartov/config/environment_config.dart';
import 'package:tropanartov/core/utils/logger.dart';

/// Datasource для получения мест из Strapi в формате api_models.Place
class PlacesStrapiDatasource {
  final StrapiService _strapiService;

  PlacesStrapiDatasource({StrapiService? strapiService})
      : _strapiService = strapiService ??
            StrapiService(baseUrl: EnvironmentConfig.strapiBaseUrl);

  /// Получить все места из Strapi в формате api_models.Place
  Future<List<Place>> getPlacesFromStrapi({
    List<int>? categoryIds,
    List<int>? areaIds,
    List<int>? tagIds,
  }) async {
    try {
      AppLogger.debug('📡 Запрос мест из Strapi для PlacesMainWidget...');
      
      final strapiPlaces = await _strapiService.getPlaces(
        categoryIds: categoryIds,
        areaIds: areaIds,
        tagIds: tagIds,
      );
      
      AppLogger.debug('✅ Получено мест из Strapi: ${strapiPlaces.length}');
      
      // Конвертируем StrapiPlace в api_models.Place
      final places = strapiPlaces.map((strapiPlace) {
        return convertStrapiPlaceToApiPlace(strapiPlace);
      }).toList();
      
      AppLogger.debug('✅ Конвертировано мест для PlacesMainWidget: ${places.length}');
      
      return places;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ Ошибка загрузки мест из Strapi: $e');
      AppLogger.debug('❌ Stack trace: $stackTrace');
      return [];
    }
  }

  /// Конвертировать StrapiPlace в api_models.Place
  /// Конвертировать StrapiPlace в Place (api_models.dart)
  Place convertStrapiPlaceToApiPlace(StrapiPlace strapiPlace) {
    // Формируем тип из первой категории
    final type = strapiPlace.categories.isNotEmpty
        ? strapiPlace.categories.first.name
        : 'Место';
    
    final typeId = strapiPlace.categories.isNotEmpty
        ? strapiPlace.categories.first.id
        : 0;

    // Формируем изображения
    final images = <Image>[];
    for (var i = 0; i < strapiPlace.imageUrls.length; i++) {
      images.add(Image(
        id: '${strapiPlace.id}_$i',
        url: _getFullImageUrl(strapiPlace.imageUrls[i]),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ));
    }

    // Формируем контакты
    final contacts = [
      if (strapiPlace.phone != null && strapiPlace.phone!.isNotEmpty)
        strapiPlace.phone!,
    ].join(', ');

    // Убираем HTML теги из истории
    final cleanHistory = strapiPlace.history != null
        ? _stripHtmlTags(strapiPlace.history!)
        : '';

    return Place(
      id: strapiPlace.id,
      name: strapiPlace.name,
      type: type,
      typeId: typeId,
      areaId: strapiPlace.area?.id ?? 0,
      rating: 4.5, // По умолчанию, т.к. в Strapi пока нет рейтингов
      images: images,
      address: strapiPlace.address ?? '',
      hours: strapiPlace.workingHours ?? 'Уточняйте',
      weekend: null,
      entry: null,
      contacts: contacts,
      contactsEmail: null,
      history: cleanHistory,
      latitude: strapiPlace.latitude ?? 0.0,
      longitude: strapiPlace.longitude ?? 0.0,
      reviews: [], // Отзывы пока пустые
      description: cleanHistory.isNotEmpty ? cleanHistory : 'Описание скоро появится',
      overview: cleanHistory.isNotEmpty ? cleanHistory.substring(0, cleanHistory.length > 200 ? 200 : cleanHistory.length) : '',
      isActive: strapiPlace.isActive,
      createdAt: DateTime.now(),
    );
  }

  /// Получить полный URL изображения
  String _getFullImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    return '${EnvironmentConfig.strapiBaseUrl}$imageUrl';
  }

  /// Убрать HTML теги из текста
  String _stripHtmlTags(String htmlString) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').trim();
  }

  /// Проверить соединение со Strapi
  Future<bool> checkConnection() async {
    try {
      return await _strapiService.checkConnection();
    } catch (e) {
      AppLogger.debug('❌ Ошибка проверки соединения со Strapi: $e');
      return false;
    }
  }
}

