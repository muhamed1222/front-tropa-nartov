import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_design_system.dart';

/// Индикатор пагинации изображений
/// Используется для отображения текущей позиции в галерее изображений
class ImagePaginationIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalCount;
  final double dotSize;
  final double activeDotWidth;
  final Color activeColor;
  final Color inactiveColor;

  const ImagePaginationIndicator({
    super.key,
    required this.currentIndex,
    required this.totalCount,
    this.dotSize = 4.0,
    this.activeDotWidth = 14.0,
    this.activeColor = AppDesignSystem.whiteColor,
    this.inactiveColor = AppDesignSystem.overlayWhite, // white with 0.6 opacity
  });

  @override
  Widget build(BuildContext context) {
    if (totalCount <= 1) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(26.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            color: AppDesignSystem.overlayWhiteLight,
            borderRadius: BorderRadius.circular(26.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(totalCount, (index) {
              final isActive = index == currentIndex;
              return Container(
                margin: EdgeInsets.only(
                  right: index < totalCount - 1 ? 3.0 : 0,
                ),
                width: isActive ? activeDotWidth : dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: isActive ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(17.0),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

