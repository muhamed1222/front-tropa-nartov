import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/auth_constants.dart';
import '../../../core/constants/app_design_system.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../utils/auth_validator.dart';
import '../../../core/errors/api_error_handler.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/di/injection_container.dart' as di;
import '../../../services/strapi_service.dart';
import 'package:tropanartov/screens/auth/recovery_screen_1.dart';
import 'package:tropanartov/screens/auth/recovery_screen_3.dart';

class AuthRecoveryTwoScreen extends StatefulWidget {
  final String email;

  const AuthRecoveryTwoScreen({super.key, required this.email});

  @override
  State<AuthRecoveryTwoScreen> createState() => _AuthRecoveryTwoScreenState();
}

class _AuthRecoveryTwoScreenState extends State<AuthRecoveryTwoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _codeFocusNode = FocusNode();
  bool _isLoading = false;
  bool _isResendingCode = false;
  bool _autoValidate = false;
  
  // Таймер для повторной отправки кода
  int _resendTimerSeconds = 60;
  Timer? _resendTimer;

  // Используем AuthValidator для валидации
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email не может быть пустым';
    }
    return AuthValidator.validateEmail(value);
  }

  String? _validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Код не может быть пустым';
    }
    return AuthValidator.validateCode(value, requiredLength: 6);
  }

  Future<void> _handleReset() async {
    // Включаем авто-валидацию
    setState(() {
      _autoValidate = true;
    });

    // Валидация формы
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final code = _codeController.text.trim();
      final email = _emailController.text.trim();
      
      // ✅ МИГРАЦИЯ: Strapi не имеет отдельного endpoint для проверки кода
      // Код проверяется при reset-password, поэтому сразу переходим к экрану сброса пароля
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => AuthRecoveryThreeScreen(
              email: email,
              resetToken: code,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage;
        if (e is ApiException) {
          // Улучшенные сообщения об ошибках
          if (e.message.toLowerCase().contains('неверный') || 
              e.message.toLowerCase().contains('invalid') ||
              e.message.toLowerCase().contains('код')) {
            errorMessage = 'Неверный код подтверждения. Проверьте код и попробуйте снова.';
          } else if (e.message.toLowerCase().contains('истек') || 
                     e.message.toLowerCase().contains('expired')) {
            errorMessage = 'Код подтверждения истек. Запросите новый код.';
          } else {
            errorMessage = e.message;
          }
        } else {
          errorMessage = 'Ошибка подключения. Проверьте интернет и попробуйте снова.';
        }
        
        AppSnackBar.showError(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Отправка кода повторно
  Future<void> _handleResendCode() async {
    if (_isResendingCode || _resendTimerSeconds > 0) {
      return;
    }

    setState(() {
      _isResendingCode = true;
    });

    try {
      final email = _emailController.text.trim();
      // ✅ МИГРАЦИЯ: Используем StrapiService вместо Go API
      final strapiService = di.sl<StrapiService>();
      await strapiService.forgotPassword(email);

      if (mounted) {
        AppSnackBar.showSuccess(context, 'Код подтверждения отправлен повторно');
        
        // Запускаем таймер обратного отсчета
        _startResendTimer();
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e is ApiException 
            ? e.message 
            : 'Не удалось отправить код. Попробуйте снова.';
        
        AppSnackBar.showError(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResendingCode = false;
        });
      }
    }
  }

  /// Запуск таймера обратного отсчета для повторной отправки
  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _resendTimerSeconds = 60;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendTimerSeconds > 0) {
            _resendTimerSeconds--;
          } else {
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    // Запускаем таймер сразу при открытии экрана
    _startResendTimer();
    // Автофокус на поле кода после загрузки
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _codeFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    try {
      _resendTimer?.cancel();
      _emailController.dispose();
      _codeController.dispose();
      _emailFocusNode.dispose();
      _codeFocusNode.dispose();
    } catch (e) {
      // Игнорируем ошибки при dispose
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthConstants.backgroundColor,
      body: SafeArea(
        child: Center(
        child: Padding(
          padding: EdgeInsets.all(AuthConstants.paddingHorizontal),
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
                const SizedBox(height: AuthConstants.spacingMedium),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Поле email с валидацией (readOnly, так как уже заполнено)
                    AppFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      hint: 'Почта',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      readOnly: true,
                      validator: _validateEmail,
                      autovalidateMode: _autoValidate 
                          ? AutovalidateMode.onUserInteraction 
                          : AutovalidateMode.disabled,
                      onSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_codeFocusNode);
                      },
                    ),
                    const SizedBox(height: 8), // 8px по макету
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        // Навигация на изменение почты (pop к первому экрану)
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Изменить почту',
                        style: AppTextStyles.secondary(
                          color: const Color(0xCC000000), // rgba(0,0,0,0.8) по макету
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // 20px по макету между секциями

                    // Поле кода подтверждения с валидацией
                    AppFormField(
                      controller: _codeController,
                      focusNode: _codeFocusNode,
                      hint: 'Код подтверждения',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      validator: _validateCode,
                      autovalidateMode: _autoValidate 
                          ? AutovalidateMode.onUserInteraction 
                          : AutovalidateMode.disabled,
                      onSubmitted: (_) {
                        if (!_isLoading) {
                          _handleReset();
                        }
                      },
                    ),
                    const SizedBox(height: 12), // 12px по макету
                    // Кнопка повторной отправки кода или таймер
                    if (_resendTimerSeconds > 0)
                      Center(
                        child: Text(
                          'Отправить код повторно можно через $_resendTimerSeconds сек.',
                          style: AppTextStyles.secondary(
                            color: AppDesignSystem.textColorSecondary.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      Center(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: _isResendingCode ? null : _handleResendCode,
                          child: Text(
                            _isResendingCode ? 'Отправка...' : 'Отправить код повторно',
                            style: AppTextStyles.secondary(
                              color: _isResendingCode 
                                  ? AppDesignSystem.textColorSecondary.withValues(alpha: 0.5)
                                  : AuthConstants.primaryColor,
                            ),
                          ),
                        ),
                      ),
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
                    Semantics(
                      button: true,
                      enabled: !_isLoading,
                      label: _isLoading ? 'Проверка кода...' : 'Сбросить',
                      child: PrimaryButton(
                        text: 'Сбросить',
                        onPressed: _isLoading ? null : _handleReset,
                        isDisabled: _isLoading,
                        isLoading: _isLoading,
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