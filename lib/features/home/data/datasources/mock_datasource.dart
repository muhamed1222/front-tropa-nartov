import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:tropanartov/features/home/domain/entities/place.dart';
import 'package:tropanartov/shared/domain/entities/review.dart';
import 'package:tropanartov/config/app_config.dart';
import 'package:tropanartov/core/utils/logger.dart';
import 'package:tropanartov/features/home/data/datasources/strapi_datasource.dart';

// Mock-источник. Здесь mockPoints, но как Place.
class MockDatasource {
  final StrapiDatasource _strapiDatasource = StrapiDatasource();

  Future<List<Place>> getPlacesFromBackend() async {
    try {
      AppLogger.debug('📡 Загрузка мест из Strapi CMS...');
      
      // Используем Strapi datasource вместо Go API
      final places = await _strapiDatasource.getPlacesFromStrapi();

      if (places.isEmpty) {
        AppLogger.debug('⚠️ Strapi вернул пустой список мест');
        AppLogger.debug('⚠️ Добавьте места через админ-панель: http://localhost:1337/admin');
          return [];
        }

      AppLogger.debug('✅ Успешно загружено мест из Strapi: ${places.length}');

        return places;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ Ошибка загрузки мест из Strapi: $e');
      AppLogger.debug('❌ Stack trace: $stackTrace');
      AppLogger.debug('⚠️ Убедитесь что:');
      AppLogger.debug('   1. Strapi запущен (http://localhost:1337)');
      AppLogger.debug('   2. Публичный доступ открыт');
      AppLogger.debug('   3. Места добавлены в админ-панели');
      return [];
    }
  }

  // Временный метод для отправки отзыва на бекенд
  Future<void> submitReviewToBackend(int placeId, int rating, String text) async {
    try {
      final baseUrl = AppConfig.baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token', // Добавить когда будет авторизация
        },
        body: json.encode({
          'place_id': placeId,
          'rating': rating,
          'text': text,
        }),
      );

      if (response.statusCode == 201) {
      } else {
        throw Exception('Failed to submit review: ${response.statusCode}');
      }
    } catch (e) {
      // print('❌ Ошибка отправки отзыва: $e');
      // throw e;
    }
  }

  // Временный метод для получения отзывов с бекенда
  Future<List<Review>> getReviewsFromBackend(int placeId) async {
    try {
      final baseUrl = AppConfig.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/reviews/place/$placeId'),
      );


      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final reviews = data.map((json) => Review.fromJson(json)).toList();
        return reviews;
      } else {
        throw Exception('Failed to load reviews from backend: ${response.statusCode}');
      }
    } catch (e) {
      // print('❌ Ошибка загрузки отзывов с бекенда: $e');
      return [];
    }
  }

  // Получить места
  static Future<List<Place>> getPlaces() async {
    try {
      final baseUrl = AppConfig.baseUrl;
      final response = await http.get(Uri.parse('$baseUrl/places'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((json) => Place.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load places: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error in ApiService.getPlaces: $e');
      return [];
    }
  }

  // Получить позицию
  Future<Position?> getCurrentPosition() async {
    try {
      // Проверяем, включены ли службы геолокации
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Службы геолокации отключены - можно показать сообщение пользователю
        return null;
      }

      // Проверяем разрешение на геолокацию
      LocationPermission permission = await Geolocator.checkPermission();
      
      // Если разрешение отклонено навсегда, возвращаем null
      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Если разрешение не предоставлено, запрашиваем его
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          return null;
        }
      }

      // Если разрешение предоставлено, получаем позицию
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
      }

      return null;
    } catch (e) {
      // Обработка ошибок
      return null;
    }
  }
}