import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../constants/app_design_system.dart';

/// Метка на карте
/// Используется для отображения мест на карте
class MapMarker extends StatelessWidget {
  final String? imageUrl;
  final Widget? image;
  final double size;
  final VoidCallback? onTap;

  const MapMarker({
    super.key,
    this.imageUrl,
    this.image,
    this.size = 50.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ДОБАВЬТЕ ЭТОТ ОТЛАДОЧНЫЙ ВЫВОД:
    debugPrint('MapMarker: imageUrl = $imageUrl, hasImage = ${image != null}');

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Круглая часть с изображением
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppDesignSystem.primaryColor, // #24a79c
                width: 2.0,
              ),
            ),
            child: ClipOval(
              child: image ??
                  (imageUrl != null
                      ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      // ДОБАВЬТЕ ДЛЯ ОТСЛЕЖИВАНИЯ ЗАГРУЗКИ:
                      if (loadingProgress == null) return child;
                      debugPrint('Image loading: $loadingProgress');
                      return Container(
                        color: Colors.grey[300],
                        child: const CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      // ЭТОТ БЛОК ВЫПОЛНЯЕТСЯ ПРИ ОШИБКЕ:
                      debugPrint('Image load ERROR: $error');
                      debugPrint('Image URL: $imageUrl');
                      return Container(
                        color: Colors.white,
                        child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 30.0
                        ),
                      );
                    },
                  )
                      : Container(
                    color: const Color(0xFF126F67),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/marker_place.svg',
                        width: 20,
                        height: 22,
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(
                          AppDesignSystem.whiteColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  )),
            ),
          ),
          // Стрелка внизу
          Transform.translate(
            offset: const Offset(0, -2), // mb-[-2px] из дизайна
            child: SvgPicture.asset(
              'assets/marker_arrow.svg',
              width: 12.0,
              height: 9.0,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}