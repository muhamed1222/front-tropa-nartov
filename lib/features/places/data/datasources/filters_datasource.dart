import 'package:tropanartov/services/strapi_service.dart';
import 'package:tropanartov/config/environment_config.dart';
import 'package:tropanartov/core/utils/logger.dart';

/// Datasource для получения данных фильтров из Strapi CMS
class FiltersDatasource {
  final StrapiService _strapiService;

  FiltersDatasource({StrapiService? strapiService})
      : _strapiService = strapiService ??
            StrapiService(baseUrl: EnvironmentConfig.strapiBaseUrl);

  /// Получить категории из Strapi
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      AppLogger.debug('📡 Загрузка категорий из Strapi...');
      
      final categories = await _strapiService.getCategories();
      
      // Конвертируем PlaceCategory в Map для совместимости с существующим кодом
      final categoriesMap = categories.map((category) {
        return {
          'id': category.id,
          'name': category.name,
          'description': category.description,
          'isActive': category.isActive,
        };
      }).toList();
      
      AppLogger.debug('✅ Загружено категорий из Strapi: ${categoriesMap.length}');
      
      return categoriesMap;
    } catch (e) {
      AppLogger.debug('❌ Ошибка загрузки категорий из Strapi: $e');
      // Возвращаем пустой список вместо ошибки
      return [];
    }
  }

  /// Получить районы из Strapi
  Future<List<Map<String, dynamic>>> getAreas() async {
    try {
      AppLogger.debug('📡 Загрузка районов из Strapi...');
      
      final areas = await _strapiService.getAreas();
      
      // Конвертируем PlaceArea в Map для совместимости с существующим кодом
      final areasMap = areas.map((area) {
        return {
          'id': area.id,
          'name': area.name,
          'description': area.description,
          'isActive': area.isActive,
        };
      }).toList();
      
      AppLogger.debug('✅ Загружено районов из Strapi: ${areasMap.length}');
      
      return areasMap;
    } catch (e) {
      AppLogger.debug('❌ Ошибка загрузки районов из Strapi: $e');
      return [];
    }
  }

  /// Получить теги из Strapi
  Future<List<Map<String, dynamic>>> getTags() async {
    try {
      AppLogger.debug('📡 Загрузка тегов из Strapi...');
      
      final tags = await _strapiService.getTags();
      
      // Конвертируем Tag в Map для совместимости с существующим кодом
      final tagsMap = tags.map((tag) {
        return {
          'id': tag.id,
          'name': tag.name,
          'description': tag.description,
          'isActive': tag.isActive,
        };
      }).toList();
      
      AppLogger.debug('✅ Загружено тегов из Strapi: ${tagsMap.length}');
      
      return tagsMap;
    } catch (e) {
      AppLogger.debug('❌ Ошибка загрузки тегов из Strapi: $e');
      return [];
    }
  }

  /// Получить типы маршрутов из Strapi
  Future<List<Map<String, dynamic>>> getRouteTypes() async {
    try {
      AppLogger.debug('📡 Загрузка типов маршрутов из Strapi...');
      
      final routeTypes = await _strapiService.getRouteTypes();
      
      // Конвертируем RouteType в Map для совместимости с существующим кодом
      final routeTypesMap = routeTypes.map((routeType) {
        return {
          'id': routeType.id,
          'name': routeType.name,
          'slug': routeType.slug,
          'isActive': routeType.isActive,
        };
      }).toList();
      
      AppLogger.debug('✅ Загружено типов маршрутов из Strapi: ${routeTypesMap.length}');
      
      return routeTypesMap;
    } catch (e) {
      AppLogger.debug('❌ Ошибка загрузки типов маршрутов из Strapi: $e');
      return [];
    }
  }

  /// Получить все фильтры одновременно
  Future<Map<String, List<Map<String, dynamic>>>> getAllFilters() async {
    try {
      AppLogger.debug('📡 Загрузка всех фильтров из Strapi...');
      
      final results = await Future.wait([
        getCategories(),
        getAreas(),
        getTags(),
      ]);
      
      return {
        'categories': results[0],
        'areas': results[1],
        'tags': results[2],
      };
    } catch (e) {
      AppLogger.debug('❌ Ошибка загрузки всех фильтров из Strapi: $e');
      return {
        'categories': [],
        'areas': [],
        'tags': [],
      };
    }
  }
}

