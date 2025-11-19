import 'package:flutter/material.dart';
import 'app_design_system.dart';

/// Константы для экранов авторизации
/// Использует AppDesignSystem для единообразия
class AuthConstants {
  AuthConstants._();

  // Цвета (из AppDesignSystem)
  static const Color primaryColor = AppDesignSystem.primaryColor;
  static const Color backgroundColor = AppDesignSystem.backgroundColor;
  static const Color inputBackgroundColor = AppDesignSystem.inputBackgroundColor;
  static const Color errorColor = AppDesignSystem.errorColor;
  static const Color textColor = AppDesignSystem.textColorPrimary;
  static const Color hintTextColor = AppDesignSystem.textColorHint;
  static const Color secondaryTextColor = AppDesignSystem.textColorSecondary;

  // Размеры (из AppDesignSystem)
  static const double borderRadius = AppDesignSystem.borderRadius;
  static const double buttonHeight = AppDesignSystem.buttonHeight;
  static const double inputHeight = AppDesignSystem.inputHeight;
  
  // Отступы (из AppDesignSystem)
  static const double paddingHorizontal = AppDesignSystem.paddingHorizontal;
  static const double paddingVertical = AppDesignSystem.paddingVerticalMedium;
  static const double spacingSmall = AppDesignSystem.spacingSmall;
  static const double spacingMedium = AppDesignSystem.spacingLarge;
  static const double spacingLarge = AppDesignSystem.spacingXXLarge;
  
  // Размеры текста (из AppDesignSystem)
  static const double fontSizeTitle = AppDesignSystem.fontSizeTitleLarge;
  static const double fontSizeBody = AppDesignSystem.fontSizeBody;
  static const double fontSizeSmall = AppDesignSystem.fontSizeSmall;
  static const double fontSizeError = AppDesignSystem.fontSizeError;
  
  // Размеры иконок (из AppDesignSystem)
  static const double iconSize = AppDesignSystem.iconSizeSmall;
  static const double loadingIndicatorSize = AppDesignSystem.loadingIndicatorSize;
  
  // Размеры иконок показа/скрытия пароля (из AppDesignSystem)
  static const double passwordIconSize = AppDesignSystem.passwordIconSize;
  static const double passwordIconVisibleHeight = AppDesignSystem.passwordIconVisibleHeight;
  
  // Валидация (из AppDesignSystem)
  static const int minPasswordLength = AppDesignSystem.minPasswordLength;
  static const int maxPasswordLength = AppDesignSystem.maxPasswordLength;
  
  // Другое (из AppDesignSystem)
  static const double borderWidth = AppDesignSystem.borderWidth;
  static const double borderWidthFocused = AppDesignSystem.borderWidthFocused;
}

