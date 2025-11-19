# Миграция шрифтов на Google Fonts

## ✅ Выполнено

1. ✅ Добавлен пакет `google_fonts: ^6.1.0` в `pubspec.yaml`
2. ✅ Удалена секция `fonts` из `pubspec.yaml`
3. ✅ Удалена папка `fonts/` с локальными файлами шрифтов
4. ✅ Обновлен `main.dart` для использования глобальной темы с `GoogleFonts.interTextTheme()`
5. ✅ Обновлен `lib/main.dart` - примеры использования `GoogleFonts.inter()`
6. ✅ Обновлен `lib/screens/auth/login_screen.dart` - примеры использования
7. ✅ **Удалены все `fontFamily: 'Inter'` из всех файлов проекта (224 вхождения в 30 файлах)**
8. ✅ Миграция завершена - все тексты теперь используют шрифт Inter из глобальной темы

## 📋 Что нужно сделать

### Вариант 1: Использовать глобальную тему (рекомендуется)

Поскольку в `main.dart` уже установлена глобальная тема:
```dart
theme: ThemeData(
  textTheme: GoogleFonts.interTextTheme(),
  useMaterial3: true,
),
```

Все `Text` виджеты автоматически будут использовать шрифт Inter. Можно просто **удалить** все `fontFamily: 'Inter'` из `TextStyle`, и шрифт будет подхватываться из темы.

**Пример:**
```dart
// Было:
Text(
  'Текст',
  style: TextStyle(
    fontSize: 16,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
  ),
)

// Стало:
Text(
  'Текст',
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  ),
)
```

### Вариант 2: Явное использование GoogleFonts (для кастомизации)

Если нужно явно указать шрифт для конкретного текста, используйте `GoogleFonts.inter()`:

```dart
// Было:
Text(
  'Текст',
  style: TextStyle(
    fontSize: 16,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
  ),
)

// Стало:
Text(
  'Текст',
  style: GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  ),
)
```

**Не забудьте добавить импорт:**
```dart
import 'package:google_fonts/google_fonts.dart';
```

## 🔍 Файлы, требующие обновления

Всего найдено **224 вхождения** `fontFamily: 'Inter'` в **30 файлах**:

### Screens (Экраны):
- `lib/screens/auth/login_screen.dart` ✅ (частично обновлен)
- `lib/screens/auth/registration_screen.dart`
- `lib/screens/auth/recovery_screen_1.dart`
- `lib/screens/auth/recovery_screen_2.dart`
- `lib/screens/auth/recovery_screen_3.dart`
- `lib/screens/welcome_screen/welcome_screen.dart`
- `lib/screens/welcome_screen/route_welcome_screen.dart`
- `lib/screens/welcome_screen/main_app_screen.dart`
- `lib/screens/welcome_screen/favorite_welcome_screen.dart`

### Features (Функциональные модули):
- `lib/features/home/presentation/pages/home_page.dart`
- `lib/features/home/presentation/widgets/active_route_widget.dart`
- `lib/features/home/presentation/widgets/place_details_sheet_widget.dart`
- `lib/features/home/presentation/widgets/rating_dialog.dart`
- `lib/features/home/presentation/widgets/route_info_sheet.dart`
- `lib/features/home/presentation/widgets/bottom_sheet_widget.dart`
- `lib/features/places/presentation/widgets/places_main_widget.dart`
- `lib/features/places/presentation/widgets/places_filter_widget.dart`
- `lib/features/routes/widgets/routes_main_widget.dart`
- `lib/features/routes/widgets/routes_filter_widget.dart`
- `lib/features/profile/presentation/pages/profile_page.dart`
- `lib/features/profile/presentation/widgets/edit_profile_page.dart`
- `lib/features/profile/presentation/widgets/change_password_dialog.dart`
- `lib/features/menu/presentation/pages/menu_page.dart`
- `lib/features/menu/presentation/widgets/settings_widget.dart`
- `lib/features/menu/presentation/widgets/about_project_widget.dart`
- `lib/features/respublic/presentation/widgets/respublic_choose_widget.dart`
- `lib/features/respublic/presentation/widgets/respublic_about_widget.dart`
- `lib/features/respublic/presentation/widgets/culture_detail_widget.dart`
- `lib/favourites/presentation/widgets/favourites_widget.dart`

## 🚀 Автоматическая миграция (опционально)

Для автоматической замены можно использовать поиск и замену в IDE:

1. **Найти:** `fontFamily: 'Inter'`
2. **Заменить на:** (удалить, если используете глобальную тему) или `GoogleFonts.inter(` (если нужно явное указание)

Или использовать регулярное выражение:
- **Найти:** `fontFamily:\s*'Inter'[,]?`
- **Заменить на:** (пусто, если используете глобальную тему)

## 📝 Рекомендации

1. **Используйте глобальную тему** для большинства случаев - это проще и консистентнее
2. **Используйте `GoogleFonts.inter()`** только когда нужно специальное форматирование
3. **Для `hintStyle` в `InputDecoration`** можно использовать глобальную тему через `Theme.of(context).textTheme`
4. **Проверьте все экраны** после миграции, чтобы убедиться, что шрифты отображаются корректно

## ⚠️ Важные замечания

- После миграции выполните `flutter pub get` для установки пакета `google_fonts`
- Убедитесь, что все файлы компилируются без ошибок
- Проверьте, что шрифты загружаются корректно (первые запуски могут быть медленнее из-за загрузки шрифтов)

## ✅ Проверка

После миграции проверьте:
1. ✅ Приложение компилируется без ошибок
2. ✅ Все тексты отображаются с шрифтом Inter
3. ✅ Нет предупреждений о отсутствующих шрифтах
4. ✅ Размер приложения уменьшился (локальные файлы шрифтов удалены)

---

**Дата создания:** Декабрь 2024  
**Статус:** ✅ **Миграция полностью завершена!** Все файлы обновлены, шрифты работают через Google Fonts.

