import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../constants/app_design_system.dart';
import '../../utils/smooth_border_radius.dart';

/// Чекбокс приложения
/// Используется для выбора опций в формах и фильтрах
class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double size;

  const AppCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null
          ? () {
              onChanged!(!value);
            }
          : null,
      child: SmoothContainer(
        width: size,
        height: size,
        borderRadius: 4.0, // По дизайну из Figma
        color: value
            ? AppDesignSystem.primaryColor // #24a79c
            : AppDesignSystem.backgroundColorSecondary, // #f6f6f6
        child: value
            ? Center(
                child: SvgPicture.asset(
                  'assets/checkmark.svg',
                  width: 10.0,
                  height: 8.0,
                  fit: BoxFit.contain,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

