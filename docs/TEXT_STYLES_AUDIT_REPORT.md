# 🔍 АУДИТ ТЕКСТОВЫХ СТИЛЕЙ - ПОЛНЫЙ ОТЧЕТ

## Дата: 2025-11-12
## Проблема: Использование `TextStyle` вместо `GoogleFonts.inter()` или `AppTextStyles`

---

## 📊 ОБЩАЯ СТАТИСТИКА:

| Тип стиля | Количество использований |
|-----------|-------------------------|
| ❌ `TextStyle(...)` | 126 (БЕЗ Google Fonts) |
| ✅ `GoogleFonts.inter(...)` | 11 (правильно) |
| ✅ `AppTextStyles.*` | 184 (правильно) |

---

## 🔴 КРИТИЧЕСКИЕ ФАЙЛЫ (требуют исправления):

### 1️⃣ **ОНБОРДИНГ (4 экрана)**
- ✅ `welcome_screen.dart` - **ИСПРАВЛЕНО**
- ✅ `route_welcome_screen.dart` - **ИСПРАВЛЕНО**
- ✅ `favorite_welcome_screen.dart` - **ИСПРАВЛЕНО**
- ✅ `main_app_screen.dart` - **ИСПРАВЛЕНО**

### 2️⃣ **АВТОРИЗАЦИЯ (5 экранов)**
- ✅ `login_screen.dart` - **ИСПРАВЛЕНО**
- ✅ `recovery_screen_1.dart` - **ИСПРАВЛЕНО**
- ✅ `recovery_screen_2.dart` - **ИСПРАВЛЕНО**
- ✅ `recovery_screen_3.dart` - **ИСПРАВЛЕНО**
- ⚠️ `registration_screen.dart` - **2 TextStyle** (в RichText для ссылок)

### 3️⃣ **РЕСПУБЛИКИ (7 bottom sheets)** - ⚠️ ~58 TextStyle
- ✅ `respublic_choose_widget.dart` - **ИСПРАВЛЕНО**
- ❌ `respublic_about_widget.dart` - **1 TextStyle**
- ❌ `culture_detail_widget.dart` - **7 TextStyle**
- ❌ `national_cuisine_widget.dart` - **14 TextStyle**
- ❌ `holidays_events_widget.dart` - **11 TextStyle**
- ❌ `peoples_languages_widget.dart` - **9 TextStyle**
- ❌ `general_kbr_widget.dart` - **8 TextStyle**

### 4️⃣ **МЕСТА И МАРШРУТЫ (10 bottom sheets)** - ⚠️ ~28 TextStyle
- ❌ `places_main_widget.dart` - **7 TextStyle**
- ❌ `places_filter_widget.dart` - **7 TextStyle**
- ❌ `routes_main_widget.dart` - (использует AppTextStyles ✅)
- ❌ `routes_filter_widget.dart` - **7 TextStyle**
- ❌ `place_details_sheet_widget.dart` - (использует AppTextStyles ✅)
- ❌ `route_info_sheet.dart` - **2 TextStyle**
- ❌ `active_route_widget.dart` - (использует AppTextStyles ✅)
- ❌ `bottom_sheet_widget.dart` - **1 TextStyle**

### 5️⃣ **ИЗБРАННОЕ (3 виджета)** - ⚠️ 14 TextStyle
- ❌ `favourites_widget.dart` - **8 TextStyle**
- ❌ `place_details_sheet_simple.dart` - **3 TextStyle**
- ❌ `route_details_sheet_simple.dart` - **3 TextStyle**

### 6️⃣ **МЕНЮ И НАСТРОЙКИ (3 экрана)** - ⚠️ ~20 TextStyle
- ❌ `menu_page.dart` - **5 TextStyle**
- ❌ `settings_widget.dart` - **6 TextStyle**
- ❌ `about_project_widget.dart` - **9 TextStyle**

### 7️⃣ **ПРОФИЛЬ (2 экрана)** - ⚠️ ~13 TextStyle
- ❌ `edit_profile_page.dart` - **9 TextStyle**
- ❌ `change_password_dialog.dart` - **4 TextStyle**

---

## 🎯 ПРИОРИТЕТ ИСПРАВЛЕНИЯ:

1. **ВЫСОКИЙ**: Республики (7 файлов, 58 проблем)
2. **ВЫСОКИЙ**: Места и маршруты (6 файлов, 28 проблем)
3. **СРЕДНИЙ**: Меню и профиль (5 файлов, 33 проблемы)
4. **НИЗКИЙ**: Избранное и регистрация (4 файла, 16 проблем)

---

## 📝 ПЛАН ДЕЙСТВИЙ:

### Фаза 1: Республики (7 файлов)
- [ ] respublic_about_widget.dart
- [ ] culture_detail_widget.dart
- [ ] national_cuisine_widget.dart
- [ ] holidays_events_widget.dart
- [ ] peoples_languages_widget.dart
- [ ] general_kbr_widget.dart

### Фаза 2: Места и маршруты (6 файлов)
- [ ] places_main_widget.dart
- [ ] places_filter_widget.dart
- [ ] routes_filter_widget.dart
- [ ] route_info_sheet.dart
- [ ] bottom_sheet_widget.dart

### Фаза 3: Меню и профиль (5 файлов)
- [ ] menu_page.dart
- [ ] settings_widget.dart
- [ ] about_project_widget.dart
- [ ] edit_profile_page.dart
- [ ] change_password_dialog.dart

### Фаза 4: Избранное и регистрация (4 файла)
- [ ] favourites_widget.dart
- [ ] place_details_sheet_simple.dart
- [ ] route_details_sheet_simple.dart
- [ ] registration_screen.dart

---

## ✅ УЖЕ ИСПРАВЛЕНО:

- ✅ Все экраны онбординга (4 файла)
- ✅ Все экраны авторизации кроме регистрации (4 файла)
- ✅ Экран выбора республики

**ИТОГО ИСПРАВЛЕНО: 9 файлов**
**ОСТАЛОСЬ ИСПРАВИТЬ: 24 файла**

---

## 🔧 ЧТО НУЖНО СДЕЛАТЬ В КАЖДОМ ФАЙЛЕ:

1. Добавить импорт:
   ```dart
   import 'package:google_fonts/google_fonts.dart';
   import '../../../../core/constants/app_design_system.dart';
   ```

2. Заменить все:
   ```dart
   // ❌ БЫЛО:
   style: TextStyle(
     fontSize: 16,
     fontWeight: FontWeight.w600,
     color: Color(0xFF000000),
   )
   
   // ✅ СТАЛО:
   style: GoogleFonts.inter(
     fontSize: 16,
     fontWeight: FontWeight.w600,
     color: AppDesignSystem.textColorPrimary,
   )
   ```

3. Заменить хардкод цвета на константы из AppDesignSystem

---

**Статус обновлен: 2025-11-12**

