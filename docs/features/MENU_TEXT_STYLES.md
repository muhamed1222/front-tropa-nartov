# Стили текстов на экране меню

Документация всех текстовых стилей, используемых на экране меню (`lib/features/menu/presentation/pages/menu_page.dart`).

---

## 1. Заголовок "Меню" (Header Title)

**Расположение:** Верхняя часть экрана, по центру шапки

**Код:**
```dart
Text(
  'Меню',
  textAlign: TextAlign.center,
  style: GoogleFonts.inter(
    color: MenuConstants.textColor,           // Color(0xFF000000) - черный
    fontSize: MenuConstants.fontSizeTitle,     // 20.0 sp
    fontWeight: FontWeight.w600,               // SemiBold
    height: 1.20,                              // Line height: 1.20 (24.0 sp)
  ),
)
```

**Параметры:**
- **Цвет:** `#000000` (черный)
- **Размер шрифта:** `20.0 sp`
- **Вес шрифта:** `FontWeight.w600` (SemiBold)
- **Высота строки:** `1.20` (24.0 sp)
- **Выравнивание:** По центру

---

## 2. Текст кнопок меню (_MenuButton)

**Расположение:** Основные кнопки меню (Личный кабинет, Обратная связь, О проекте, Настройки)

**Код:**
```dart
Text(
  text,  // 'Личный кабинет', 'Обратная связь', 'О проекте', 'Настройки'
  style: GoogleFonts.inter(
    color: MenuConstants.textColor,           // Color(0xFF000000) - черный
    fontSize: MenuConstants.fontSizeLarge,    // 18.0 sp
    fontWeight: FontWeight.w500,               // Medium
    height: 1.20,                              // Line height: 1.20 (21.6 sp)
  ),
)
```

**Параметры:**
- **Шрифт:** `GoogleFonts.inter()` (явно указан для избежания конфликтов с глобальной темой)
- **Цвет:** `#000000` (черный)
- **Размер шрифта:** `18.0 sp`
- **Вес шрифта:** `FontWeight.w500` (Medium)
- **Высота строки:** `1.20` (21.6 sp)

**Важно:** Используется `GoogleFonts.inter()` явно, чтобы избежать конфликтов с глобальной темой `GoogleFonts.interTextTheme()` из `main.dart`

**Применяется к:**
- "Личный кабинет"
- "Обратная связь"
- "О проекте"
- "Настройки"

---

## 3. Заголовок блока спонсорства

**Расположение:** В блоке спонсорства, верхняя строка

**Код:**
```dart
Text(
  'Станьте спонсором проекта "Тропа Нартов"',
  style: GoogleFonts.inter(
    color: MenuConstants.whiteColor,           // Color(0xFFFFFFFF) - белый
    fontSize: MenuConstants.fontSizeLarge,     // 18.0 sp
    fontWeight: FontWeight.w600,                // SemiBold
    height: 1.20,                              // Line height: 1.20 (21.6 sp)
  ),
)
```

**Параметры:**
- **Цвет:** `#FFFFFF` (белый)
- **Размер шрифта:** `18.0 sp`
- **Вес шрифта:** `FontWeight.w600` (SemiBold)
- **Высота строки:** `1.20` (21.6 sp)
- **Ширина контейнера:** `65%` от ширины экрана

---

## 4. Описание блока спонсорства

**Расположение:** В блоке спонсорства, под заголовком

**Код:**
```dart
Text(
  'Ваше участие поможет сделать проект масштабнее, а ваш бренд — заметнее.',
  style: GoogleFonts.inter(
    color: MenuConstants.whiteColor,           // Color(0xFFFFFFFF) - белый
    fontSize: MenuConstants.fontSizeSmall,     // 14.0 sp
    fontWeight: FontWeight.w400,               // Regular
    height: 1.20,                              // Line height: 1.20 (16.8 sp)
    letterSpacing: -0.28,                     // Межбуквенное расстояние: -0.28
  ),
)
```

