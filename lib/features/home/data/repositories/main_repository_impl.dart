import 'package:geolocator/geolocator.dart';
import 'package:tropanartov/features/home/data/datasources/mock_datasource.dart';
import 'package:tropanartov/features/home/domain/entities/place.dart';
import 'package:tropanartov/features/home/domain/repositories/main_repository.dart';

// Реализация абстрактного репозитория. Использует datasource.
class MainRepositoryImpl implements MainRepository {
  final MockDatasource datasource;

  MainRepositoryImpl(this.datasource);

  @override
  Future<List<Place>> getPlaces() async {
    // Используем метод с логами вместо статического
    return await datasource.getPlacesFromBackend();
  }

  @override
  Future<Position?> getCurrentPosition() async {
    return await datasource.getCurrentPosition();
  }
}
