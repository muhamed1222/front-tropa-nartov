import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/smooth_border_radius.dart';
import '../../../config/app_config.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/auth_constants.dart';
import 'package:tropanartov/features/home/presentation/pages/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthRecoveryThreeScreen extends StatefulWidget {
  final String email;
  final String resetToken;

  const AuthRecoveryThreeScreen({super.key, required this.email, required this.resetToken});

  @override
  State<AuthRecoveryThreeScreen> createState() => _AuthRecoveryThreeScreenState();
}

class _AuthRecoveryThreeScreenState extends State<AuthRecoveryThreeScreen> {
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController _newpasswordController = TextEditingController();
  final TextEditingController _newpasswordreturnController = TextEditingController();

  // Валидационные поля
  String? _passwordError;
  String? _confirmPasswordError;

  // Методы валидации
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ошибка: неверный формат пароля';
    }
    if (value.length < 8) {
      return 'Пароль должен содержать минимум 8 символов';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ошибка: неверный формат повторного пароля';
    }
    if (value != _newpasswordController.text) {
      return 'Ошибка: неверный формат повторного пароля';
    }
    return null;
  }

  // Проверка всех полей
  bool _validateAllFields() {
    final passwordError = _validatePassword(_newpasswordController.text);
    final confirmPasswordError = _validateConfirmPassword(_newpasswordreturnController.text);

    setState(() {
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
    });

    return passwordError == null && confirmPasswordError == null;
  }

  Future<void> _handleReset() async {
    if (!_validateAllFields()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': widget.resetToken,
          'password': _newpasswordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        // Показываем сообщение об успехе
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Пароль успешно изменен'),
        //     backgroundColor: Colors.green,
        //   ),
        // );

        // Переходим на главную страницу
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
        );
      } else {
        // final errorData = json.decode(response.body);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(errorData['error'] ?? 'Ошибка сброса пароля'),
        //     backgroundColor: Colors.red,
        //   ),
        // );
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Ошибка подключения: $e'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      isConfirmPasswordVisible = !isConfirmPasswordVisible;
    });
  }

  @override
  void dispose() {
    _newpasswordController.dispose();
    _newpasswordreturnController.dispose();
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
                    // Поле нового пароля с валидацией
                    TextField(
                      controller: _newpasswordController,
                      obscureText: !isPasswordVisible,
                      keyboardType: TextInputType.visiblePassword,
                      style: AppTextStyles.body(),
                      decoration: InputDecoration(
                        hintText: 'Новый пароль',
                        hintStyle: AppTextStyles.hint(color: const Color(0xFF919191)),
                        filled: true,
                        fillColor: AuthConstants.inputBackgroundColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        border: SmoothOutlineInputBorder(
                          borderRadius: 10.0, // 10px по макету
                          smoothing: 0.6,
                          borderSide: BorderSide(
                            color: _passwordError != null ? AuthConstants.errorColor : Colors.transparent,
                            width: _passwordError != null ? 1.5 : 0,
                          ),
                        ),
                        enabledBorder: SmoothOutlineInputBorder(
                          borderRadius: 10.0,
                          smoothing: 0.6,
                          borderSide: BorderSide(
                            color: _passwordError != null ? AuthConstants.errorColor : Colors.transparent,
                            width: _passwordError != null ? 1.5 : 0,
                          ),
                        ),
                        focusedBorder: SmoothOutlineInputBorder(
                          borderRadius: 10.0,
                          smoothing: 0.6,
                          borderSide: BorderSide(
                            color: _passwordError != null ? AuthConstants.errorColor : AuthConstants.primaryColor,
                            width: _passwordError != null ? 2.0 : 1.5,
                          ),
                        ),
                        errorBorder: SmoothOutlineInputBorder(
                          borderRadius: 10.0,
                          smoothing: 0.6,
                          borderSide: const BorderSide(color: AuthConstants.errorColor, width: 1.5),
                        ),
                        suffixIcon: IconButton(
                          onPressed: _togglePasswordVisibility,
                          icon: SvgPicture.asset(
                            isPasswordVisible ? 'assets/view-on.svg' : 'assets/view-off.svg',
                            width: AuthConstants.passwordIconSize,
                            height: isPasswordVisible 
                                ? AuthConstants.passwordIconVisibleHeight 
                                : AuthConstants.passwordIconSize,
                            fit: BoxFit.contain,
                          ),
                          tooltip: isPasswordVisible ? 'Скрыть пароль' : 'Показать пароль',
                        ),
                      ),
                      onChanged: (value) {
                        if (_passwordError != null) {
                          setState(() {
                            _passwordError = _validatePassword(value);
                          });
                        }
                        // Также проверяем подтверждение пароля при изменении основного пароля
                        if (_confirmPasswordError != null) {
                          setState(() {
                            _confirmPasswordError = _validateConfirmPassword(_newpasswordreturnController.text);
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
                            style: AppTextStyles.error(),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10), // 10px по макету

                    // Поле подтверждения пароля с валидацией
                    TextField(
                      controller: _newpasswordreturnController,
                      obscureText: !isConfirmPasswordVisible,
                      keyboardType: TextInputType.visiblePassword,
                      style: AppTextStyles.body(),
                      decoration: InputDecoration(
                        hintText: 'Повторите пароль',
                        hintStyle: AppTextStyles.hint(color: const Color(0xFF919191)),
                        filled: true,
                        fillColor: AuthConstants.inputBackgroundColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        border: SmoothOutlineInputBorder(
                          borderRadius: 10.0, // 10px по макету
                          smoothing: 0.6,
                          borderSide: BorderSide(
                            color: _confirmPasswordError != null ? AuthConstants.errorColor : Colors.transparent,
                            width: _confirmPasswordError != null ? 1.5 : 0,
                          ),
                        ),
                        enabledBorder: SmoothOutlineInputBorder(
                          borderRadius: 10.0,
                          smoothing: 0.6,
                          borderSide: BorderSide(
                            color: _confirmPasswordError != null ? AuthConstants.errorColor : Colors.transparent,
                            width: _confirmPasswordError != null ? 1.5 : 0,
                          ),
                        ),
                        focusedBorder: SmoothOutlineInputBorder(
                          borderRadius: 10.0,
                          smoothing: 0.6,
                          borderSide: BorderSide(
                            color: _confirmPasswordError != null ? AuthConstants.errorColor : AuthConstants.primaryColor,
                            width: _confirmPasswordError != null ? 2.0 : 1.5,
                          ),
                        ),
                        errorBorder: SmoothOutlineInputBorder(
                          borderRadius: 10.0,
                          smoothing: 0.6,
                          borderSide: const BorderSide(color: AuthConstants.errorColor, width: 1.5),
                        ),
                        suffixIcon: IconButton(
                          onPressed: _toggleConfirmPasswordVisibility,
                          icon: SvgPicture.asset(
                            isConfirmPasswordVisible ? 'assets/view-on.svg' : 'assets/view-off.svg',
                            width: AuthConstants.passwordIconSize,
                            height: isConfirmPasswordVisible 
                                ? AuthConstants.passwordIconVisibleHeight 
                                : AuthConstants.passwordIconSize,
                            fit: BoxFit.contain,
                          ),
                          tooltip: isConfirmPasswordVisible ? 'Скрыть пароль' : 'Показать пароль',
                        ),
                      ),
                      onChanged: (value) {
                        if (_confirmPasswordError != null) {
                          setState(() {
                            _confirmPasswordError = _validateConfirmPassword(value);
                          });
                        }
                      },
                    ),
                    if (_confirmPasswordError != null) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Text(
                            _confirmPasswordError!,
                            style: AppTextStyles.error(),
                          ),
                        ),
                      ),
                    ],
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
                          'Обновить и продолжить',
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