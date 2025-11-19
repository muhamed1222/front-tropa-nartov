# 📊 Анализ стилей текстов и скруглений

## 🔍 Общая оценка: 4/10

Приложение имеет множество проблем с консистентностью стилей текста и скруглений. Найдено **множество несоответствий** и **жестко заданных значений** вместо использования констант.

---

## 📋 ТЕКУЩАЯ СИТУАЦИЯ

### Константы в проекте

#### 1. AuthConstants (`lib/core/constants/auth_constants.dart`)
```dart
// Размеры текста
fontSizeTitle = 22.0
fontSizeBody = 16.0
fontSizeSmall = 14.0
fontSizeError = 12.0

// Скругления
borderRadius = 12.0
```

#### 2. MenuConstants (`lib/core/constants/menu_constants.dart`)
```dart
// Размеры текста
fontSizeSmall = 14.0
fontSizeMedium = 16.0
fontSizeLarge = 18.0
fontSizeTitle = 20.0  // ⚠️ Отличается от AuthConstants!

// Скругления
borderRadius = 12.0
borderRadiusLarge = 16.0
borderRadiusSmall = 8.0
borderRadiusButton = 20.0
borderRadiusSwitch = 21.0
```

### Глобальная тема (`lib/main.dart`)
```dart
theme: ThemeData(
  textTheme: GoogleFonts.interTextTheme(),
  useMaterial3: true,
)
```

---

## 🔴 КРИТИЧЕСКИЕ ПРОБЛЕМЫ

### 1. Дублирование констант

**Проблема:**
- `AuthConstants` и `MenuConstants` содержат одинаковые значения с разными названиями
- `fontSizeTitle` в AuthConstants = 22.0, в MenuConstants = 20.0
- `borderRadius` дублируется в обоих файлах
- Нет единого источника истины

**Примеры:**
```dart
// AuthConstants
static const double fontSizeTitle = 22.0;
static const double borderRadius = 12.0;

// MenuConstants
static const double fontSizeTitle = 20.0;  // ❌ Другое значение!
static const double borderRadius = 12.0;   // ✅ Одинаковое, но дублируется
```

### 2. Жестко заданные значения fontSize

**Найдено:** 556+ вхождений `fontSize` в коде

**Проблемы:**
- Используются магические числа вместо констант
- Разные значения для одного типа текста
- Нет единой системы размеров

**Примеры несоответствий:**

| Тип текста | Используемые значения | Должно быть |
|-----------|----------------------|-------------|
| Заголовок | 20, 22, 34 | Одна константа |
| Основной текст | 14, 16, 18 | Одна константа |
| Мелкий текст | 12, 14 | Одна константа |
| Ошибка | 12 | Константа есть |

**Конкретные примеры:**
```dart
// main.dart
fontSize: 34,  // ❌ Жестко задано
fontSize: 14,  // ❌ Жестко задано

// place_details_sheet_widget.dart
fontSize: 16,  // ❌ Жестко задано (должно быть fontSizeBody)
fontSize: 14,  // ❌ Жестко задано (должно быть fontSizeSmall)
fontSize: 18,  // ❌ Жестко задано (должно быть fontSizeLarge)
fontSize: 12,  // ❌ Жестко задано (должно быть fontSizeError)
fontSize: 20,  // ❌ Жестко задано (должно быть fontSizeTitle)

// rating_dialog.dart
fontSize: 20,  // ❌ Жестко задано
fontSize: 16,  // ❌ Жестко задано
```

### 3. Жестко заданные значения borderRadius

**Найдено:** 315+ вхождений `borderRadius` в коде

**Проблемы:**
- Используются магические числа: 2, 8, 10, 12, 16, 20, 21, 24, 26, 27, 30, 40
- Разные значения для похожих элементов
- Нет единой системы скруглений

**Примеры несоответствий:**

| Элемент | Используемые значения | Должно быть |
|---------|----------------------|-------------|
| Кнопки | 12, 20, 27, 30 | Одна константа |
| Поля ввода | 12, 30 | Одна константа |
| Карточки | 10, 12, 16, 20, 26 | Одна константа |
| Контейнеры | 8, 12, 16, 20, 24 | Одна константа |

