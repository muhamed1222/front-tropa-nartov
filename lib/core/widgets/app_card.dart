import 'package:flutter/material.dart';
import '../constants/app_design_system.dart';
import '../../utils/smooth_border_radius.dart';

/// Универсальная карточка приложения
/// Использует дизайн-систему для консистентного стиля
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final double? borderRadius;
  final VoidCallback? onTap;
  final BoxShadow? shadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    final card = SmoothContainer(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
      margin: margin,
      borderRadius: borderRadius ?? AppDesignSystem.borderRadiusMedium,
      color: backgroundColor ?? AppDesignSystem.backgroundColor,
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

