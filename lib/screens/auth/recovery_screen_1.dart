import 'package:flutter/material.dart';
import '../../../utils/smooth_border_radius.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/auth_constants.dart';
import '../../../config/app_config.dart';
import 'package:tropanartov/screens/auth/recovery_screen_2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_screen.dart';

class AuthRecoveryOneScreen extends StatefulWidget {
  const AuthRecoveryOneScreen({super.key});

  @override
  State<AuthRecoveryOneScreen> createState() => _AuthRecoveryOneScreenState();
}

class _AuthRecoveryOneScreenState extends State<AuthRecoveryOneScreen> {
  final TextEditingController _emailController = TextEditingController();

  // Валидационное поле
  String? _emailError;
  bool _isLoading = false;

  // Метод валидации email
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

  // Проверка всех полей
  bool _validateAllFields() {
    final emailError = _validateEmail(_emailController.text);

    setState(() {
      _emailError = emailError;
    });

    return emailError == null;
  }

  Future<void> _handleGetCode() async {
    // Валидация всех полей
    if (!_validateAllFields()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final email = _emailController.text.trim();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AuthRecoveryTwoScreen(email: email)
        ));
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          _emailError = errorData['error'] ?? 'Произошла ошибка при отправке кода';
        });
      }
    } catch (e) {
      setState(() {
        _emailError = 'Ошибка подключения: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthConstants.backgroundColor,
      body: SafeArea(
        child: Center(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Восстановление пароля',
                textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge(), // 22px SemiBold
                ),
                const SizedBox(height: 16),
              Form(
                child: Column(
                  children: [
                    // Поле email с валидацией
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTextStyles.body(),
                      decoration: InputDecoration(
                        hintText: 'Почта',
                        hintStyle: AppTextStyles.hint(),
                        filled: true,
                        fillColor: AuthConstants.inputBackgroundColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        border: SmoothOutlineInputBorder(
                          borderRadius: 10.0, // 10px по макету
                          smoothing: 0.6,
                          borderSide: BorderSide(
                            color: _emailError != null ? AuthConstants.errorColor : Colors.transparent,
                            width: _emailError != null ? 1.5 : 0,
                          ),
                        ),
                        enabledBorder: SmoothOutlineInputBorder(
                          borderRadius: 10.0,
                          smoothing: 0.6,
                          borderSide: BorderSide(
                            color: _emailError != null ? AuthConstants.errorColor : Colors.transparent,
                            width: _emailError != null ? 1.5 : 0,
                          ),
                        ),
                        focusedBorder: SmoothOutlineInputBorder(
                          borderRadius: 10.0,
                          smoothing: 0.6,
                          borderSide: BorderSide(
                            color: _emailError != null ? AuthConstants.errorColor : AuthConstants.primaryColor,
                            width: _emailError != null ? 2.0 : 1.5,
                          ),
                        ),
                        errorBorder: SmoothOutlineInputBorder(
                          borderRadius: 10.0,
                          smoothing: 0.6,
                          borderSide: const BorderSide(color: AuthConstants.errorColor, width: 1.5),
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
                            style: AppTextStyles.error(),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12), // 12px по макету
                    // Вспомнили пароль
                    SizedBox(
                      height: 17, // Высота контейнера 17px
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Вспомнили пароль?',
                            style: AppTextStyles.secondary(), // 14px
                        ),
                        TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.only(left: 4),
                              minimumSize: Size.zero, // Убираем минимальный размер
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Убираем дополнительные отступы
                            ),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthAuthorizationScreen()));
                          },
                            child: Text(
                            'Вернуться',
                              style: AppTextStyles.secondary( // 14px
                                color: Colors.black, // Черный по макету
                            ),
                          ),
                        ),
                      ],
                    ),
                    ),
                    const SizedBox(height: 30), // 30px по макету
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleGetCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AuthConstants.primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AuthConstants.primaryColor.withValues(alpha: 0.6),
                          shape: const SmoothRoundedRectangleBorder(
                            borderRadius: 12.0, // 12px по макету
                            smoothing: 0.6,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0, // 16px по макету
                            horizontal: 12.0,
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                          height: AuthConstants.loadingIndicatorSize,
                          width: AuthConstants.loadingIndicatorSize,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : Text(
                          'Получить код',
                          style: AppTextStyles.button(), // 16px Medium
                        ),
                      ),
                    ),
                  ],
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