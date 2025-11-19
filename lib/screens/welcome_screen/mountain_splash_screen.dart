import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tropanartov/screens/auth/login_screen.dart';

/// Промежуточный splash экран с горами и логотипом
/// Показывается после онбординга перед экраном входа
class MountainSplashScreen extends StatefulWidget {
  const MountainSplashScreen({super.key});

  @override
  State<MountainSplashScreen> createState() => _MountainSplashScreenState();
}

class _MountainSplashScreenState extends State<MountainSplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToAuth();
  }

  /// Переход на экран входа после задержки
  void _navigateToAuth() {
    Future.delayed(const Duration(seconds: 2), () {
      // Проверяем, что виджет все еще в дереве
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
            const AuthAuthorizationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/welcome.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/GroupLogoLast.svg',
            width: 86,
            height: 78,
          ),
        ),
      ),
    );
  }
}

