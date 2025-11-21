import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/auth_constants.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../utils/auth_validator.dart';
import '../../../core/errors/api_error_handler.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/di/injection_container.dart' as di;
import '../../../services/strapi_service.dart';
import 'package:tropanartov/screens/auth/recovery_screen_2.dart';
import 'login_screen.dart';

class AuthRecoveryOneScreen extends StatefulWidget {
  const AuthRecoveryOneScreen({super.key});

  @override
  State<AuthRecoveryOneScreen> createState() => _AuthRecoveryOneScreenState();
}

class _AuthRecoveryOneScreenState extends State<AuthRecoveryOneScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  bool _isLoading = false;
  bool _autoValidate = false;

  // Используем AuthValidator для валидации
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email не может быть пустым';
    }
    return AuthValidator.validateEmail(value);
  }

  Future<void> _handleGetCode() async {
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
      final email = _emailController.text.trim();
      // ✅ МИГРАЦИЯ: Используем StrapiService вместо Go API
      final strapiService = di.sl<StrapiService>();
      await strapiService.forgotPassword(email);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AuthRecoveryTwoScreen(email: email),
          ),
        );
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
    // Автофокус на поле email после загрузки
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _emailFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    try {
      _emailController.dispose();
      _emailFocusNode.dispose();
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
                  children: [
                    // Поле email с валидацией
                    AppFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      hint: 'Почта',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      validator: _validateEmail,
                      autovalidateMode: _autoValidate 
                          ? AutovalidateMode.onUserInteraction 
                          : AutovalidateMode.disabled,
                      onSubmitted: (_) {
                        if (!_isLoading) {
                          _handleGetCode();
                        }
                      },
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
                              minimumSize: Size.zero, // Убираем минимальный размер
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Убираем дополнительные отступы
                            ),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthLoginScreen()));
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
                      label: _isLoading ? 'Отправка кода...' : 'Получить код',
                      child: PrimaryButton(
                        text: 'Получить код',
                        onPressed: _isLoading ? null : _handleGetCode,
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