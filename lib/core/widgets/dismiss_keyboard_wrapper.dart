import 'package:flutter/material.dart';

/// Обертка для автоматического закрытия клавиатуры при нажатии вне полей ввода
class DismissKeyboardWrapper extends StatelessWidget {
  final Widget child;

  const DismissKeyboardWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Закрываем клавиатуру при нажатии на любое место
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

