import 'package:flutter/material.dart';
import '../constants/app_design_system.dart';

/// Индикатор перетаскивания для bottom sheets
/// Использует обычное скругление (без smooth corner)
class DragIndicator extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  const DragIndicator({
    super.key,
    this.width,
    this.height,
    this.color,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 8),
      child: Center(
        child: Container(
          width: width ?? AppDesignSystem.handleBarWidth,
          height: height ?? AppDesignSystem.handleBarHeight,
          decoration: BoxDecoration(
            color: color ?? AppDesignSystem.handleBarColor,
            borderRadius: BorderRadius.circular(
              borderRadius ?? 3.0,
            ),
          ),
        ),
      ),
    );
  }
}

