import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tropanartov/features/home/presentation/bloc/home_bloc.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tropanartov/models/api_models.dart' hide Image;
import 'package:tropanartov/utils/smooth_border_radius.dart';
import 'package:tropanartov/features/home/presentation/widgets/place_details_sheet_widget.dart';
import 'package:tropanartov/features/places/data/mappers/place_mapper.dart';
import '../bloc/favourites_bloc.dart';
import 'route_details_sheet_simple.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/widgets/place_card.dart';

class FavouritesWidget extends StatefulWidget {
  final ScrollController scrollController;
  final HomeBloc? homeBloc;

  const FavouritesWidget({
    super.key,
    required this.scrollController,
    this.homeBloc,
  });

  @override
  State<FavouritesWidget> createState() => _FavouritesWidgetState();
}

class _FavouritesWidgetState extends State<FavouritesWidget> with WidgetsBindingObserver {
  // Контроллер для скролла карточек
  late ScrollController _cardsScrollController;

  @override
  void initState() {
    super.initState();
    _cardsScrollController = widget.scrollController;
    WidgetsBinding.instance.addObserver(this);
    
    // Данные загружаются через BLoC при создании BlocProvider

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Обновляем список при возвращении приложения в активное состояние
    if (state == AppLifecycleState.resumed && mounted) {
      final bloc = context.read<FavouritesBloc>();
      final currentState = bloc.state;
      if (currentState is FavouritesLoaded) {
        if (currentState.selectedTabIndex == 0) {
          bloc.add(const LoadFavoritePlaces(forceRefresh: false)); // Используем кеш при инициализации
        } else {
          bloc.add(const LoadFavoriteRoutes(forceRefresh: false));
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Не удаляем _cardsScrollController так как он передан извне

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


  // Универсальный метод для показа диалога удаления
  void _showDeleteDialog(FavouritesLoaded state, {required bool isPlace, required int index}) {
    final questionText = isPlace
        ? 'Вы точно хотите убрать это место из избранного?'
        : 'Вы точно хотите убрать этот маршрут из избранного?';
    
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Размытый фон
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
            // Диалоговое окно
            Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(14),
              child: Stack(
                children: [
                  SmoothContainer(
                    width: 384,
                    padding: const EdgeInsets.all(14),
                    borderRadius: 20,
                    color: AppDesignSystem.whiteColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Текст вопроса
                        Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: Text(
                            questionText,
                            style: AppTextStyles.title(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Кнопки
                        Row(
                          children: [
                            // Кнопка "Нет"
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: SmoothContainer(
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                  borderRadius: 12,
                                  border: Border.all(color: AppDesignSystem.primaryColor),
                                  child: Center(
                                    child: Text(
                                      'Нет',
                                      style: AppTextStyles.button(
                                        color: AppDesignSystem.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Кнопка "Да"
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  final bloc = context.read<FavouritesBloc>();
                                  if (isPlace) {
                                    bloc.add(RemovePlaceFromFavorites(index));
                                  } else {
                                    bloc.add(RemoveRouteFromFavorites(index));
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: SmoothContainer(
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                  borderRadius: 12,
                                  color: AppDesignSystem.primaryColor,
                                  child: Center(
                                    child: Text(
                                      'Да',
                                      style: AppTextStyles.button(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Крестик закрытия
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: const Center(
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: AppDesignSystem.textColorTertiary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Иконка bookmark
          SizedBox(
            width: 50,
            height: 50,
            child: SvgPicture.asset(
              'assets/bookmark_empty.svg',
              width: 50,
              height: 50,
              colorFilter: const ColorFilter.mode(
                Color(0xFFD3EDEB),
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Текст "Здесь пока ничего нет..."
          Text(
            'Здесь пока ничего нет...',
            style: AppTextStyles.title(
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Описание
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Text(
              'Отмечайте понравившиеся места и маршруты флажком и они будут отображаться в этом разделе.',
              style: AppTextStyles.body(
                color: Colors.black.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showPlaceDetails(Place place) {
    // Конвертируем Place из api_models в Place из home/domain/entities
    final homePlace = PlaceMapper.fromApi(place);
    
    // Получаем HomeBloc из параметров или из текущего контекста
    HomeBloc? homeBloc = widget.homeBloc;
    if (homeBloc == null) {
      try {
        homeBloc = context.read<HomeBloc>();
      } catch (e) {
        // Если HomeBloc недоступен, ничего не делаем
      }
    }
    
    // Используем тот же компонент, что и на карте
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceDetailsSheet(
        place: homePlace,
        fullScreen: false,
        homeBloc: homeBloc, // Передаем HomeBloc явно
      ),
    );
  }

  void _showRouteDetails(AppRoute route) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RouteDetailsSheetSimple(route: route),
    );
  }

  // Получить URL изображения маршрута
  String _getRouteImageUrl(AppRoute route) {
    if (route.imageUrl != null && route.imageUrl!.isNotEmpty) {
      return route.imageUrl!;
    }
    return '';
  }

  // Виджет для статичной шапки
  Widget _buildHeader(FavouritesLoaded state) {
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
            'Избранное',
            style: AppTextStyles.title(),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 28),

        // Кнопки переключения
        SmoothContainer(
          width: double.infinity,
          borderRadius: 12,
          color: AppDesignSystem.greyLight,
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              // Кнопка "Места"
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.read<FavouritesBloc>().add(const SwitchTab(0));
                  },
                  child: SmoothContainer(
                    padding: const EdgeInsets.all(10),
                    borderRadius: 10,
                    color: state.selectedTabIndex == 0
                        ? AppDesignSystem.primaryColor
                        : Colors.transparent,
                    child: Center(
                      child: Text(
                        'Места',
                        style: AppTextStyles.small(
                          color: state.selectedTabIndex == 0
                              ? AppDesignSystem.whiteColor
                              : AppDesignSystem.textColorPrimary,
                          fontWeight: state.selectedTabIndex == 0
                              ? AppDesignSystem.fontWeightMedium
                              : AppDesignSystem.fontWeightRegular,
                          letterSpacing: state.selectedTabIndex == 0
                              ? 0.0
                              : AppDesignSystem.letterSpacingTight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Кнопка "Маршруты"
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.read<FavouritesBloc>().add(const SwitchTab(1));
                  },
                  child: SmoothContainer(
                    padding: const EdgeInsets.all(10),
                    borderRadius: 10,
                    color: state.selectedTabIndex == 1
                        ? AppDesignSystem.primaryColor
                        : Colors.transparent,
                    child: Center(
                      child: Text(
                        'Маршруты',
                        style: AppTextStyles.small(
                          color: state.selectedTabIndex == 1
                              ? AppDesignSystem.whiteColor
                              : AppDesignSystem.textColorPrimary,
                          fontWeight: state.selectedTabIndex == 1
                              ? AppDesignSystem.fontWeightMedium
                              : AppDesignSystem.fontWeightRegular,
                          letterSpacing: state.selectedTabIndex == 1
                              ? 0.0
                              : AppDesignSystem.letterSpacingTight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // Виджет для скроллируемого контента с карточками
  Widget _buildScrollableContent(FavouritesLoaded state) {
    if (state.isLoading && state.selectedTabIndex == 0 && state.favoritePlaces.isEmpty ||
        state.isLoading && state.selectedTabIndex == 1 && state.favoriteRoutes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isEmpty = state.selectedTabIndex == 0
        ? state.favoritePlaces.isEmpty
        : state.favoriteRoutes.isEmpty;

    if (isEmpty) {
      return _buildEmptyState();
    }

    if (state.selectedTabIndex == 0) {
      // Отображаем места
      return GridView.builder(
        controller: _cardsScrollController,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 187 / 260,
        ),
        itemCount: state.favoritePlaces.length,
        itemBuilder: (context, index) {
          final place = state.favoritePlaces[index];
          return PlaceCard(
            place: place,
            isFavorite: true, // Всегда true, так как это экран избранного
            isVisited: false, // TODO: добавить проверку посещенных мест
            onTap: () => _showPlaceDetails(place),
            onFavoriteTap: () => _showDeleteDialog(state, isPlace: true, index: index),
          );
        },
      );
    } else {
      // Отображаем маршруты
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
        itemCount: state.favoriteRoutes.length,
        itemBuilder: (context, index) {
          return _buildRouteCard(state, state.favoriteRoutes[index], index);
        },
      );
    }
  }

  Widget _buildRouteCard(FavouritesLoaded state, AppRoute route, int index) {
    final imageUrl = _getRouteImageUrl(route);
    
    return GestureDetector(
      onTap: () => _showRouteDetails(route),
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
                          isFavorite: true, // Всегда true, так как это экран избранного
                          onTap: () => _showDeleteDialog(state, isPlace: false, index: index),
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
                                    route.typeName ?? 'Маршрут',
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
                width: 187,
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavouritesBloc, FavouritesState>(
      builder: (context, state) {
        if (state is FavouritesError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      final bloc = context.read<FavouritesBloc>();
                      bloc.add(const LoadFavoritePlaces(forceRefresh: true)); // Явное обновление
                      bloc.add(const LoadFavoriteRoutes(forceRefresh: true));
                    },
                    child: const Text('Попробовать снова'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is FavouritesLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<FavouritesBloc>().add(const RefreshFavorites());
            },
            child: Column(
              children: [
                // Статичная шапка
                _buildHeader(state),

                // Скроллируемые карточки
                Expanded(
                  child: _buildScrollableContent(state),
                ),
              ],
            ),
          );
        }

        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}