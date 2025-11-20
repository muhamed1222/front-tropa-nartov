import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../../models/api_models.dart' hide Image;
import '../../../services/auth_service.dart';
import '../../../core/constants/app_design_system.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/utils/auth_helper.dart';
import '../presentation/bloc/routes_bloc.dart';
import 'routes_filter_widget.dart';
import '../../favourites/presentation/widgets/route_details_sheet_simple.dart';

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

  @override
  void initState() {
    super.initState();
    _cardsScrollController = widget.scrollController ?? ScrollController();
    
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
      builder:
          (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder:
            (context, scrollController) => RoutesFilterWidget(
          initialFilters: state.filters,
          scrollController: scrollController,
          onFiltersApplied: (RouteFilters newFilters) {
            context.read<RoutesBloc>().add(ApplyFilters(newFilters));
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

  void _toggleFavorite(RoutesLoaded state, int routeId) async {
    String token;
    try {
      token = await AuthHelper.requireAuthentication();
    } on AuthException catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, e.message);
      }
      return;
    }

    try {
      context.read<RoutesBloc>().add(ToggleFavorite(routeId));
      
      final currentStatus = state.favoriteStatus[routeId] ?? false;
      if (mounted) {
        AppSnackBar.showSuccess(
          context,
          currentStatus 
              ? 'Маршрут удален из избранного'
              : 'Маршрут добавлен в избранное',
        );
      }
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      if (mounted) {
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
                builder:
                    (context, controller, child) => IconButton(
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
                menuChildren:
                RoutesBloc.sortingItems
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