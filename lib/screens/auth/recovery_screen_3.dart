import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/auth_constants.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../utils/auth_validator.dart';
import '../../../core/errors/api_error_handler.dart';
import '../../services/api_service_static.dart';
import '../../../services/auth_service.dart';
import '../../../core/widgets/app_snackbar.dart';
import 'package:tropanartov/features/home/presentation/pages/home_page.dart';
import 'login_screen.dart';

class AuthRecoveryThreeScreen extends StatefulWidget {
  final String email;
  final String resetToken;

  const AuthRecoveryThreeScreen({super.key, required this.email, required this.resetToken});

  @override
  State<AuthRecoveryThreeScreen> createState() => _AuthRecoveryThreeScreenState();
}

class _AuthRecoveryThreeScreenState extends State<AuthRecoveryThreeScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _autoValidate = false;

  final TextEditingController _newpasswordController = TextEditingController();
  final TextEditingController _newpasswordreturnController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  // Используем AuthValidator для валидации
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пароль не может быть пустым';
    }
    return AuthValidator.validatePassword(value, minLength: AuthConstants.minPasswordLength);
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Повторный пароль не может быть пустым';
    }
    return AuthValidator.validateConfirmPassword(_newpasswordController.text, value);
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
      final newPassword = _newpasswordController.text.trim();
      
      // 1. Сбрасываем пароль
      await ApiService.resetPassword(widget.resetToken, newPassword);

      // 2. Автоматически входим с новым паролем
      try {
        final loginResponse = await ApiService.login(widget.email, newPassword);
        await AuthService.saveToken(loginResponse.token);
        await AuthService.saveUser(loginResponse.user);

        if (mounted) {
          // Показываем сообщение об успехе
          AppSnackBar.showSuccess(context, 'Пароль успешно изменен');

          // Переходим на главную страницу
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
        }
      } catch (loginError) {
        // Если автоматический вход не удался, все равно показываем успех
        // и перенаправляем на экран входа
        if (mounted) {
          AppSnackBar.showSuccess(
            context, 
            'Пароль успешно изменен. Пожалуйста, войдите с новым паролем.',
          );
          
          // Перенаправляем на экран входа
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const AuthLoginScreen(),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e is ApiException 
            ? e.message 
            : 'Ошибка подключения. Проверьте интернет и попробуйте снова.';
        
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

  @override
  void initState() {
    super.initState();
    // Автофокус на поле нового пароля после загрузки
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _passwordFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _newpasswordController.dispose();
    _newpasswordreturnController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
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
                    // Поле нового пароля с валидацией
                    AppFormField(
                      controller: _newpasswordController,
                      focusNode: _passwordFocusNode,
                      hint: 'Новый пароль',
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.next,
                      validator: _validatePassword,
                      autovalidateMode: _autoValidate 
                          ? AutovalidateMode.onUserInteraction 
                          : AutovalidateMode.disabled,
                      onChanged: (value) {
                        // При изменении пароля также валидируем подтверждение
                        if (_autoValidate && _formKey.currentState != null) {
                          _formKey.currentState!.validate();
                        }
                      },
                      onSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
                      },
                    ),
                    const SizedBox(height: 10), // 10px по макету

                    // Поле подтверждения пароля с валидацией
                    AppFormField(
                      controller: _newpasswordreturnController,
                      focusNode: _confirmPasswordFocusNode,
                      hint: 'Повторите пароль',
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      validator: _validateConfirmPassword,
                      autovalidateMode: _autoValidate 
                          ? AutovalidateMode.onUserInteraction 
                          : AutovalidateMode.disabled,
                      onSubmitted: (_) {
                        if (!_isLoading) {
                          _handleReset();
                        }
                      },
                    ),
                    const SizedBox(height: 30), // 30px по макету
                    Semantics(
                      button: true,
                      enabled: !_isLoading,
                      label: _isLoading ? 'Обновление пароля...' : 'Обновить и продолжить',
                      child: PrimaryButton(
                        text: 'Обновить и продолжить',
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