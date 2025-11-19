/// Класс для валидации данных авторизации и регистрации
class AuthValidator {
  /// Валидация email адреса
  /// 
  /// Возвращает null если валидация успешна, иначе возвращает сообщение об ошибке
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ошибка: неверный формат email адреса';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ошибка: неверный формат email адреса';
    }
    
    return null;
  }

  /// Валидация пароля
  /// 
  /// Возвращает null если валидация успешна, иначе возвращает сообщение об ошибке
  /// [minLength] - минимальная длина пароля (по умолчанию 8)
  static String? validatePassword(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Ошибка: неверный формат пароля';
    }
    
    if (value.length < minLength) {
      return 'Пароль должен содержать минимум $minLength символов';
    }
    
    return null;
  }

  /// Валидация имени пользователя
  /// 
  /// Возвращает null если валидация успешна, иначе возвращает сообщение об ошибке
  /// [minLength] - минимальная длина имени (по умолчанию 2)
  static String? validateName(String? value, {int minLength = 2}) {
    if (value == null || value.isEmpty) {
      return 'Ошибка: неверный формат имени';
    }
    
    if (value.trim().length < minLength) {
      return 'Имя должно содержать минимум $minLength символа';
    }
    
    return null;
  }

  /// Валидация кода подтверждения
  /// 
  /// Возвращает null если валидация успешна, иначе возвращает сообщение об ошибке
  /// [requiredLength] - требуемая длина кода (по умолчанию 6)
  static String? validateCode(String? value, {int requiredLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Ошибка: неверный формат кода подтверждения';
    }
    
    if (value.length != requiredLength) {
      return 'Код должен содержать $requiredLength цифр';
    }
    
    // Проверка, что код состоит только из цифр
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Код должен содержать только цифры';
    }
    
    return null;
  }

  /// Валидация подтверждения пароля
  /// 
  /// Возвращает null если валидация успешна, иначе возвращает сообщение об ошибке
  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Ошибка: неверный формат повторного пароля';
    }
    
    if (password != confirmPassword) {
      return 'Ошибка: неверный формат повторного пароля';
    }
    
    return null;
  }
}

