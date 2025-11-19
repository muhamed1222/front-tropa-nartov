import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_design_system.dart';
import 'package:tropanartov/models/api_models.dart' hide Image;
import 'package:tropanartov/utils/smooth_border_radius.dart';

/// Упрощенный виджет для отображения деталей места
/// Используется в экране избранного
class PlaceDetailsSheetSimple extends StatelessWidget {
  final Place place;

  const PlaceDetailsSheetSimple({
    super.key,
    required this.place,
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
                      // Изображение места
                      if (place.images.isNotEmpty)
                        ClipPath(
                          clipper: SmoothBorderClipper(radius: 16),
                          child: Image.network(
                            place.images.first.url,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.photo_camera,
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
                            Icons.photo_camera,
                            size: 48,
                            color: Color(0xFF24A79C),
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Название места
                      Text(
                        place.name,
                        style: GoogleFonts.inter(
                          color: AppDesignSystem.textColorPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1.20,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Тип места
                      if (place.type.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            place.type,
                            style: GoogleFonts.inter(
                              color: Color(0xFF24A79C),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.20,
                            ),
                          ),
                        ),

                      // Адрес
                      if (place.address.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 20,
                              color: Color(0xFF24A79C),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                place.address,
                                style: GoogleFonts.inter(
                                  color: AppDesignSystem.textColorPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  height: 1.20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Часы работы
                      if (place.hours.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 20,
                              color: Color(0xFF24A79C),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                place.hours,
                                style: GoogleFonts.inter(
                                  color: AppDesignSystem.textColorPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  height: 1.20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Контакты
                      if (place.contacts.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 20,
                              color: Color(0xFF24A79C),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                place.contacts,
                                style: GoogleFonts.inter(
                                  color: AppDesignSystem.textColorPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  height: 1.20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Описание
                      if (place.description.isNotEmpty) ...[
                        const Text(
                          'Описание',
                          style: TextStyle(
                            color: AppDesignSystem.textColorPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 1.20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          place.description,
                          style: GoogleFonts.inter(
                            color: AppDesignSystem.textColorPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.40,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // История (если есть)
                      if (place.history.isNotEmpty && place.history != place.description) ...[
                        const Text(
                          'История',
                          style: TextStyle(
                            color: AppDesignSystem.textColorPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 1.20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          place.history,
                          style: GoogleFonts.inter(
                            color: AppDesignSystem.textColorPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.40,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Обзор (если есть)
                      if (place.overview.isNotEmpty) ...[
                        const Text(
                          'Обзор',
                          style: TextStyle(
                            color: AppDesignSystem.textColorPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 1.20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          place.overview,
                          style: GoogleFonts.inter(
                            color: AppDesignSystem.textColorPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.40,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
              // Кнопка закрытия
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
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

