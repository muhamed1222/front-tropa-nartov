import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tropanartov/features/home/domain/entities/place.dart';

// Mock-источник. Здесь mockPoints, но как Place.
class MockDatasource {
  final List<Place> _mockPlaces = [];

  // Получить места
  Future<List<Place>> getPlaces() async {
    return _mockPlaces;
  }

  // Получить позицию
  Future<Position?> getCurrentPosition() async {
    PermissionStatus status = await Permission.location.status;
    if (status != PermissionStatus.granted) {
      status = await Permission.location.request();
    }
    if (status.isGranted) {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
    }
    return null;
  }
}
