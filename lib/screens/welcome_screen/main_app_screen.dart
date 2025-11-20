import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tropanartov/screens/welcome_screen/mountain_splash_screen.dart';
import '../../utils/smooth_border_radius.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_design_system.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  bool _showAnimation = true;

  @override
  void initState() {
    super.initState();
    _startAnimationCycle();
  }

  void _startAnimationCycle() {
    // Каждые 10 секунд + длительность анимации перезапускаем анимацию
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

  /// Показываем промежуточный splash экран с горами
  void _showMountainScreenBeforeAuth(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          const MountainSplashScreen(),
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
  }

  // void _replaceWithFade(BuildContext context, Widget page) {
  //   Navigator.pushReplacement(
  //     context,
  //     PageRouteBuilder(
  //       pageBuilder: (context, animation, secondaryAnimation) => page,
  //       transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //         // const begin = 0.0;
  //         // const end = 1.0;
  //         const curve = Curves.easeInOut;
  //
  //         var fadeAnimation = CurvedAnimation(
  //           parent: animation,
  //           curve: curve,
  //         );
  //
  //         return FadeTransition(
  //           opacity: fadeAnimation,
  //           child: child,
  //         );
  //       },
  //       transitionDuration: const Duration(milliseconds: 300),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Overlay4.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 80, 14, 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Вся область с анимацией и текстом поверх
              Expanded(
                child: Stack(
                  children: [
                    // Анимация на заднем плане
                    if (_showAnimation)
                      Positioned(
                        top: 0,
                        bottom: 0,
                        right: -20,
                        left: -20,
                        child: ClipRect(
                          child: Align(
                            alignment: Alignment.topCenter,
                            heightFactor: 0.7,
                            child: Lottie.asset(
                              'assets/animations/4.json',
                              width: 700,
                              height: 600,
                              fit: BoxFit.fitWidth,
                              repeat: false, // Проигрываем один раз
                            ),
                          ),
                        ),
                      ),

                    // Градиент для плавного перехода
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.white,
                              Colors.white.withValues(alpha: 0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Текст поверх анимации
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Text(
                            'Собирай статистику',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.onboarding(), // Headlines/H1 28px, SemiBold
                          ),
                          const SizedBox(height: 8), // 8px по макету
                          Text(
                            'Отслеживайте статистику в личном кабинете и завоевывайте новые звания.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: const Color(0x99000000),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Прелоадер для четвертой страницы
                          _buildPageIndicator(3),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 51,
                      child: ElevatedButton(
                        onPressed: () {
                          _showMountainScreenBeforeAuth(context);
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
                          'Начать',
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