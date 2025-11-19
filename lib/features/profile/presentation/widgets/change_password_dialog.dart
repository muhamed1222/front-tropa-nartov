import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../services/auth_service.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/widgets.dart';
import 'edit_profile_action_bar.dart';

/// Функция-хелпер для открытия диалога смены пароля
Future<void> showChangePasswordDialog(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppDesignSystem.textColorPrimary.withValues(alpha: 0.5),
    builder: (context) => const ChangePasswordDialog(),
  );
}

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final FocusNode _oldPasswordFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  
  bool _showNewPasswordFields = false;
  bool _isLoading = false;
  bool _isVerifying = false;
  bool _hasInteractedWithOldPassword = false;
  bool _hasInteractedWithNewPassword = false;
  bool _hasInteractedWithConfirmPassword = false;

  // Валидационные поля
  String? _oldPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  // Debounce таймеры
  Timer? _oldPasswordDebounceTimer;
  Timer? _newPasswordDebounceTimer;
  Timer? _confirmPasswordDebounceTimer;

  // Анимация для появления новых полей
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Добавляем слушатели для валидации при потере фокуса
    _oldPasswordFocusNode.addListener(() {
      if (!_oldPasswordFocusNode.hasFocus && _hasInteractedWithOldPassword) {
        _validateOldPasswordOnBlur();
      }
    });
    _newPasswordFocusNode.addListener(() {
      if (!_newPasswordFocusNode.hasFocus && _hasInteractedWithNewPassword) {
        _validateNewPasswordOnBlur();
      }
    });
    _confirmPasswordFocusNode.addListener(() {
      if (!_confirmPasswordFocusNode.hasFocus && _hasInteractedWithConfirmPassword) {
        _validateConfirmPasswordOnBlur();
      }
    });
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _oldPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _oldPasswordDebounceTimer?.cancel();
    _newPasswordDebounceTimer?.cancel();
    _confirmPasswordDebounceTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }


  // Методы валидации
  String? _validateOldPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите старый пароль';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите новый пароль';
    }
    if (value.length < 8) {
      return 'Пароль должен содержать минимум 8 символов';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Повторите новый пароль';
    }
    if (value != _newPasswordController.text) {
      return 'Пароли не совпадают';
    }
    return null;
  }

  // Валидация при потере фокуса
  void _validateOldPasswordOnBlur() {
    setState(() {
      _oldPasswordError = _validateOldPassword(_oldPasswordController.text);
    });
  }

  void _validateNewPasswordOnBlur() {
    setState(() {
      _newPasswordError = _validateNewPassword(_newPasswordController.text);
      // Также проверяем подтверждение пароля
      if (_hasInteractedWithConfirmPassword) {
        _confirmPasswordError = _validateConfirmPassword(_confirmPasswordController.text);
      }
    });
  }

  void _validateConfirmPasswordOnBlur() {
    setState(() {
      _confirmPasswordError = _validateConfirmPassword(_confirmPasswordController.text);
    });
  }

  // Debounced валидация для старого пароля
  void _onOldPasswordChanged(String value) {
    _hasInteractedWithOldPassword = true;
    _oldPasswordDebounceTimer?.cancel();
    if (_oldPasswordError != null) {
      _oldPasswordDebounceTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _oldPasswordError = _validateOldPassword(value);
          });
        }
      });
    }
  }

  // Debounced валидация для нового пароля
  void _onNewPasswordChanged(String value) {
    _hasInteractedWithNewPassword = true;
    _newPasswordDebounceTimer?.cancel();
    if (_newPasswordError != null) {
      _newPasswordDebounceTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _newPasswordError = _validateNewPassword(value);
            // Также проверяем подтверждение пароля при изменении нового
            if (_confirmPasswordError != null && value.isNotEmpty) {
              _confirmPasswordError = _validateConfirmPassword(_confirmPasswordController.text);
            }
          });
        }
      });
    }
  }

  // Debounced валидация для подтверждения пароля
  void _onConfirmPasswordChanged(String value) {
    _hasInteractedWithConfirmPassword = true;
    _confirmPasswordDebounceTimer?.cancel();
    if (_confirmPasswordError != null) {
      _confirmPasswordDebounceTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _confirmPasswordError = _validateConfirmPassword(value);
          });
        }
      });
    }
  }

  Future<void> _verifyOldPassword() async {
    final error = _validateOldPassword(_oldPasswordController.text);
    setState(() {
      _oldPasswordError = error;
    });

    if (error != null) return;

    setState(() {
      _isVerifying = true;
      _oldPasswordError = null; // Очищаем ошибку при начале проверки
    });

    try {
      // Проверяем старый пароль через логин
      // Примечание: verifyPassword использует login endpoint для проверки
      // без сохранения нового токена
      final isValid = await AuthService.verifyPassword(_oldPasswordController.text.trim());
      
      if (!isValid) {
        if (mounted) {
          setState(() {
            _oldPasswordError = 'Неверный пароль';
            _isVerifying = false;
          });
        }
        return;
      }

      // Пароль верный - показываем поля для нового пароля
      if (mounted) {
        setState(() {
          _showNewPasswordFields = true;
          _isVerifying = false;
        });

        // Запускаем анимацию появления новых полей
        _animationController.forward();
        
        // Автоматически фокусируемся на поле нового пароля
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _newPasswordFocusNode.requestFocus();
          }
        });
      }
    } catch (e, stackTrace) {
      // Обработка неожиданных ошибок (хотя verifyPassword не должен их бросать)
      AppLogger.error('Verify old password - unexpected error', e, stackTrace);
      if (mounted) {
        String errorMessage = 'Ошибка при проверке пароля';
        
        // Улучшенная обработка ошибок
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('timeout')) {
          errorMessage = 'Превышено время ожидания. Проверьте подключение к интернету';
        } else if (errorString.contains('network') || errorString.contains('connection')) {
          errorMessage = 'Ошибка сети. Проверьте подключение к интернету';
        } else if (errorString.contains('пользователь не найден') || errorString.contains('user not found')) {
          errorMessage = 'Ошибка: пользователь не найден';
        } else {
          // Для других ошибок показываем общее сообщение
          errorMessage = 'Неверный пароль';
        }
        
        setState(() {
          _oldPasswordError = errorMessage;
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _saveNewPassword() async {
    final newPasswordError = _validateNewPassword(_newPasswordController.text);
    final confirmPasswordError = _validateConfirmPassword(
        _confirmPasswordController.text);

    setState(() {
      _newPasswordError = newPasswordError;
      _confirmPasswordError = confirmPasswordError;
    });

    if (newPasswordError != null || confirmPasswordError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.changePassword(
        _oldPasswordController.text.trim(),
        _newPasswordController.text.trim(),
      );
      
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackBar.showSuccess(context, 'Пароль успешно изменен');
    } catch (e, stackTrace) {
      AppLogger.error('Change password', e, stackTrace);
      if (!mounted) return;
      
      String errorMessage = 'Ошибка при изменении пароля';
      String? oldPasswordError;
      
      // Улучшенная обработка ошибок
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('timeout')) {
        errorMessage = 'Превышено время ожидания. Проверьте подключение к интернету';
      } else if (errorString.contains('network') || errorString.contains('connection')) {
        errorMessage = 'Ошибка сети. Проверьте подключение к интернету';
      } else if (errorString.contains('400') || errorString.contains('bad request')) {
        errorMessage = 'Неверный формат данных';
      } else if (errorString.contains('401') || errorString.contains('unauthorized')) {
        errorMessage = 'Сессия истекла. Войдите заново';
      } else if (errorString.contains('старый') || errorString.contains('old password') || 
                 errorString.contains('неверный пароль') || errorString.contains('invalid password')) {
        // Если ошибка связана со старым паролем, показываем ошибку в поле старого пароля
        oldPasswordError = 'Неверный старый пароль';
        errorMessage = 'Неверный старый пароль';
      } else if (errorString.contains('отличаться') || errorString.contains('different')) {
        errorMessage = 'Новый пароль должен отличаться от старого';
      }
      
      // Если ошибка связана со старым паролем, показываем её в поле
      if (oldPasswordError != null) {
        setState(() {
          _oldPasswordError = oldPasswordError;
        });
      }
      
      AppSnackBar.showError(context, errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 1.0,
      minChildSize: 0.2,
      maxChildSize: 1.0,
      expand: false,
      snap: true,
      snapSizes: const [1.0],
      builder: (BuildContext context, ScrollController scrollController) {
        return ClipPath(
          clipper: SmoothBorderClipper(radius: AppDesignSystem.borderRadiusLarge),
          child: Container(
            decoration: const BoxDecoration(
              color: AppDesignSystem.whiteColor,
            ),
            child: Column(
              children: [
                // Индикатор перетаскивания на самом верху с отступом 8px
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Semantics(
                    label: 'Перетащите для закрытия',
                    child: DragIndicator(
                      color: AppDesignSystem.handleBarColor,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      left: AppDesignSystem.paddingHorizontal,
                      right: AppDesignSystem.paddingHorizontal,
                      bottom: AppDesignSystem.spacingXXLarge,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: AppDesignSystem.spacingHandleToTitle),
                        
                        // Заголовок
                        Semantics(
                          header: true,
                          child: Center(
                            child: Text(
                              'Смена пароля',
                              style: AppTextStyles.title(
                                fontWeight: AppDesignSystem.fontWeightSemiBold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppDesignSystem.spacingTitleToInput),
                        
                        // Поле "Старый пароль"
                        AppInputField(
                          controller: _oldPasswordController,
                          hint: 'Старый пароль',
                          errorText: _oldPasswordError,
                          obscureText: true,
                          enabled: !_isVerifying && !_showNewPasswordFields,
                          focusNode: _oldPasswordFocusNode,
                          onChanged: _onOldPasswordChanged,
                          onSubmitted: (_) => _validateOldPasswordOnBlur(),
                          suffixIcon: _isVerifying
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppDesignSystem.primaryColor),
                                  ),
                                )
                              : null,
                        ),
                        SizedBox(height: AppDesignSystem.spacingBetweenInputs),
                        
                        // Текст подсказки
                        Semantics(
                          child: Text(
                            'Чтобы обезопасить ваши личные данные, сначала введите старый пароль. После этого вы сможете сменить его.',
                            style: AppTextStyles.small(
                              color: AppDesignSystem.textColorSecondary,
                            ),
                          ),
                        ),

                        // Новые поля пароля с анимацией
                        if (_showNewPasswordFields)
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: AppDesignSystem.spacingXXLarge),

                                  // Поле "Новый пароль"
                                  AppInputField(
                                    controller: _newPasswordController,
                                    hint: 'Новый пароль',
                                    errorText: _newPasswordError,
                                    obscureText: true,
                                    enabled: !_isLoading,
                                    focusNode: _newPasswordFocusNode,
                                    onChanged: _onNewPasswordChanged,
                                    onSubmitted: (_) => _validateNewPasswordOnBlur(),
                                  ),
                                  SizedBox(height: AppDesignSystem.spacingInputToHint),

                                  // Поле "Повторите пароль"
                                  AppInputField(
                                    controller: _confirmPasswordController,
                                    hint: 'Повторите пароль',
                                    errorText: _confirmPasswordError,
                                    obscureText: true,
                                    enabled: !_isLoading,
                                    focusNode: _confirmPasswordFocusNode,
                                    onChanged: _onConfirmPasswordChanged,
                                    onSubmitted: (_) => _validateConfirmPasswordOnBlur(),
                                  ),
                                  SizedBox(height: AppDesignSystem.spacingInputToHint),

                                  // Подсказка с требованиями к паролю (показывается всегда)
                                  Semantics(
                                    child: Text(
                                      'Пароль должен содержать минимум 8 символов',
                                      style: AppTextStyles.small(
                                        color: AppDesignSystem.textColorSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          else
                          // Показываем требования к паролю заранее (до ввода)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: AppDesignSystem.spacingXXLarge),
                              Semantics(
                                child: Text(
                                  'Требования к новому паролю:',
                                  style: AppTextStyles.small(
                                    fontWeight: AppDesignSystem.fontWeightMedium,
                                    color: AppDesignSystem.textColorPrimary,
                                  ),
                                ),
                              ),
                              SizedBox(height: AppDesignSystem.spacingSmall),
                              _buildPasswordRequirement('Минимум 8 символов'),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Кнопки внизу
                EditProfileActionBar(
                  onCancel: () {
                    if (!_isLoading && !_isVerifying) {
                      Navigator.of(context).pop();
                    }
                  },
                  onSave: _showNewPasswordFields ? _saveNewPassword : _verifyOldPassword,
                  isSaving: _isLoading || _isVerifying,
                  cancelText: 'Отменить',
                  saveText: _showNewPasswordFields ? 'Сохранить' : 'Подтвердить',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDesignSystem.spacingTiny),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 4,
              right: AppDesignSystem.spacingSmall,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 16,
              color: AppDesignSystem.textColorSecondary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.small(
                color: AppDesignSystem.textColorSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
