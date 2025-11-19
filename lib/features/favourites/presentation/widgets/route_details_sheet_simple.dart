import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_design_system.dart';
import 'package:tropanartov/models/api_models.dart' hide Image;
import 'package:tropanartov/utils/smooth_border_radius.dart';

/// Упрощенный виджет для отображения деталей маршрута
/// Используется в экране истории активности
class RouteDetailsSheetSimple extends StatelessWidget {
  final AppRoute route;

  const RouteDetailsSheetSimple({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return ClipPath(
          clipper: SmoothBorderClipper(radius: 20),
          child: Container(
            color: Colors.white,
            child: Stack(
              children: [
                // Контент с прокруткой
                SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(14, 50, 14, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Индикатор перетаскивания
                      Center(
                        child: SmoothContainer(
                          margin: const EdgeInsets.only(bottom: 20),
                          width: 40,
                          height: 4,
                          borderRadius: 3,
                          color: const Color(0xFFBFBFBF),
                          child: const SizedBox.shrink(),
                        ),
                      ),
                      // Изображение маршрута
                      if (route.imageUrl != null && route.imageUrl!.isNotEmpty)
                        ClipPath(
                          clipper: SmoothBorderClipper(radius: 16),
                          child: Image.network(
                            route.imageUrl!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.route,
                                size: 48,
                                color: Color(0xFF24A79C),
                              ),
                            ),
                          ),
                        )
                      else
                        SmoothContainer(
                          width: double.infinity,
                          height: 200,
                          borderRadius: 16,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.route,
                            size: 48,
                            color: Color(0xFF24A79C),
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Название маршрута
                      Text(
                        route.name,
                        style: GoogleFonts.inter(
                          color: AppDesignSystem.textColorPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1.20,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Тип маршрута
                      if (route.typeName != null && route.typeName!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            route.typeName!,
                            style: GoogleFonts.inter(
                              color: Color(0xFF24A79C),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.20,
                            ),
                          ),
                        ),

                      // Рейтинг
                      if (route.rating > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Color(0xFFFFD700),
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                route.rating.toStringAsFixed(1),
                                style: GoogleFonts.inter(
                                  color: AppDesignSystem.textColorPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.20,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Расстояние и длительность
                      Row(
                        children: [
                          if (route.distance > 0)
                            Row(
                              children: [
                                const Icon(
                                  Icons.straighten,
                                  color: Color(0xFF24A79C),
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${route.distance.toStringAsFixed(1)} км',
                                  style: GoogleFonts.inter(
                                    color: AppDesignSystem.textColorPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    height: 1.20,
                                  ),
                                ),
                              ],
                            ),
                          if (route.distance > 0 && route.duration != null)
                            const SizedBox(width: 16),
                          if (route.duration != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Color(0xFF24A79C),
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${route.duration!.toStringAsFixed(0)} мин',
                                  style: GoogleFonts.inter(
                                    color: AppDesignSystem.textColorPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    height: 1.20,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Описание
                      if (route.description.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Описание',
                              style: TextStyle(
                                color: AppDesignSystem.textColorPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 1.20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              route.description,
                              style: GoogleFonts.inter(
                                color: AppDesignSystem.textColorPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.40,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),

                      // Обзор
                      if (route.overview != null && route.overview!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Обзор',
                              style: TextStyle(
                                color: AppDesignSystem.textColorPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 1.20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              route.overview!,
                              style: GoogleFonts.inter(
                                color: AppDesignSystem.textColorPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.40,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),

                      // История
                      if (route.history != null && route.history!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'История',
                              style: TextStyle(
                                color: AppDesignSystem.textColorPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 1.20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              route.history!,
                              style: GoogleFonts.inter(
                                color: AppDesignSystem.textColorPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.40,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Кнопка закрытия
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: SmoothContainer(
                      width: 30,
                      height: 30,
                      borderRadius: 15,
                      color: Colors.white.withValues(alpha: 0.9),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: AppDesignSystem.textColorPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

