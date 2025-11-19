import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/auth_constants.dart';
import '../../../config/app_config.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../utils/auth_validator.dart';
import '../../../core/errors/api_error_handler.dart';
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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _codeFocusNode = FocusNode();
  bool _isLoading = false;
  bool _autoValidate = false;

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
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/verify-reset-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(),
          'token': _codeController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final email = _emailController.text.trim();
        final code = _codeController.text.trim();

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AuthRecoveryThreeScreen(
                email: email,
                resetToken: code,
              ),
            ),
          );
        }
      } else {
        final errorData = json.decode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorData['error'] ?? 'Неверный код подтверждения'),
              backgroundColor: AuthConstants.errorColor,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e is ApiException 
            ? e.message 
            : 'Ошибка подключения. Проверьте интернет и попробуйте снова.';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AuthConstants.errorColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
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
    _emailController.text = widget.email;
    // Автофокус на поле кода после загрузки
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _codeFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _emailFocusNode.dispose();
    _codeFocusNode.dispose();
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
                        // Навигация на изменение почты
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AuthRecoveryOneScreen()),
                        );
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