import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tropanartov/features/home/presentation/bloc/home_bloc.dart';
import 'package:tropanartov/features/home/presentation/widgets/map_marker_current_widget.dart';
import 'package:tropanartov/core/widgets/widgets.dart';

class MapWidget extends StatelessWidget {
  final MapController mapController;
  final HomeState state;

  const MapWidget({
    Key? key,
    required this.mapController,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: const LatLng(43.49, 43.6189),
        initialZoom: 12.0,
        minZoom: 10.0,
        maxZoom: 18.0,
        // // Разрешаем вращение карты
        // rotationThreshold: 0.1, // Порог для начала вращения
        // Добавляем обработчик нажатия на карту для закрытия деталей
        // Важно: onTap вызывается только для кликов по карте, не по маркерам
        onTap: (tapPosition, point) {
          // Закрываем детали места при нажатии на пустую область карты
          // Это не должно перехватывать клики по маркерам, так как маркеры обрабатывают свои жесты
          if (state.showPlaceDetails) {
            context.read<HomeBloc>().add(const ClosePlaceDetails());
          }
        },
        // Отключаем перехват жестов маркерами для корректной работы кликов
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        // Отображение карты
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.outcasts.tropanartov',
        ),

        // Отрисовка маршрута (если есть) - пунктирная линия
        if (state.routeCoordinates != null && state.routeCoordinates!.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: state.routeCoordinates!,
                color: const Color(0xFF23A69B),
                strokeWidth: 8.0,
                strokeCap: StrokeCap.round,
                strokeJoin: StrokeJoin.round,
                pattern: StrokePattern.dotted(),
              ),
            ],
          ),

        // Отображение точек на карте
        Builder(
          builder: (context) {
            // Отладочный вывод
            debugPrint('MapWidget: Всего мест в state: ${state.places.length}');
            
            if (state.places.isEmpty) {
              debugPrint('MapWidget: Список мест пуст - метки не будут отображаться');
              return const SizedBox.shrink();
            }

            final validPlaces = state.places
                .where((place) {
                  final isValid = place.latitude != 0.0 &&
                      place.longitude != 0.0 &&
                      place.latitude.abs() <= 90.0 &&
                      place.longitude.abs() <= 180.0;
                  
                  if (!isValid) {
                    debugPrint('MapWidget: Место "${place.name}" (ID: ${place.id}) имеет невалидные координаты: lat=${place.latitude}, lng=${place.longitude}');
                  }
                  
                  return isValid;
                })
                .toList();
            
            debugPrint('MapWidget: Всего мест: ${state.places.length}, с валидными координатами: ${validPlaces.length}');
            
            if (validPlaces.isEmpty) {
              debugPrint('MapWidget: Нет мест с валидными координатами - метки не будут отображаться');
              return const SizedBox.shrink();
            }

            if (validPlaces.isNotEmpty) {
              debugPrint('MapWidget: Первое место - "${validPlaces.first.name}", lat: ${validPlaces.first.latitude}, lng: ${validPlaces.first.longitude}');
            }

            debugPrint('MapWidget: Создаю ${validPlaces.length} маркеров для отображения на карте');

            return MarkerLayer(
              rotate: true, // Включаем вращение маркеров вместе с картой
              markers: validPlaces.map((place) {
                debugPrint('MapWidget: Создаю маркер для места "${place.name}" в точке (${place.latitude}, ${place.longitude})');
                return Marker(
                  point: LatLng(place.latitude, place.longitude),
                  width: 62.0, // 50px (круг) + 12px (стрелка)
                  height: 59.0, // 50px (круг) + 9px (стрелка)
                  alignment: Alignment.topCenter,
                  child: MapMarker(
                    imageUrl: place.images.isNotEmpty ? place.images.first.url : null,
                    onTap: () {
                      context.read<HomeBloc>().add(SelectPlace(place));
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),

        // Текущая геолокация пользователя
        if (state.myLocation != null)
          MarkerLayer(
            rotate: true, // Включаем вращение для маркера пользователя
            markers: [
              Marker(
                point: state.myLocation!,
                width: 120.0,
                height: 120.0,
                child: const CurrentUserPositionWidget(),
              ),
            ],
          ),
      ],
    );
  }
}