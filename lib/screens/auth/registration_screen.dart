import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Добавляем пакет для SVG
import 'package:url_launcher/url_launcher.dart';

import '../../features/home/presentation/pages/home_page.dart';
import 'login_screen.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/smooth_border_radius.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_design_system.dart';

class AuthRegistrationScreen extends StatefulWidget {
  const AuthRegistrationScreen({super.key});

  @override
  State<AuthRegistrationScreen> createState() => _AuthRegistrationScreenState();
}

class _AuthRegistrationScreenState extends State<AuthRegistrationScreen> {
  bool isAgree = false;
  bool isPasswordVisible = false;
  bool isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Валидационные поля
  String? _nameError;
  String? _emailError;
  String? _passwordError;

  static final Uri _termsUrl = Uri.parse('https://wise-mission-436584.framer.app/terms-and-conditions');
  static final Uri _privacyUrl = Uri.parse('https://wise-mission-436584.framer.app/privacy-policy');

  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = _handleTermsTap;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _handlePrivacyTap;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  // Обработчик для Условий использования
  void _handleTermsTap() {
    _openUrl(_termsUrl);
  }

  // Обработчик для Политики конфиденциальности
  void _handlePrivacyTap() {
    _openUrl(_privacyUrl);
  }

  Future<void> _openUrl(Uri url) async {
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void _togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  // Методы валидации
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ошибка: неверный формат имени';
    }
    if (value.length < 2) {
      return 'Имя должно содержать минимум 2 символа';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ошибка: неверный формат email адреса';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ошибка: неверный формат email адреса';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ошибка: неверный формат пароля';
    }
    if (value.length < 8) {
      return 'Пароль должен содержать минимум 8 символов';
    }
    return null;
  }
  // Проверка всех полей
  bool _validateAllFields() {
    final nameError = _validateName(_nameController.text);
    final emailError = _validateEmail(_emailController.text);
    final passwordError = _validatePassword(_passwordController.text);

    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _passwordError = passwordError;
    });

    return nameError == null && emailError == null && passwordError == null;
  }

  void _handleCreateAccount() async {
    // Проверка на согласие
    if (!isAgree) {
      return;
    }

    // Валидация всех полей
    if (!_validateAllFields()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // РЕАЛЬНЫЙ ВЫЗОВ API РЕГИСТРАЦИИ
      final user = await ApiService.register(name, email, password);

      // ВТОМАТИЧЕСКИ ВХОДИМ ПОСЛЕ РЕГИСТРАЦИИ
      final loginResponse = await ApiService.login(email, password);

      // Сохраняем токен и пользователя
      await AuthService.saveToken(loginResponse.token);
      await AuthService.saveUser(loginResponse.user);

      // Переход на главный экран только при УСПЕШНОЙ регистрации и входе
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage())
        );
      }
    } catch (e) {
      // Ошибка регистрации - показываем пользователю
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка регистрации: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Обработчик для кнопки "Войти"
  void _handleLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthAuthorizationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Регистрация',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge(),
              ),
              const SizedBox(height: 16),
              Form(
                child: Column(
                  children: [
                    // Поле имени
                    TextField(
                      controller: _nameController,
                      style: AppTextStyles.body(),
                      decoration: InputDecoration(
                        hintText: 'Имя',
                        hintStyle: AppTextStyles.hint(),
                        filled: true,
                        fillColor: const Color.fromRGBO(246, 246, 246, 1),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        border: SmoothOutlineInputBorder(
                          borderRadius: 10,
                          borderSide: BorderSide(
                            color: _nameError != null ? Color(0xFFFF4444) : Colors.transparent,
                            width: _nameError != null ? 1.5 : 0,
                          ),
                        ),
                        enabledBorder: SmoothOutlineInputBorder(
                          borderRadius: 10,
                          borderSide: BorderSide(
                            color: _nameError != null ? Color(0xFFFF4444) : Colors.transparent,
                            width: _nameError != null ? 1.5 : 0,
                          ),
                        ),
                        focusedBorder: SmoothOutlineInputBorder(
                          borderRadius: 10,
                          borderSide: BorderSide(
                            color: _nameError != null ? Color(0xFFFF4444) : Colors.transparent,
                            width: _nameError != null ? 2.0 : 1.5,
                          ),
                        ),
                        errorBorder: SmoothOutlineInputBorder(
                          borderRadius: 10,
                          borderSide: const BorderSide(color: Color(0xFFFF4444), width: 1.5),
                        ),
                      ),
                      onChanged: (value) {
                        if (_nameError != null) {
                          setState(() {
                            _nameError = _validateName(value);
                          });
                        }
                      },
                    ),
                    if (_nameError != null) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Text(
                            _nameError!,
                            style: AppTextStyles.error(), // 12px, красный
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),

                    // Поле email
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTextStyles.body(),
                      decoration: InputDecoration(
                        hintText: 'Почта',
                        hintStyle: AppTextStyles.hint(),
                        filled: true,
                        fillColor: const Color.fromRGBO(246, 246, 246, 1),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        border: SmoothOutlineInputBorder(
                          borderRadius: 10,
                          borderSide: BorderSide(
                            color: _emailError != null ? Color(0xFFFF4444) : Colors.transparent,
                            width: _emailError != null ? 1.5 : 0,
                          ),
                        ),
                        enabledBorder: SmoothOutlineInputBorder(
                          borderRadius: 10,
                          borderSide: BorderSide(
                            color: _emailError != null ? Color(0xFFFF4444) : Colors.transparent,
                            width: _emailError != null ? 1.5 : 0,
                          ),
                        ),
                        focusedBorder: SmoothOutlineInputBorder(
                          borderRadius: 10,
                          borderSide: BorderSide(
                            color: _emailError != null ? Color(0xFFFF4444) : Colors.transparent,
                            width: _emailError != null ? 2.0 : 1.5,
                          ),
                        ),
                        errorBorder: SmoothOutlineInputBorder(
                          borderRadius: 10,
                          borderSide: const BorderSide(color: Color(0xFFFF4444), width: 1.5),
                        ),
                      ),
                      onChanged: (value) {
                        if (_emailError != null) {
                          setState(() {
                            _emailError = _validateEmail(value);
                          });
                        }
                      },
                    ),
                    if (_emailError != null) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Text(
                            _emailError!,
                            style: AppTextStyles.error(), // 12px, красный
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),

                    // Поле пароля
                    TextField(
                      controller: _passwordController,
                      obscureText: !isPasswordVisible,
                      keyboardType: TextInputType.visiblePassword,
                      style: AppTextStyles.body(
                        color: _passwordError != null ? AppDesignSystem.textColorError : null,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Пароль',
                        hintStyle: AppTextStyles.hint(color: const Color(0xFF919191)),
                        filled: true,
                        fillColor: const Color.fromRGBO(246, 246, 246, 1),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        border: SmoothOutlineInputBorder(
                          borderRadius: 10,
                          borderSide: BorderSide(
                            color: _passwordError != null ? Color(0xFFFF4444) : Colors.transparent,
                            width: _passwordError != null ? 1.5 : 0,
                          ),
                        ),
                        enabledBorder: SmoothOutlineInputBorder(
                          borderRadius: 10,
                          borderSide: BorderSide(
                            color: _passwordError != null ? Color(0xFFFF4444) : Colors.transparent,
                            width: _passwordError != null ? 1.5 : 0,
                          ),
                        ),
                        focusedBorder: SmoothOutlineInputBorder(
                          borderRadius: 10,
                          borderSide: BorderSide(
                            color: _passwordError != null ? Color(0xFFFF4444) : Colors.transparent,
                            width: _nameError != null ? 2.0 : 1.5,
                          ),
                        ),
                        errorBorder: SmoothOutlineInputBorder(
                          borderRadius: 10,
                          borderSide: const BorderSide(color: Color(0xFFFF4444), width: 1.5),
                        ),
                        suffixIcon: IconButton(
                          onPressed: _togglePasswordVisibility,
                          icon: SvgPicture.asset(
                            isPasswordVisible ? 'assets/view-on.svg' : 'assets/view-off.svg',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (_passwordError != null) {
                          setState(() {
                            _passwordError = _validatePassword(value);
                          });
                        }
                      },
                    ),
                    if (_passwordError != null) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Text(
                            _passwordError!,
                            style: AppTextStyles.error(), // 12px, красный
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Чекбокс согласия
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: Checkbox(
                              activeColor: const Color(0xFF24A79C),
                              value: isAgree,
                              side: const BorderSide(color: Colors.transparent, width: 0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // Кнопка использует встроенный стиль
                              fillColor: WidgetStateProperty.resolveWith((states) {
                                if (!states.contains(WidgetState.selected)) {
                                  return const Color(0xFFF6F6F6);
                                }
                                return const Color(0xFF24A79C);
                              }),
                              onChanged: isLoading ? null : (value) {
                                setState(() {
                                  isAgree = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: AppTextStyles.secondary(), // 14px, rgba(0,0,0,0.6)
                                children: [
                                  const TextSpan(text: 'Я соглашаюсь с '),
                                  TextSpan(
                                    text: 'Условиями использования',
                                    style: GoogleFonts.inter(
                                      color: AppDesignSystem.primaryColor,
                                    ),
                                    recognizer: _termsRecognizer,
                                  ),
                                  const TextSpan(text: ' и '),
                                  TextSpan(
                                    text: 'Политикой конфиденциальности',
                                    style: GoogleFonts.inter(
                                      color: AppDesignSystem.primaryColor,
                                    ),
                                    recognizer: _privacyRecognizer,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Кнопка создания аккаунта
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleCreateAccount,
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.20,
                          ),
                          backgroundColor: const Color(0xFF24A79C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Кнопка использует встроенный стиль
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child:  isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Text('Создать аккаунт'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Уже есть аккаунт?',
                style: AppTextStyles.secondary(), // 14px, rgba(0,0,0,0.6)
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  visualDensity: const VisualDensity(horizontal: -2, vertical: 0),
                ),
                onPressed: isLoading ? null : _handleLogin,
                child: Text(
                  'Войти',
                  style: AppTextStyles.secondary(
                    color: AppDesignSystem.primaryColor,
                  ), // 14px, акцентный
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}