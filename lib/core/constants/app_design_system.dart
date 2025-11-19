import 'package:flutter/material.dart';

/// Единая дизайн-система приложения
/// Содержит все константы для текстов, скруглений, отступов и цветов
class AppDesignSystem {
  AppDesignSystem._();

  // ============================================================================
  // ТЕКСТ
  // ============================================================================

  /// Размеры текста
  static const double fontSizeError = 12.0;
  static const double fontSizeSmall = 14.0;
  static const double fontSizeBody = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeTitle = 20.0;
  static const double fontSizeTitleLarge = 22.0;
  static const double fontSizeOnboarding = 28.0; // Для заголовков онбординга
  static const double fontSizeHero = 34.0;

  /// Веса шрифтов
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  /// Высота строки (line height)
  static const double lineHeightTight = 1.0;
  static const double lineHeightNormal = 1.20;
  static const double lineHeightLoose = 1.5;

  /// Межбуквенное расстояние (letter spacing)
  static const double letterSpacingTight = -0.28;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;

  /// Цвета текста
  static const Color textColorPrimary = Color(0xFF000000);
  static const Color textColorSecondary = Color(0x99000000); // black.withOpacity(0.60)
  static const Color textColorTertiary = Color(0x66000000);  // black.withOpacity(0.40)
  static const Color textColorHint = Color(0x66000000);
  static const Color textColorError = Color(0xFFFF4444);
  static const Color textColorWhite = Color(0xFFFFFFFF);

  // ============================================================================
  // СКРУГЛЕНИЯ (BORDER RADIUS)
  // ============================================================================

  static const double borderRadiusTiny = 2.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadius = 12.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 20.0;
  static const double borderRadiusXLarge = 24.0;
  static const double borderRadiusXXLarge = 26.0;
  static const double borderRadiusInput = 30.0;
  static const double borderRadiusSwitch = 21.0;
  static const double borderRadiusCircular = 27.0;

  // ============================================================================
  // ОТСТУПЫ (SPACING)
  // ============================================================================

  static const double spacingTiny = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacing = 14.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 20.0;
  static const double spacingXXLarge = 24.0;
  static const double spacingHuge = 30.0;
  
  // Специфичные отступы для экранов
  static const double spacingHandleToTitle = 26.0; // От handle bar до заголовка
  static const double spacingTitleToInput = 28.0; // От заголовка до поля ввода
  static const double spacingBetweenInputs = 10.0; // Между полями ввода
  static const double spacingInputToHint = 12.0; // От поля ввода до подсказки
  static const double spacingBottomButtons = 44.0; // Отступ снизу для кнопок

  // ============================================================================
  // ПАДДИНГИ (PADDING)
  // ============================================================================

  static const double paddingTiny = 4.0;
  static const double paddingSmall = 8.0;
  static const double padding = 12.0;
  static const double paddingMedium = 14.0;
  static const double paddingLarge = 16.0;
  static const double paddingXLarge = 20.0;
  static const double paddingXXLarge = 24.0;

  // Горизонтальные паддинги
  static const double paddingHorizontal = 14.0;
  static const double paddingHorizontalSmall = 8.0;
  static const double paddingHorizontalLarge = 20.0;

  // Вертикальные паддинги
  static const double paddingVertical = 12.0;
  static const double paddingVerticalSmall = 8.0;
  static const double paddingVerticalMedium = 14.0;
  static const double paddingVerticalLarge = 16.0;

  // ============================================================================
  // ЦВЕТА
  // ============================================================================

  /// Основные цвета
  static const Color primaryColor = Color(0xFF24A79C);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color backgroundColorSecondary = Color(0xFFF6F6F6);
  static const Color errorColor = Color(0xFFFF4444);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color blackColor = Color(0xFF000000);

