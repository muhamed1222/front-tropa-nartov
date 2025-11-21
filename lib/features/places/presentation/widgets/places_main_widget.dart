import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tropanartov/core/di/injection_container.dart' as di;
import 'package:tropanartov/features/home/presentation/bloc/home_bloc.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/utils/auth_helper.dart';
import '../../../../core/utils/logger.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../models/api_models.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/strapi_service.dart';
import '../../../home/data/datasources/mock_datasource.dart';
import '../../data/datasources/places_strapi_datasource.dart';
import '../../../../shared/data/datasources/mock_place_areas_for_place.dart';
import '../../../../shared/data/datasources/mock_place_categories_for_place.dart';
import '../../../../shared/data/datasources/mock_place_tags_for_place.dart';
import '../../data/datasources/filters_datasource.dart';
import 'places_filter_widget.dart';
import '../../../home/presentation/widgets/place_details_sheet_widget.dart';

class PlacesMainWidget extends StatefulWidget {
  const PlacesMainWidget({
    super.key,
    this.scrollController,
    this.initialSearchQuery,
    this.homeBloc,
  });

  final ScrollController? scrollController;
  final String? initialSearchQuery;
  final HomeBloc? homeBloc;

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
  
  // Ключ для поля поиска, чтобы гарантировать его пересоздание
  late final Key _searchFieldKey;

  List<Place> _places = [];
  List<Place> _filteredPlaces = [];
  bool _isLoading = true;
  bool _hasError = false;

  // Состояние фильтров
  PlaceFilters _currentFilters = const PlaceFilters();
  
  // Данные для фильтров из Strapi
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _areas = [];
  List<Map<String, dynamic>> _tags = [];
  bool _filtersLoaded = false;
  
  // FiltersDatasource для загрузки фильтров
  final FiltersDatasource _filtersDatasource = FiltersDatasource();

  // Состояние поиска
  late TextEditingController _searchController;
  String _searchQuery = '';

  // Map для хранения состояния избранного для каждого места
  final Map<int, bool> _favoriteStatus = {};
  
  // Map для хранения состояния посещенных мест
  final Map<int, bool> _visitedStatus = {};

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
    // Создаем уникальный ключ для поля поиска при каждой инициализации
    _searchFieldKey = ValueKey(DateTime.now().millisecondsSinceEpoch);
    _loadFilters(); // Загружаем фильтры из Strapi
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
  
