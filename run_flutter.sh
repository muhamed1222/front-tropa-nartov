#!/bin/bash
# Скрипт для запуска Flutter проекта

cd "$(dirname "$0")"
export FLUTTER_ROOT=/Users/kelemetovmuhamed/flutter

# Запускаем flutter run.
# Убрали жесткую привязку к iOS симулятору (-d UUID), 
# теперь будет запускаться на активном устройстве (например, Android эмуляторе)
"$FLUTTER_ROOT/bin/flutter" run "$@"
