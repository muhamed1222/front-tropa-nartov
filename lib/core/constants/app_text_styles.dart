import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_design_system.dart';

/// Хелперы для текстовых стилей
/// Использует константы из AppDesignSystem и GoogleFonts.inter
class AppTextStyles {
  AppTextStyles._();

  // ============================================================================
  // ОСНОВНЫЕ СТИЛИ
  // ============================================================================

  /// Заголовок (Hero) - 34px, Bold
  static TextStyle hero({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: AppDesignSystem.fontSizeHero,
      fontWeight: fontWeight ?? AppDesignSystem.fontWeightBold,
      color: color ?? AppDesignSystem.textColorPrimary,
      height: AppDesignSystem.lineHeightNormal,
    );
  }

  /// Заголовок большой - 22px, SemiBold
  static TextStyle titleLarge({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: AppDesignSystem.fontSizeTitleLarge,
      fontWeight: fontWeight ?? AppDesignSystem.fontWeightSemiBold,
      color: color ?? AppDesignSystem.textColorPrimary,
      height: AppDesignSystem.lineHeightNormal,
    );
  }

  /// Заголовок онбординга - 28px, SemiBold
  static TextStyle onboarding({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: AppDesignSystem.fontSizeOnboarding,
      fontWeight: fontWeight ?? AppDesignSystem.fontWeightSemiBold,
      color: color ?? AppDesignSystem.textColorPrimary,
      height: AppDesignSystem.lineHeightNormal,
    );
  }

  /// Заголовок - 20px, SemiBold
  static TextStyle title({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: AppDesignSystem.fontSizeTitle,
      fontWeight: fontWeight ?? AppDesignSystem.fontWeightSemiBold,
      color: color ?? AppDesignSystem.textColorPrimary,
      height: AppDesignSystem.lineHeightNormal,
    );
  }

  /// Основной текст - 16px, Regular
  static TextStyle body({
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: AppDesignSystem.fontSizeBody,
      fontWeight: fontWeight ?? AppDesignSystem.fontWeightRegular,
      color: color ?? AppDesignSystem.textColorPrimary,
      height: AppDesignSystem.lineHeightNormal,
      letterSpacing: letterSpacing ?? AppDesignSystem.letterSpacingNormal,
    );
  }

  /// Большой текст - 18px, Regular
  static TextStyle bodyLarge({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: AppDesignSystem.fontSizeLarge,
      fontWeight: fontWeight ?? AppDesignSystem.fontWeightRegular,
      color: color ?? AppDesignSystem.textColorPrimary,
      height: AppDesignSystem.lineHeightNormal,
    );
  }

  /// Мелкий текст - 14px, Regular
  static TextStyle small({
    Color? color,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: AppDesignSystem.fontSizeSmall,
      fontWeight: fontWeight ?? AppDesignSystem.fontWeightRegular,
      color: color ?? AppDesignSystem.textColorSecondary,
      height: AppDesignSystem.lineHeightNormal,
      letterSpacing: letterSpacing ?? AppDesignSystem.letterSpacingTight,
    );
  }

  /// Текст ошибки - 12px, Regular
  static TextStyle error({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: AppDesignSystem.fontSizeError,
      fontWeight: fontWeight ?? AppDesignSystem.fontWeightRegular,
      color: color ?? AppDesignSystem.textColorError,
      height: AppDesignSystem.lineHeightNormal,
    );
  }

  // ============================================================================
  // СПЕЦИАЛИЗИРОВАННЫЕ СТИЛИ
  // ============================================================================

  /// Подсказка (hint) - 14px, Regular, серый
  static TextStyle hint({
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: AppDesignSystem.fontSizeSmall,
      fontWeight: AppDesignSystem.fontWeightRegular,
      color: color ?? AppDesignSystem.textColorHint,
      height: AppDesignSystem.lineHeightNormal,
    );
  }

  /// Вторичный текст - 14px, Regular, серый
  static TextStyle secondary({
    Color? color,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: AppDesignSystem.fontSizeSmall,
      fontWeight: AppDesignSystem.fontWeightRegular,
      color: color ?? AppDesignSystem.textColorSecondary,
      height: AppDesignSystem.lineHeightNormal,
      letterSpacing: letterSpacing ?? AppDesignSystem.letterSpacingTight,
    );
  }

  /// Текст кнопки - 16px, Medium
  static TextStyle button({
    Color? color,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.inter(
      fontSize: AppDesignSystem.fontSizeBody,
      fontWeight: fontWeight ?? AppDesignSystem.fontWeightMedium,
      color: color ?? AppDesignSystem.textColorWhite,
      height: AppDesignSystem.lineHeightNormal,
    );
  }

  /// Текст ссылки - 14px, Regular, основной цвет
  static TextStyle link({
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: AppDesignSystem.fontSizeSmall,
      fontWeight: AppDesignSystem.fontWeightRegular,
      color: color ?? AppDesignSystem.primaryColor,
      height: AppDesignSystem.lineHeightNormal,
    );
  }

  /// Текст лейбла - 14px, Regular
  static TextStyle label({
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: AppDesignSystem.fontSizeSmall,
      fontWeight: AppDesignSystem.fontWeightRegular,
      color: color ?? AppDesignSystem.textColorPrimary,
      height: AppDesignSystem.lineHeightNormal,
    );
  }
}

