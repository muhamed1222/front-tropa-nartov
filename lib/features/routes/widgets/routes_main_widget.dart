import 'dart:ui'; // Добавлено для ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/api_models.dart' hide Image;
import '../../../core/constants/app_design_system.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/utils/auth_helper.dart';
import '../../../core/utils/logger.dart';
import '../../../core/di/injection_container.dart' as di;
import '../../../services/auth_service.dart';
import '../../../services/strapi_service.dart';
import '../data/datasources/routes_strapi_datasource.dart';
import '../../home/presentation/bloc/home_bloc.dart';
import '../../home/domain/entities/place.dart' as home_entities;
import '../../../shared/domain/entities/image.dart' as shared_entities;
import '../../../shared/domain/entities/review.dart' as shared_entities_review;
import '../../home/presentation/widgets/rating_dialog.dart';
import '../../places/data/datasources/filters_datasource.dart';
import '../presentation/bloc/routes_bloc.dart';
import 'routes_filter_widget.dart';

class RoutesMainWidget extends StatefulWidget {
  const RoutesMainWidget({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  State<RoutesMainWidget> createState() => _RoutesMainWidgetState();
}

class _RoutesMainWidgetState extends State<RoutesMainWidget> {
  // Контроллер для поиска
  final TextEditingController _searchController = TextEditingController();

  // Состояние для анимации иконки сортировки
  bool _isSortingMenuOpen = false;

  // Контроллер для скролла карточек
  late ScrollController _cardsScrollController;

  // Типы маршрутов из Strapi
  List<Map<String, dynamic>> _routeTypes = [];

  @override
  void initState() {
    super.initState();
    _cardsScrollController = widget.scrollController ?? ScrollController();

    // Загружаем типы маршрутов из Strapi
    _loadRouteTypes();

    // Маршруты загружаются через BLoC при создании BlocProvider

    // Устанавливаем светлый status bar при открытии
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  /// Загрузить типы маршрутов из Strapi
  Future<void> _loadRouteTypes() async {
    try {
      final filtersDatasource = FiltersDatasource(strapiService: di.sl<StrapiService>());
      final routeTypes = await filtersDatasource.getRouteTypes();
      
      setState(() {
        _routeTypes = routeTypes;
      });
      AppLogger.debug('✅ Типы маршрутов загружены из Strapi: ${_routeTypes.length}');
    } catch (e) {
      AppLogger.debug('❌ Ошибка загрузки типов маршрутов: $e');
      AppLogger.debug('⚠️ Используются fallback типы (Пеший, Авто)');
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

  void _onSortingChanged(String newValue) {
    context.read<RoutesBloc>().add(ApplySorting(newValue));
  }

  void _shuffleRandom(RoutesLoaded state) {
    // Открываем случайную карточку маршрута вместо перетасовки списка
    if (state.filteredRoutes.isEmpty) return;

    // Выбираем случайный маршрут из отфильтрованного списка
    final random = state.filteredRoutes.length > 1
        ? state.filteredRoutes.length - 1
        : 0;
    final randomRoute = state.filteredRoutes[random];

    // Открываем детали случайного маршрута
    _onRouteTap(randomRoute);
  }

  void _openRouteFilterSheet(RoutesLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppDesignSystem.textColorPrimary.withValues(alpha: 0.5),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => RoutesFilterWidget(
          initialFilters: state.filters,
          scrollController: scrollController,
          routeTypes: _routeTypes, // Передаем типы из Strapi
          onFiltersApplied: (RouteFilters newFilters) {
            context.read<RoutesBloc>().add(ApplyFilters(newFilters));
          },
        ),
      ),
    );
  }

  void _onRouteTap(AppRoute route) {
    // Получаем статус избранного из BLoC state
    final state = context.read<RoutesBloc>().state;
    final isFavorite = state is RoutesLoaded
        ? (state.favoriteStatus[route.id] ?? false)
        : false;

    // Сохраняем context перед async операцией
    if (!mounted) return;
    final currentContext = context;

    // Открываем детали маршрута
    showModalBottomSheet(
      context: currentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RouteDetailWidget(
        route: route,
        isFavorite: isFavorite,
        onFavoriteTap: () {
          // Закрываем bottom sheet
          Navigator.of(context).pop();
          // Переключаем избранное
          if (state is RoutesLoaded) {
            _toggleFavorite(state, route.id);
          }
        },
      ),
    );
  }

  void _toggleFavorite(RoutesLoaded state, int routeId) async {
    // Сохраняем context и mounted перед async операцией
    if (!mounted) return;
    final currentContext = context;
    final bloc = currentContext.read<RoutesBloc>();
    
    try {
      await AuthHelper.requireAuthentication();
    } on AuthException catch (e) {
      if (mounted) {
        AppSnackBar.showError(currentContext, e.message);
      }
      return;
    }

    try {
      if (!mounted) return;
      bloc.add(ToggleFavorite(routeId));

      final currentStatus = state.favoriteStatus[routeId] ?? false;
      if (mounted) {
        AppSnackBar.showSuccess(
          currentContext,
          currentStatus
              ? 'Маршрут удален из избранного'
              : 'Маршрут добавлен в избранное',
        );
      }
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('404') || errorMessage.contains('500')) {
        AppSnackBar.showInfo(
          currentContext,
          'Функционал избранного для маршрутов находится в разработке',
        );
      } else {
        AppSnackBar.showError(
          currentContext,
          'Не удалось изменить избранное: $errorMessage',
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    context.read<RoutesBloc>().add(SearchRoutes(query));
  }

  // Удалить конкретный тип маршрута
  void _removeRouteType(RoutesLoaded state, String type) {
    final newSelectedTypes = List<String>.from(state.filters.selectedTypes);
    newSelectedTypes.remove(type);
    final newFilters = state.filters.copyWith(selectedTypes: newSelectedTypes);
    context.read<RoutesBloc>().add(ApplyFilters(newFilters));
  }

  // Сбросить фильтр дистанции
  void _resetDistanceFilter(RoutesLoaded state) {
    final newFilters = state.filters.copyWith(
      minDistance: 1.0,
      maxDistance: 30.0,
    );
    context.read<RoutesBloc>().add(ApplyFilters(newFilters));
  }

  void _resetAllFilters() {
    context.read<RoutesBloc>().add(const ResetFilters());
  }

  // Виджет для статичной шапки
  Widget _buildHeader(RoutesLoaded state) {
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
          onFilterTap: () => _openRouteFilterSheet(state),
          onChanged: _onSearchChanged,
        ),
        const SizedBox(height: 16),

        // Показываем активные фильтры как отдельные чипсы
        if (state.filters.hasActiveFilters)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Чипсы для типов маршрутов
                  ...state.filters.selectedTypes.map((type) => _buildRouteTypeChip(state, type)),

                  // Чипс для дистанции (если отличается от стандартной)
                  if (state.filters.minDistance > 1.0 || state.filters.maxDistance < 30.0)
                    _buildDistanceChip(state),
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
                        state.sortType,
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
                menuChildren: RoutesBloc.sortingItems
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
                                color: state.sortType == e
                                    ? AppDesignSystem.primaryColor
                                    : AppDesignSystem.whiteColor,
                                width: 1,
                              ),
                            ),
                            child: state.sortType == e
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
                onTap: () => _shuffleRandom(state),
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
  Widget _buildScrollableContent(RoutesLoaded state) {
    if (state.isLoading && state.routes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.filteredRoutes.isNotEmpty) {
      final bloc = context.read<RoutesBloc>();
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
        itemCount: state.filteredRoutes.length,
        itemBuilder: (context, index) {
          final route = state.filteredRoutes[index];
          final isFavorite = state.favoriteStatus[route.id] ?? false;
          final imageUrl = bloc.getRouteImageUrl(route, state.routeImages);

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
                              CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppDesignSystem.blackColor,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppDesignSystem.primaryColor,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) {
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
                                onTap: () => _toggleFavorite(state, route.id),
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

    if (state.filteredRoutes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.route, size: 60, color: AppDesignSystem.greyMedium),
            const SizedBox(height: 16),
            Text(
              state.filters.hasActiveFilters ? 'Маршруты не найдены по выбранным фильтрам' : 'Маршруты не найдены',
              style: AppTextStyles.body(
                color: AppDesignSystem.greyMedium,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            if (state.filters.hasActiveFilters)
              PrimaryButton(
                text: 'Сбросить все фильтры',
                onPressed: _resetAllFilters,
              )
            else
              PrimaryButton(
                text: 'Обновить',
                onPressed: () => context.read<RoutesBloc>().add(const LoadRoutes(forceRefresh: true)),
              ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // Виджет для чипса типа маршрута
  Widget _buildRouteTypeChip(RoutesLoaded state, String type) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AppFilterChip(
        label: type,
        onDelete: () => _removeRouteType(state, type),
      ),
    );
  }

  // Виджет для чипса дистанции
  Widget _buildDistanceChip(RoutesLoaded state) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AppFilterChip(
        label: '${state.filters.minDistance.toInt()}-${state.filters.maxDistance.toInt()} км',
        onDelete: () => _resetDistanceFilter(state),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoutesBloc, RoutesState>(
      builder: (context, state) {
        if (state is RoutesLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is RoutesError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    text: 'Попробовать снова',
                    onPressed: () => context.read<RoutesBloc>().add(const LoadRoutes(forceRefresh: true)),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is RoutesLoaded) {
          return Column(
            children: [
              // Статичная шапка
              _buildHeader(state),

              // Скроллируемые карточки
              Expanded(
                child: _buildScrollableContent(state),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class RouteDetailWidget extends StatefulWidget {
  final AppRoute route;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const RouteDetailWidget({
    super.key,
    required this.route,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  @override
  State<RouteDetailWidget> createState() => _RouteDetailWidgetState();
}

class _RouteDetailWidgetState extends State<RouteDetailWidget> {
  List<Review> _reviews = [];
  bool _isLoadingReviews = false;
  bool _reviewsLoaded = false;
  String? _reviewsError;
  final StrapiService _strapiService = di.sl<StrapiService>();
  final RoutesStrapiDatasource _routesDatasource = RoutesStrapiDatasource();

  // Данные маршрута
  AppRoute? _fullRoute; // Полные данные маршрута с местами
  bool _isLoadingRoute = false;
  String? _routeError;
  Map<int, bool> _placesVisitStatus = {}; // Статусы посещений мест

  @override
  void initState() {
    super.initState();
    // Загружаем полные данные маршрута и отзывы
    _loadRouteData();
    _loadReviews();
  }

  /// Загружает полные данные маршрута с местами
  Future<void> _loadRouteData() async {
    if (_isLoadingRoute) return;

    setState(() {
      _isLoadingRoute = true;
      _routeError = null;
    });

    try {
      // Загружаем полные данные маршрута из Strapi
      final route = await _routesDatasource.getRouteById(widget.route.id);
      
      if (route != null && mounted) {
        setState(() {
          _fullRoute = route;
        });

        // Загружаем статусы посещений для всех мест маршрута
        if (route.places != null && route.places!.isNotEmpty) {
          final placeIds = route.places!.map((p) => p.placeId).toList();
          final userId = await _strapiService.getCurrentUserId();
          if (userId != null) {
            final visitStatus = await _strapiService.getPlacesVisitStatus(placeIds, userId);
            
            if (mounted) {
              setState(() {
                _placesVisitStatus = visitStatus;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _routeError = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
        });
      }
    }
  }

  Future<void> _loadReviews() async {
    if (_isLoadingReviews || _reviewsLoaded) return;

    setState(() {
      _isLoadingReviews = true;
      _reviewsError = null;
    });

    try {
      // Загружаем отзывы из Strapi
      final strapiReviews = await _strapiService.getRouteReviews(widget.route.id);
      
      // Конвертируем StrapiReview в Review
      final reviews = strapiReviews.map((sr) => Review(
        id: sr.id,
        userId: int.tryParse(sr.userId) ?? 0,
        placeId: sr.place?.id,
        routeId: sr.route?.id,
        rating: sr.rating.toInt(),
        comment: sr.comment,
        photos: sr.photos.map((p) => p.url).toList(),
        createdAt: sr.createdAt,
        updatedAt: sr.updatedAt,
        userName: 'Пользователь', // Strapi не хранит имя в отзыве
        userAvatar: null,
      )).toList();
      
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _reviewsLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _reviewsError = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
    }
  }

  Future<void> _refreshReviews() async {
    setState(() {
      _reviewsLoaded = false;
      _reviewsError = null;
    });
    await _loadReviews();
  }

  /// Конвертирует Place из api_models в Place из home/domain/entities
  home_entities.Place _convertPlaceToHomeEntity(Place apiPlace) {
    return home_entities.Place(
      id: apiPlace.id,
      name: apiPlace.name,
      type: apiPlace.type,
      rating: apiPlace.rating,
      images: apiPlace.images.map((img) => shared_entities.Image(
        id: img.id.toString(),
        url: img.url,
        createdAt: img.createdAt?.toString() ?? '',
        updatedAt: img.updatedAt?.toString() ?? '',
      )).toList(),
      address: apiPlace.address,
      hours: apiPlace.hours,
      weekend: apiPlace.weekend,
      entry: apiPlace.entry,
      contacts: apiPlace.contacts,
      contactsEmail: apiPlace.contactsEmail,
      history: apiPlace.history,
      latitude: apiPlace.latitude,
      longitude: apiPlace.longitude,
      reviews: apiPlace.reviews.map((review) {
        return shared_entities_review.Review(
          id: review.id,
          text: review.text,
          authorId: review.userId ?? 0,
          authorName: review.authorName,
          authorAvatar: review.authorAvatar ?? '',
          rating: review.rating,
          placeId: review.placeId ?? 0,
          createdAt: review.createdAt?.toString() ?? '',
          updatedAt: review.updatedAt?.toString() ?? '',
          isActive: review.isActive ?? true,
        );
      }).toList(),
      description: apiPlace.description,
      overview: apiPlace.overview,
    );
  }

  /// Обработчик нажатия на кнопку "Маршрут"
  void _onRoutePressed(BuildContext context) {
    if (_fullRoute?.places == null || _fullRoute!.places!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Маршрут не содержит мест'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      // Получаем HomeBloc из контекста
      final homeBloc = _getHomeBloc(context);
      if (homeBloc == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось получить доступ к карте. Откройте главный экран.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Конвертируем RoutePlace в home domain entities Place
      final places = _fullRoute!.places!
          .map((routePlace) => _convertPlaceToHomeEntity(routePlace.place))
          .toList();

      // Вызываем событие для построения маршрута
      homeBloc.add(BuildRouteFromPlaces(places));

      // Закрываем RouteDetailWidget
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при создании маршрута: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Получает HomeBloc из доступного контекста
  HomeBloc? _getHomeBloc(BuildContext context) {
    try {
      return BlocProvider.of<HomeBloc>(context, listen: false);
    } catch (e) {
      // Пробуем найти в дереве предков
      HomeBloc? foundBloc;
      context.visitAncestorElements((element) {
        try {
          final bloc = BlocProvider.of<HomeBloc>(element, listen: false);
          if (bloc != null) {
            foundBloc = bloc;
            return false; // Прекращаем поиск
          }
        } catch (e) {
          // Продолжаем поиск
        }
        return true;
      });
      return foundBloc;
    }
  }

  /// Показывает диалог оценки маршрута
  void _showRatingDialog(BuildContext context) {
    RatingDialog.showForRoute(
      context,
      widget.route,
      onReviewAdded: () {
        // Обновляем список отзывов после добавления нового
        _refreshReviews();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppDesignSystem.whiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDesignSystem.borderRadiusLarge),
                topRight: Radius.circular(AppDesignSystem.borderRadiusLarge),
              ),
            ),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Индикатор закрытия
                      Center(
                        child: Container(
                          width: AppDesignSystem.handleBarWidth,
                          height: AppDesignSystem.handleBarHeight,
                          margin: const EdgeInsets.only(
                              top: AppDesignSystem.spacingSmall,
                              bottom: AppDesignSystem.spacingXLarge),
                          decoration: BoxDecoration(
                            color: AppDesignSystem.handleBarColor,
                            borderRadius: BorderRadius.circular(
                                AppDesignSystem.borderRadiusTiny),
                          ),
                        ),
                      ),

                      // Шапка
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppDesignSystem.paddingHorizontal),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.route.name,
                                    style: AppTextStyles.title(
                                        color: AppDesignSystem.blackColor),
                                  ),
                                ),
                                const SizedBox(
                                    width: AppDesignSystem.spacingLarge),
                                // Кнопка избранного с блюром
                                GestureDetector(
                                  onTap: widget.onFavoriteTap,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(34),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 6, sigmaY: 6),
                                      child: Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: AppDesignSystem.blackColor
                                              .withValues(alpha: 0.05),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            widget.isFavorite
                                                ? 'assets/bookyes.svg'
                                                : 'assets/bookmark_empty.svg',
                                            width: 14,
                                            height: 17,
                                            fit: BoxFit.contain,
                                            colorFilter: const ColorFilter.mode(
                                              AppDesignSystem.whiteColor,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 11),

                            // Теги
                            Row(
                              children: [
                                _buildTag(widget.route.typeName ?? 'Пеший'),
                                const SizedBox(width: 6),
                                _buildTag('${widget.route.distance.toInt()} км'),
                              ],
                            ),
                            const SizedBox(height: 11),

                            // Описание
                            Text(
                              widget.route.description,
                              style: AppTextStyles.small(
                                color: AppDesignSystem.textColorHint,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDesignSystem.spacingXLarge),

                      // Детали маршрута
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppDesignSystem.paddingHorizontal),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Детали маршрута',
                              style: AppTextStyles.body(
                                fontWeight: AppDesignSystem.fontWeightSemiBold,
                                color: AppDesignSystem.blackColor,
                              ),
                            ),
                            const SizedBox(height: AppDesignSystem.spacingMedium),
                            _buildDetailRow('assets/route.svg', 'Протяженность',
                                '${widget.route.distance.toInt()} км',
                                showBorder: true),
                            _buildDetailRow('assets/clock.svg', 'Время прохождения',
                                widget.route.formattedDuration,
                                showBorder: true),
                            _buildDetailRow('assets/flag.svg', 'Мест к посещению',
                                '${_fullRoute?.places?.length ?? widget.route.places?.length ?? 0}',
                                showBorder: false),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDesignSystem.spacingXLarge),

                      // Места (Таймлайн)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppDesignSystem.paddingHorizontal),
                        child: Text(
                          'Места',
                          style: AppTextStyles.body(
                            fontWeight: AppDesignSystem.fontWeightSemiBold,
                            color: AppDesignSystem.blackColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDesignSystem.spacingMedium),
                    ],
                  ),
                ),

                // Список мест с таймлайном
                // Места маршрута (таймлайн)
                if (_isLoadingRoute)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppDesignSystem.paddingVerticalMedium),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                else if (_routeError != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDesignSystem.paddingHorizontal),
                      child: Container(
                        padding: const EdgeInsets.all(AppDesignSystem.paddingVerticalMedium),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppDesignSystem.borderRadius),
                          color: AppDesignSystem.errorColor.withValues(alpha: 0.1),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Ошибка загрузки мест маршрута',
                              style: AppTextStyles.error(
                                fontWeight: AppDesignSystem.fontWeightBold,
                              ),
                            ),
                            const SizedBox(height: AppDesignSystem.spacingSmall),
                            Text(
                              _routeError!,
                              style: AppTextStyles.error(),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (_fullRoute?.places != null && _fullRoute!.places!.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDesignSystem.paddingHorizontal),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildPlaceTimelineItem(
                            context, index, _fullRoute!.places!.length),
                        childCount: _fullRoute!.places!.length,
                      ),
                    ),
                  )
                else
                  const SliverToBoxAdapter(
                    child: SizedBox.shrink(),
                  ),

                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: AppDesignSystem.spacingXXLarge),

                      // Отзывы заголовок
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppDesignSystem.paddingHorizontal),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Отзывы',
                              style: AppTextStyles.body(
                                fontWeight: AppDesignSystem.fontWeightSemiBold,
                                color: AppDesignSystem.blackColor,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppDesignSystem.paddingSmall,
                                  vertical: AppDesignSystem.paddingTiny),
                              decoration: BoxDecoration(
                                color: AppDesignSystem.greyLight,
                                borderRadius: BorderRadius.circular(
                                    AppDesignSystem.borderRadiusSmall),
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/star.svg',
                                    width: 14,
                                    height: 13,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(
                                      width: AppDesignSystem.spacingTiny),
                                  Text(
                                    widget.route.formattedRating,
                                    style: AppTextStyles.small(
                                      color: AppDesignSystem.blackColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Список отзывов (динамическая загрузка)
                      if (_isLoadingReviews)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppDesignSystem.paddingVerticalMedium),
                            child: Column(
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: AppDesignSystem.spacingSmall),
                                Text(
                                  'Загрузка отзывов...',
                                  style: AppTextStyles.body(
                                    color: AppDesignSystem.greyColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (_reviewsError != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppDesignSystem.paddingHorizontal),
                          child: Container(
                            padding: const EdgeInsets.all(AppDesignSystem.paddingVerticalMedium),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppDesignSystem.borderRadius),
                              color: AppDesignSystem.errorColor.withValues(alpha: 0.1),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Ошибка загрузки отзывов',
                                  style: AppTextStyles.error(
                                    fontWeight: AppDesignSystem.fontWeightBold,
                                  ),
                                ),
                                const SizedBox(height: AppDesignSystem.spacingSmall),
                                Text(
                                  _reviewsError!,
                                  style: AppTextStyles.error(),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppDesignSystem.spacingSmall),
                                PrimaryButton(
                                  text: 'Попробовать снова',
                                  onPressed: _refreshReviews,
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (_reviews.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppDesignSystem.paddingVerticalMedium),
                            child: Column(
                              children: [
                                SvgPicture.asset(
                                  'assets/reviews_empty.svg',
                                  width: 33,
                                  height: 32,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: AppDesignSystem.spacingLarge),
                                Text(
                                  'Пока нет отзывов',
                                  style: AppTextStyles.body(
                                    color: AppDesignSystem.greyColor,
                                  ),
                                ),
                                const SizedBox(height: AppDesignSystem.spacingSmall),
                                Text(
                                  'Будьте первым, кто оставит отзыв!',
                                  style: AppTextStyles.small(
                                    color: AppDesignSystem.greyColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Column(
                          children: _reviews.map((review) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppDesignSystem.paddingHorizontal),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ReviewCard(
                                  review: review,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                      // Отступ для нижней панели
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Нижняя панель с кнопками
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                  14, 14, 14, AppDesignSystem.spacingBottomButtons),
              decoration: BoxDecoration(
                color: AppDesignSystem.whiteColor,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDesignSystem.borderRadiusLarge)),
                boxShadow: [
                  BoxShadow(
                    color: AppDesignSystem.blackColor.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Кнопка "Оценить" - используем SecondaryButton
                  Expanded(
                    flex: 1,
                    child: SecondaryButton(
                      text: 'Оценить',
                      onPressed: () {
                        // Логика оценки маршрута
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Кнопка "Маршрут" - используем PrimaryButton
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      text: 'Маршрут',
                      onPressed: _fullRoute?.places != null &&
                              _fullRoute!.places!.isNotEmpty
                          ? () => _onRoutePressed(context)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDesignSystem.paddingMedium,
          vertical: 6),
      decoration: BoxDecoration(
        color: AppDesignSystem.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTextStyles.small(
          color: AppDesignSystem.primaryColor,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String iconPath, String label, String value,
      {required bool showBorder}) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppDesignSystem.paddingVertical),
      decoration: showBorder
          ? const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Color(0xFFF0F0F0))),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                iconPath,
                width: 16,
                height: 16,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  AppDesignSystem.greyMedium,
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (context) => Container(
                  width: 16,
                  height: 16,
                  color: Colors.grey[300],
                ),
                semanticsLabel: label,
                allowDrawingOutsideViewBox: false,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.body(
                  fontWeight: AppDesignSystem.fontWeightMedium,
                  color: AppDesignSystem.blackColor,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: AppTextStyles.body(
              color: AppDesignSystem.textColorHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceTimelineItem(
      BuildContext context, int index, int totalCount) {
    if (_fullRoute?.places == null || index >= _fullRoute!.places!.length) {
      return const SizedBox.shrink();
    }

    final routePlace = _fullRoute!.places![index];
    final place = routePlace.place;
    final isLast = index == totalCount - 1;
    final isVisited = _placesVisitStatus[place.id] ?? false;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Линия таймлайна
          SizedBox(
            width: 20,
            child: Column(
              children: [
                // Маркер (Кружок или галочка)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: index < 2
                        ? AppDesignSystem.primaryColor // Пройденное место
                        : AppDesignSystem.greyLight, // Непройденное место
                    shape: BoxShape.circle,
                  ),
                  child: index < 2
                      ? Center(
                          child: SvgPicture.asset(
                            'assets/checkmark.svg',
                            width: 10,
                            height: 8,
                            fit: BoxFit.contain,
                          ),
                        )
                      : null,
                ),
                // Линия
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFE9E9E9), // Или градиент
                      margin: const EdgeInsets.symmetric(
                          vertical: AppDesignSystem.spacingTiny),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppDesignSystem.spacingMedium),
          // Контент места
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: AppDesignSystem.spacingXLarge),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Фото места
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                        AppDesignSystem.borderRadiusMedium),
                    child: Container(
                      width: 100,
                      height: 85,
                      color: AppDesignSystem.greyMedium,
                      child: place.images.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: place.images.first.url,
                              width: 100,
                              height: 85,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppDesignSystem.greyMedium,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppDesignSystem.primaryColor,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.image,
                                      color: AppDesignSystem.whiteColor),
                            )
                          : const Icon(Icons.image,
                              color: AppDesignSystem.whiteColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Текст
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: AppTextStyles.small(
                            fontWeight: AppDesignSystem.fontWeightSemiBold,
                            color: AppDesignSystem.blackColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          place.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.error(
                            color: AppDesignSystem.textColorHint,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppDesignSystem.primaryColor
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Text(
                            place.type,
                            style: AppTextStyles.error(
                              color: AppDesignSystem.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceVisitedWidget extends StatefulWidget {
  final String placeName;
  final VoidCallback? onMarkAsVisited;
  final VoidCallback? onCancel;

  const PlaceVisitedWidget({
    super.key,
    required this.placeName,
    this.onMarkAsVisited,
    this.onCancel,
  });

  @override
  State<PlaceVisitedWidget> createState() => _PlaceVisitedWidgetState();
}

class _PlaceVisitedWidgetState extends State<PlaceVisitedWidget> {
  int _selectedOption = 0; // 0 - Нет, 1 - Да

  void _showPlaceVisitedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          // Блюр-фон
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.transparent,
            ),
          ),
          // Диалоговое окно
          AlertDialog(
            backgroundColor: AppDesignSystem.whiteColor,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDesignSystem.borderRadiusMedium)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок "Вы были здесь:"
                Text(
                  'Вы были здесь:',
                  style: AppTextStyles.small(
                    color: AppDesignSystem.textColorHint,
                  ),
                ),

                // Название места
                const SizedBox(height: AppDesignSystem.spacingSmall),
                Text(
                  widget.placeName,
                  style: AppTextStyles.bodyLarge(
                    fontWeight: AppDesignSystem.fontWeightSemiBold,
                    color: AppDesignSystem.blackColor,
                  ),
                ),

                // Вопрос
                const SizedBox(height: AppDesignSystem.spacingLarge),
                Text(
                  'Пометить место как пройденное?',
                  style: AppTextStyles.body(
                    fontWeight: AppDesignSystem.fontWeightMedium,
                    color: AppDesignSystem.blackColor,
                  ),
                ),

                // Радио-кнопки
                const SizedBox(height: AppDesignSystem.spacingLarge),
                _buildRadioOption(0, 'Нет'),
                const SizedBox(height: AppDesignSystem.spacingMedium),
                _buildRadioOption(1, 'Да'),

                // Кнопки действий
                const SizedBox(height: AppDesignSystem.spacingXXLarge),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onCancel?.call();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppDesignSystem.spacingMedium),
                          side: const BorderSide(
                              color: AppDesignSystem.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDesignSystem.borderRadius),
                          ),
                        ),
                        child: Text(
                          'Отменить',
                          style: AppTextStyles.button(
                            color: AppDesignSystem.primaryColor,
                            fontWeight: AppDesignSystem.fontWeightMedium,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDesignSystem.spacingMedium),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedOption == 1
                            ? () {
                                Navigator.of(context).pop();
                                widget.onMarkAsVisited?.call();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppDesignSystem.primaryColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppDesignSystem.spacingMedium),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDesignSystem.borderRadius),
                          ),
                          disabledBackgroundColor: AppDesignSystem.primaryColor
                              .withValues(alpha: 0.5),
                        ),
                        child: Text(
                          'Подтвердить',
                          style: AppTextStyles.button(
                            color: AppDesignSystem.whiteColor,
                            fontWeight: AppDesignSystem.fontWeightMedium,
                          ),
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
    );
  }

  Widget _buildRadioOption(int value, String text) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = value;
        });
      },
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _selectedOption == value
                    ? AppDesignSystem.primaryColor
                    : AppDesignSystem.shadowColor,
                width: 2,
              ),
            ),
            child: _selectedOption == value
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppDesignSystem.primaryColor,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppDesignSystem.spacingMedium),
          Text(
            text,
            style: AppTextStyles.body(
              color: AppDesignSystem.blackColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPlaceVisitedDialog(context),
      child: Container(
        padding: const EdgeInsets.all(AppDesignSystem.paddingLarge),
        decoration: BoxDecoration(
          color: AppDesignSystem.greyLight,
          borderRadius:
              BorderRadius.circular(AppDesignSystem.borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Вы были здесь:',
                  style: AppTextStyles.small(
                    color: AppDesignSystem.textColorHint,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.placeName,
                  style: AppTextStyles.body(
                    fontWeight: AppDesignSystem.fontWeightSemiBold,
                    color: AppDesignSystem.blackColor,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDesignSystem.paddingMedium, vertical: 6),
              decoration: BoxDecoration(
                color: AppDesignSystem.primaryColor,
                borderRadius:
                    BorderRadius.circular(AppDesignSystem.borderRadiusMedium),
              ),
              child: Text(
                'Отметить',
                style: AppTextStyles.small(
                  color: AppDesignSystem.whiteColor,
                  fontWeight: AppDesignSystem.fontWeightMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
