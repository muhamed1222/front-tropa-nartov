import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../models/api_models.dart';
import '../../../../services/api_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../shared/data/datasources/mock_place_areas_for_place.dart';
import '../../../../shared/data/datasources/mock_place_categories_for_place.dart';
import '../../../../shared/data/datasources/mock_place_tags_for_place.dart';
import '../../../../utils/smooth_border_radius.dart';
import 'places_filter_widget.dart';
import '../../../home/presentation/widgets/place_details_sheet_widget.dart';

class PlacesMainWidget extends StatefulWidget {
  const PlacesMainWidget({
    super.key,
    this.scrollController,
    this.initialSearchQuery,
  });

  final ScrollController? scrollController;
  final String? initialSearchQuery;

  @override
  State<PlacesMainWidget> createState() => _PlacesMainWidgetState();
}

class _PlacesMainWidgetState extends State<PlacesMainWidget> {
  static const sortingItems = [
    'Сначала популярные',
    'Сначала с высоким рейтингом',
    'Сначала новые',
  ];
  String sortingValue = sortingItems.first;

  List<Place> _places = [];
  List<Place> _filteredPlaces = [];
  bool _isLoading = true;
  bool _hasError = false;

  // Состояние фильтров
  PlaceFilters _currentFilters = const PlaceFilters();

  // Состояние поиска
  late TextEditingController _searchController;
  String _searchQuery = '';

  // Map для хранения состояния избранного для каждого места
  final Map<int, bool> _favoriteStatus = {};

  // Состояние для анимации иконки сортировки
  bool _isSortingMenuOpen = false;

  // Контроллер для скролла карточек
  late ScrollController _cardsScrollController;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearchQuery ?? '';
    _searchController = TextEditingController(text: _searchQuery);
    _cardsScrollController = widget.scrollController ?? ScrollController();
    _loadPlaces();

    // Устанавливаем светлый status bar при открытии
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Не удаляем _cardsScrollController если он передан извне
    if (widget.scrollController == null) {
      _cardsScrollController.dispose();
    }

