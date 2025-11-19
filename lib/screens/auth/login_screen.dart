import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tropanartov/features/home/presentation/pages/home_page.dart';
import 'package:tropanartov/screens/auth/recovery_screen_1.dart';
import 'package:tropanartov/screens/auth/registration_screen.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../core/errors/api_error_handler.dart';
import '../../../utils/smooth_border_radius.dart';
import '../../../core/constants/auth_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_design_system.dart';

class AuthAuthorizationScreen extends StatefulWidget {
  const AuthAuthorizationScreen({super.key});

  @override
  State<AuthAuthorizationScreen> createState() => _AuthLoginScreenState();
}

class _AuthLoginScreenState extends State<AuthAuthorizationScreen> {
  bool isPasswordVisible = false;
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

  void _togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  // Методы валидации
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email не может быть пустым';
    }
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return 'Email не может быть пустым';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmedValue)) {
      return 'Неверный формат email адреса';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пароль не может быть пустым';
    }
    if (value.length < AuthConstants.minPasswordLength) {
      return 'Пароль должен содержать минимум ${AuthConstants.minPasswordLength} символов';
    }
    if (value.length > AuthConstants.maxPasswordLength) {
      return 'Пароль не должен превышать ${AuthConstants.maxPasswordLength} символов';
    }
    return null;
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

  // Метод для создания стиля поля ввода
  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? suffixIcon,
    bool isPasswordField = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: isPasswordField
          ? AppTextStyles.hint(color: const Color(0xFF919191)) // #919191 для пароля по макету
          : AppTextStyles.hint(), // rgba(0,0,0,0.4) для почты
      filled: true,
      fillColor: AuthConstants.inputBackgroundColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14.0, // Точно по макету
        vertical: 14.0,   // Высота поля 47px при таком padding
      ),
      border: const SmoothOutlineInputBorder(
        borderRadius: 10.0, // 10px по макету
        smoothing: 0.6,
        borderSide: BorderSide.none,
      ),
      enabledBorder: const SmoothOutlineInputBorder(
        borderRadius: 10.0,
        smoothing: 0.6,
        borderSide: BorderSide.none,
      ),
      focusedBorder: SmoothOutlineInputBorder(
        borderRadius: 10.0,
        smoothing: 0.6,
        borderSide: BorderSide(
          color: AuthConstants.primaryColor,
          width: AuthConstants.borderWidth,
        ),
      ),
      errorBorder: const SmoothOutlineInputBorder(
        borderRadius: 10.0,
        smoothing: 0.6,
        borderSide: BorderSide(
          color: AuthConstants.errorColor,
          width: AuthConstants.borderWidth,
        ),
      ),
      focusedErrorBorder: const SmoothOutlineInputBorder(
        borderRadius: 10.0,
        smoothing: 0.6,
        borderSide: BorderSide(
          color: AuthConstants.errorColor,
          width: AuthConstants.borderWidthFocused,
        ),
      ),
      suffixIcon: suffixIcon,
      errorStyle: AppTextStyles.error(),
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
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofocus: true,
                          autocorrect: false,
                          enableSuggestions: false,
                          style: AppTextStyles.body(),
                          decoration: _buildInputDecoration(
                            hintText: 'Почта',
                            isPasswordField: false,
                          ),
                          validator: _validateEmail,
                          autovalidateMode: _autoValidate 
                              ? AutovalidateMode.onUserInteraction 
                              : AutovalidateMode.disabled,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_passwordFocusNode);
                          },
                        ),
                        const SizedBox(height: 10), // 10px по макету

                        // Поле пароля с валидацией
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: !isPasswordVisible,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          enableSuggestions: false,
                          style: AppTextStyles.body(),
                          decoration: _buildInputDecoration(
                            hintText: 'Пароль',
                            isPasswordField: true, // Используем цвет #919191
                            suffixIcon: Semantics(
                              label: isPasswordVisible ? 'Скрыть пароль' : 'Показать пароль',
                              button: true,
                              child: IconButton(
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
                          ),
                          validator: _validatePassword,
                          autovalidateMode: _autoValidate 
                              ? AutovalidateMode.onUserInteraction 
                              : AutovalidateMode.disabled,
                          onFieldSubmitted: (_) {
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
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleLogin,
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
                              child: isLoading
                                  ? SizedBox(
                                      height: AuthConstants.loadingIndicatorSize,
                                      width: AuthConstants.loadingIndicatorSize,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Войти в аккаунт',
                                      style: AppTextStyles.button(),
                                    ),
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
