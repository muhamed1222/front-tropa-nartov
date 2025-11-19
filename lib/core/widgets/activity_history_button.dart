import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_design_system.dart';
import '../constants/app_text_styles.dart';

/// Кнопка для истории активности
/// Используется в личном кабинете для перехода к истории активности
class ActivityHistoryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const ActivityHistoryButton({
    super.key,
    this.text = 'Перейти',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDesignSystem.borderRadiusInput),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesignSystem.paddingHorizontal,
                vertical: 8.0, // По дизайну из Figma
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDesignSystem.borderRadiusInput),
                color: AppDesignSystem.greyButton, // #e7e7e7
              ),
              child: Text(
                text,
                style: AppTextStyles.small(
                  color: AppDesignSystem.textColorPrimary,
                  fontWeight: AppDesignSystem.fontWeightRegular,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

