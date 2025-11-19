import 'package:flutter/material.dart';
import 'app_design_system.dart';

/// Константы для экрана меню
/// Использует AppDesignSystem для единообразия
class MenuConstants {
  MenuConstants._();

  // Цвета (из AppDesignSystem)
  static const Color primaryColor = AppDesignSystem.primaryColor;
  static const Color backgroundColor = AppDesignSystem.backgroundColorSecondary;
  static const Color textColor = AppDesignSystem.textColorPrimary;
  static const Color textSecondaryColor = AppDesignSystem.textColorPrimary;
  static const Color whiteColor = AppDesignSystem.whiteColor;
  static const Color greyColor = AppDesignSystem.greyColor;
  static const Color sponsorOverlayColor = AppDesignSystem.overlayColor;

  // Размеры (из AppDesignSystem)
  static const double buttonHeight = AppDesignSystem.buttonHeight;
  static const double borderRadius = AppDesignSystem.borderRadius;
  static const double borderRadiusLarge = AppDesignSystem.borderRadiusMedium;
  static const double borderRadiusSmall = AppDesignSystem.borderRadiusSmall;
  static const double borderRadiusButton = AppDesignSystem.borderRadiusLarge;
  static const double borderRadiusSwitch = AppDesignSystem.borderRadiusSwitch;
  
  // Отступы (из AppDesignSystem)
  static const double paddingHorizontal = AppDesignSystem.paddingHorizontal;
  static const double paddingVertical = AppDesignSystem.paddingVertical;
  static const double paddingSmall = AppDesignSystem.paddingSmall;
  static const double spacingSmall = AppDesignSystem.spacingSmall;
  static const double spacingMedium = AppDesignSystem.spacingXLarge;
  static const double spacingLarge = AppDesignSystem.spacingHuge;
  
  // Размеры кнопок и иконок (из AppDesignSystem)
  static const double iconSize = AppDesignSystem.iconSize;
  static const double iconSizeSmall = AppDesignSystem.iconSizeSmall;
  static const double buttonIconSize = AppDesignSystem.iconSizeLarge;
  static const double switchWidth = AppDesignSystem.switchWidth;
  static const double switchHeight = AppDesignSystem.switchHeight;
  static const double switchThumbSize = AppDesignSystem.switchThumbSize;
  
  // Размеры текста (из AppDesignSystem)
  static const double fontSizeSmall = AppDesignSystem.fontSizeSmall;
  static const double fontSizeMedium = AppDesignSystem.fontSizeBody;
  static const double fontSizeLarge = AppDesignSystem.fontSizeLarge;
  static const double fontSizeTitle = AppDesignSystem.fontSizeTitle;
  
  // Высота блоков (из AppDesignSystem)
  static const double sponsorBlockMinHeight = AppDesignSystem.cardMinHeight;
  static const double settingsItemHeight = AppDesignSystem.settingsItemHeight;
  
  // Ширина блоков (специфичные для меню)
  static const double sponsorTextWidth = 270.0;
  static const double sponsorDescriptionWidth = 281.0;
  
  // URLs
  static const String baseUrl = 'https://wise-mission-436584.framer.app';
  static const String termsUrl = '$baseUrl/terms-and-conditions';
  static const String privacyUrl = '$baseUrl/privacy-policy';
  static const String websiteUrl = '$baseUrl/';
  static const String feedbackUrl = '$baseUrl/feedback';
  static const String sponsorUrl = '$baseUrl/sponsor';
  static const String vkUrl = 'https://vk.com/tropanartov';
  static const String telegramUrl = 'https://t.me/tropanartov';
  
  // Ключи для SharedPreferences
  static const String pushNotificationsKey = 'push_notifications';
  
  // Длительность анимаций (из AppDesignSystem)
  static const Duration switchAnimationDuration = AppDesignSystem.switchAnimationDuration;
  
  // Размеры bottom sheet (из AppDesignSystem)
  static const double bottomSheetInitialSize = AppDesignSystem.bottomSheetInitialSize;
  static const double bottomSheetMinSize = AppDesignSystem.bottomSheetMinSize;
  static const double bottomSheetMaxSize = AppDesignSystem.bottomSheetMaxSize;
  
  // Другие константы (специфичные для меню)
  static const double sponsorImageScale = 2.2;
  static const double sponsorImageWidth = 120.0;
  static const double sponsorImageHeight = 180.0;
  static const double handleBarWidth = AppDesignSystem.handleBarWidth;
  static const double handleBarHeight = AppDesignSystem.handleBarHeight;
}

