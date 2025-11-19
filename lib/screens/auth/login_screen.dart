import 'package:flutter/material.dart';
import 'package:tropanartov/features/home/presentation/pages/home_page.dart';
import 'package:tropanartov/screens/auth/recovery_screen_1.dart';
import 'package:tropanartov/screens/auth/registration_screen.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../core/errors/api_error_handler.dart';
import '../../../core/constants/auth_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_design_system.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../utils/auth_validator.dart';

class AuthAuthorizationScreen extends StatefulWidget {
  const AuthAuthorizationScreen({super.key});

  @override
  State<AuthAuthorizationScreen> createState() => _AuthLoginScreenState();
}

class _AuthLoginScreenState extends State<AuthAuthorizationScreen> {
  bool isLoading = false;
  bool _autoValidate = false;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadLastEmail();
    // Автофокус на поле email после загрузки
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _emailFocusNode.requestFocus();
      }
    });
  }

  Future<void> _loadLastEmail() async {
    final lastEmail = await AuthService.getLastEmail();
    if (lastEmail != null && mounted) {
      _emailController.text = lastEmail;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }


  // Используем AuthValidator для валидации
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email не может быть пустым';
    }
    return AuthValidator.validateEmail(value);
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пароль не может быть пустым';
    }
    return AuthValidator.validatePassword(value, minLength: AuthConstants.minPasswordLength);
  }

  void _handleLogin() async {
    // Включаем авто-валидацию
    setState(() {
      _autoValidate = true;
    });

    // Валидация формы
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Вызов API
      final response = await ApiService.login(email, password);

      // Сохраняем токен и пользователя
      await AuthService.saveToken(response.token);
      await AuthService.saveUser(response.user);
      
      // Сохраняем email для автозаполнения
      await AuthService.saveLastEmail(email);

      // Переход только при УСПЕШНОЙ авторизации
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      // Ошибка авторизации - показываем пользователю
      if (mounted) {
        final errorMessage = e is ApiException ? e.message : 'Ошибка входа. Проверьте данные и попробуйте снова.';
        
        // Показываем диалог для критичных ошибок или SnackBar для обычных
        if (e is ApiException && (e.statusCode == 401 || e.statusCode == 403)) {
          _showErrorDialog(errorMessage);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AuthConstants.errorColor,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка входа'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthConstants.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AuthConstants.paddingHorizontal),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Вход',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleLarge(),
                    ),
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
                          textInputAction: TextInputAction.next,
                          validator: _validateEmail,
                          autovalidateMode: _autoValidate 
                              ? AutovalidateMode.onUserInteraction 
                              : AutovalidateMode.disabled,
                          onSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_passwordFocusNode);
                          },
                        ),
                        const SizedBox(height: 10), // 10px по макету

                        // Поле пароля с валидацией
                        AppFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          hint: 'Пароль',
                          obscureText: true,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          validator: _validatePassword,
                          autovalidateMode: _autoValidate 
                              ? AutovalidateMode.onUserInteraction 
                              : AutovalidateMode.disabled,
                          onSubmitted: (_) {
                            if (!isLoading) {
                              _handleLogin();
                            }
                          },
                        ),
                        const SizedBox(height: 12), // 12px по макету

                        // Забыли пароль
                        SizedBox(
                          height: 17, // Высота контейнера 17px по требованию
                          child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Забыли пароль?',
                                style: AppTextStyles.secondary(), // 14px
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.only(left: 4),
                                  minimumSize: Size.zero, // Убираем минимальный размер
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Убираем дополнительные отступы
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const AuthRecoveryOneScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Восстановить',
                                  style: AppTextStyles.secondary( // 14px
                                    color: AppDesignSystem.primaryColor, // Акцентный цвет #24A79C
                                  ),
                                ),
                              ),
                            ],
                            ),
                        ),
                        const SizedBox(height: 30), // 30px по макету

                        // Кнопка входа
                        Semantics(
                          button: true,
                          enabled: !isLoading,
                          label: isLoading ? 'Выполняется вход...' : 'Войти в аккаунт',
                          child: PrimaryButton(
                            text: 'Войти в аккаунт',
                            onPressed: isLoading ? null : _handleLogin,
                            isDisabled: isLoading,
                            isLoading: isLoading,
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
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AuthConstants.paddingHorizontal),
          child: SizedBox(
            height: 17, // Высота контейнера 17px
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Нет аккаунта?',
                  style: AppTextStyles.secondary(), // 14px
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.only(left: 4),
                    minimumSize: Size.zero, // Убираем минимальный размер
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Убираем дополнительные отступы
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AuthRegistrationScreen(),
                    ),
                  );
                },
                child: Text(
                  'Зарегистрироваться',
                    style: AppTextStyles.secondary( // 14px вместо link()
                      color: AppDesignSystem.primaryColor, // Акцентный цвет #24A79C
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
