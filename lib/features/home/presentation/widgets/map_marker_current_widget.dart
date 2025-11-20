import 'package:flutter/material.dart';

// Добавлено: Анимированная метка с пульсациями
class CurrentUserPositionWidget extends StatefulWidget {
  const CurrentUserPositionWidget({super.key});

  @override
  CurrentUserPositionWidgetState createState() => CurrentUserPositionWidgetState();
}

class CurrentUserPositionWidgetState extends State<CurrentUserPositionWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2), // Период пульсации 2 секунды
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.8, // Максимальный размер пульсации
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // Запускаем бесконечную анимацию
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF24A79C);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Пульсирующие круги (3 слоя для эффекта)
            Container(
              width: 30.0 * _animation.value,
              height: 30.0 * _animation.value,
              decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor.withValues(alpha: 0.3)),
            ),

            // Основная метка (не пульсирует)
            Container(
              width: 20.0,
              height: 20.0,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,

                boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.5), blurRadius: 6.0, offset: Offset(0, 2))],
              ),
            ),
          ],
        );
      },
    );
  }
}
