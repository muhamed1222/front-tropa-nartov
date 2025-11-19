import 'package:flutter/material.dart';
import '../constants/app_design_system.dart';
import '../constants/app_text_styles.dart';
import '../../utils/smooth_border_radius.dart';

/// Основная кнопка приложения
/// Использует единый стиль из дизайн-системы
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final bool isLoading;
  final Color? color;
  final TextStyle? textStyle; // НОВЫЙ ПАРАМЕТР: кастомный стиль текста

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isDisabled = false,
    this.isLoading = false,
    this.color,
    this.textStyle, // Добавляем в конструктор
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isDisabled && !isLoading;

    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.6,
        child: SmoothContainer(
          width: double.infinity,
          height: AppDesignSystem.buttonHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesignSystem.paddingHorizontal,
            vertical: AppDesignSystem.paddingVerticalMedium,
          ),
          borderRadius: AppDesignSystem.borderRadius,
          color: isLoading
              ? (color ?? AppDesignSystem.primaryColor).withValues(alpha: 0.5)
              : (color ?? AppDesignSystem.primaryColor),
          child: Center(
            child: isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppDesignSystem.whiteColor),
              ),
            )
                : Text(
              text,
              style: textStyle ?? AppTextStyles.button(), // ИЗМЕНЕНИЕ: используем переданный стиль или дефолтный
            ),
          ),
        ),
      ),
    );
  }
}