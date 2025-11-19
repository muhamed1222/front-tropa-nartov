import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tropanartov/screens/auth/login_screen.dart';
import '../../utils/smooth_border_radius.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_design_system.dart';

import 'main_app_screen.dart';

class FavoriteWelcomeScreen extends StatefulWidget {
  const FavoriteWelcomeScreen({super.key});

  @override
  State<FavoriteWelcomeScreen> createState() => _FavoriteWelcomeScreenState();
}

class _FavoriteWelcomeScreenState extends State<FavoriteWelcomeScreen> {
  bool _showAnimation = true;

  @override
  void initState() {
    super.initState();
    _startAnimationCycle();
  }

  void _startAnimationCycle() {
    // Каждые 10 секунд перезапускаем анимацию
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showAnimation = false;
        });
        // Даем время на исчезновение и снова показываем
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            setState(() {
              _showAnimation = true;
            });
            // Запускаем следующий цикл
            _startAnimationCycle();
          }
        });
      }
    });
  }

  void _replaceWithFade(BuildContext context, Widget page) {
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
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Overlay3.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 80, 14, 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Анимация с отрицательным отступом снизу
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14), // Отрицательный отступ
                  child: Stack(
                    children: [
                      // Анимация занимает всю доступную ширину
                      if (_showAnimation)
                        Positioned.fill(
                          child: Lottie.asset(
                            'assets/animations/1.json',
                            fit: BoxFit.cover,
                            repeat: false, // Проигрываем один раз
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Column(
                  children: [
                    Text(
                      'Сохраняй избранное',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.onboarding(), // Headlines/H1 28px, SemiBold
                    ),
                    const SizedBox(height: 8), // 8px по макету
                    Text(
                        'Добавляйте понравившиеся места и маршруты в избранное, чтобы не потерять их.',
                        textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 16,
                        fontWeight: FontWeight.w400, // Regular
                        color: const Color(0x99000000), // rgba(0,0,0,0.6)
                        height: 1.2,
                      ),
                    ),
                  ],
              ),
              const SizedBox(height: 30),

              // Прелоадер для третьей страницы
              _buildPageIndicator(2),
              const SizedBox(height: 40),

              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 51,
                        child: TextButton(
                          onPressed: () {
                            _replaceWithFade(context, const AuthAuthorizationScreen());
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: AppDesignSystem.backgroundColorSecondary,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            shape: const SmoothRoundedRectangleBorder(
                              borderRadius: 12.0,
                              smoothing: 0.6,
                            ),
                          ),
                          child: Text(
                            'Пропустить',
                            style: AppTextStyles.button(
                              color: AppDesignSystem.textColorPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 51,
                        child: ElevatedButton(
                          onPressed: () {
                            _replaceWithFade(context, const MainAppScreen());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppDesignSystem.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            shape: const SmoothRoundedRectangleBorder(
                              borderRadius: 12.0,
                              smoothing: 0.6,
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Далее',
                            style: AppTextStyles.button(),
                          ),
                        ),
                      ),
                    ),
                  ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Виджет прелоадера
  Widget _buildPageIndicator(int currentPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == currentPage ? 26 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: index == currentPage ? Colors.black : const Color(0xFFE7E7E7),
            borderRadius: BorderRadius.circular(17),
          ),
        );
      }),
    );
  }
}