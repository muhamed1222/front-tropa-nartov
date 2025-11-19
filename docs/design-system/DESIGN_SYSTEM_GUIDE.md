# 🎨 Руководство по использованию дизайн-системы

## 📋 Обзор

Единая дизайн-система приложения состоит из трех основных компонентов:

1. **AppDesignSystem** - все константы (цвета, размеры, отступы, скругления)
2. **AppTextStyles** - готовые стили текста
3. **AuthConstants / MenuConstants** - специфичные константы для модулей (используют AppDesignSystem)

---

## 🎯 AppDesignSystem

### Использование констант

```dart
import 'package:tropanartov/core/constants/app_design_system.dart';

// Цвета
Container(
  color: AppDesignSystem.primaryColor,
  child: Text(
    'Текст',
    style: TextStyle(color: AppDesignSystem.textColorPrimary),
  ),
)

// Размеры текста
Text(
  'Заголовок',
  style: TextStyle(fontSize: AppDesignSystem.fontSizeTitle),
)

// Скругления
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppDesignSystem.borderRadius),
  ),
)

// Отступы
Padding(
  padding: const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
  child: Widget(),
)

// Spacing
Column(
  children: [
    Widget1(),
    SizedBox(height: AppDesignSystem.spacingMedium),
    Widget2(),
  ],
)
```

### Доступные константы

#### Текст
- `fontSizeError` = 12.0
- `fontSizeSmall` = 14.0
- `fontSizeBody` = 16.0
- `fontSizeLarge` = 18.0
- `fontSizeTitle` = 20.0
- `fontSizeTitleLarge` = 22.0
- `fontSizeHero` = 34.0

#### Скругления
- `borderRadiusTiny` = 2.0
- `borderRadiusSmall` = 8.0
- `borderRadius` = 12.0
- `borderRadiusMedium` = 16.0
- `borderRadiusLarge` = 20.0
- `borderRadiusXLarge` = 24.0
- `borderRadiusXXLarge` = 26.0
- `borderRadiusInput` = 30.0
- `borderRadiusSwitch` = 21.0

#### Отступы
- `spacingTiny` = 4.0
- `spacingSmall` = 8.0
- `spacingMedium` = 12.0
- `spacing` = 14.0
- `spacingLarge` = 16.0
- `spacingXLarge` = 20.0
- `spacingXXLarge` = 24.0
- `spacingHuge` = 30.0

#### Цвета
- `primaryColor` = #24A79C
- `backgroundColor` = #FFFFFF
- `backgroundColorSecondary` = #F6F6F6
- `textColorPrimary` = #000000
- `textColorSecondary` = rgba(0,0,0,0.60)
- `textColorTertiary` = rgba(0,0,0,0.40)
- `textColorHint` = rgba(0,0,0,0.40)
- `textColorError` = #FF4444
- `errorColor` = #FF4444

---

## 📝 AppTextStyles

### Использование стилей текста

```dart
import 'package:tropanartov/core/constants/app_text_styles.dart';

// Заголовок (Hero) - 34px, Bold
Text(
  'ТРОПА НАРТОВ',
  style: AppTextStyles.hero(),
)

// Заголовок большой - 22px, SemiBold
Text(
  'Вход',
  style: AppTextStyles.titleLarge(),
)

// Заголовок - 20px, SemiBold
Text(
  'Заголовок',
  style: AppTextStyles.title(),
)

// Основной текст - 16px, Regular
Text(
  'Основной текст',
  style: AppTextStyles.body(),
)

// Большой текст - 18px, Regular
Text(
  'Большой текст',
  style: AppTextStyles.bodyLarge(),
)

// Мелкий текст - 14px, Regular
Text(
  'Мелкий текст',
  style: AppTextStyles.small(),
)

// Текст ошибки - 12px, Regular, красный
Text(
  'Ошибка',
  style: AppTextStyles.error(),
)

// Подсказка (hint) - 14px, Regular, серый
Text(
  'Подсказка',
  style: AppTextStyles.hint(),
)

// Вторичный текст - 14px, Regular, серый
Text(
  'Вторичный текст',
  style: AppTextStyles.secondary(),
)

// Текст кнопки - 16px, Medium, белый
Text(
  'Войти',
  style: AppTextStyles.button(),
)

// Текст ссылки - 14px, Regular, основной цвет
Text(
  'Зарегистрироваться',
  style: AppTextStyles.link(),
)

// Текст лейбла - 14px, Regular
Text(
  'Лейбл',
  style: AppTextStyles.label(),
)
```

### Кастомизация стилей

Все методы AppTextStyles поддерживают опциональные параметры:

```dart
// Изменить цвет
Text(
  'Текст',
  style: AppTextStyles.body(
    color: AppDesignSystem.primaryColor,
  ),
)

// Изменить вес шрифта
Text(
  'Текст',
  style: AppTextStyles.body(
    fontWeight: AppDesignSystem.fontWeightBold,
  ),
)

// Изменить межбуквенное расстояние
Text(
  'Текст',
  style: AppTextStyles.body(
    letterSpacing: AppDesignSystem.letterSpacingWide,
  ),
)
```

