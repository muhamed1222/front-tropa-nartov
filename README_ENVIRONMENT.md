# Конфигурация окружений

Приложение поддерживает три окружения: `dev`, `staging` и `production`.

## Использование

### Способ 1: --dart-define (рекомендуется)

При запуске приложения используйте флаги `--dart-define`:

```bash
# Development
flutter run --dart-define=ENVIRONMENT=dev

# Staging
flutter run --dart-define=ENVIRONMENT=staging --dart-define=API_BASE_URL=https://staging-api.example.com

# Production
flutter run --dart-define=ENVIRONMENT=production --dart-define=API_BASE_URL=https://api.example.com
```

### Способ 2: Переменные окружения системы

Установите переменные окружения перед запуском:

```bash
export ENVIRONMENT=dev
export SERVER_IP=192.168.1.48
export SERVER_PORT=8001
flutter run
```

### Способ 3: .env файл (будущая поддержка)

В будущем будет добавлена поддержка .env файлов через пакет `flutter_dotenv`.

## Доступные переменные

- `ENVIRONMENT` - окружение: `dev`, `staging`, `production`
- `API_BASE_URL` - базовый URL API (обязателен для production)
- `SERVER_IP` - IP адрес сервера (по умолчанию: 192.168.1.48)
- `SERVER_PORT` - порт сервера (по умолчанию: 8001)
- `ENABLE_LOGGING` - включить логирование (по умолчанию: true)

## Автоматическое определение для Dev

В режиме разработки (`dev`) базовый URL определяется автоматически:
- iOS симулятор: `http://localhost:8001`
- Android эмулятор: `http://10.0.2.2:8001`
- Реальное устройство: `http://<SERVER_IP>:<SERVER_PORT>`

## Примеры сборки

### Development
```bash
flutter build apk --dart-define=ENVIRONMENT=dev
```

### Staging
```bash
flutter build apk --dart-define=ENVIRONMENT=staging --dart-define=API_BASE_URL=https://staging-api.example.com
```

### Production
```bash
flutter build apk --release --dart-define=ENVIRONMENT=production --dart-define=API_BASE_URL=https://api.example.com
```

## Валидация

При запуске приложения автоматически проверяется валидность конфигурации:
- Для `production` обязательно указание `API_BASE_URL`
- Для `staging` рекомендуется указание `API_BASE_URL`

Если валидация не прошла, приложение выбросит исключение с описанием проблемы.

