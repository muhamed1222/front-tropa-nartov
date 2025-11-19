# 🎨 Переиспользуемые виджеты

Эта папка содержит переиспользуемые виджеты, построенные на основе дизайн-системы приложения.

## 📦 Доступные виджеты

### 1. AppButton
Универсальная кнопка приложения с поддержкой различных стилей.

```dart
AppButton(
  text: 'Нажми меня',
  onPressed: () => print('Нажато'),
  style: AppButtonStyle.primary,
)

// С иконкой
AppButton(
  text: 'Сохранить',
  icon: Icons.save,
  onPressed: () => save(),
)

// С индикатором загрузки
AppButton(
  text: 'Загрузка',
  isLoading: true,
)
```

**Стили:**
- `AppButtonStyle.primary` - Основная кнопка (primary color, white text)
- `AppButtonStyle.secondary` - Вторичная кнопка (grey background, black text)
- `AppButtonStyle.outline` - Кнопка с обводкой (transparent, black text)
- `AppButtonStyle.error` - Кнопка ошибки (error color, white text)
- `AppButtonStyle.text` - Текстовая кнопка (transparent, black text)

### 2. AppCard
Универсальная карточка приложения.

```dart
AppCard(
  child: Text('Содержимое карточки'),
  padding: EdgeInsets.all(16),
  onTap: () => print('Нажато'),
)

// Карточка с изображением
AppImageCard(
  imageUrl: 'https://example.com/image.jpg',
  title: 'Заголовок',
  subtitle: 'Подзаголовок',
  onTap: () => navigate(),
)
```

### 3. AppInputField / AppFormField
Универсальное поле ввода с поддержкой валидации.

```dart
// Простое поле ввода
AppInputField(
  label: 'Email',
  hint: 'Введите email',
  controller: emailController,
)

// Поле с валидацией
AppFormField(
  label: 'Пароль',
  hint: 'Введите пароль',
  obscureText: true,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Поле обязательно для заполнения';
    }
    return null;
  },
  autovalidateMode: AutovalidateMode.onUserInteraction,
)
```

### 4. AppDialog
Универсальный диалог приложения.

```dart
// Простой диалог
AppDialog(
  title: 'Подтверждение',
  message: 'Вы уверены?',
  confirmText: 'Да',
  cancelText: 'Нет',
  onConfirm: () => print('Подтверждено'),
)

// Диалог подтверждения (статический метод)
AppDialog.showConfirmDialog(
  context: context,
  title: 'Удалить?',
  message: 'Это действие нельзя отменить',
  confirmText: 'Удалить',
  cancelText: 'Отмена',
  confirmStyle: AppButtonStyle.error,
).then((confirmed) {
  if (confirmed == true) {
    // Действие подтверждено
  }
})

// Диалог с ошибкой
AppDialog.showErrorDialog(
  context: context,
  title: 'Ошибка',
  message: 'Что-то пошло не так',
)
```

## 🎯 Преимущества

1. **Консистентность** - Все виджеты используют единую дизайн-систему
2. **Переиспользуемость** - Один раз создали, используем везде
3. **Поддерживаемость** - Изменения в одном месте применяются везде
4. **Типобезопасность** - Все параметры типизированы
5. **Документированность** - Каждый виджет имеет документацию

## 📝 Примеры использования

### Замена стандартных кнопок

**Было:**
```dart
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF24A79C),
    padding: EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: Text('Кнопка', style: TextStyle(color: Colors.white)),
)
```

**Стало:**
```dart
AppButton(
  text: 'Кнопка',
  onPressed: () {},
  style: AppButtonStyle.primary,
)
```

### Замена стандартных карточек

**Было:**
```dart
Container(
  padding: EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Text('Контент'),
)
```

**Стало:**
```dart
AppCard(
  child: Text('Контент'),
)
```

### 5. AppChip
Универсальный чип для фильтров, тегов и других элементов.

```dart
// Простой чип
AppChip(
  label: 'Фильтр',
  onTap: () => print('Нажато'),
)

// Чип с удалением
AppChip(
  label: 'Активный фильтр',
  onDelete: () => removeFilter(),
)

// Выбранный чип
AppChip(
  label: 'Выбрано',
  isSelected: true,
)
```

### 6. AppBadge
Бейдж для уведомлений и счетчиков.

```dart
// Бейдж с числом
AppBadge(count: 5)

// Бейдж с текстом
AppBadge(text: 'NEW')

// Точка (dot)
AppBadge(showDot: true)
```

### 7. AppProgressBar
Прогресс-бар для отображения прогресса.

```dart
// Простой прогресс-бар
AppProgressBar(
  progress: 0.7,
  label: 'Загрузка: 70%',
)

// С градиентом
AppProgressBar(
  progress: 0.5,
  showGradient: true,
)
```

### 8. AppSnackBar
Уведомления (SnackBar).

```dart
// Успешное уведомление
AppSnackBar.showSuccess(context, 'Успешно сохранено!');

// Ошибка
AppSnackBar.showError(context, 'Ошибка загрузки');

// Информация
AppSnackBar.showInfo(context, 'Информация');

// Кастомное
AppSnackBar.show(
  context,
  'Сообщение',
  backgroundColor: Colors.blue,
)
```

## 🚀 Планы развития

- [x] AppButton - Кнопки
- [x] AppCard - Карточки
- [x] AppInputField - Поля ввода
- [x] AppDialog - Диалоги
- [x] AppChip - Чипсы для фильтров и тегов
- [x] AppBadge - Бейджи для уведомлений
- [x] AppProgressBar - Прогресс-бар
- [x] AppSnackBar - Уведомления
- [ ] AppSwitch - Переключатель
- [ ] AppCheckbox - Чекбокс
- [ ] AppRadio - Радио-кнопка
- [ ] AppBottomSheet - Нижний лист
- [ ] AppLoadingIndicator - Индикатор загрузки
- [ ] AppEmptyState - Пустое состояние

---

**Версия:** 2.0  
**Дата обновления:** 11 ноября 2025


