//TODO: В будущем может нужно будет исключить в доменном слое зависимость от плагина?
import 'package:geolocator/geolocator.dart'; // Для Position
import 'package:tropanartov/features/home/domain/entities/place.dart'; // Твоя сущность

// Абстрактный репозиторий (интерфейс для работы с данными)
abstract class MainRepository {
  // Получить список мест (асинхронно, вдруг из сети)
  Future<List<Place>> getPlaces();

  // Получить текущую позицию пользователя
  Future<Position?> getCurrentPosition();
}