  // Загрузка фильтров из Strapi
  Future<void> _loadFilters() async {
    try {
      final filters = await _filtersDatasource.getAllFilters();
      
      setState(() {
        _categories = filters['categories'] ?? [];
        _areas = filters['areas'] ?? [];
        _tags = filters['tags'] ?? [];
        _filtersLoaded = true;
      });
      
      AppLogger.debug('✅ Фильтры загружены: категорий=${_categories.length}, районов=${_areas.length}, тегов=${_tags.length}');
    } catch (e) {
      AppLogger.debug('❌ Ошибка загрузки фильтров: $e');
      AppLogger.debug('⚠️ Используются fallback данные (mock)');
      
      // Если загрузка из Strapi не удалась, используем mock данные
      setState(() {
        _categories = mockPlaceCategories;
        _areas = mockAreas;
        _tags = mockPlaceTags;
        _filtersLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    try {
      _searchController.dispose();
    } catch (e) {
      // Игнорируем ошибки dispose
    }
    
    // Не удаляем _cardsScrollController если он передан извне
    if (widget.scrollController == null) {
      try {
        _cardsScrollController.dispose();
      } catch (e) {
        // Игнорируем ошибки dispose
      }
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

      // Загружаем места из Strapi
      AppLogger.debug('📡 PlacesMainWidget: Загрузка мест из Strapi...');
      final strapiDatasource = PlacesStrapiDatasource(strapiService: di.sl<StrapiService>());
      final places = await strapiDatasource.getPlacesFromStrapi();
      AppLogger.debug('✅ PlacesMainWidget: Загружено мест из Strapi: ${places.length}');

      // Загружаем статусы избранного для всех мест
      await _loadFavoriteStatuses(places);
      
      // Загружаем статусы посещенных мест
      await _loadVisitedStatuses(places);

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

  // Метод для загрузки статусов избранного из Strapi
  Future<void> _loadFavoriteStatuses(List<Place> places) async {
    try {
      final strapiService = di.sl<StrapiService>();
      final userId = await strapiService.getCurrentUserId();
      if (userId == null) return;

      // Загружаем все избранное пользователя одним запросом
      final favorites = await strapiService.getFavorites(userId);
      final favoritePlaceIds = favorites
          .where((f) => f.place != null)
          .map((f) => f.place!.id)
          .toSet();

      // Обновляем статусы для всех мест
      for (final place in places) {
        _favoriteStatus[place.id] = favoritePlaceIds.contains(place.id);
      }
    } catch (e) {
      // Игнорируем ошибки, устанавливаем false для всех мест
      for (final place in places) {
        _favoriteStatus[place.id] = false;
      }
      print('❌ Ошибка загрузки статусов избранного: $e');
    }
  }
  
  // Метод для загрузки статусов посещенных мест из Strapi
  Future<void> _loadVisitedStatuses(List<Place> places) async {
    try {
      final strapiService = di.sl<StrapiService>();
      final userId = await strapiService.getCurrentUserId();
      if (userId == null) return;

      // Загружаем всю историю посещений одним запросом
      final visitedPlaces = await strapiService.getVisitedPlaces(userId);
      final visitedPlaceIds = visitedPlaces
          .where((v) => v.place != null)
          .map((v) => v.place!.id)
          .toSet();
      
      AppLogger.debug('🔍 Посещенные места (IDs): $visitedPlaceIds');
      
      // Обновляем статусы для всех мест
      for (final place in places) {
        _visitedStatus[place.id] = visitedPlaceIds.contains(place.id);
        if (visitedPlaceIds.contains(place.id)) {
          AppLogger.debug('✅ Место "${place.name}" (ID: ${place.id}) отмечено как посещенное');
        }
      }
    } catch (e) {
      // Игнорируем ошибки загрузки посещенных мест
      AppLogger.error('❌ Ошибка загрузки посещенных мест: $e');
    }
  }

  // Метод для переключения избранного через Strapi
  Future<void> _toggleFavorite(int placeId) async {
    // Проверяем авторизацию используя AuthHelper
    try {
      await AuthHelper.requireAuthentication();
    } on AuthException catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, e.message);
      }
      return;
    }

    // Получаем userId
    final strapiService = di.sl<StrapiService>();
    final userId = await strapiService.getCurrentUserId();
    if (userId == null) {
      if (mounted) {
        AppSnackBar.showError(context, 'Не удалось получить данные пользователя');
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
        // Удаляем из избранного
        await strapiService.removeFromFavoritesByPlaceOrRoute(
          userId: userId,
          placeId: placeId,
        );
        if (mounted) {
          AppSnackBar.showSuccess(
            context,
            'Место удалено из избранного',
          );
        }
      } else {
        // Добавляем в избранное
        await strapiService.addToFavorites(
          userId: userId,
          placeId: placeId,
        );
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
          categories: _filtersLoaded ? _categories : mockPlaceCategories,
          areas: _filtersLoaded ? _areas : mockAreas,
          tags: _filtersLoaded ? _tags : mockPlaceTags,
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

  void _onPlaceTap(Place place) async {
    // Конвертируем Place из api_models в Place из home/domain/entities
    final homePlace = place.toEntity();
    // Сохраняем корневой контекст до открытия bottom sheet для диалогов
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final rootContext = rootNavigator.overlay?.context ?? context;
    
    // Получаем HomeBloc из параметров или из контекста
    HomeBloc? homeBloc = widget.homeBloc;
    if (homeBloc == null) {
      try {
        homeBloc = context.read<HomeBloc>();
      } catch (e) {
        // Если HomeBloc недоступен, ничего не делаем
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true, // Включаем стандартное закрытие по жесту
      enableDrag: true, 
      useRootNavigator: true, // Используем root Navigator, чтобы создать отдельный Navigator stack
      builder: (bottomSheetContext) => PlaceDetailsSheet(
        place: homePlace,
        fullScreen: true,
        rootContext: rootContext,
        homeBloc: homeBloc, // Передаем HomeBloc явно
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
          key: _searchFieldKey, // Уникальный ключ для гарантии пересоздания виджета
          controller: _searchController,
          hint: 'Поиск мест',
          onChanged: (value) {
            // Проверяем, что виджет все еще смонтирован перед обновлением состояния
            if (mounted) {
            setState(() {
              _searchQuery = value;
              _filteredPlaces = _applyFiltersAndSorting(_places);
            });
            }
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
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 187 / 260,
        ),
        itemCount: _filteredPlaces.length,
        itemBuilder: (context, index) {
          final place = _filteredPlaces[index];
          final isFavorite = _favoriteStatus[place.id] ?? false;
          final totalImages = place.images.length;
          final currentImageIndex = 0;

          final isVisited = _visitedStatus[place.id] ?? false;
          
          return PlaceCard(
            place: place,
            isFavorite: isFavorite,
            isVisited: isVisited, // ✅ Загружаем из состояния
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