# Flutter Mobile App - Tropa Nartov 📱

Мобильное приложение для туристов, исследующих достопримечательности и маршруты Кабардино-Балкарии.

## 📋 Содержание

- [Особенности](#особенности)
- [Установка](#установка)
- [Архитектура](#архитектура)
- [Конфигурация](#конфигурация)
- [Разработка](#разработка)
- [Тестирование](#тестирование)
- [Сборка](#сборка)

## ✨ Особенности

- 🗺️ **Интерактивная карта** с достопримечательностями
- 📍 **Детальная информация** о местах (фото, описание, контакты)
- 🏔️ **Туристические маршруты** с расчетом расстояния
- ⭐ **Система рейтингов** и отзывов
- 💝 **Избранное** для сохранения интересных мест
- 📱 **Адаптивный дизайн** для всех устройств
- 🌐 **Офлайн режим** (в разработке)
- 🎨 **Modern Material Design UI**

## 🚀 Установка

### Предварительные требования

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / Xcode (для эмуляторов)
- Backend API (см. [../back/README.md](../back/README.md))

### Быстрый старт

```bash
# 1. Клонируйте репозиторий (если еще не сделали)
git clone https://github.com/yourusername/tropa-nartov.git
cd tropa-nartov/app-new-project

# 2. Установите зависимости
flutter pub get

# 3. Создайте .env файл
cp .env.example .env
# Отредактируйте SERVER_IP и другие параметры

# 4. Запустите приложение
flutter run

# Или для конкретной платформы:
flutter run -d android
flutter run -d ios
flutter run -d chrome  # Web версия
```

### Проверка установки

```bash
# Проверка Flutter
flutter doctor

# Список доступных устройств
flutter devices

# Анализ кода
flutter analyze
```

## 🏗️ Архитектура

Приложение следует **Clean Architecture** принципам с feature-based модулями.

### Структура проекта

```
lib/
├── main.dart                   # Точка входа
├── features/                   # Feature modules (Clean Architecture)
│   ├── auth/                  # Аутентификация
│   │   ├── data/             # Data layer (repositories impl, API)
│   │   ├── domain/           # Domain layer (entities, use cases)
│   │   └── presentation/     # UI layer (pages, widgets, blocs)
│   │       ├── pages/       # Screens
│   │       └── widgets/     # Reusable widgets
│   ├── onboarding/           # Onboarding flow
│   ├── places/               # Места и достопримечательности
│   ├── routes/               # Туристические маршруты
│   └── profile/              # Профиль пользователя
├── core/                      # Shared functionality
│   ├── router/               # Navigation (go_router)
│   ├── theme/                # App theme & styles
│   ├── utils/                # Helper functions
│   └── widgets/              # Common widgets
├── services/                  # Global services
│   ├── api_service.dart      # HTTP client (Dio)
│   ├── auth_service.dart     # Authentication
│   ├── location_service.dart # Geolocation
│   └── storage_service.dart  # Local storage
└── config/                    # Configuration
    ├── app_config.dart        # App-wide config
    └── environment_config.dart # Environment vars
```

### Слои архитектуры

#### Data Layer
- **Repositories Implementation** - реализация data sources
- **Models** - data models для API
- **API Clients** - HTTP запросы

#### Domain Layer
- **Entities** - бизнес-объекты
- **Use Cases** - бизнес-логика
- **Repository Interfaces** - контракты для data layer

#### Presentation Layer
- **Pages** - полноэкранные виджеты
- **Widgets** - переиспользуемые UI компоненты
- **BLoC/Cubit** - state management

## ⚙️ Конфигурация

### Environment Variables (.env)

```env
# API Configuration
SERVER_IP=192.168.1.48
SERVER_PORT=8001
API_BASE_URL=http://192.168.1.48:8001

# Environment
ENVIRONMENT=development  # development | staging | production

# Feature Flags
ENABLE_LOGGING=true
ENABLE_ANALYTICS=false
```

### Загрузка .env

Используем `flutter_dotenv`:

```dart
// main.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

// Использование
final apiUrl = dotenv.env['API_BASE_URL'];
```

### Конфигурация для разных окружений

```bash
# Development
flutter run --dart-define=ENVIRONMENT=development

# Production
flutter run --dart-define=ENVIRONMENT=production \
            --dart-define=API_BASE_URL=https://api.tropa-nartov.ru
```

## 💻 Разработка

### State Management

Используем **flutter_bloc** для управления состоянием:

```dart
// Example: Auth BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.email, event.password);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
```

### Навигация

Используем **go_router** для декларативной навигации:

```dart
// lib/core/router/app_router.dart
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/places/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PlaceDetailPage(placeId: id);
      },
    ),
  ],
);

// Использование
context.go('/home');
context.push('/places/123');
```

### API Calls

```dart
// lib/services/api_service.dart
class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: EnvironmentConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
  ));

  Future<List<Place>> getPlaces({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/places', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return (response.data['data'] as List)
          .map((json) => Place.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw ApiException(e.message);
    }
  }
}
```

### Локальное хранилище

```dart
// lib/services/storage_service.dart
class StorageService {
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
```

## 🧪 Тестирование

### Unit Tests

```bash
# Запуск unit тестов
flutter test

# С coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Widget Tests

```dart
// test/widgets/login_widget_test.dart
testWidgets('Login form should validate email', (tester) async {
  await tester.pumpWidget(MaterialApp(home: LoginPage()));
  
  // Найти поле email
  final emailField = find.byKey(const Key('email_field'));
  
  // Ввести невалидный email
  await tester.enterText(emailField, 'invalid');
  await tester.pump();
  
  // Проверить ошибку
  expect(find.text('Неверный формат email'), findsOneWidget);
});
```

### Integration Tests

```bash
# Запуск integration тестов
flutter test integration_test

# На конкретном устройстве
flutter test integration_test -d chrome
```

## 📦 Сборка

### Android

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App bundle для Play Store
flutter build appbundle --release

# Output: build/app/outputs/
```

### iOS

```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release

# Требуется Xcode и настроенные сертификаты
```

### Web

```bash
# Build для web
flutter build web --release

# Output: build/web/

# Deploy на сервер
rsync -avz build/web/ user@server:/var/www/tropa-nartov/
```

## 🎨 Темизация

### Настройка темы

```dart
// lib/core/theme/app_theme.dart
class AppTheme {
  static ThemeData light() {
    return ThemeData(
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      // ... другие настройки
    );
  }

  static ThemeData dark() {
    return ThemeData.dark().copyWith(
      primaryColor: Colors.blueAccent,
      // ... dark theme настройки
    );
  }
}
```

## 🔧 Troubleshooting

### Проблема: "Unable to connect to API"

```dart
// Проверьте:
1. Backend запущен (http://localhost:8001/ping)
2. Правильный IP в .env (для Android эмулятора: 10.0.2.2)
3. CORS настроен в backend
```

### Проблема: "Build failed"

```bash
# Очистка build
flutter clean
flutter pub get
flutter run
```

### Проблема: "Версия Flutter устарела"

```bash
flutter upgrade
flutter pub upgrade
```

## 📚 Полезные команды

```bash
# Анализ кода
flutter analyze

# Форматирование
dart format lib/

# Генерация кода (для freezed, json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Обновление зависимостей
flutter pub upgrade

# Список outdated пакетов
flutter pub outdated
```

## 📱 Поддерживаемые платформы

- ✅ Android 5.0+ (API 21+)
- ✅ iOS 12.0+
- ✅ Web (Chrome, Safari, Firefox)
- ⚠️ Desktop (Windows, macOS, Linux) - в разработке

## 🤝 Contributing

См. [CONTRIBUTING.md](../CONTRIBUTING.md)

## 📄 License

MIT License - см. [LICENSE](../LICENSE)