**Параметры:**
- **Цвет:** `#FFFFFF` (белый)
- **Размер шрифта:** `14.0 sp`
- **Вес шрифта:** `FontWeight.w400` (Regular)
- **Высота строки:** `1.20` (16.8 sp)
- **Межбуквенное расстояние:** `-0.28`
- **Ширина контейнера:** `70%` от ширины экрана

---

## 5. Кнопка "Подробнее" в блоке спонсорства

**Расположение:** В блоке спонсорства, внизу

**Код:**
```dart
Text(
  'Подробнее',
  style: GoogleFonts.inter(
    color: MenuConstants.whiteColor,           // Color(0xFFFFFFFF) - белый
    fontSize: MenuConstants.fontSizeSmall,     // 14.0 sp
    fontWeight: FontWeight.w500,               // Medium
    height: 1.20,                              // Line height: 1.20 (16.8 sp)
  ),
)
```

**Параметры:**
- **Цвет:** `#FFFFFF` (белый)
- **Размер шрифта:** `14.0 sp`
- **Вес шрифта:** `FontWeight.w500` (Medium)
- **Высота строки:** `1.20` (16.8 sp)
- **Фон:** `MenuConstants.sponsorOverlayColor` (Color(0x33FFFFFF) - белый с прозрачностью 20%)

---

## 6. Тексты в SnackBar (вспомогательные)

**Расположение:** Всплывающие уведомления об ошибках

### Основной текст SnackBar:
```dart
Text('Не удалось открыть ссылку')
```

### Текст кнопки действия:
```dart
SnackBarAction(
  label: 'Повторить',
  // ...
)
```

**Параметры:** Используются стандартные стили Flutter для SnackBar

---

## Сводная таблица стилей

| Элемент | Цвет | Размер | Вес | Высота строки | Letter Spacing |
|---------|------|--------|-----|---------------|----------------|
| Заголовок "Меню" | `#000000` | `20.0 sp` | `w600` | `1.20` | `0.0` |
| Кнопки меню | `#000000` | `18.0 sp` | `w500` | `1.20` | `0.0` |
| Заголовок спонсорства | `#FFFFFF` | `18.0 sp` | `w600` | `1.20` | `0.0` |
| Описание спонсорства | `#FFFFFF` | `14.0 sp` | `w400` | `1.20` | `-0.28` |
| Кнопка "Подробнее" | `#FFFFFF` | `14.0 sp` | `w500` | `1.20` | `0.0` |

---

## Константы из MenuConstants

Все стили используют константы из `MenuConstants`, которые в свою очередь ссылаются на `AppDesignSystem`:

```dart
// Размеры шрифтов
fontSizeSmall = 14.0    // AppDesignSystem.fontSizeSmall
fontSizeLarge = 18.0     // AppDesignSystem.fontSizeLarge
fontSizeTitle = 20.0     // AppDesignSystem.fontSizeTitle

// Цвета
textColor = Color(0xFF000000)      // AppDesignSystem.textColorPrimary
whiteColor = Color(0xFFFFFFFF)     // AppDesignSystem.whiteColor
primaryColor = Color(0xFF24A79C)  // AppDesignSystem.primaryColor
```

---

## Примечания

1. **Единообразие:** Все стили используют единую дизайн-систему через `MenuConstants` и `AppDesignSystem`
2. **Высота строки:** Все тексты используют `height: 1.20` для единообразия
3. **Цветовая схема:** Основной текст - черный (`#000000`), текст в блоке спонсорства - белый (`#FFFFFF`)
4. **Межбуквенное расстояние:** Используется только для описания спонсорства (`-0.28`)
5. **Шрифт:** Все тексты используют `GoogleFonts.inter()` явно для избежания конфликтов с глобальной темой `GoogleFonts.interTextTheme()` из `main.dart`
6. **Важно:** Использование `GoogleFonts.inter()` явно гарантирует, что стили не будут переопределены глобальной темой