---

## 🔄 Миграция существующего кода

### До (плохо)

```dart
Text(
  'Заголовок',
  style: GoogleFonts.inter(
    color: Colors.black,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.20,
  ),
)

Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    color: Color(0xFF24A79C),
  ),
)
```

### После (хорошо)

```dart
Text(
  'Заголовок',
  style: AppTextStyles.titleLarge(),
)

Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppDesignSystem.borderRadius),
    color: AppDesignSystem.primaryColor,
  ),
)
```

---

## 🎨 Примеры использования

### Кнопка

```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppDesignSystem.primaryColor,
    foregroundColor: AppDesignSystem.textColorWhite,
    shape: SmoothRoundedRectangleBorder(
      borderRadius: AppDesignSystem.borderRadius,
    ),
    padding: const EdgeInsets.symmetric(
      vertical: AppDesignSystem.paddingVerticalMedium,
    ),
  ),
  child: Text(
    'Войти в аккаунт',
    style: AppTextStyles.button(),
  ),
)
```

### Поле ввода

```dart
TextFormField(
  decoration: InputDecoration(
    hintText: 'Почта',
    hintStyle: AppTextStyles.hint(),
    filled: true,
    fillColor: AppDesignSystem.inputBackgroundColor,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppDesignSystem.paddingHorizontal,
      vertical: AppDesignSystem.paddingVerticalMedium,
    ),
    border: SmoothOutlineInputBorder(
      borderRadius: AppDesignSystem.borderRadius,
      borderSide: BorderSide.none,
    ),
    errorStyle: AppTextStyles.error(),
  ),
  style: AppTextStyles.body(),
)
```

### Карточка

```dart
SmoothContainer(
  borderRadius: AppDesignSystem.borderRadiusMedium,
  color: AppDesignSystem.cardBackgroundColor,
  padding: const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Заголовок карточки',
        style: AppTextStyles.title(),
      ),
      SizedBox(height: AppDesignSystem.spacingSmall),
      Text(
        'Описание карточки',
        style: AppTextStyles.body(),
      ),
    ],
  ),
)
```

### Заголовок экрана

```dart
Column(
  children: [
    Text(
      'Главная',
      style: AppTextStyles.titleLarge(),
    ),
    SizedBox(height: AppDesignSystem.spacingMedium),
    // Контент
  ],
)
```

---

## ✅ Правила использования

### ✅ ДЕЛАТЬ

1. **Использовать AppDesignSystem** для всех констант
2. **Использовать AppTextStyles** для всех текстовых стилей
3. **Использовать SmoothContainer** для контейнеров с плавными скруглениями
4. **Использовать SmoothRoundedRectangleBorder** для кнопок
5. **Использовать SmoothOutlineInputBorder** для полей ввода

### ❌ НЕ ДЕЛАТЬ

1. **Не использовать** жестко заданные значения (магические числа)
2. **Не использовать** `GoogleFonts.inter()` напрямую (использовать AppTextStyles)
3. **Не использовать** `BorderRadius.circular()` с жестко заданными значениями
4. **Не использовать** `Colors.black`, `Colors.white` напрямую (использовать AppDesignSystem)
5. **Не создавать** новые константы без добавления в AppDesignSystem

---

## 🔍 Проверка кода

### Перед коммитом проверьте:

1. ✅ Нет жестко заданных `fontSize: 16` (использовать AppTextStyles)
2. ✅ Нет жестко заданных `borderRadius: 12` (использовать AppDesignSystem)
3. ✅ Нет жестко заданных цветов `Color(0xFF24A79C)` (использовать AppDesignSystem)
4. ✅ Нет прямого использования `GoogleFonts.inter()` (использовать AppTextStyles)
5. ✅ Все тексты используют AppTextStyles

### Команда для проверки:

```bash
# Найти жестко заданные fontSize
grep -r "fontSize:" lib --include="*.dart" | grep -v "AppDesignSystem\|AppTextStyles"

# Найти жестко заданные borderRadius
grep -r "borderRadius:" lib --include="*.dart" | grep -v "AppDesignSystem\|MenuConstants\|AuthConstants"

# Найти прямое использование GoogleFonts.inter
grep -r "GoogleFonts.inter(" lib --include="*.dart" | grep -v "app_text_styles.dart"
```

---

## 📚 Дополнительные ресурсы

- `lib/core/constants/app_design_system.dart` - все константы
- `lib/core/constants/app_text_styles.dart` - все текстовые стили
- `lib/core/constants/auth_constants.dart` - константы для авторизации
- `lib/core/constants/menu_constants.dart` - константы для меню

---

## 🚀 Следующие шаги

1. Мигрировать все существующие файлы на AppDesignSystem
2. Заменить все жестко заданные значения на константы
3. Использовать AppTextStyles везде
4. Проверить консистентность стилей

---

**Дата создания:** 11 ноября 2025  
**Версия:** 1.0