**Конкретные примеры:**
```dart
// home_page.dart
borderRadius: BorderRadius.circular(27),  // ❌ Жестко задано
borderRadius: 20.0,                       // ❌ Жестко задано
borderRadius: 10,                         // ❌ Жестко задано

// place_details_sheet_widget.dart
borderRadius: 20,   // ❌ Жестко задано
borderRadius: 40,   // ❌ Жестко задано (очень большое!)
borderRadius: 2,    // ❌ Жестко задано (очень маленькое!)
borderRadius: 12,   // ❌ Жестко задано
borderRadius: 10,   // ❌ Жестко задано
borderRadius: 8,    // ❌ Жестко задано

// rating_dialog.dart
borderRadius: 20,   // ❌ Жестко задано
borderRadius: 8,    // ❌ Жестко задано
borderRadius: 12,   // ❌ Жестко задано

// active_route_widget.dart
borderRadius: 16,   // ❌ Жестко задано
borderRadius: 10,   // ❌ Жестко задано
borderRadius: BorderRadius.circular(16),  // ❌ Жестко задано
borderRadius: BorderRadius.circular(12),  // ❌ Жестко задано

// route_info_sheet.dart
borderRadius: 2,    // ❌ Жестко задано (очень маленькое!)
borderRadius: BorderRadius.circular(12),  // ❌ Жестко задано

// bottom_sheet_widget.dart
borderRadius: BorderRadius.circular(12),  // ❌ Жестко задано
borderRadius: BorderRadius.circular(30),  // ❌ Жестко задано (для поля поиска!)

// places_filter_widget.dart
borderRadius: BorderRadius.circular(12),  // ❌ Жестко задано

// respublic widgets
borderRadius: BorderRadius.circular(16),  // ❌ Жестко задано (везде одинаково, но не константа)
borderRadius: BorderRadius.circular(26),  // ❌ Жестко задано

// routes_main_widget.dart
borderRadius: BorderRadius.circular(30),  // ❌ Жестко задано
borderRadius: BorderRadius.circular(12),  // ❌ Жестко задано
borderRadius: BorderRadius.circular(26),  // ❌ Жестко задано
```

### 4. Несоответствие fontWeight

**Проблемы:**
- Нет констант для fontWeight
- Используются разные значения: w400, w500, w600, w700
- Нет системы весов шрифтов

**Примеры:**
```dart
fontWeight: FontWeight.w400,  // Обычный текст
fontWeight: FontWeight.w500,  // Средний
fontWeight: FontWeight.w600,  // Полужирный
fontWeight: FontWeight.w700,  // Жирный
```

### 5. Несоответствие цветов текста

**Проблемы:**
- Используются разные способы задания цветов
- `Colors.black`, `Color(0xFF000000)`, `Colors.black54`, `Colors.black.withOpacity(0.4)`
- Нет единой системы цветов текста

**Примеры:**
```dart
color: Colors.black,                    // ❌ Не константа
color: Color(0xFF000000),               // ❌ Не константа
color: Colors.black54,                  // ❌ Не константа
color: Colors.black.withOpacity(0.4),   // ❌ Не константа
color: Colors.black.withOpacity(0.60),  // ❌ Не константа
```

### 6. Несоответствие letterSpacing и height

**Проблемы:**
- Используются разные значения: `letterSpacing: -0.28`, `height: 1.20`
- Нет констант для этих значений
- Не везде указаны

---

## 🟡 СРЕДНИЕ ПРОБЛЕМЫ

### 7. Неиспользование SmoothContainer/SmoothBorderRadius

**Проблема:**
- Есть утилита `SmoothContainer` с плавными скруглениями
- Но многие элементы используют обычный `BorderRadius.circular()`
- Несоответствие стиля скруглений

**Примеры:**
```dart
// Используется SmoothContainer
SmoothContainer(
  borderRadius: 12,
  // ...
)

// Но также используется обычный BorderRadius
BorderRadius.circular(12),  // ❌ Не консистентно
```

### 8. Отсутствие единой дизайн-системы

**Проблема:**
- Нет централизованного файла с дизайн-системой
- Константы разбросаны по разным файлам
- Нет документации по использованию стилей

