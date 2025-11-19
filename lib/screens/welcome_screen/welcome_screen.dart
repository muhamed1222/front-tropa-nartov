import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tropanartov/screens/auth/login_screen.dart';
import 'package:tropanartov/screens/welcome_screen/route_welcome_screen.dart';
import 'package:tropanartov/services/auth_service.dart';
import '../../utils/smooth_border_radius.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_design_system.dart';

import '../../features/home/presentation/pages/home_page.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _showSlowDeviceScreen = false;
  bool _isLoggedIn = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Инициализируем контроллер анимации
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Увеличена длительность анимации
    );

    _checkAuthAndLoading();
    _startAnimation();
  }

  void _checkAuthAndLoading() async {
    // Проверяем авторизацию
    _isLoggedIn = await AuthService.isLoggedIn();

    // Если пользователь уже авторизован, сразу переходим на главную
    if (_isLoggedIn && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
      return;
    }

    // Если не авторизован, продолжаем с обычной загрузкой
    await Future.delayed(const Duration(seconds: 2));
    bool isSlowDevice = await _simulateSpeedCheck();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _showSlowDeviceScreen = isSlowDevice;
      });
    }
  }

  // Запускаем анимацию
  void _startAnimation() {
    _animationController.repeat(); // Бесконечное повторение
  }

  Future<bool> _simulateSpeedCheck() async {
    return false;
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
        transitionDuration: const Duration(milliseconds: 50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Если пользователь уже авторизован, показываем пустой контейнер
    // (будет выполнена навигация в initState)
    if (_isLoggedIn) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isLoading) {
      return _buildSlowDeviceWelcomeScreen();
    }

    return _showSlowDeviceScreen
        ? _buildSlowDeviceWelcomeScreen()
        : _buildMainWelcomeScreen();
  }

  Widget _buildSlowDeviceWelcomeScreen() {
    return Scaffold(
      body: Container(
        width: 412,
        height: 917,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Overlay.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.02),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Column(
              children: [
                const Spacer(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/FrameLogoMain.svg',
                      width: 86,
                      height: 78,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'ТРОПА НАРТОВ',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.hero(), // 34px, Bold
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Text(
                    'Версия 1.0',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.small(
                      color: Colors.black54,
                    ), // 14px, Regular
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainWelcomeScreen() {
    return Scaffold(
      body: Stack(
        children: [
          // Основной фон
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Overlay1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Анимация Lottie на заднем плане
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            left: 0,
            child: ClipRect(
              child: Align(
                alignment: Alignment.center,
                heightFactor: 0.7,
                child: Lottie.asset(
                  'assets/animations/1json.json',
                  width: 700,
                  height: 700,
                  fit: BoxFit.fitWidth,
                  controller: _animationController, // Используем контроллер для управления анимацией
                  onLoaded: (composition) {
                    // Анимация загружена и готова к воспроизведению
                    _startAnimationWithPause(composition);
                  },
                ),
              ),
            ),
          ),

          // Градиент для плавного перехода между анимацией и контентом
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.5),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.3, 0.6],
                ),
              ),
            ),
          ),

          // Основной контент поверх анимации
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 80, 14, 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  children: [
                    Text(
                      'Выбирай места',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.onboarding(), // Headlines/H1 28px, SemiBold
                    ),
                    const SizedBox(height: 8), // 8px по макету
                    Text(
                        'Вдохновляйтесь нашими подборками мест для незабываемого путешествия по Кавказу.',
                        textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        color: const Color(0x99000000),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Прелоадер для первой страницы
                _buildPageIndicator(0),
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
                            _replaceWithFade(context, const RouteWelcomeScreen());
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
        ],
      ),
    );
  }

  // Виджет прелоадера для всех страниц
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

  @override
  void dispose() {
    _animationController.dispose(); // Важно: освобождаем контроллер анимации
    super.dispose();
  }

  void _startAnimationWithPause(LottieComposition composition) {
    // Устанавливаем продолжительность анимации
    _animationController.duration = composition.duration * 1.4;

    // Запускаем цикл с паузой
    _playAnimationWithPause();
  }

  void _playAnimationWithPause() {
    // Проигрываем анимацию один раз
    _animationController.forward().then((_) {
      // После завершения анимации ждем 5 секунд
      Future.delayed(Duration(seconds: 5), () {
        // Сбрасываем анимацию и запускаем снова
        _animationController.reset();
        _playAnimationWithPause();
      });
    });
  }
}