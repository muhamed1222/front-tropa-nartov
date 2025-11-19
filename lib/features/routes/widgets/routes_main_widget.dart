import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../../../models/api_models.dart' hide Image;
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/smooth_border_radius.dart';
import '../../../core/constants/app_design_system.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import 'routes_filter_widget.dart';
import '../../favourites/presentation/widgets/route_details_sheet_simple.dart';

class RoutesMainWidget extends StatefulWidget {
  const RoutesMainWidget({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  State<RoutesMainWidget> createState() => _RoutesMainWidgetState();
}

class _RoutesMainWidgetState extends State<RoutesMainWidget> {
  static const sortingItems = ['Сначала популярные', 'Сначала с высоким рейтингом', 'Сначала новые'];
  String sortingValue = sortingItems.first;
  final Map<int, List<String>> _routeImages = {};
  List<AppRoute> _routes = [];
  List<AppRoute> _filteredRoutes = [];
  bool _isLoading = true;
  bool _hasError = false;

  // Состояние фильтров
  RouteFilters _currentFilters = const RouteFilters();

  // Map для хранения состояния избранного для каждого маршрута
  final Map<int, bool> _favoriteStatus = {};

  // Контроллер для поиска
  final TextEditingController _searchController = TextEditingController();

  // Состояние для анимации иконки сортировки
  bool _isSortingMenuOpen = false;

  // Контроллер для скролла карточек
  late ScrollController _cardsScrollController;

  @override
  void initState() {
    super.initState();
    _cardsScrollController = widget.scrollController ?? ScrollController();
    _loadRoutes();

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

  Future<void> _loadRoutes() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final routes = await ApiService.getRoutes();

      // Загружаем статусы избранного для всех маршрутов
      await _loadFavoriteStatuses(routes);

      // Загружаем изображения для маршрутов
      await _loadRouteImages(routes);

      setState(() {
        _routes = routes;
        _filteredRoutes = _applyFiltersAndSorting(routes);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // Метод для загрузки статусов избранного для маршрутов
  Future<void> _loadFavoriteStatuses(List<AppRoute> routes) async {
    final token = await AuthService.getToken();
    if (token == null) return;

    for (final route in routes) {
      try {
        final isFavorite = await ApiService.isRouteFavorite(route.id, token);
        _favoriteStatus[route.id] = isFavorite;
      } catch (e) {
        _favoriteStatus[route.id] = false;
      }
    }
  }

  // Исправленный метод для загрузки изображений маршрутов
  Future<void> _loadRouteImages(List<AppRoute> routes) async {
    for (int i = 0; i < routes.length; i++) {
      final route = routes[i];
      try {
        final places = await ApiService.getPlaces();

        if (places.isNotEmpty) {
          final firstPlace = places.first;
          // Преобразуем List<Image> в List<String> (URL строки)
          final imageUrls = firstPlace.images.map((image) => image.url).toList();
          _routeImages[route.id] = imageUrls;
        } else {
          _routeImages[route.id] = [];
        }
      } catch (e) {
        _routeImages[route.id] = [];
        // Игнорируем ошибку загрузки изображения
      }
    }
  }

  // Исправленный метод для получения URL изображения маршрута
  String _getRouteImageUrl(AppRoute route) {
    final images = _routeImages[route.id];
    if (images != null && images.isNotEmpty) {
      return images.first; // Возвращаем первую картинку из списка
    }
    return ''; // Возвращаем пустую строку если нет изображений
  }

  // Метод для переключения избранного
  Future<void> _toggleFavorite(int routeId) async {
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
    final currentStatus = _favoriteStatus[routeId] ?? false;
    
    // Оптимистично обновляем UI
    if (mounted) {
      setState(() {
        _favoriteStatus[routeId] = !currentStatus;
      });
    }

    try {
      if (currentStatus) {
        await ApiService.removeRouteFromFavorites(routeId, token);
        if (mounted) {
          AppSnackBar.showSuccess(
            context,
            'Маршрут удален из избранного',
          );
        }
      } else {
        await ApiService.addRouteToFavorites(routeId, token);
        if (mounted) {
          AppSnackBar.showSuccess(
            context,
            'Маршрут добавлен в избранное',
          );
        }
      }
    } catch (e) {
      // Откатываем изменения при ошибке
      if (mounted) {
        setState(() {
          _favoriteStatus[routeId] = currentStatus;
        });
        
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        // Если ошибка 404 или 500, возможно API еще не реализовано на backend
        if (errorMessage.contains('404') || errorMessage.contains('500')) {
          AppSnackBar.showInfo(
            context,
            'Функционал избранного для маршрутов находится в разработке',
          );
        } else {
          AppSnackBar.showError(
            context,
            'Не удалось изменить избранное: $errorMessage',
          );
        }
      }
    }
  }

  List<AppRoute> _applyFiltersAndSorting(List<AppRoute> routes) {
    // Сначала применяем фильтры
    List<AppRoute> filteredRoutes = _applyFilters(routes);

    // Затем применяем сортировку
    return _applySorting(filteredRoutes, sortingValue);
  }

  List<AppRoute> _applyFilters(List<AppRoute> routes) {
    return routes.where((route) {
      // Фильтр по типу маршрута
      if (_currentFilters.selectedTypes.isNotEmpty) {}

      // Фильтр по дистанции
      if (route.distance < _currentFilters.minDistance || route.distance > _currentFilters.maxDistance) {
        return false;
      }

      return true;
    }).toList();
  }

  List<AppRoute> _applySorting(List<AppRoute> routes, String sortType) {
    List<AppRoute> sortedRoutes = List.from(routes);

    switch (sortType) {
      case 'Сначала популярные':
        sortedRoutes.sort((a, b) => b.rating.compareTo(a.rating));
        break;

      case 'Сначала с высоким рейтингом':
        sortedRoutes.sort((a, b) => b.rating.compareTo(a.rating));
        break;

      case 'Сначала новые':
        sortedRoutes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;

      case 'Рандомный порядок':
        sortedRoutes.shuffle();
        break;

      default:
        break;
    }

    return sortedRoutes;
  }

  void _onSortingChanged(String newValue) {
    setState(() {
      sortingValue = newValue;
      _filteredRoutes = _applyFiltersAndSorting(_routes);
    });
  }

  void _shuffleRandom() {
    // Открываем случайную карточку маршрута вместо перетасовки списка
    if (_filteredRoutes.isEmpty) return;
    
    // Выбираем случайный маршрут из отфильтрованного списка
    final random = Random().nextInt(_filteredRoutes.length);
    final randomRoute = _filteredRoutes[random];
    
    // Открываем детали случайного маршрута
    _onRouteTap(randomRoute);
  }

  void _openRouteFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppDesignSystem.textColorPrimary.withValues(alpha: 0.5),
      builder:
          (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder:
            (context, scrollController) => RoutesFilterWidget(
          initialFilters: _currentFilters,
          scrollController: scrollController,
          onFiltersApplied: (RouteFilters newFilters) {
            setState(() {
              _currentFilters = newFilters;
              _filteredRoutes = _applyFiltersAndSorting(_routes);
            });
          },
        ),
      ),
    );
  }

  void _onRouteTap(AppRoute route) {
    // Открываем детали маршрута
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RouteDetailsSheetSimple(
        route: route,
      ),
    );
  }

  // Удалить конкретный тип маршрута
  void _removeRouteType(String type) {
    setState(() {
      final newSelectedTypes = List<String>.from(_currentFilters.selectedTypes);
      newSelectedTypes.remove(type);
      _currentFilters = _currentFilters.copyWith(selectedTypes: newSelectedTypes);
      _filteredRoutes = _applyFiltersAndSorting(_routes);
    });
  }

  // Сбросить фильтр дистанции
  void _resetDistanceFilter() {
    setState(() {
      _currentFilters = _currentFilters.copyWith(
        minDistance: 1.0,
        maxDistance: 30.0,
      );
      _filteredRoutes = _applyFiltersAndSorting(_routes);
    });
  }

  // Виджет для чипса типа маршрута
  Widget _buildRouteTypeChip(String type) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AppFilterChip(
        label: type,
        onDelete: () => _removeRouteType(type),
      ),
    );
  }