    // Восстанавливаем темный status bar при закрытии
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    super.dispose();
  }

  // ... остальные методы остаются без изменений (_loadPlaces, _loadFavoriteStatuses, _toggleFavorite, etc.)

  Future<void> _loadPlaces() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final places = await ApiService.getPlaces();

      // Загружаем статусы избранного для всех мест
      await _loadFavoriteStatuses(places);

      setState(() {
        _places = places;
        _filteredPlaces = _applyFiltersAndSorting(places);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // Метод для загрузки статусов избранного
  Future<void> _loadFavoriteStatuses(List<Place> places) async {
    final token = await AuthService.getToken();
    if (token == null) return;

    for (final place in places) {
      try {
        final isFavorite = await ApiService.isPlaceFavorite(place.id, token);
        _favoriteStatus[place.id] = isFavorite;
      } catch (e) {
        _favoriteStatus[place.id] = false;
      }
    }
  }

  // Метод для переключения избранного
  Future<void> _toggleFavorite(int placeId) async {
    // Проверяем авторизацию
    final token = await AuthService.getToken();
    if (token == null) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          'Для добавления в избранное необходимо войти в аккаунт',
        );
      }
      return;
    }

    // Сохраняем текущее состояние для отката в случае ошибки
      final currentStatus = _favoriteStatus[placeId] ?? false;

    // Оптимистично обновляем UI
    if (mounted) {
      setState(() {
        _favoriteStatus[placeId] = !currentStatus;
      });
    }

    try {
      if (currentStatus) {
        await ApiService.removeFromFavorites(placeId, token);
        if (mounted) {
          AppSnackBar.showSuccess(
            context,
            'Место удалено из избранного',
          );
        }
      } else {
        await ApiService.addToFavorites(placeId, token);
        if (mounted) {
          AppSnackBar.showSuccess(
            context,
            'Место добавлено в избранное',
          );
        }
      }
    } catch (e) {
      // Откатываем изменения при ошибке
      if (mounted) {
        setState(() {
          _favoriteStatus[placeId] = currentStatus;
        });
        
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        AppSnackBar.showError(
          context,
          'Не удалось изменить избранное: $errorMessage',
        );
      }
    }
  }

  List<Place> _applyFiltersAndSorting(List<Place> places) {
    // Сначала применяем фильтры
    List<Place> filteredPlaces = _applyFilters(places);

    // Затем применяем сортировку
    return _applySorting(filteredPlaces, sortingValue);
  }

  List<Place> _applyFilters(List<Place> places) {
    List<Place> filtered = places;

    // Применяем поисковый запрос
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      filtered =
          filtered.where((place) {
            final nameMatch = place.name.toLowerCase().contains(query);
            final descriptionMatch = place.shortDescription.toLowerCase().contains(query);
            final typeMatch = place.type.toLowerCase().contains(query);
            return nameMatch || descriptionMatch || typeMatch;
          }).toList();
    }

    return filtered;
  }

  List<Place> _applySorting(List<Place> places, String sortType) {
    List<Place> sortedPlaces = List.from(places);

    switch (sortType) {
      case 'Сначала популярные':
      // Сортируем по количеству отзывов (если есть) или по рейтингу
        sortedPlaces.sort((a, b) {
          final aReviews = a.reviews.length;
          final bReviews = b.reviews.length;
          if (aReviews != bReviews) {
            return bReviews.compareTo(aReviews); // По убыванию
          }
          return b.rating.compareTo(a.rating); // По убыванию рейтинга
        });
        break;

      case 'Сначала с высоким рейтингом':
      // Сортируем по рейтингу от высокого к низкому
        sortedPlaces.sort((a, b) => b.rating.compareTo(a.rating));
        break;

      case 'Сначала новые':
      // Сортируем по дате создания от новых к старым
        sortedPlaces.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;

      case 'Рандомный порядок':
      // Перемешиваем список случайным образом
        sortedPlaces.shuffle();
        break;

      default:
      // По умолчанию - без сортировки (оригинальный порядок)
        break;
    }

    return sortedPlaces;
  }

  void _onSortingChanged(String newValue) {
    setState(() {
      sortingValue = newValue;
      _filteredPlaces = _applyFiltersAndSorting(_places);
    });
  }

  void _shuffleRandom() {
    // Открываем случайную карточку места вместо перетасовки списка
    if (_filteredPlaces.isEmpty) return;
    
    // Выбираем случайное место из отфильтрованного списка
    final random = Random().nextInt(_filteredPlaces.length);
    final randomPlace = _filteredPlaces[random];
    
    // Открываем детали случайного места
    _onPlaceTap(randomPlace);
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Прозрачный фон для затемнения
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.0,
        maxChildSize: 0.9,
        expand: false,
        snap: true,
        snapSizes: const [0.0, 0.9],
        builder: (context, scrollController) => FilterWidget(
          categories: mockPlaceCategories,
          areas: mockAreas,
          tags: mockPlaceTags,
          initialFilters: _currentFilters,
          scrollController: scrollController,
          onFiltersApplied: (PlaceFilters newFilters) {
            setState(() {
              _currentFilters = newFilters;
              _filteredPlaces = _applyFiltersAndSorting(_places);
            });
          },
        ),
      ),
    );
  }

  void _onPlaceTap(Place place) {
    // Конвертируем Place из api_models в Place из home/domain/entities
    final homePlace = place.toEntity();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceDetailsSheet(
        place: homePlace,
        fullScreen: true, // Сразу открывается на весь экран
      ),
    );
  }

  // Удалить конкретную категорию
  void _removeCategory(int categoryId) {
    setState(() {
      final newCategories = List<int>.from(_currentFilters.selectedCategories);
      newCategories.remove(categoryId);
      _currentFilters = _currentFilters.copyWith(selectedCategories: newCategories);
      _filteredPlaces = _applyFiltersAndSorting(_places);
    });
  }

  // Удалить конкретный район
  void _removeArea(int areaId) {
    setState(() {
      final newAreas = List<int>.from(_currentFilters.selectedAreas);
      newAreas.remove(areaId);
      _currentFilters = _currentFilters.copyWith(selectedAreas: newAreas);
      _filteredPlaces = _applyFiltersAndSorting(_places);
    });
  }

  // Удалить конкретный тег
  void _removeTag(int tagId) {
    setState(() {
      final newTags = List<int>.from(_currentFilters.selectedTags);
      newTags.remove(tagId);
      _currentFilters = _currentFilters.copyWith(selectedTags: newTags);
      _filteredPlaces = _applyFiltersAndSorting(_places);
    });
  }

  // Получить название категории по ID
  String _getCategoryName(int categoryId) {
    final category = mockPlaceCategories.firstWhere(
          (cat) => cat['id'] == categoryId,
      orElse: () => {'name': 'Категория $categoryId'},
    );
    return category['name'];
  }

  // Получить название района по ID
  String _getAreaName(int areaId) {
    final area = mockAreas.firstWhere(
          (a) => a['id'] == areaId,
      orElse: () => {'name': 'Район $areaId'},
    );
    return area['name'];
  }

  // Получить название тега по ID
  String _getTagName(int tagId) {
    final tag = mockPlaceTags.firstWhere(
          (t) => t['id'] == tagId,
      orElse: () => {'name': 'Тег $tagId'},
    );
    return tag['name'];
  }

  // Виджет для чипса категории
  Widget _buildCategoryChip(int categoryId) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AppFilterChip(
        label: _getCategoryName(categoryId),
        onDelete: () => _removeCategory(categoryId),
      ),
    );
  }

  // Виджет для чипса района
  Widget _buildAreaChip(int areaId) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AppFilterChip(
        label: _getAreaName(areaId),
        onDelete: () => _removeArea(areaId),
      ),
    );
  }

  // Виджет для чипса тега
  Widget _buildTagChip(int tagId) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AppFilterChip(
        label: _getTagName(tagId),
        onDelete: () => _removeTag(tagId),
      ),
    );
  }

  // Виджет для статичной шапки
  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Индикатор перетаскивания
        DragIndicator(
          color: AppDesignSystem.handleBarColor,
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: 26),

        // Заголовок
        Center(
          child: Text(
            'Места',
            style: AppTextStyles.title(),
          ),
        ),
        const SizedBox(height: 28),

        // Поиск и фильтрация
        AppSearchField(
          controller: _searchController,
          hint: 'Поиск мест',
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _filteredPlaces = _applyFiltersAndSorting(_places);
            });
          },
          onFilterTap: _openFilterSheet,
        ),
        const SizedBox(height: 16),

        // Показываем активные фильтры как отдельные чипсы
        if (_currentFilters.hasActiveFilters)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Чипсы для категорий
                  ..._currentFilters.selectedCategories.map(_buildCategoryChip),

                  // Чипсы для районов
                  ..._currentFilters.selectedAreas.map(_buildAreaChip),

                  // Чипсы для тегов
                  ..._currentFilters.selectedTags.map(_buildTagChip),
                ],
              ),
            ),
          ),

        // Сортировка и рандом
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MenuAnchor(
                style: MenuStyle(
                  padding: const WidgetStatePropertyAll(EdgeInsets.all(16)),
                  backgroundColor: const WidgetStatePropertyAll(AppDesignSystem.backgroundColor),
                  elevation: const WidgetStatePropertyAll(0),
                  shadowColor: const WidgetStatePropertyAll(Colors.transparent),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
                onOpen: () {
                  setState(() {
                    _isSortingMenuOpen = true;
                  });
                },
                onClose: () {
                  setState(() {
                    _isSortingMenuOpen = false;
                  });
                },
                builder: (context, controller, child) => IconButton(
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        sortingValue,
                        style: AppTextStyles.small(
                          color: AppDesignSystem.textColorSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        turns: _isSortingMenuOpen ? 0 : -0.25,
                        duration: const Duration(milliseconds: 200),
                        child: SvgPicture.asset(
                          'assets/V.svg',
                          width: 4,
                          height: 8,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                ),
                menuChildren: sortingItems
                    .map(
                      (e) => MenuItemButton(
                    style: MenuItemButton.styleFrom(
                      minimumSize: const Size(266, 27),
                      maximumSize: const Size(266, 27),
                    ),
                    onPressed: () {
                      _onSortingChanged(e);
                    },
                    child: SizedBox(
                      width: 290,
                      height: 114,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e),
                          // Индикатор выбора
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: sortingValue == e
                                    ? AppDesignSystem.primaryColor
                                    : AppDesignSystem.whiteColor,
                                width: 1,
                              ),
                            ),
                            child: sortingValue == e
                                ? Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppDesignSystem.primaryColor,
                              ),
                            )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
              GestureDetector(
                onTap: _shuffleRandom,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                  color: AppDesignSystem.greyLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/random.svg',
                        width: 16,
                        height: 16,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Рандом',
                        style: AppTextStyles.small(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Виджет для скроллируемого контента с карточками
  Widget _buildScrollableContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(14.0),
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Text('Ошибка загрузки мест'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadPlaces,
              child: Text('Попробовать снова'),
            ),
          ],
        ),
      );
    }

    if (!_isLoading && !_hasError && _filteredPlaces.isNotEmpty) {
      return GridView.builder(
        controller: _cardsScrollController, // Используем контроллер для скролла
        physics: const BouncingScrollPhysics(), // Включаем физику скролла
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 187 / 260,
        ),
        itemCount: _filteredPlaces.length,
        itemBuilder: (context, index) {
          final place = _filteredPlaces[index];
          final isFavorite = _favoriteStatus[place.id] ?? false;
          final totalImages = place.images.length;
          final currentImageIndex = 0;

          return PlaceCard(
            place: place,
            isFavorite: isFavorite,
            currentImageIndex: currentImageIndex,
            totalImages: totalImages > 0 ? totalImages : 1,
            onTap: () => _onPlaceTap(place),
            onFavoriteTap: () => _toggleFavorite(place.id),
          );
        },
      );
    }

    if (!_isLoading && !_hasError && _filteredPlaces.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.place, size: 60, color: AppDesignSystem.greyMedium),
              const SizedBox(height: 16),
              Text(
                _currentFilters.hasActiveFilters ? 'Места не найдены по выбранным фильтрам' : 'Места не найдены',
                style: AppTextStyles.body(
                  color: AppDesignSystem.greyMedium,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              if (_currentFilters.hasActiveFilters)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentFilters = const PlaceFilters();
                      _filteredPlaces = _applyFiltersAndSorting(_places);
                    });
                  },
                  child: Text('Сбросить все фильтры'),
                )
              else
                ElevatedButton(
                  onPressed: _loadPlaces,
                  child: Text('Обновить'),
                ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Статичная шапка
        _buildHeader(),

        // Скроллируемые карточки
        Expanded(
          child: _buildScrollableContent(),
        ),
      ],
    );
  }
}