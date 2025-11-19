import 'package:geolocator/geolocator.dart';
import 'package:tropanartov/features/home/domain/repositories/main_repository.dart';

// Use case для геолокации.
class GetCurrentPosition {
  final MainRepository repository;

  GetCurrentPosition(this.repository);

  Future<Position?> call() async {
    return await repository.getCurrentPosition();
  }
}