  // Виджет для чипса дистанции
  Widget _buildDistanceChip() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AppFilterChip(
        label: '${_currentFilters.minDistance.toInt()}-${_currentFilters.maxDistance.toInt()} км',
        onDelete: _resetDistanceFilter,
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
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: DragIndicator(
              color: AppDesignSystem.handleBarColor,
              padding: EdgeInsets.zero,
            ),
          ),
        ),

        // Заголовок
        Padding(
          padding: const EdgeInsets.only(top: 26, bottom: 28),
          child: Center(
            child: Text(
                'Маршруты',
                style: AppTextStyles.title(fontWeight: AppDesignSystem.fontWeightBold)
            ),
          ),
        ),

        // Поиск и фильтрация
        AppSearchField(
          controller: _searchController,
          hint: 'Поиск маршрутов',
          onFilterTap: _openRouteFilterSheet,
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
                  // Чипсы для типов маршрутов
                  ..._currentFilters.selectedTypes.map(_buildRouteTypeChip),

                  // Чипс для дистанции (если отличается от стандартной)
                  if (_currentFilters.minDistance > 1.0 || _currentFilters.maxDistance < 30.0)
                    _buildDistanceChip(),
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
                builder:
                    (context, controller, child) => IconButton(
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
                menuChildren:
                sortingItems
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Ошибка загрузки маршрутов'),
              const SizedBox(height: 10),
              PrimaryButton(
                text: 'Попробовать снова',
                onPressed: _loadRoutes,
              ),
            ],
          ),
        ),
      );
    }

    if (!_isLoading && !_hasError && _filteredRoutes.isNotEmpty) {
      return GridView.builder(
        controller: _cardsScrollController,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 171 / 260,
        ),
        itemCount: _filteredRoutes.length,
        itemBuilder: (context, index) {
          final route = _filteredRoutes[index];
          final isFavorite = _favoriteStatus[route.id] ?? false;
          final imageUrl = _getRouteImageUrl(route);

          return GestureDetector(
            onTap: () => _onRouteTap(route),
            child: Stack(
              children: [
                Column(
                  children: [
                    // Карточка с изображением - ФОТО ЗАНИМАЕТ ВСЁ ПРОСТРАНСТВО
                    Container(
                      width: 187,
                      height: 218,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppDesignSystem.borderRadius),
                        color: imageUrl.isEmpty ? AppDesignSystem.primaryColor : Colors.transparent,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppDesignSystem.borderRadius),
                        child: Stack(
                          children: [
                            // Фоновая картинка маршрута на ВСЁ ПРОСТРАНСТВО
                            if (imageUrl.isNotEmpty)
                              Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppDesignSystem.blackColor,
                                  );
                                },
                              )
                            else
                              Container(
                                color: AppDesignSystem.primaryColor,
                              ),

                            // Градиент для лучшей читаемости текста
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppDesignSystem.borderRadius),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.6),
                                  ],
                                ),
                              ),
                            ),

                            // Верхняя часть - кнопка избранного
                            Positioned(
                              top: 10,
                              left: 10,
                              child: FavoriteButton(
                                isFavorite: isFavorite,
                                onTap: () => _toggleFavorite(route.id),
                              ),
                            ),

                            // Тип маршрута и протяженность (из route)
                            Positioned(
                              bottom: AppDesignSystem.spacingMedium - 2,
                              left: AppDesignSystem.spacingSmall + 2,
                              right: AppDesignSystem.spacingSmall + 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      // Тип маршрута (из route)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppDesignSystem.spacingSmall,
                                          vertical: AppDesignSystem.spacingTiny,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(AppDesignSystem.borderRadiusXXLarge),
                                          color: AppDesignSystem.textColorWhite.withValues(alpha: 0.2),
                                        ),
                                        child: Text(
                                          route.typeName.toString(),
                                          style: AppTextStyles.error(
                                            color: AppDesignSystem.textColorWhite,
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: AppDesignSystem.spacingTiny),
                                      // Протяженность маршрута (из route)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppDesignSystem.spacingSmall,
                                          vertical: AppDesignSystem.spacingTiny,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(AppDesignSystem.borderRadiusXXLarge),
                                          color: AppDesignSystem.textColorWhite.withValues(alpha: 0.2),
                                        ),
                                        child: Text(
                                          '${route.distance.toInt()} км',
                                          style: AppTextStyles.error(
                                            color: AppDesignSystem.textColorWhite,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: AppDesignSystem.spacingSmall),

                    // Текст под карточкой (все данные из route)
                    Container(
                      width: AppDesignSystem.cardMinHeight,
                      padding: const EdgeInsets.symmetric(horizontal: AppDesignSystem.spacingTiny),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Название маршрута (из route)
                          Text(
                            route.name,
                            style: AppTextStyles.small(
                              fontWeight: AppDesignSystem.fontWeightSemiBold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: AppDesignSystem.spacingTiny),

                          // Описание маршрута (из route)
                          Text(
                            route.description,
                            style: AppTextStyles.error(
                              color: AppDesignSystem.textColorSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Палочка поверх карточки
                Positioned(
                  top: 97, // отступ сверху
                  bottom: 157, // отступ снизу 183-26
                  left: 162, // отступ слева
                  right: 22, // отступ справа
                  child: Transform.rotate(
                    angle: -90 * (3.14159265359 / 90),
                    child: Container(
                      width: 26,
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.white, // #FFF
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    if (!_isLoading && !_hasError && _filteredRoutes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.route, size: 60, color: AppDesignSystem.greyMedium),
            const SizedBox(height: 16),
            Text(
              _currentFilters.hasActiveFilters ? 'Маршруты не найдены по выбранным фильтрам' : 'Маршруты не найдены',
              style: AppTextStyles.body(
                color: AppDesignSystem.greyMedium,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            if (_currentFilters.hasActiveFilters)
              PrimaryButton(
                text: 'Сбросить все фильтры',
                onPressed: () {
                  setState(() {
                    _currentFilters = const RouteFilters();
                    _filteredRoutes = _applyFiltersAndSorting(_routes);
                  });
                },
              )
            else
              PrimaryButton(
                text: 'Обновить',
                onPressed: _loadRoutes,
              ),
          ],
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