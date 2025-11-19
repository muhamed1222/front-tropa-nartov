import 'package:flutter/material.dart';
import '../../utils/smooth_border_radius.dart';
import '../constants/app_design_system.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

/// Нижняя панель действий с кнопками Cancel и Confirm
/// По дизайну Figma: белый контейнер с тенью, скругленными верхними углами
/// Padding: 14px слева, 14px сверху, 14px справа, 44px снизу
/// Кнопки: адаптивная ширина (Expanded), padding 12px/16px
/// Расстояние между кнопками: 10px
class BottomActionBar extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final String? cancelText;
  final String? confirmText;

  const BottomActionBar({
    super.key,
    this.onCancel,
    required this.onConfirm,
    this.cancelText,
    this.confirmText,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return IntrinsicHeight(
      child: OverflowBox(
        maxWidth: screenWidth,
        alignment: Alignment.centerLeft,
        child: Transform.translate(
          offset: const Offset(-14, 0),
          child: SizedBox(
            width: screenWidth,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppDesignSystem.shadowColor.withValues(alpha: 0.2),
                    offset: const Offset(0, -2),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipPath(
                clipper: _TopRoundedSmoothClipper(radius: 20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 44),
                  decoration: const BoxDecoration(
                    color: AppDesignSystem.whiteColor,
                  ),
                  child: Row(
                  children: [
                    if (onCancel != null) ...[
                        // Кнопка "Отменить" (левая) - используем SecondaryButton
                      Expanded(
                          child: SecondaryButton(
                            text: cancelText ?? 'Отменить',
                            onPressed: onCancel,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                      // Кнопка "Подтвердить" (правая) - используем PrimaryButton с Expanded
                    Expanded(
                        child: PrimaryButton(
                          text: confirmText ?? 'Подтвердить',
                          onPressed: onConfirm,
                      ),
                    ),
                  ],
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

/// CustomClipper для скругления только верхних углов с smooth corner
class _TopRoundedSmoothClipper extends CustomClipper<Path> {
  final double radius;
  final double smoothing;

  _TopRoundedSmoothClipper({
    required this.radius,
    this.smoothing = defaultCornerSmoothing,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final r = radius;
    final s = smoothing;
    final controlPoint = r * (1 - s);

    // Начинаем с левого нижнего угла (без скругления)
    path.moveTo(0, size.height);
    
    // Идем к правому нижнему углу (без скругления)
    path.lineTo(size.width, size.height);
    
    // Правый верхний угол с smooth corner
    path.lineTo(size.width, r);
    path.cubicTo(
      size.width,
      controlPoint,
      size.width - controlPoint,
      0,
      size.width - r,
      0,
    );
    
    // Верхняя сторона
    path.lineTo(r, 0);
    
    // Левый верхний угол с smooth corner
    path.cubicTo(
      controlPoint,
      0,
      0,
      controlPoint,
      0,
      r,
    );
    
    // Завершаем путь
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(_TopRoundedSmoothClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.smoothing != smoothing;
  }
}