---

## 📊 СТАТИСТИКА ПРОБЛЕМ

### Использование fontSize

| Значение | Количество | Должно быть константой |
|----------|-----------|----------------------|
| 12 | ~50+ | `fontSizeError` |
| 14 | ~100+ | `fontSizeSmall` |
| 16 | ~200+ | `fontSizeBody` / `fontSizeMedium` |
| 18 | ~30+ | `fontSizeLarge` |
| 20 | ~50+ | `fontSizeTitle` (MenuConstants) |
| 22 | ~20+ | `fontSizeTitle` (AuthConstants) |
| 34 | ~5+ | `fontSizeHero` (нет константы) |

### Использование borderRadius

| Значение | Количество | Должно быть константой |
|----------|-----------|----------------------|
| 2 | ~5+ | `borderRadiusTiny` (нет константы) |
| 8 | ~20+ | `borderRadiusSmall` |
| 10 | ~30+ | `borderRadiusMedium` (нет константы) |
| 12 | ~100+ | `borderRadius` |
| 16 | ~50+ | `borderRadiusLarge` |
| 20 | ~40+ | `borderRadiusButton` |
| 21 | ~5+ | `borderRadiusSwitch` |
| 24 | ~10+ | `borderRadiusXLarge` (нет константы) |
| 26 | ~15+ | `borderRadiusXXLarge` (нет константы) |
| 27 | ~5+ | Не используется |
| 30 | ~20+ | `borderRadiusInput` (нет константы) |
| 40 | ~5+ | Не используется |

---

## ✅ РЕКОМЕНДАЦИИ

### 1. Создать единый файл дизайн-системы

**Создать:** `lib/core/constants/app_design_system.dart`

```dart
class AppDesignSystem {
  AppDesignSystem._();

  // === ТЕКСТ ===
  
  // Размеры текста
  static const double fontSizeError = 12.0;
  static const double fontSizeSmall = 14.0;
  static const double fontSizeBody = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeTitle = 20.0;
  static const double fontSizeHero = 34.0;
  
  // Веса шрифтов
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  
  // Высота строки
  static const double lineHeightNormal = 1.20;
  static const double lineHeightTight = 1.0;
  static const double lineHeightLoose = 1.5;
  
  // Межбуквенное расстояние
  static const double letterSpacingTight = -0.28;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
  
  // Цвета текста
  static const Color textColorPrimary = Color(0xFF000000);
  static const Color textColorSecondary = Color(0x99000000); // black.withOpacity(0.60)
  static const Color textColorTertiary = Color(0x66000000);  // black.withOpacity(0.40)
  static const Color textColorHint = Color(0x66000000);
  static const Color textColorError = Color(0xFFFF4444);
  
  // === СКРУГЛЕНИЯ ===
  
  static const double borderRadiusTiny = 2.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadius = 12.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 20.0;
  static const double borderRadiusXLarge = 24.0;
  static const double borderRadiusXXLarge = 26.0;
  static const double borderRadiusInput = 30.0;
  static const double borderRadiusSwitch = 21.0;
  
  // === ОТСТУПЫ ===
  
  static const double spacingTiny = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 20.0;
  static const double spacingXXLarge = 24.0;
  static const double spacingHuge = 30.0;
  
  // === ПАДДИНГИ ===
  
  static const double paddingSmall = 8.0;
  static const double padding = 12.0;
  static const double paddingMedium = 14.0;
  static const double paddingLarge = 16.0;
  static const double paddingXLarge = 20.0;
}
```

### 2. Объединить AuthConstants и MenuConstants

**Вариант А:** Использовать `AppDesignSystem` для общих значений
**Вариант Б:** Оставить специфичные константы, но использовать `AppDesignSystem` для общих

### 3. Заменить все жестко заданные значения

**Приоритет:**
1. ✅ Высокий: fontSize, borderRadius (используются везде)
2. ✅ Средний: fontWeight, colors
3. ✅ Низкий: letterSpacing, height

### 4. Создать хелперы для текстовых стилей

