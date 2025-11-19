#!/bin/bash
# Скрипт для запуска Flutter проекта с правильной обработкой пути с пробелом

cd "$(dirname "$0")"
export FLUTTER_ROOT=/Users/kelemetovmuhamed/flutter

# Используем реальный путь с правильным экранированием
PROJECT_DIR="/Users/kelemetovmuhamed/Documents/app new "

cd "$PROJECT_DIR"

# Запускаем flutter run с правильными параметрами
"$FLUTTER_ROOT/bin/flutter" run -d 7954F28F-2378-455E-81A6-9AC3AAA8149D "$@"

