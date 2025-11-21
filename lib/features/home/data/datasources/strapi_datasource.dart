import 'package:tropanartov/features/home/domain/entities/place.dart';
import 'package:tropanartov/services/strapi_service.dart';
import 'package:tropanartov/shared/domain/entities/image.dart';
import 'package:tropanartov/config/environment_config.dart';
import 'package:tropanartov/core/utils/logger.dart';

/// Datasource для получения данных из Strapi CMS
class StrapiDatasource {
  final StrapiService _strapiService;

  StrapiDatasource({StrapiService? strapiService})
      : _strapiService = strapiService ??
            StrapiService(baseUrl: EnvironmentConfig.strapiBaseUrl);

  /// Получить все места из Strapi
  Future<List<Place>> getPlacesFromStrapi({
    List<int>? categoryIds,
    List<int>? areaIds,
    List<int>? tagIds,
  }) async {
    try {
      AppLogger.debug('📡 Запрос мест из Strapi...');
      
      final strapiPlaces = await _strapiService.getPlaces(
        categoryIds: categoryIds,
        areaIds: areaIds,
        tagIds: tagIds,
      );
      
      AppLogger.debug('✅ Получено мест из Strapi: ${strapiPlaces.length}');
      
      // Конвертируем StrapiPlace в Place
      final places = strapiPlaces.map((strapiPlace) {
        return _convertStrapiPlaceToPlace(strapiPlace);
      }).toList();
      
      // Подсчитываем места с валидными координатами
      final validCoordinatesCount = places.where((place) =>
        place.latitude != 0.0 && 
        place.longitude != 0.0 &&
        place.latitude.abs() <= 90.0 && 
        place.longitude.abs() <= 180.0
      ).length;
      
      AppLogger.debug('✅ Конвертировано мест: ${places.length}, с валидными координатами: $validCoordinatesCount');
      
      return places;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ Ошибка загрузки мест из Strapi: $e');
      AppLogger.debug('❌ Stack trace: $stackTrace');
      return [];
    }
  }

  /// Получить место по ID из Strapi
  Future<Place?> getPlaceById(int id) async {
    try {
      AppLogger.debug('📡 Запрос места ID=$id из Strapi...');
      
      final strapiPlace = await _strapiService.getPlaceById(id);
      
      AppLogger.debug('✅ Место получено из Strapi: ${strapiPlace.name}');
      
      return _convertStrapiPlaceToPlace(strapiPlace);
    } catch (e) {
      AppLogger.debug('❌ Ошибка получения места ID=$id из Strapi: $e');
      return null;
    }
  }

  /// Конвертировать StrapiPlace в Place (для совместимости с существующим кодом)
  Place _convertStrapiPlaceToPlace(StrapiPlace strapiPlace) {
    // Формируем тип из категорий
    final type = strapiPlace.categories.isNotEmpty
        ? strapiPlace.categories.first.name
        : 'Место';

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
        'Тел: ${strapiPlace.phone}',
      if (strapiPlace.website != null && strapiPlace.website!.isNotEmpty)
        'Web: ${strapiPlace.website}',
    ].join(', ');

    // Формируем описание из истории (убираем HTML теги)
    final description = strapiPlace.history != null
        ? _stripHtmlTags(strapiPlace.history!)
        : 'Описание скоро появится';

    return Place(
      id: strapiPlace.id,
      name: strapiPlace.name,
      type: type,
      rating: 4.5, // По умолчанию, т.к. в Strapi нет rating
      images: images,
      address: strapiPlace.address ?? '',
      hours: strapiPlace.workingHours ?? 'Уточняйте',
      weekend: null,
      entry: null,
      contacts: contacts,
      contactsEmail: null,
      history: strapiPlace.history ?? '',
      latitude: strapiPlace.latitude ?? 0.0,
      longitude: strapiPlace.longitude ?? 0.0,
      reviews: [], // Отзывы пока пустые
      description: description,
      overview: description, // Используем то же описание
    );
  }

  /// Получить полный URL изображения
  String _getFullImageUrl(String imageUrl) {
    // Если URL уже полный - возвращаем как есть
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    
    // Если относительный путь - добавляем базовый URL Strapi
    final baseUrl = EnvironmentConfig.strapiBaseUrl;
    return '$baseUrl$imageUrl';
  }

  /// Убрать HTML теги из текста
  String _stripHtmlTags(String htmlString) {
    // Простой способ убрать HTML теги
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

