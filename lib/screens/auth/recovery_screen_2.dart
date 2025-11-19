import 'package:flutter/material.dart';
import '../../../utils/smooth_border_radius.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/auth_constants.dart';
import '../../../config/app_config.dart';
import 'package:tropanartov/screens/auth/recovery_screen_1.dart';
import 'package:tropanartov/screens/auth/recovery_screen_3.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthRecoveryTwoScreen extends StatefulWidget {
  final String email;

  const AuthRecoveryTwoScreen({super.key, required this.email});

  @override
  State<AuthRecoveryTwoScreen> createState() => _AuthRecoveryTwoScreenState();
}

class _AuthRecoveryTwoScreenState extends State<AuthRecoveryTwoScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  // Валидационные поля
  String? _emailError;
  String? _codeError;
  bool _isLoading = false;

  // Методы валидации
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

  String? _validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ошибка: неверный формат кода подтверждения';
    }
    if (value.length != 6) {
      return 'Код должен содержать 6 цифр';
    }
    return null;
  }

  // Проверка всех полей
  bool _validateAllFields() {
    final emailError = _validateEmail(_emailController.text);
    final codeError = _validateCode(_codeController.text);

    setState(() {
      _emailError = emailError;
      _codeError = codeError;
    });

    return emailError == null && codeError == null;
  }

  Future<void> _handleReset() async {
    if (!_validateAllFields()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _codeError = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/verify-reset-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(), // ДОБАВИТЬ email
          'token': _codeController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final email = _emailController.text.trim();
        final code = _codeController.text.trim();

        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AuthRecoveryThreeScreen(
              email: email,
              resetToken: code,
            )
        ));
      } else {
        final errorData = json.decode(response.body);
        setState(() {
          _codeError = errorData['error'] ?? 'Неверный код подтверждения';
        });
      }
    } catch (e) {
      setState(() {
        _codeError = 'Ошибка подключения: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 8), // 8px по макету
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        // Навигация на изменение почты
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthRecoveryOneScreen()));
                      },
                      child: Text(
                        'Изменить почту',
                        style: AppTextStyles.secondary( // 14px
                          color: const Color(0xCC000000), // rgba(0,0,0,0.8) по макету
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // 20px по макету между секциями

                    // Поле кода подтверждения с валидацией
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.body(),
                      decoration: InputDecoration(
                        hintText: 'Код подтверждения',
                        hintStyle: AppTextStyles.hint(),
                        filled: true,
                        fillColor: AuthConstants.inputBackgroundColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        border: SmoothOutlineInputBorder(
                          borderRadius: 10.0, // 10px по макету
                          smoothing: 0.6,
                          borderSide: BorderSide(
                            color: _codeError != null ? AuthConstants.errorColor : Colors.transparent,
                            width: _codeError != null ? 1.5 : 0,
                          ),
                        ),
                        enabledBorder: SmoothOutlineInputBorder(
                          borderRadius: 10.0,
                          smoothing: 0.6,
                          borderSide: BorderSide(
                            color: _codeError != null ? AuthConstants.errorColor : Colors.transparent,
                            width: _codeError != null ? 1.5 : 0,
                          ),
                        ),
                        focusedBorder: SmoothOutlineInputBorder(
                          borderRadius: 10.0,
                          smoothing: 0.6,
                          borderSide: BorderSide(
                            color: _codeError != null ? AuthConstants.errorColor : AuthConstants.primaryColor,
                            width: _codeError != null ? 2.0 : 1.5,
                          ),
                        ),
                        errorBorder: SmoothOutlineInputBorder(
                          borderRadius: 10.0,
                          smoothing: 0.6,
                          borderSide: const BorderSide(color: AuthConstants.errorColor, width: 1.5),
                        ),
                      ),
                      onChanged: (value) {
                        if (_codeError != null) {
                          setState(() {
                            _codeError = _validateCode(value);
                          });
                        }
                      },
                    ),
                    if (_codeError != null) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Text(
                            _codeError!,
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
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthRecoveryOneScreen()));
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
                        onPressed: _isLoading ? null : _handleReset,
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
                          'Сбросить',
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