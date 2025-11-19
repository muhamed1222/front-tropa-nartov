import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;

import 'package:tropanartov/features/home/domain/entities/place.dart';
import 'package:tropanartov/features/home/presentation/bloc/home_bloc.dart';

class PlaceMarkerWidget extends StatefulWidget {
  final Place place;

  const PlaceMarkerWidget({super.key, required this.place});

  @override
  State<PlaceMarkerWidget> createState() => _PlaceMarkerWidgetState();
}

class _PlaceMarkerWidgetState extends State<PlaceMarkerWidget> {
  DateTime? _lastTapTime;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final isInRoute = state.routePoints.any((p) => p.id == widget.place.id);
        const Color primaryColor = Color(0xFF24A79C);
        // Если точка в маршруте - делаем обводку толще
        final double borderWidth = isInRoute ? 4.0 : 3.0;

        return GestureDetector(
          onTap: () {
            final now = DateTime.now();

            // Защита от множественных нажатий (не чаще чем раз в 500ms)
            if (_lastTapTime != null &&
                now.difference(_lastTapTime!).inMilliseconds < 500) {
              return;
            }
            _lastTapTime = now;

            // Сначала очищаем предыдущий выбор, затем выбираем новое место
            context.read<HomeBloc>().add(const ClearPlaceSelection());

            // Добавляем небольшую задержку для гарантии очистки состояния
            Future.delayed(const Duration(milliseconds: 50), () {
              context.read<HomeBloc>().add(SelectPlace(widget.place));
            });
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Основная рамка с изображением
              Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryColor, width: borderWidth),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8.0,
                        offset: const Offset(0, 4)
                    )
                  ],
                ),
                child: ClipOval(
                  child: Stack(
                    children: [
                      // Изображение из данных
                      widget.place.images.isNotEmpty
                          ? Image.network(
                              widget.place.images.first.url,
                              width: 50.0,
                              height: 50.0,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 74.0,
                                  height: 74.0,
                                  color: Colors.grey[300],
                                  child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[600],
                                size: 30.0
                            ),
                          );
                        },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                          // Показываем индикатор загрузки
                          return Container(
                            width: 74.0,
                            height: 74.0,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: primaryColor,
                                  strokeWidth: 2.0
                              ),
                            ),
                          );
                        },
                      )
                          : Container(
                              width: 74.0,
                              height: 74.0,
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[600],
                                size: 30.0,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              // Стрелочка вниз
              CustomPaint(
                  size: const Size(13.0, 9.0),
                  painter: ArrowPainter(color: primaryColor)
              ),
            ],
          ),
        );
      },
    );
  }
}

// Стрелочка под кружочком
class ArrowPainter extends CustomPainter {
  final Color color;

  ArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final ui.Path path = ui.Path();

    path.moveTo(size.width / 2, size.height - 2);
    path.lineTo(0, -2);
    path.lineTo(size.width, -2);
    path.close();

    // Рисуем тень
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    canvas.save();
    canvas.translate(1.0, 1.0);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}