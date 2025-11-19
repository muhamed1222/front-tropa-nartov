import '../../domain/entities/republic.dart';

class RepublicsDataSource {
  static const List<Republic> _republics = [
    Republic(
      name: 'Кабардино-Балкария',
      imagePath: 'assets/Kabardinobalcaria.png',
      isAvailable: true,
    ),
    Republic(
      name: 'Карачаево-Черкессия',
      imagePath: 'assets/Karachaevocherkessia.png',
      isAvailable: false,
    ),
    Republic(
      name: 'Северная Осетия',
      imagePath: 'assets/Severnayaossetia.png',
      isAvailable: false,
    ),
    Republic(
      name: 'Ставропольский край',
      imagePath: 'assets/StavropolskyKrai.png',
      isAvailable: false,
    ),
    Republic(
      name: 'Ингушетия',
      imagePath: 'assets/Ingushetia.png',
      isAvailable: false,
    ),
    Republic(
      name: 'Чечня',
      imagePath: 'assets/Chechnya.png',
      isAvailable: false,
    ),
    Republic(
      name: 'Дагестан',
      imagePath: 'assets/Dagestan.png',
      isAvailable: false,
    ),
  ];

  /// Получить список всех республик
  static List<Republic> getAllRepublics() => _republics;

  /// Получить республику по имени
  static Republic? getRepublicByName(String name) {
    try {
      return _republics.firstWhere(
        (republic) => republic.name == name,
      );
    } catch (e) {
      return null;
    }
  }

  /// Получить доступные республики
  static List<Republic> getAvailableRepublics() {
    return _republics.where((republic) => republic.isAvailable).toList();
  }
}

