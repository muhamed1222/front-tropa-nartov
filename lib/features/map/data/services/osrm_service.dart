import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OsrmService {
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final url = '$_baseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseGeoJson(data);
      } else {
        throw Exception('OSRM API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch route: $e');
    }
  }

  List<LatLng> _parseGeoJson(Map<String, dynamic> data) {
    final geometry = data['routes'][0]['geometry'];
    final coordinates = geometry['coordinates'] as List;

    // GeoJSON использует [lng, lat] формат, а нам нужен [lat, lng]
    return coordinates.map((coord) {
      return LatLng(coord[1], coord[0]); // Конвертируем в LatLng
    }).toList();
  }
}