# Отступы на экране настроек

Документация всех горизонтальных и вертикальных отступов на экране настроек (`lib/features/menu/presentation/widgets/settings_widget.dart`).

---

## Структура отступов

Экран настроек состоит из нескольких уровней отступов:

1. **Отступы контейнера bottom sheet** (из `open_bottom_sheet.dart`)
2. **Отступы элементов внутри экрана** (из `settings_widget.dart`)

---

## 1. Отступы контейнера bottom sheet

**Файл:** `lib/core/helpers/open_bottom_sheet.dart`

**Код:**
```dart
Container(
  padding: const EdgeInsets.only(left: 14, right: 14, top: 8),
  color: Colors.white,
  child: childBuilder(controller),
)
```

**Параметры:**
- **Слева:** `14.0 px` (жестко заданное значение)
- **Справа:** `14.0 px` (жестко заданное значение)
- **Сверху:** `8.0 px` (жестко заданное значение)
- **Снизу:** `0.0 px` (нет отступа)

---

## 2. Handle bar (полоска для закрытия)

**Расположение:** Верхняя часть экрана

**Код:**
```dart
SmoothContainer(
  width: MenuConstants.handleBarWidth,  // 40.0
  height: MenuConstants.handleBarHeight, // 4.0
  margin: EdgeInsets.only(top: MenuConstants.paddingSmall),  // 8.0
  // ...
)
```

**Параметры:**
- **Отступ сверху:** `8.0 px` (`MenuConstants.paddingSmall`)
- **Горизонтальные отступы:** Нет (центрируется автоматически)
- **Ширина:** `40.0 px`
- **Высота:** `4.0 px`

---

## 3. Заголовок "Настройки"

**Расположение:** Под handle bar

**Код:**
```dart
const SizedBox(height: 26),  // Отступ сверху
Text('Настройки', ...),
const SizedBox(height: 28),  // Отступ снизу
```

**Параметры:**
- **Отступ сверху:** `26.0 px` (жестко заданное значение)
- **Отступ снизу:** `28.0 px` (жестко заданное значение)
- **Горизонтальные отступы:** Нет (текст центрируется)

---

## 4. Блок "Версия приложения"

**Расположение:** Первый блок настроек

**Код:**
```dart
SmoothContainer(
  height: MenuConstants.settingsItemHeight,  // 54.0
  margin: EdgeInsets.symmetric(horizontal: MenuConstants.paddingHorizontal),  // 14.0
  padding: EdgeInsets.symmetric(horizontal: MenuConstants.paddingHorizontal),  // 14.0
  // ...
)
```

**Параметры:**
- **Отступ слева (margin):** `14.0 px` (`MenuConstants.paddingHorizontal`)
- **Отступ справа (margin):** `14.0 px` (`MenuConstants.paddingHorizontal`)
- **Отступ слева (padding внутри блока):** `14.0 px` (`MenuConstants.paddingHorizontal`)
- **Отступ справа (padding внутри блока):** `14.0 px` (`MenuConstants.paddingHorizontal`)
- **Высота блока:** `54.0 px` (`MenuConstants.settingsItemHeight`)

**Итого от края экрана до текста:**
- `14.0` (контейнер bottom sheet) + `14.0` (margin блока) + `14.0` (padding блока) = **42.0 px** с каждой стороны

---

## 5. Блок "PUSH-уведомления"

**Расположение:** Второй блок настроек

**Код:**
```dart
SmoothContainer(
  height: MenuConstants.settingsItemHeight,  // 54.0
  margin: EdgeInsets.symmetric(horizontal: MenuConstants.paddingHorizontal),  // 14.0
  padding: EdgeInsets.symmetric(horizontal: MenuConstants.paddingHorizontal),  // 14.0
  // ...
)
```

**Параметры:**
- **Отступ слева (margin):** `14.0 px` (`MenuConstants.paddingHorizontal`)
- **Отступ справа (margin):** `14.0 px` (`MenuConstants.paddingHorizontal`)
- **Отступ слева (padding внутри блока):** `14.0 px` (`MenuConstants.paddingHorizontal`)
- **Отступ справа (padding внутри блока):** `14.0 px` (`MenuConstants.paddingHorizontal`)
- **Высота блока:** `54.0 px` (`MenuConstants.settingsItemHeight`)

**Итого от края экрана до текста:**
- `14.0` (контейнер bottom sheet) + `14.0` (margin блока) + `14.0` (padding блока) = **42.0 px** с каждой стороны

---

## 6. Отступ между блоками

**Код:**
```dart
SizedBox(height: MenuConstants.spacingSmall),  // 8.0
```

**Параметры:**
- **Отступ между блоками:** `8.0 px` (`MenuConstants.spacingSmall`)

---

## 7. Отступ перед ссылками

**Код:**
```dart
SizedBox(height: MenuConstants.spacingLarge),  // 30.0
```

**Параметры:**
- **Отступ перед ссылками:** `30.0 px` (`MenuConstants.spacingLarge`)

---

## 8. Ссылки внизу (Политика конфиденциальности, Условия использования)

