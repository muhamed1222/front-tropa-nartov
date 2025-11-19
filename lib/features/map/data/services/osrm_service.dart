import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Модель информации о маршруте из OSRM
class RouteInfo {
  final List<LatLng> coordinates;
  final double duration; // в секундах
  final double distance; // в метрах

  RouteInfo({
    required this.coordinates,
    required this.duration,
    required this.distance,
  });
}

class OsrmService {
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1';

  /// Получает маршрут на машине с координатами, временем и расстоянием
  Future<RouteInfo> getDrivingRoute(LatLng start, LatLng end) async {
    return _getRoute(start, end, 'driving');
  }

  /// Получает пешеходный маршрут с координатами, временем и расстоянием
  Future<RouteInfo> getWalkingRoute(LatLng start, LatLng end) async {
    return _getRoute(start, end, 'walking');
  }

  /// Устаревший метод - используйте getDrivingRoute или getWalkingRoute
  @Deprecated('Use getDrivingRoute or getWalkingRoute instead')
  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final routeInfo = await getDrivingRoute(start, end);
    return routeInfo.coordinates;
  }

  /// Базовый метод для получения маршрута
  Future<RouteInfo> _getRoute(LatLng start, LatLng end, String profile) async {
    final url =
        '$_baseUrl/$profile/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return _parseRouteInfo(data);
      } else {
        throw Exception('OSRM API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch route: $e');
    }
  }

  /// Парсит ответ OSRM API и извлекает координаты, время и расстояние
  RouteInfo _parseRouteInfo(Map<String, dynamic> data) {
    final routes = data['routes'] as List;
    if (routes.isEmpty) {
      throw Exception('OSRM API: No routes found');
    }

    final route = routes[0] as Map<String, dynamic>;
    final geometry = route['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List;

    // Duration в секундах, distance в метрах
    final duration = (route['duration'] as num?)?.toDouble() ?? 0.0;
    final distance = (route['distance'] as num?)?.toDouble() ?? 0.0;

    // GeoJSON использует [lng, lat] формат, а нам нужен [lat, lng]
    final latLngCoordinates = coordinates.map((coord) {
      return LatLng(coord[1] as double, coord[0] as double);
    }).toList();

    return RouteInfo(
      coordinates: latLngCoordinates,
      duration: duration,
      distance: distance,
    );
  }
}