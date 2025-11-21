# Flutter Refactoring Guide

## Миграция в Clean Architecture с Features

### Структура нового проекта

```
lib/
├── features/           # Feature-based модули
│   ├── auth/
│   │   ├── data/          # Data layer (repositories impl, models)
│   │   ├── domain/        # Domain layer (entities, use cases, repository interfaces)
│   │   └── presentation/  # Presentation layer (pages, widgets, blocs/cubits)
│   │       ├── pages/
│   │       └── widgets/
│   ├── onboarding/
│   ├── places/
│   ├── routes/
│   └── profile/
├── core/              # Shared код
│   ├── router/
│   ├── theme/
│   ├── utils/
│   └── widgets/
└── services/          # Глобальные сервисы
```

### План миграции

#### 1. Auth Feature (STARTED)
- [x] Создана структура папок
- [ ] Перенести `screens/auth/login_screen.dart` → `features/auth/presentation/pages/login_page.dart`
- [ ] Перенести `screens/auth/registration_screen.dart` → `features/auth/presentation/pages/registration_page.dart`
- [ ] Перенести `screens/auth/recovery_screen_*.dart` → `features/auth/presentation/pages/`

#### 2. Onboarding Feature (STARTED)
- [x] Создана структура папок
- [ ] Перенести `screens/welcome_screen/*` → `features/onboarding/presentation/pages/`

#### 3. Обновить импорты
После переноса файлов обновить все импорты в:
- `main.dart`
- Route definitions
- Другие экраны, которые ссылаются на перенесенные файлы

#### 4. Удалить старую папку screens/
После проверки что все работает - удалить `lib/screens/`

### Пример миграции

**До:**
```dart
import 'package:app/screens/auth/login_screen.dart';
```

**После:**
```dart
import 'package:app/features/auth/presentation/pages/login_page.dart';
```

## Следующие шаги

1. Протестировать приложение после каждого переноса
2. Убедиться что навигация работает
3. Проверить что все импорты обновлены
4. Запустить `flutter analyze` чтобы найти сломанные импорты

