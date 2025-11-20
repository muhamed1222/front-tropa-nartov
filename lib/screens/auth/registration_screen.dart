import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/home/presentation/pages/home_page.dart';
import 'login_screen.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_design_system.dart';
import '../../../core/constants/auth_constants.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../utils/auth_validator.dart';
import '../../../core/errors/api_error_handler.dart';

class AuthRegistrationScreen extends StatefulWidget {
  const AuthRegistrationScreen({super.key});

  @override
  State<AuthRegistrationScreen> createState() => _AuthRegistrationScreenState();
}

class _AuthRegistrationScreenState extends State<AuthRegistrationScreen> {
  bool isAgree = false;
  bool isLoading = false;
  bool _autoValidate = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  static final Uri _termsUrl = Uri.parse('https://wise-mission-436584.framer.app/terms-and-conditions');
  static final Uri _privacyUrl = Uri.parse('https://wise-mission-436584.framer.app/privacy-policy');

  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = _handleTermsTap;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _handlePrivacyTap;
    
    // Добавляем слушатель для перевалидации поля подтверждения пароля
    _passwordController.addListener(() {
      if (_autoValidate && _confirmPasswordController.text.isNotEmpty) {
        _formKey.currentState?.validate();
      }
    });
    
    // Автофокус на поле имени после загрузки
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _nameFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
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
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  // Используем AuthValidator для валидации
  String? _validateName(String? value) {
    // Для пустых полей во время ввода не показываем ошибку
    if (value == null || value.isEmpty) {
      return _autoValidate ? 'Имя не может быть пустым' : null;
    }
    return AuthValidator.validateName(value, minLength: 2);
  }

  String? _validateEmail(String? value) {
    // Для пустых полей во время ввода не показываем ошибку
    if (value == null || value.isEmpty) {
      return _autoValidate ? 'Email не может быть пустым' : null;
    }
    return AuthValidator.validateEmail(value);
  }

  String? _validatePassword(String? value) {
    // Для пустых полей во время ввода не показываем ошибку
    if (value == null || value.isEmpty) {
      return _autoValidate ? 'Пароль не может быть пустым' : null;
    }
    return AuthValidator.validatePassword(value, minLength: AuthConstants.minPasswordLength);
  }

  String? _validateConfirmPassword(String? value) {
    // Для пустых полей во время ввода не показываем ошибку
    if (value == null || value.isEmpty) {
      return _autoValidate ? 'Подтвердите пароль' : null;
    }
    if (value != _passwordController.text) {
      return 'Пароли не совпадают';
    }
    return null;
  }

  void _handleCreateAccount() async {
    // Проверка на согласие
    if (!isAgree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Необходимо согласиться с условиями использования'),
          backgroundColor: AuthConstants.errorColor,
        ),
      );
      return;
    }

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
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Регистрация
      await ApiService.register(name, email, password);

      // Автоматический вход после регистрации
      try {
        final loginResponse = await ApiService.login(email, password);

        // Сохраняем токен и пользователя
        await AuthService.saveToken(loginResponse.token);
        await AuthService.saveUser(loginResponse.user);
        await AuthService.saveLastEmail(email);

        // Переход на главный экран
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      } catch (loginError) {
        // Если вход не удался, показываем сообщение и переходим на экран входа
        if (mounted) {
          final errorMessage = loginError is ApiException 
              ? loginError.message 
              : 'Регистрация успешна. Пожалуйста, войдите в аккаунт.';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AuthConstants.errorColor,
            ),
          );
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthLoginScreen()),
          );
        }
      }
    } catch (e) {
      // Ошибка регистрации
      if (mounted) {
        final errorMessage = e is ApiException 
            ? e.message 
            : 'Ошибка регистрации. Проверьте данные и попробуйте снова.';
        
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
          isLoading = false;
        });
      }
    }
  }

  // Обработчик для кнопки "Войти"
  void _handleLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthLoginScreen()),
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
                      'Регистрация',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleLarge(),
                    ),
                  ),
                  const SizedBox(height: AuthConstants.spacingMedium),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Поле имени
                        AppFormField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          hint: 'Имя',
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          validator: _validateName,
                          autovalidateMode: _autoValidate 
                              ? AutovalidateMode.onUserInteraction 
                              : AutovalidateMode.disabled,
                          onSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_emailFocusNode);
                          },
                        ),
                        const SizedBox(height: 10),

                        // Поле email
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
                        const SizedBox(height: 10),

                        // Поле пароля
                        AppFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          hint: 'Пароль',
                          obscureText: true,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.next,
                          validator: _validatePassword,
                          autovalidateMode: _autoValidate 
                              ? AutovalidateMode.onUserInteraction 
                              : AutovalidateMode.disabled,
                          onSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
                          },
                        ),
                        const SizedBox(height: 10),

                        // Поле подтверждения пароля
                        AppFormField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocusNode,
                          hint: 'Подтвердите пароль',
                          obscureText: true,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          validator: _validateConfirmPassword,
                          autovalidateMode: _autoValidate 
                              ? AutovalidateMode.onUserInteraction 
                              : AutovalidateMode.disabled,
                          onSubmitted: (_) {
                            if (!isLoading && isAgree) {
                              _handleCreateAccount();
                            }
                          },
                        ),
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
                                  activeColor: AuthConstants.primaryColor,
                                  value: isAgree,
                                  side: const BorderSide(color: Colors.transparent, width: 0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  fillColor: WidgetStateProperty.resolveWith((states) {
                                    if (!states.contains(WidgetState.selected)) {
                                      return AuthConstants.inputBackgroundColor;
                                    }
                                    return AuthConstants.primaryColor;
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
                        Semantics(
                          button: true,
                          enabled: !isLoading && isAgree,
                          label: isLoading ? 'Создание аккаунта...' : 'Создать аккаунт',
                          child: PrimaryButton(
                            text: 'Создать аккаунт',
                            onPressed: isLoading ? null : _handleCreateAccount,
                            isDisabled: isLoading || !isAgree,
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