  /// Серые оттенки
  static const Color greyColor = Color(0xFFBFBFBF);
  static const Color greyLight = Color(0xFFF6F6F6);
  static const Color greyMedium = Color(0xFF919191);
  static const Color greyDark = Color(0xFF999999);
  static const Color greyPlaceholder = Color(0xFFEDEDED); // Для placeholder и загрузки
  static const Color greyButton = Color(0xFFE7E7E7); // Для кнопок
  static const Color handleBarColor = Color(0xFFBFBFBF); // Цвет handle bar для bottom sheets

  /// Цвета для фонов
  static const Color inputBackgroundColor = Color(0xFFF6F6F6);
  static const Color cardBackgroundColor = Color(0xFFF6F6F6);
  static const Color overlayColor = Color(0x33FFFFFF);

  /// Цвета для градиентов и прогресс-баров
  static const Color primaryColorLight = Color(0xFF8BCCC8); // Светло-бирюзовый для градиентов

  /// Цвета для оверлеев (прозрачность)
  static const Color overlayDark = Color(0x66000000); // Черный 40% для затемнения
  static const Color overlayDarkLight = Color(0x33000000); // Черный 20% для легкого затемнения
  static const Color overlayWhite = Color(0x99FFFFFF); // Белый 60% для текста на темном фоне
  static const Color overlayWhiteLight = Color(0x33FFFFFF); // Белый 20% для легкого затемнения

  /// Цвета для теней
  static const Color shadowColor = Color(0xFFC0C0C0); // Серый цвет для теней

  // ============================================================================
  // РАЗМЕРЫ
  // ============================================================================

  /// Высота элементов
  static const double buttonHeight = 54.0;
  static const double inputHeight = 48.0;
  static const double iconButtonSize = 40.0;
  static const double settingsItemHeight = 54.0;

  /// Размеры иконок
  static const double iconSize = 24.0;
  static const double iconSizeSmall = 20.0;
  static const double iconSizeLarge = 40.0;
  static const double loadingIndicatorSize = 20.0;

  /// Размеры switch
  static const double switchWidth = 44.0;
  static const double switchHeight = 24.0;
  static const double switchThumbSize = 20.0;

  /// Ширина границ
  static const double borderWidth = 1.5;
  static const double borderWidthFocused = 2.0;
  static const double borderWidthThick = 3.0;

  // ============================================================================
  // РАЗМЕРЫ КАРТОЧЕК И БЛОКОВ
  // ============================================================================

  static const double cardMinHeight = 171.0;
  static const double cardWidth = 187.0;
  static const double cardHeight = 260.0;
  static const double dialogWidth = 384.0;

  // ============================================================================
  // АНИМАЦИИ
  // ============================================================================

  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 400);
  static const Duration switchAnimationDuration = Duration(milliseconds: 200);

  // ============================================================================
  // ДРУГИЕ КОНСТАНТЫ
  // ============================================================================

  /// Размеры bottom sheet
  static const double bottomSheetInitialSize = 0.9;
  static const double bottomSheetMinSize = 0.5;
  static const double bottomSheetMaxSize = 0.9;

  /// Размеры handle bar
  static const double handleBarWidth = 40.0;
  static const double handleBarHeight = 4.0;

  /// Валидация
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;

  /// Размеры иконок показа/скрытия пароля
  static const double passwordIconSize = 20.0;
  static const double passwordIconVisibleHeight = 20.0 * (14.0 / 19.0); // ≈ 14.74

  // ============================================================================
  // КОНСТАНТЫ ДЛЯ ПРОФИЛЯ
  // ============================================================================

  /// Минимальная ширина прогресс-бара для видимости (5%)
  static const double progressBarMinWidth = 0.05;

  /// Максимальное количество элементов избранного на главном экране профиля
  static const int maxFavoriteItemsOnProfile = 5;

  /// Максимальное количество элементов истории активности на главном экране профиля
  static const int maxHistoryItemsOnProfile = 10;

  /// Длительность кэширования данных профиля
  static const Duration profileCacheDuration = Duration(minutes: 5);
}

