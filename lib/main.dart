import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tropanartov/core/di/injection_container.dart' as di;
import 'package:tropanartov/config/app_config.dart';
import 'package:tropanartov/features/home/presentation/pages/home_page.dart';
import 'package:tropanartov/screens/welcome_screen/welcome_screen.dart';
import 'package:tropanartov/services/auth_service.dart';
import 'package:tropanartov/services/preferences_service.dart';
import 'core/constants/app_text_styles.dart';
import 'core/constants/app_design_system.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Запрещаем горизонтальную ориентацию - только портретный режим
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Инициализируем конфигурацию окружения
  AppConfig.init();
  
  // Инициализируем PreferencesService перед DI
  await PreferencesService.init();
  
  await di.init();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Устанавливаем ориентацию при инициализации
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // При каждом изменении состояния приложения устанавливаем ориентацию
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Listener(
          onPointerDown: (_) {
            // Закрываем клавиатуру при нажатии на любое место экрана
            FocusManager.instance.primaryFocus?.unfocus();
          },
          behavior: HitTestBehavior.translucent,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

      Future<void> _checkAuthStatus() async {
        // Даем время для показа splash screen
        await Future.delayed(const Duration(milliseconds: 1500));

        // Проверяем наличие токена и его валидность
        final isLoggedIn = await AuthService.isLoggedIn();
        
        if (isLoggedIn) {
          // Если токен есть, проверяем его валидность
          final isTokenValid = await AuthService.isTokenValid();
          
          if (mounted) {
            if (isTokenValid) {
              // Токен валиден - идем на главную
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            } else {
              // Токен невалиден - показываем onboarding
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              );
            }
          }
        } else {
          // Нет токена - показываем onboarding
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            );
          }
        }
      }

  @override
  Widget build(BuildContext context) {
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
                      style: AppTextStyles.hero(),
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Text(
                    'Версия 1.0',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.secondary(
                      color: AppDesignSystem.textColorTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}