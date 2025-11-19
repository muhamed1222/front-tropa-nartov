import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_design_system.dart';
import '../../utils/smooth_border_radius.dart';
import 'package:tropanartov/models/api_models.dart' hide Image;
import '../constants/app_text_styles.dart';
import 'place_tag.dart';
import 'favorite_button.dart';
import 'image_pagination_indicator.dart';

/// Карточка места
/// Используется для отображения мест в списках и сетках
class PlaceCard extends StatelessWidget {
  final Place place;
  final bool isFavorite;
  final int currentImageIndex;
  final int totalImages;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const PlaceCard({
    super.key,
    required this.place,
    this.isFavorite = false,
    this.currentImageIndex = 0,
    this.totalImages = 1,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = place.images.isNotEmpty
        ? place.images[currentImageIndex].url
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Ширина карточки = половина доступной ширины минус отступ между карточками
        // constraints.maxWidth уже учитывает padding контейнера (14px с каждой стороны)
        final availableWidth = constraints.maxWidth;
        final spacing = AppDesignSystem.spacingMedium; // Отступ между карточками (12px)
        final cardWidth = (availableWidth - spacing) / 2; // 2 карточки + 1 отступ между ними
        final cardHeight = 260.0; // Фиксированная высота по дизайну

        return GestureDetector(
          onTap: onTap,
          child: SmoothContainer(
            width: cardWidth,
            height: cardHeight,
            borderRadius: 16.0, // По дизайну из Figma
            child: Stack(
              children: [
            // Фоновое изображение с градиентом
            Positioned.fill(
              child: ClipPath(
                clipper: SmoothBorderClipper(radius: 16.0),
                child: Stack(
                  children: [
                    // Изображение
                    if (imageUrl != null)
                      Positioned.fill(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppDesignSystem.primaryColor,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: AppDesignSystem.whiteColor,
                              size: 48,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        color: AppDesignSystem.primaryColor,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: AppDesignSystem.whiteColor,
                          size: 48,
                        ),
                      ),
                    // Градиент
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppDesignSystem.overlayDark,
                            ],
                            stops: const [0.5, 0.99862],
                          ),
                          // Дополнительный градиент слева направо
                          color: AppDesignSystem.overlayDarkLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Контент карточки с padding
            Padding(
              padding: const EdgeInsets.all(10.0), // По дизайну из Figma
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Верхняя часть: тип места и кнопка избранного
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge с типом места
                      PlaceTag(
                        text: place.type,
                      ),

                      // Кнопка избранного
                      FavoriteButton(
                        isFavorite: isFavorite,
                        onTap: onFavoriteTap,
                      ),
                    ],
                  ),

                  // Нижняя часть: индикатор пагинации, название и описание
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // // Индикатор пагинации (точки)
                      // if (totalImages > 1) ...[
                      //   ImagePaginationIndicator(
                      //     currentIndex: currentImageIndex,
                      //     totalCount: totalImages,
                      //   ),
                      //   SizedBox(height: 8.0),
                      // ],
                      //
                      //         ImagePaginationIndicator(
                      //           currentIndex: 0,
                      //           totalCount: 4,
                      //         ),
                      //         SizedBox(height: 8),
                      // Название и описание
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
                            style: GoogleFonts.inter(
                              color: AppDesignSystem.whiteColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6.0),
                          Text(
                            place.shortDescription,
                            style: GoogleFonts.inter(
                              color: AppDesignSystem.overlayWhite,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
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

Widget _buildSection({
  required String title,
  required List<Widget> children,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: AppTextStyles.title(
          fontWeight: AppDesignSystem.fontWeightSemiBold,
        ),
      ),
      SizedBox(height: AppDesignSystem.spacingMedium),
      ...children,
      SizedBox(height: AppDesignSystem.spacingXXLarge),
    ],
  );
}
