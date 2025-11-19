import 'package:flutter/material.dart';

class NavigationHelper {
  static void replaceWithFade(BuildContext context, Widget page, {int duration = 300}) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // const begin = 0.0;
          // const end = 1.0;
          const curve = Curves.easeInOut;

          var fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: curve,
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: duration),
      ),
    );
  }
}