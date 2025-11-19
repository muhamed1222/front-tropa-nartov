import 'package:flutter/material.dart';
import '../constants/app_design_system.dart';

/// Переключатель (Switch) приложения
/// Используется для включения/выключения опций
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double size;

  const AppSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null
          ? () {
              onChanged!(!value);
            }
          : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: value
              ? AppDesignSystem.whiteColor
              : AppDesignSystem.backgroundColorSecondary, // #f6f6f6
          borderRadius: BorderRadius.circular(14.0), // По дизайну из Figma (круглый)
          border: value
              ? Border.all(
                  color: AppDesignSystem.primaryColor, // #24a79c
                  width: 1.0,
                )
              : null,
        ),
        padding: value ? const EdgeInsets.all(3.0) : null,
        child: value
            ? Container(
                width: 10.0,
                height: 10.0,
                decoration: BoxDecoration(
                  color: AppDesignSystem.primaryColor, // #24a79c
                  borderRadius: BorderRadius.circular(14.0), // Круглый индикатор
                ),
              )
            : null,
      ),
    );
  }
}