**Расположение:** Внизу экрана

**Код:**
```dart
Padding(
  padding: EdgeInsets.symmetric(vertical: 12),  // Только вертикальные отступы
  child: Text('Политика конфиденциальности', ...),
)
```

**Параметры:**
- **Отступ сверху:** `12.0 px` (жестко заданное значение)
- **Отступ снизу:** `12.0 px` (жестко заданное значение)
- **Отступ слева:** `0.0 px` (нет отступа)
- **Отступ справа:** `0.0 px` (нет отступа)

**Итого от края экрана до текста ссылок:**
- `14.0` (контейнер bottom sheet) = **14.0 px** с каждой стороны

---

## 9. Отступ внизу экрана

**Код:**
```dart
SizedBox(height: MenuConstants.spacingLarge),  // 30.0
```

**Параметры:**
- **Отступ внизу:** `30.0 px` (`MenuConstants.spacingLarge`)

---

## Сводная таблица горизонтальных отступов

| Элемент | Отступ от края экрана | Margin | Padding внутри | Итого до контента |
|---------|----------------------|--------|----------------|-------------------|
| Контейнер bottom sheet | - | - | `14.0 px` | `14.0 px` |
| Handle bar | `14.0 px` | - | - | `14.0 px` |
| Заголовок "Настройки" | `14.0 px` | - | - | `14.0 px` |
| Блок "Версия приложения" | `14.0 px` | `14.0 px` | `14.0 px` | `42.0 px` |
| Блок "PUSH-уведомления" | `14.0 px` | `14.0 px` | `14.0 px` | `42.0 px` |
| Ссылки внизу | `14.0 px` | - | - | `14.0 px` |

---

## Сводная таблица вертикальных отступов

| Элемент | Отступ сверху | Отступ снизу |
|---------|---------------|--------------|
| Handle bar | `8.0 px` (контейнер) + `8.0 px` (margin) = `16.0 px` | - |
| Заголовок "Настройки" | `26.0 px` | `28.0 px` |
| Блок "Версия приложения" | `28.0 px` (от заголовка) | `8.0 px` (до следующего блока) |
| Блок "PUSH-уведомления" | `8.0 px` (от предыдущего блока) | `30.0 px` (до ссылок) |
| Ссылки | `30.0 px` (от блока) | `12.0 px` (между ссылками) |
| Отступ внизу | - | `30.0 px` |

---

## Константы из MenuConstants

Все отступы используют константы из `MenuConstants`, которые ссылаются на `AppDesignSystem`:

```dart
// Горизонтальные отступы
paddingHorizontal = 14.0    // AppDesignSystem.paddingHorizontal

// Вертикальные отступы
paddingSmall = 8.0          // AppDesignSystem.paddingSmall
paddingVertical = 12.0      // AppDesignSystem.paddingVertical

// Отступы между элементами
spacingSmall = 8.0          // AppDesignSystem.spacingSmall
spacingLarge = 30.0         // AppDesignSystem.spacingHuge

// Высота элементов
settingsItemHeight = 54.0   // AppDesignSystem.settingsItemHeight
handleBarWidth = 40.0       // AppDesignSystem.handleBarWidth
handleBarHeight = 4.0       // AppDesignSystem.handleBarHeight
```

---

## Визуальное представление

```
┌─────────────────────────────────────┐
│ ← 14px →                           │  ← Контейнер bottom sheet
│                                     │
│         [Handle bar 40×4]           │  ← Top: 8px
│                                     │
│         "Настройки"                 │  ← Top: 26px, Bottom: 28px
│                                     │
│ ← 14px → ┌─────────────────────┐   │
│          │ ← 14px →             │   │  ← Margin: 14px
│          │                      │   │
│          │ Версия приложения   │   │  ← Padding: 14px
│          │                      │   │
│          └─────────────────────┘   │
│          ← 14px →                   │
│                                     │  ← Spacing: 8px
│ ← 14px → ┌─────────────────────┐   │
│          │ ← 14px →             │   │  ← Margin: 14px
│          │                      │   │
│          │ PUSH-уведомления    │   │  ← Padding: 14px
│          │                      │   │
│          └─────────────────────┘   │
│          ← 14px →                   │
│                                     │  ← Spacing: 30px
│ ← 14px → Политика конфиденциальности│  ← Только padding контейнера
│                                     │
│ ← 14px → Условия использования      │
│                                     │
│                                     │  ← Bottom: 30px
└─────────────────────────────────────┘
```

---

## Примечания

1. **Единообразие:** Все основные блоки используют одинаковые отступы `14.0 px` для margin и padding
2. **Ссылки:** Ссылки внизу не имеют дополнительных горизонтальных отступов, только отступ контейнера `14.0 px`
3. **Контейнер:** Отступы контейнера bottom sheet (`14.0 px` слева и справа) применяются ко всему содержимому экрана
4. **Итого:** От края экрана до текста в блоках настроек: **42.0 px** (14 + 14 + 14)
5. **Итого:** От края экрана до текста ссылок: **14.0 px** (только padding контейнера)


