import 'package:tropanartov/features/home/domain/entities/place.dart';
import 'package:tropanartov/features/home/domain/repositories/main_repository.dart';

// Use case для получения мест. Это маленькое действие, которое вызывает репозиторий.
class GetPlaces {
  final MainRepository repository;

  GetPlaces(this.repository);

  // Вызываем, чтобы получить список мест.
  Future<List<Place>> call() async {
    return await repository.getPlaces();
  }
}
