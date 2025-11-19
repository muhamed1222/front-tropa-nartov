import 'package:flutter/material.dart';
import '../constants/app_design_system.dart';

/// Переключатель (Toggle Switch) приложения
/// Используется для включения/выключения опций с анимацией
class AppToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double width;
  final double height;

  const AppToggleSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.width = 44.0,
    this.height = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null
          ? () {
              onChanged!(!value);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        padding: const EdgeInsets.all(2.0), // По дизайну из Figma
        decoration: BoxDecoration(
          color: value
              ? AppDesignSystem.primaryColor // #24a79c
              : AppDesignSystem.greyButton, // #e7e7e7
          borderRadius: BorderRadius.circular(21.0), // По дизайну из Figma
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20.0, // По дизайну из Figma
            height: 20.0, // По дизайну из Figma
            decoration: BoxDecoration(
              color: AppDesignSystem.whiteColor,
              borderRadius: BorderRadius.circular(13.0), // По дизайну из Figma
            ),
          ),
        ),
      ),
    );
  }
}

