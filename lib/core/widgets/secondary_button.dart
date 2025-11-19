import 'package:flutter/material.dart';
import '../constants/app_design_system.dart';
import '../constants/app_text_styles.dart';
import '../../utils/smooth_border_radius.dart';

/// Вторичная кнопка приложения
/// Прозрачный фон с обводкой цвета primary, текст цвета primary
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SmoothContainer(
        width: width ?? double.infinity,
        height: AppDesignSystem.buttonHeight,
        borderRadius: AppDesignSystem.borderRadius,
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0, // По дизайну из Figma
          vertical: AppDesignSystem.paddingVerticalMedium,
        ),
        border: Border.all(
          color: AppDesignSystem.primaryColor,
          width: 1.0,
        ),
        color: Colors.transparent,
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.body(
              color: AppDesignSystem.primaryColor,
              fontWeight: AppDesignSystem.fontWeightMedium,
            ),
          ),
        ),
      ),
    );
  }
}

