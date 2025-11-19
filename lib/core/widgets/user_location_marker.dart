import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_design_system.dart';

/// Метка местоположения пользователя на карте
/// Используется для отображения текущего местоположения пользователя
class UserLocationMarker extends StatefulWidget {
  final String? text;
  final double outerCircleSize;
  final double innerCircleSize;

  const UserLocationMarker({
    super.key,
    this.text,
    this.outerCircleSize = 30.0, // Максимальный размер по дизайну
    this.innerCircleSize = 20.0,
  });

  @override
  State<UserLocationMarker> createState() => _UserLocationMarkerState();
}

class _UserLocationMarkerState extends State<UserLocationMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.7, // Минимальный размер (30 * 0.7 = 21px)
      end: 1.0, // Максимальный размер (30px)
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayText = widget.text ?? 'Вы тут';

    return SizedBox(
      width: 52.0, // По дизайну из Figma
      height: 64.0, // По дизайну из Figma
      child: Stack(
        children: [
          // Верхняя часть: концентрические круги с анимацией
          // Занимает примерно 65.63% высоты (top: 0, bottom: 43.75%)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Внешний круг (светлый) с пульсацией
                      Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: widget.outerCircleSize,
                          height: widget.outerCircleSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppDesignSystem.primaryColor.withValues(
                              alpha: 0.3 / _pulseAnimation.value, // Уменьшаем прозрачность при увеличении
                            ),
                          ),
                        ),
                      ),
                      // Внутренний круг (темный) - не пульсирует, всегда в центре
                      Container(
                        width: widget.innerCircleSize,
                        height: widget.innerCircleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppDesignSystem.primaryColor, // #24a79c
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          // Нижняя часть: текст в прямоугольнике
          // Занимает примерно 34.37% высоты (top: 65.63%, bottom: 0)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0, // По дизайну из Figma
                vertical: 4.0, // По дизайну из Figma
              ),
              decoration: BoxDecoration(
                color: AppDesignSystem.primaryColor, // #24a79c
                borderRadius: BorderRadius.circular(8.0), // По дизайну из Figma
              ),
              child: Text(
                displayText,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10, // Уменьшенный размер текста
                  fontWeight: FontWeight.w400, // Regular
                  color: AppDesignSystem.whiteColor,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

