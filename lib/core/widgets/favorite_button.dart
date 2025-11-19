import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../constants/app_design_system.dart';

/// Кнопка избранного
/// Используется для добавления/удаления места из избранного
class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onTap;
  final double size;

  const FavoriteButton({
    super.key,
    this.isFavorite = false,
    this.onTap,
    this.size = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppDesignSystem.overlayWhiteLight,
                borderRadius: BorderRadius.circular(26.0),
              ),
              child: Center(
                child: SvgPicture.asset(
                  isFavorite
                      ? 'assets/bookyes.svg'
                      : 'assets/bookmark_empty.svg',
                  width: 16.0,
                  height: 16.0,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    AppDesignSystem.whiteColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

