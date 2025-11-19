import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_design_system.dart';
import '../../utils/smooth_border_radius.dart';

/// Группа кнопок-переключателей
/// Поддерживает 2 или 3 кнопки
/// По дизайну Figma: контейнер с фоном #f6f6f6, padding 4px, кнопки с gap 4px
class ToggleButtonGroup extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  const ToggleButtonGroup({
    super.key,
    required this.options,
    required this.selectedIndex,
    this.onSelected,
  }) : assert(options.length >= 2 && options.length <= 3, 'Должно быть 2 или 3 опции');

  @override
  Widget build(BuildContext context) {
    return SmoothContainer(
      padding: const EdgeInsets.all(4.0), // По дизайну Figma
      borderRadius: 12.0, // По дизайну Figma
      color: AppDesignSystem.greyLight, // Светло-серый фон
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (index) {
          final isSelected = index == selectedIndex;
          final isFirst = index == 0;
          final isLast = index == options.length - 1;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: isFirst ? 0 : 2, // Gap 4px между кнопками (2px с каждой стороны)
                right: isLast ? 0 : 2,
              ),
              child: GestureDetector(
                onTap: () => onSelected?.call(index),
                child: SmoothContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 10.0,
                  ),
                  borderRadius: 10.0, // По дизайну Figma
                  color: isSelected
                      ? AppDesignSystem.primaryColor // #24a79c
                      : Colors.transparent,
                  child: Center(
                    child: Text(
                      options[index],
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w500 // Medium для выбранной
                            : FontWeight.w400, // Regular для невыбранной
                        color: isSelected
                            ? AppDesignSystem.whiteColor
                            : AppDesignSystem.textColorPrimary, // Черный
                        height: 1.2,
                        letterSpacing: isSelected ? 0.0 : -0.28, // Letter spacing только для невыбранной
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

