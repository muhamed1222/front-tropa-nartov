/// Миксин для общей логики фильтрации списков
/// 
/// Используется в BLoC для унификации логики фильтрации маршрутов и мест
mixin FilterMixin {
  /// Фильтрация списка по поисковому запросу
  /// 
  /// Ищет вхождение запроса в текстовых полях элемента
  List<T> filterBySearchQuery<T>({
    required List<T> items,
    required String? searchQuery,
    required String Function(T) getSearchableText,
  }) {
    if (searchQuery == null || searchQuery.trim().isEmpty) {
      return items;
    }

    final query = searchQuery.trim().toLowerCase();
    return items.where((item) {
      final text = getSearchableText(item).toLowerCase();
      return text.contains(query);
    }).toList();
  }

  /// Фильтрация списка по нескольким критериям
  /// 
  /// Применяет все фильтры последовательно (AND логика)
  List<T> applyFilters<T>({
    required List<T> items,
    String? searchQuery,
    String Function(T)? getSearchableText,
    Map<String, bool Function(T)>? filters,
  }) {
    var result = items;

    // Применяем поисковый запрос
    if (searchQuery != null && getSearchableText != null) {
      result = filterBySearchQuery<T>(
        items: result,
        searchQuery: searchQuery,
        getSearchableText: getSearchableText,
      );
    }

    // Применяем остальные фильтры
    if (filters != null && filters.isNotEmpty) {
      for (final entry in filters.entries) {
        // Фильтр применяется только если значение true
        if (entry.value == true) {
          result = result.where(entry.value).toList();
        }
      }
    }

    return result;
  }

  /// Сортировка списка
  List<T> sortList<T>({
    required List<T> items,
    required SortType sortType,
    int Function(T, T)? customCompare,
    double Function(T)? getRating,
    String Function(T)? getName,
    DateTime Function(T)? getDate,
  }) {
    final sortedList = List<T>.from(items);

    switch (sortType) {
      case SortType.nameAsc:
        if (getName != null) {
          sortedList.sort((a, b) => getName(a).compareTo(getName(b)));
        }
        break;
      case SortType.nameDesc:
        if (getName != null) {
          sortedList.sort((a, b) => getName(b).compareTo(getName(a)));
        }
        break;
      case SortType.ratingAsc:
        if (getRating != null) {
          sortedList.sort((a, b) => getRating(a).compareTo(getRating(b)));
        }
        break;
      case SortType.ratingDesc:
        if (getRating != null) {
          sortedList.sort((a, b) => getRating(b).compareTo(getRating(a)));
        }
        break;
      case SortType.dateAsc:
        if (getDate != null) {
          sortedList.sort((a, b) => getDate(a).compareTo(getDate(b)));
        }
        break;
      case SortType.dateDesc:
        if (getDate != null) {
          sortedList.sort((a, b) => getDate(b).compareTo(getDate(a)));
        }
        break;
      case SortType.custom:
        if (customCompare != null) {
          sortedList.sort(customCompare);
        }
        break;
      case SortType.none:
        // Без сортировки, возвращаем исходный порядок
        break;
    }

    return sortedList;
  }

  /// Сортировка списка по строковому типу (для обратной совместимости)
  /// 
  /// Поддерживает строковые значения для сортировки, как в RoutesBloc
  List<T> sortListByString<T>({
    required List<T> items,
    required String sortType,
    int Function(T, T)? customCompare,
    double Function(T)? getRating,
    String Function(T)? getName,
    DateTime Function(T)? getDate,
  }) {
    final sortedList = List<T>.from(items);

    // Определяем тип сортировки по строке
    if (sortType.contains('популярные') || sortType.contains('рейтинг')) {
      // Сортировка по рейтингу (по убыванию)
      if (getRating != null) {
        sortedList.sort((a, b) => getRating(b).compareTo(getRating(a)));
      }
    } else if (sortType.contains('новые')) {
      // Сортировка по дате (по убыванию)
      if (getDate != null) {
        sortedList.sort((a, b) => getDate(b).compareTo(getDate(a)));
      }
    } else if (sortType.contains('Рандомный')) {
      // Рандомный порядок
      sortedList.shuffle();
    } else if (sortType.contains('названию')) {
      // Сортировка по названию
      if (getName != null) {
        sortedList.sort((a, b) => getName(a).compareTo(getName(b)));
      }
    } else if (customCompare != null) {
      // Кастомная сортировка
      sortedList.sort(customCompare);
    }

    return sortedList;
  }
}

/// Типы сортировки
enum SortType {
  none,
  nameAsc,
  nameDesc,
  ratingAsc,
  ratingDesc,
  dateAsc,
  dateDesc,
  custom,
}

