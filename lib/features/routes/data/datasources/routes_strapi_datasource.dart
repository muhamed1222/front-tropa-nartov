import 'package:tropanartov/models/api_models.dart';
import 'package:tropanartov/services/strapi_service.dart';
import 'package:tropanartov/config/environment_config.dart';
import 'package:tropanartov/core/utils/logger.dart';

/// Datasource для получения маршрутов из Strapi CMS
class RoutesStrapiDatasource {
  final StrapiService _strapiService;

  RoutesStrapiDatasource({StrapiService? strapiService})
      : _strapiService = strapiService ??
            StrapiService(baseUrl: EnvironmentConfig.strapiBaseUrl);

  /// Получить все маршруты из Strapi
  Future<List<AppRoute>> getRoutesFromStrapi({
    List<int>? routeTypeIds,
  }) async {
    try {
      AppLogger.debug('📡 Запрос маршрутов из Strapi...');
      
      final strapiRoutes = await _strapiService.getRoutes(
        routeTypeIds: routeTypeIds,
      );
      
      AppLogger.debug('✅ Получено маршрутов из Strapi: ${strapiRoutes.length}');
      
      // Конвертируем StrapiRoute в AppRoute
      final routes = strapiRoutes.map((strapiRoute) {
        return _convertStrapiRouteToAppRoute(strapiRoute);
      }).toList();
      
      AppLogger.debug('✅ Конвертировано маршрутов: ${routes.length}');
      
      return routes;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ Ошибка загрузки маршрутов из Strapi: $e');
      AppLogger.debug('❌ Stack trace: $stackTrace');
      return [];
    }
  }

  /// Получить маршрут по ID из Strapi
  Future<AppRoute?> getRouteById(int id) async {
    try {
      AppLogger.debug('📡 Запрос маршрута ID=$id из Strapi...');
      
      final strapiRoute = await _strapiService.getRouteById(id);
      
      AppLogger.debug('✅ Маршрут получен из Strapi: ${strapiRoute.name}');
      
      return _convertStrapiRouteToAppRoute(strapiRoute);
    } catch (e) {
      AppLogger.debug('❌ Ошибка получения маршрута ID=$id из Strapi: $e');
      return null;
    }
  }

  /// Конвертировать StrapiRoute в AppRoute (для совместимости с существующим кодом)
  AppRoute _convertStrapiRouteToAppRoute(StrapiRoute strapiRoute) {
    // Формируем тип маршрута
    final typeName = strapiRoute.routeType?.name ?? 'Маршрут';
    final typeId = strapiRoute.routeType?.id ?? 0;

    return AppRoute(
      id: strapiRoute.id,
      name: strapiRoute.name,
      description: strapiRoute.description ?? 'Описание скоро появится',
      typeName: typeName,
      typeId: typeId,
      areaId: 0, // Пока не используется
      isActive: strapiRoute.isActive,
      rating: 4.5, // По умолчанию, т.к. в Strapi нет rating
      duration: 1.0, // По умолчанию 1 день
      distance: 0, // Не указано
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
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

