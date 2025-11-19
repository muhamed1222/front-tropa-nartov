import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_design_system.dart';
import '../../utils/smooth_border_radius.dart';

/// Компонент для отображения выбранных фильтров
/// Используется на экранах "Места" и "Маршруты" для показа активных фильтров
/// По дизайну Figma: светло-бирюзовый фон, текст цвета primary, круглая иконка закрытия
class AppFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDelete;

  const AppFilterChip({
    super.key,
    required this.label,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SmoothContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      borderRadius: 20, // По дизайну Figma
      color: AppDesignSystem.primaryColor.withValues(alpha: 0.12), // rgba(36,167,156,0.12)
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Текст фильтра
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400, // Regular
              color: AppDesignSystem.primaryColor, // #24a79c
              height: 1.2,
              letterSpacing: -0.28,
            ),
          ),
          // Иконка закрытия
          if (onDelete != null) ...[
            const SizedBox(width: 5), // Gap между текстом и иконкой
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: AppDesignSystem.primaryColor, // #24a79c
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 10,
                  color: AppDesignSystem.whiteColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