```dart
class AppTextStyles {
  AppTextStyles._();

  static TextStyle title(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: AppDesignSystem.fontSizeTitle,
      fontWeight: AppDesignSystem.fontWeightSemiBold,
      color: AppDesignSystem.textColorPrimary,
      height: AppDesignSystem.lineHeightNormal,
    );
  }

  static TextStyle body(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: AppDesignSystem.fontSizeBody,
      fontWeight: AppDesignSystem.fontWeightRegular,
      color: AppDesignSystem.textColorPrimary,
      height: AppDesignSystem.lineHeightNormal,
    );
  }

  static TextStyle small(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: AppDesignSystem.fontSizeSmall,
      fontWeight: AppDesignSystem.fontWeightRegular,
      color: AppDesignSystem.textColorSecondary,
      height: AppDesignSystem.lineHeightNormal,
    );
  }

  static TextStyle error(BuildContext context) {
    return GoogleFonts.inter(
      fontSize: AppDesignSystem.fontSizeError,
      fontWeight: AppDesignSystem.fontWeightRegular,
      color: AppDesignSystem.textColorError,
      height: AppDesignSystem.lineHeightNormal,
    );
  }
}
```

### 5. Использовать SmoothContainer везде

**Рекомендация:**
- Заменить все `BorderRadius.circular()` на `SmoothContainer` или `SmoothRoundedRectangleBorder`
- Использовать константы из `AppDesignSystem`

### 6. Создать виджеты для переиспользования

```dart
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  
  const AppButton({
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: SmoothRoundedRectangleBorder(
          borderRadius: AppDesignSystem.borderRadius,
        ),
        // ...
      ),
      child: Text(
        text,
        style: AppTextStyles.body(context),
      ),
    );
  }
}
```

---

## 📋 ПЛАН ДЕЙСТВИЙ

### Фаза 1: Создание дизайн-системы (Высокий приоритет)
- [ ] Создать `AppDesignSystem` с всеми константами
- [ ] Создать `AppTextStyles` с хелперами
- [ ] Документировать дизайн-систему

### Фаза 2: Миграция констант (Высокий приоритет)
- [ ] Заменить все `fontSize` на константы из `AppDesignSystem`
- [ ] Заменить все `borderRadius` на константы из `AppDesignSystem`
- [ ] Заменить все цвета текста на константы из `AppDesignSystem`

### Фаза 3: Унификация стилей (Средний приоритет)
- [ ] Использовать `AppTextStyles` везде
- [ ] Использовать `SmoothContainer` везде
- [ ] Создать переиспользуемые виджеты

### Фаза 4: Очистка (Низкий приоритет)
- [ ] Удалить дублирующиеся константы из `AuthConstants` и `MenuConstants`
- [ ] Обновить документацию
- [ ] Добавить тесты для констант

---

## 🎯 ПРИОРИТЕТНЫЕ ИСПРАВЛЕНИЯ

### Топ-10 файлов для исправления:

1. `lib/features/home/presentation/widgets/place_details_sheet_widget.dart` - 20+ жестко заданных значений
2. `lib/features/profile/presentation/pages/profile_page.dart` - 30+ жестко заданных значений
3. `lib/features/home/presentation/widgets/rating_dialog.dart` - 15+ жестко заданных значений
4. `lib/features/home/presentation/widgets/active_route_widget.dart` - 10+ жестко заданных значений
5. `lib/features/routes/widgets/routes_main_widget.dart` - 15+ жестко заданных значений
6. `lib/features/home/presentation/pages/home_page.dart` - 10+ жестко заданных значений
7. `lib/features/respublic/presentation/widgets/*.dart` - 20+ жестко заданных значений
8. `lib/screens/auth/registration_screen.dart` - 10+ жестко заданных значений
9. `lib/screens/welcome_screen/*.dart` - 15+ жестко заданных значений
10. `lib/main.dart` - 5+ жестко заданных значений

---

## 📝 ЗАМЕТКИ

- Глобальная тема использует `GoogleFonts.interTextTheme()` - это хорошо
- Есть `SmoothContainer` для плавных скруглений - нужно использовать везде
- Константы есть, но используются не везде
- Нет единой системы именования констант

---

**Дата анализа:** 11 ноября 2025  
**Статус:** ⚠️ Требуется рефакторинг

