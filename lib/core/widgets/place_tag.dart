import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_design_system.dart';
import '../constants/app_text_styles.dart';

/// Тег места
/// Используется для отображения типа места (например, "Озеро", "Гора")
class PlaceTag extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  const PlaceTag({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 4.0,
          ),
          decoration: BoxDecoration(
            color: backgroundColor ?? AppDesignSystem.overlayWhiteLight,
            borderRadius: BorderRadius.circular(26.0),
          ),
          child: Text(
            text,
            style: AppTextStyles.error(
              color: textColor ?? AppDesignSystem.whiteColor,
              fontWeight: AppDesignSystem.fontWeightRegular,
            ), // 12px
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

