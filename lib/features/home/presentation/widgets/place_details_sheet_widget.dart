import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tropanartov/features/home/domain/entities/place.dart';
import 'package:tropanartov/features/home/presentation/bloc/home_bloc.dart';
import 'package:tropanartov/features/home/presentation/widgets/rating_dialog.dart';
import '../../../../services/api_service_static.dart';
import 'package:tropanartov/services/auth_service.dart';
import 'package:tropanartov/models/api_models.dart' hide Image, Place;
import 'dart:ui' as ui;
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/widgets/image_carousel_indicator.dart';
import '../../../../services/api_service.dart' show ApiServiceDio;
import '../../../../core/di/injection_container.dart' as di;

// ═══════════════════════════════════════════════════════════════════════════════
// 📱 PLACE DETAILS SHEET - РАСКРЫТАЯ КАРТОЧКА МЕСТА
// ═══════════════════════════════════════════════════════════════════════════════
//
// Всплывающее окно с деталями места
// Показывается снизу экрана и растягивается от 50% до 100%
//
// ┌─────────────────────────────────────────────────────────────────────────────┐
// │                        СТРУКТУРА ИЗ 3-Х БЛОКОВ:                             │
// ├─────────────────────────────────────────────────────────────────────────────┤
// │                                                                              │
// │  📸 БЛОК 1: ФОТОГРАФИИ                                                       │
// │     - Карусель изображений (PageView)                                       │
// │     - Градиент поверх фото                                                  │
// │     - Bookmark кнопка (верх справа)                                         │
// │     - Индикатор пагинации (низ слева)                                       │
// │     - Плашка "Вы уже были здесь" (низ справа)                               │
// │                                                                              │
// │  📄 БЛОК 2: КОНТЕНТ                                                          │
// │     - Drag индикатор (по центру вверху)                                     │
// │     - Название места и рейтинг                                              │
// │     - Тег типа места                                                        │
// │     - Табы навигации (История / Обзор / Отзывы)                             │
// │     - Содержимое выбранного таба                                            │
// │                                                                              │
// │  🎯 БЛОК 3: ПАНЕЛЬ ДЕЙСТВИЙ                                                  │
// │     - Кнопка "Оценить" (слева)                                              │
// │     - Кнопка "Маршрут" (справа)                                             │
// │                                                                              │
// └─────────────────────────────────────────────────────────────────────────────┘
//
// ═══════════════════════════════════════════════════════════════════════════════

/// Всплывающее окно с деталями места
/// Показывается снизу экрана и растягивается от 50% до 100%
class PlaceDetailsSheet extends StatefulWidget {
  final Place place;
  final bool fullScreen; // Если true, сразу открывается на весь экран
  final BuildContext? rootContext; // Корневой контекст для открытия диалогов поверх bottom sheet
  final HomeBloc? homeBloc; // Явно переданный HomeBloc

  const PlaceDetailsSheet({
    super.key,
    required this.place,
    this.fullScreen = false,
    this.rootContext,
    this.homeBloc,
  });

  @override
  State<PlaceDetailsSheet> createState() => _PlaceDetailsSheetState();
}

class _PlaceDetailsSheetState extends State<PlaceDetailsSheet> {
  double _sheetExtent = 0.5; // Текущий размер sheet (от 0.0 до 1.0)
  static const double _closeThreshold = 0.12; // Порог для закрытия окна
  final DraggableScrollableController _sheetController = DraggableScrollableController(); // Контроллер для программного управления sheet
  bool _isInitialAnimation = true; // true = идёт анимация появления
  int _selectedTabIndex = 0; // 0 = История, 1 = Обзор, 2 = Отзывы
  bool _isBookmarked = false; // Состояние закладки
  
  // Состояние для карусели изображений
  int _currentImageIndex = 0;
  final PageController _imagePageController = PageController();
  
  // Состояние для посещенных мест
  bool _isVisited = false;

  // Добавляем состояние для отзывов
  List<Review> _reviews = [];
  bool _isLoadingReviews = false;
  String? _reviewsError;
  bool _reviewsLoaded = false; // Флаг, что отзывы уже загружались

  @override
  void initState() {
    super.initState();
    
    // Загружаем статус посещенного места
    _loadVisitedStatus();

    // Плавное появление окна при открытии
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _sheetController.isAttached) {
        final targetSize = widget.fullScreen ? 1.0 : 0.5;
        _sheetExtent = targetSize;
        _sheetController
            .animateTo(
          targetSize,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        )
            .then((_) {
          if (mounted) {
            setState(() {
              _isInitialAnimation = false;
            });
          }
        });
      }
    });

    _checkFavoriteStatus(); // Проверяем статус при инициализации
  }
  
  @override
  void dispose() {
    _imagePageController.dispose();
    _sheetController.dispose();
    super.dispose();
  }
  
  // Загружает статус посещенного места
  Future<void> _loadVisitedStatus() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return;
      
      final apiService = di.sl<ApiServiceDio>();
      final visitedPlaces = await apiService.getUserActivityPlaces(token);
      final isVisited = visitedPlaces.any((item) => item['place_id'] == widget.place.id);
      
      if (mounted) {
        setState(() {
          _isVisited = isVisited;
        });
      }
    } catch (e) {
      // Игнорируем ошибку
    }
  }

  // Метод для проверки статуса избранного
  Future<void> _checkFavoriteStatus() async {
    final token = await AuthService.getToken();
    if (token != null) {
      try {
        final isFavorite = await ApiService.isPlaceFavorite(widget.place.id, token);
        if (mounted) {
          setState(() {
            _isBookmarked = isFavorite;
          });
        }
      } catch (e) {
        // print('Error checking favorite status: $e');
      }
    }
  }

  // Метод для переключения избранного
  Future<void> _toggleFavorite() async {
    final token = await AuthService.getToken();
    if (token == null) {

      return;
    }

    try {
      if (_isBookmarked) {
        await ApiService.removePlaceFromFavorites(widget.place.id, token);
        if (mounted) {
          setState(() {
            _isBookmarked = false;
          });
        }
      } else {
        await ApiService.addPlaceToFavorites(widget.place.id, token);
        if (mounted) {
          setState(() {
            _isBookmarked = true;
          });
        }
      }
    } catch (e) {
      // print('Error toggling favorite: $e');
    }
  }

  // Метод для загрузки отзывов
  Future<void> _loadReviews() async {
    if (_isLoadingReviews || _reviewsLoaded) return;

    if (mounted) {
      setState(() {
        _isLoadingReviews = true;
        _reviewsError = null;
      });
    }

    try {
      final reviews = await ApiService.getPlaceReviews(widget.place.id);

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
      // print('Error loading reviews: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
    }
  }

  Future<void> _refreshReviews() async {
    if (mounted) {
      setState(() {
        _isLoadingReviews = true;
        _reviewsError = null;
      });
    }

    try {
      final reviews = await ApiService.getPlaceReviews(widget.place.id);
      if (mounted) {
        setState(() {
          _reviews = reviews;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _reviewsError = e.toString();
        });
      }
      // print('Error refreshing reviews: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
    }
  }

  // Получение HomeBloc из доступного контекста
  HomeBloc? _getHomeBloc(BuildContext context) {
    // 0. Если передан явно через параметры - используем его
    if (widget.homeBloc != null) {
      return widget.homeBloc;
    }

    // Пробуем несколько способов найти HomeBloc
    // 1. Текущий контекст (работает, если PlaceDetailsSheet открыт из HomePage)
    try {
      final bloc = BlocProvider.of<HomeBloc>(context, listen: false);
      if (bloc != null) return bloc;
    } catch (e) {
      // Продолжаем поиск
    }
    
    // 2. rootContext если передан (контекст корневого Navigator)
    if (widget.rootContext != null && widget.rootContext != context) {
      try {
        final bloc = BlocProvider.of<HomeBloc>(widget.rootContext!, listen: false);
        if (bloc != null) return bloc;
      } catch (e) {
        // Продолжаем поиск
      }
    }
    
    // 3. Через root Navigator overlay context
    try {
      final rootNavigator = Navigator.of(context, rootNavigator: true);
      if (rootNavigator.overlay?.context != null) {
        final overlayContext = rootNavigator.overlay!.context!;
        if (overlayContext != context && overlayContext != widget.rootContext) {
          try {
            final bloc = BlocProvider.of<HomeBloc>(overlayContext, listen: false);
            if (bloc != null) return bloc;
          } catch (e) {
            // Продолжаем поиск
          }
        }
      }
    } catch (e) {
      // Игнорируем ошибки
    }
    
    // 4. Ищем в дереве предков через visitAncestorElements
    // Это работает даже если HomeBloc находится в другом Navigator stack
    HomeBloc? foundBloc;
    try {
      context.visitAncestorElements((element) {
        // Ищем BlocProvider<HomeBloc> в дереве виджетов
        final widget = element.widget;
        if (widget is BlocProvider<HomeBloc>) {
          // Пробуем получить bloc из разных свойств
          try {
            foundBloc = (widget as dynamic).value;
            if (foundBloc != null) return false;
          } catch (e) {
            // Продолжаем поиск
          }
          try {
            foundBloc = (widget as dynamic).bloc;
            if (foundBloc != null) return false;
          } catch (e) {
            // Продолжаем поиск
          }
        }
        return true; // Продолжаем поиск
      });
      
      // Если нашли через visitAncestorElements, пробуем получить через его контекст
      if (foundBloc == null) {
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
      }
    } catch (e) {
      // Игнорируем ошибки
    }
    
    return foundBloc;
  }
  
  // Проверка доступности HomeBloc
  bool _hasHomeBloc(BuildContext context) {
    return _getHomeBloc(context) != null;
  }

  // Безопасное закрытие модального окна
  // Используется только для HomeBloc сценариев, не для showModalBottomSheet
  void _safePop(BuildContext context) {
    if (!mounted) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Используем rootNavigator: false для закрытия только текущего bottom sheet
        final navigator = Navigator.of(context, rootNavigator: false);
        if (navigator.canPop()) {
        try {
            navigator.pop();
        } catch (e) {
          // Игнорируем ошибки закрытия
          }
        }
      }
    });
  }

  // Метод для открытия диалога оценки
  void _showRatingDialog() {
    // Получаем корневой Navigator для открытия диалогов поверх bottom sheet
    // Если rootContext передан, используем его, иначе получаем из root Navigator overlay
    BuildContext? dialogContext;
    if (widget.rootContext != null) {
      dialogContext = widget.rootContext;
    } else {
      // Получаем корневой контекст из Navigator overlay
      final rootNavigator = Navigator.of(context, rootNavigator: true);
      dialogContext = rootNavigator.overlay?.context;
    }
    
    // Если не удалось получить root context, используем текущий контекст
    // В этом случае используем useRootNavigator: true в RatingDialog.show
    final contextForDialog = dialogContext ?? context;
    
    RatingDialog.show(
      contextForDialog,
      widget.place,
      onReviewAdded: _refreshReviews,
    );
  }

  // Метод для обработки нажатия на кнопку "Маршрут"
  void _onRoutePressed() {
    // Получаем HomeBloc из доступного контекста
    final homeBloc = _getHomeBloc(context);
    
    if (homeBloc == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Функция маршрута доступна только на главном экране с картой.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      final currentState = homeBloc.state;

      // Проверяем, строится ли маршрут
      final isRouteBuilding = currentState.isLoading && currentState.routePoints.length == 1;
      if (isRouteBuilding) {
        // Кнопка неактивна во время построения маршрута, но сообщение не показываем
        return;
      }

      // Проверяем, есть ли местоположение пользователя
      if (currentState.myLocation == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Не удалось определить ваше местоположение. Включите геолокацию в настройках.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Маршрут всегда будет от моего местоположения до выбранного места
      homeBloc.add(AddRoutePoint(widget.place));

      // Закрываем PlaceDetailsSheet после добавления в маршрут
      if (_sheetController.isAttached) {
        _sheetController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
      
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          try {
            // Используем тот же HomeBloc для закрытия
            final bloc = _getHomeBloc(context);
            if (bloc != null) {
              bloc.add(const ClosePlaceDetails());
            } else {
              // Если не удалось получить HomeBloc, используем безопасное закрытие
              _safePop(context);
            }
          } catch (e) {
            // Если не удалось закрыть через HomeBloc, используем безопасное закрытие
            _safePop(context);
          }
        }
      });
    } catch (e) {
      // Если произошла ошибка, показываем сообщение
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка при создании маршрута. Попробуйте снова.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildActionButtonsPanel(BuildContext context) {
    // Пытаемся получить HomeBloc из доступного контекста
    final homeBloc = _getHomeBloc(context);
    
    // debugPrint('PlaceDetailsSheet: homeBloc is ${homeBloc != null ? 'available' : 'null'}');
    
    if (homeBloc == null) {
      // Если HomeBloc недоступен, показываем панель с неактивной кнопкой маршрута
      return ActionButtonsPanel(
        onRate: _showRatingDialog,
        onRoute: null, // Кнопка маршрута неактивна
      );
    }

    // Если HomeBloc доступен, используем BlocBuilder с BlocProvider.value для безопасности
    return BlocProvider.value(
      value: homeBloc,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final isRouteBuilding = state.isLoading && state.routePoints.length == 1;
          // Кнопка всегда активна, кроме случая когда строится маршрут
          final canAddToRoute = !isRouteBuilding;
          
          // debugPrint('PlaceDetailsSheet: isRouteBuilding=$isRouteBuilding, canAddToRoute=$canAddToRoute');

          return ActionButtonsPanel(
            onRate: _showRatingDialog,
            onRoute: canAddToRoute ? _onRoutePressed : null,
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: widget.fullScreen ? 1.0 : 0.0,
      minChildSize: 0.0,
      maxChildSize: 1.0,
      snap: true,
      snapSizes: widget.fullScreen ? const [1.0] : const [0.5, 1.0],
      builder: (context, scrollController) {
        final h = MediaQuery.of(context).size.height;
        final double minImg = h * 0.15;
        final double maxImg = h * 0.35;

        final double t = ((_sheetExtent - 0.5) / (1.0 - 0.5)).clamp(0.0, 1.0);

        final double imageHeight = ui.lerpDouble(minImg, maxImg, t)!;

        // Интерполяция радиуса закругления для фото: от borderRadiusLarge (50%) до 0 (100%)
        final double imageBorderRadius = ui.lerpDouble(AppDesignSystem.borderRadiusLarge, 0.0, t)!;

        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            setState(() => _sheetExtent = notification.extent);
            // Логика закрытия полностью удалена, чтобы использовать стандартное поведение isDismissible
            return false;
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppDesignSystem.backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDesignSystem.borderRadiusLarge),
                topRight: Radius.circular(AppDesignSystem.borderRadiusLarge),
              ),
            ),
            child: Stack(
              children: [
                CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    // ═══════════════════════════════════════════════════════════════
                    // 📸 БЛОК 1: ФОТОГРАФИИ
                    // ═══════════════════════════════════════════════════════════════
// Содержит:
// - Карусель изображений (PageView)
// - Градиент поверх фото
// - Bookmark кнопка (верх справа)
// - Индикатор пагинации (низ слева)
// - Плашка "Вы уже были здесь" (низ справа)
// - Белая полоска перехода
                    // ═══════════════════════════════════════════════════════════════
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: imageHeight,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Карусель изображений с изменяющимся закруглением
                            () {
                              final images = widget.place.images;
                              if (images.isNotEmpty) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(imageBorderRadius),
                                    topRight: Radius.circular(imageBorderRadius),
                                  ),
                                  child: PageView.builder(
                                    controller: _imagePageController,
                                    itemCount: images.length,
                                    onPageChanged: (index) {
                                      if (mounted) {
                                        setState(() {
                                          _currentImageIndex = index;
                                        });
                                      }
                                    },
                                    itemBuilder: (context, index) {
                                      return Image.network(
                                        images[index].url,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: AppDesignSystem.greyLight,
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: AppDesignSystem.textColorPrimary,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(imageBorderRadius),
                                      topRight: Radius.circular(imageBorderRadius),
                                    ),
                                    color: AppDesignSystem.greyLight,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: AppDesignSystem.textColorPrimary,
                                    ),
                                  ),
                                );
                              }
                            }(),
                            // Градиент поверх фото с тем же закруглением (пропускает touch-события)
                            IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(imageBorderRadius),
                                    topRight: Radius.circular(imageBorderRadius),
                                  ),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Color(0x8A000000)],
                                  ),
                                ),
                                child: const SizedBox.shrink(),
                              ),
                            ),
                            // Кнопка bookmark в правом верхнем углу (появляется только при полном открытии)
                            if (_sheetExtent > 0.9)
                              Positioned(
                                top: 53,
                                right: AppDesignSystem.spacingLarge,
                                child: GestureDetector(
                                  onTap: _toggleFavorite,
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(AppDesignSystem.borderRadiusInput),
                                      color: const Color(0x4DFFFFFF),
                                    ),
                                    child: Icon(
                                      _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                      size: AppDesignSystem.iconSizeSmall,
                                      color: AppDesignSystem.textColorWhite,
                                    ),
                                  ),
                                ),
                              ),
                            
                            // Индикатор пагинации (левый нижний угол)
                            if (_sheetExtent > 0.9 && widget.place.images.isNotEmpty)
                              Positioned(
                                left: 14,
                                bottom: 30,
                                child: ImageCarouselIndicator(
                                  itemCount: widget.place.images.length,
                                  currentIndex: _currentImageIndex,
                                ),
                              ),
                            
                            // Плашка "Вы уже были здесь" (правый нижний угол)
                            if (_sheetExtent > 0.9 && _isVisited)
                              Positioned(
                                right: 14,
                                bottom: 30,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0x40FFFFFF), // rgba(255,255,255,0.25)
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                  child: Opacity(
                                    opacity: 0.6,
                                    child: Text(
                                      'Вы уже были здесь',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            // Белый фон под фото с фиксированным закруглением
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: -AppDesignSystem.spacingLarge,
                              child: Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppDesignSystem.backgroundColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(AppDesignSystem.borderRadiusLarge),
                                    topRight: Radius.circular(AppDesignSystem.borderRadiusLarge),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // ═══════════════════════════════════════════════════════════════
                    // 📄 БЛОК 2: КОНТЕНТ
                    // ═══════════════════════════════════════════════════════════════
                    // Содержит:
                    // - Drag индикатор (по центру вверху)
                    // - Название места и рейтинг
                    // - Тег типа места (Достопримечательность и т.д.)
                    // - Табы навигации (История / Обзор / Отзывы)
                    // - Содержимое выбранного таба
                    // - Отступ для панели действий
                    // ═══════════════════════════════════════════════════════════════
                    SliverToBoxAdapter(
                      child: Container(
                        color: AppDesignSystem.backgroundColor,
                        padding: const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Drag индикатор
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: AppDesignSystem.spacingMedium),
                                child: DragIndicator(
                                  color: AppDesignSystem.greyColor,
                                  borderRadius: AppDesignSystem.borderRadiusTiny,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            // Название и рейтинг
                            PlaceNameAndRatingWidget(widget: widget),
                            SizedBox(height: AppDesignSystem.spacingSmall + 1),
                            PlaceTypeWidget(widget: widget),
                            SizedBox(height: AppDesignSystem.spacingXLarge),
                            _buildTabs(),
                            SizedBox(height: AppDesignSystem.spacingLarge),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        color: AppDesignSystem.backgroundColor,
                        padding: const EdgeInsets.symmetric(horizontal: AppDesignSystem.paddingHorizontal),
                        child: _buildTabContent(),
                      ),
                    ),
                    // Добавляем отступ для кнопок
                    SliverToBoxAdapter(
                      child: SizedBox(height: AppDesignSystem.buttonHeight + AppDesignSystem.paddingHorizontal * 2),
                    ),
                  ],
                ),
                
                // ═══════════════════════════════════════════════════════════════
                // 🎯 БЛОК 3: ПАНЕЛЬ ДЕЙСТВИЙ
                // ═══════════════════════════════════════════════════════════════
                // Содержит:
                // - Кнопка "Оценить" (слева)
                // - Кнопка "Маршрут" (справа)
                // Фиксирована внизу экрана, всегда видна при прокрутке
                // ═══════════════════════════════════════════════════════════════
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildActionButtonsPanel(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildInfoRow(String iconAsset, String title, List<String> contents, bool showEmail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDesignSystem.paddingVerticalMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            iconAsset,
            width: AppDesignSystem.spacingLarge,
            height: AppDesignSystem.spacingLarge,
            colorFilter: const ColorFilter.mode(
              Color(0xFF919191),
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: AppDesignSystem.spacingTiny + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body(
                    fontWeight: AppDesignSystem.fontWeightMedium,
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacingTiny),
                ...contents.map((content) => Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Text(
                    content,
                    style: AppTextStyles.body(
                      color: AppDesignSystem.textColorSecondary,
                    ),
                  ),
                )),
                // Email показывается только если это строка телефона и установлен флаг showEmail
                if (showEmail && widget.place.contactsEmail != null && widget.place.contactsEmail!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      widget.place.contactsEmail!,
                      style: AppTextStyles.body(
                        color: AppDesignSystem.textColorSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDesignSystem.spacingTiny),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDesignSystem.borderRadius),
        color: AppDesignSystem.backgroundColorSecondary,
      ),
      child: Row(
        children: [
          _buildTab('История', 0),
          _buildTab('Обзор', 1),
          _buildTab('Отзывы', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
          // Загружаем отзывы при переключении на вкладку
          if (index == 2 && !_reviewsLoaded && !_isLoadingReviews) {
            _loadReviews();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(AppDesignSystem.spacingSmall + 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDesignSystem.spacingSmall + 2),
            color: isSelected ? AppDesignSystem.primaryColor : Colors.transparent,
          ),
          child: Center(
            child: Text(
              title,
              style: AppTextStyles.small(
                color: isSelected ? AppDesignSystem.textColorWhite : AppDesignSystem.textColorPrimary,
                fontWeight: isSelected ? AppDesignSystem.fontWeightMedium : AppDesignSystem.fontWeightRegular,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildHistoryContent();
      case 1:
        return _buildOverviewContent();
      case 2:
        return _buildReviewsContent();
      default:
        return _buildOverviewContent();
    }
  }

  Widget _buildOverviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('assets/location.svg', 'Адрес', [widget.place.address], false),
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.black26,
        ),
        SizedBox(height: 14),
        _buildInfoRow('assets/clock.svg', 'Часы работы', [
          widget.place.hours,
          if (widget.place.weekend != null && widget.place.weekend!.isNotEmpty) widget.place.weekend!,
          if (widget.place.entry != null && widget.place.entry!.isNotEmpty) widget.place.entry!,
        ], false),
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.black26,
        ),
        SizedBox(height: 14),
        _buildInfoRow('assets/phone.svg', 'Телефон', [widget.place.contacts], true),
        SizedBox(height: AppDesignSystem.spacingLarge),
      ],
    );
  }
  Widget _buildHistoryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppDesignSystem.spacingLarge),
        Text(
          widget.place.history.isNotEmpty
              ? widget.place.history
              : 'Историческая информация отсутствует',
          style: AppTextStyles.body(),
        ),
      ],
    );
  }

  Widget _buildReviewsContent() {
    // Если отзывы еще не загружались и не загружены, начинаем загрузку
    if (!_reviewsLoaded && !_isLoadingReviews) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadReviews();
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLoadingReviews)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDesignSystem.paddingVerticalMedium),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppDesignSystem.spacingSmall),
                  Text(
                    'Загрузка отзывов...',
                    style: AppTextStyles.secondary(
                      color: AppDesignSystem.greyColor,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_reviewsError != null)
          Column(
            children: [
              Container(
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
                    SizedBox(height: AppDesignSystem.spacingSmall),
                    Text(
                      _reviewsError!,
                      style: AppTextStyles.error(),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppDesignSystem.spacingSmall),
                    PrimaryButton(
                      text: 'Попробовать снова',
                      onPressed: _refreshReviews,
                    ),
                  ],
                ),
              ),
            ],
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
                    SizedBox(height: AppDesignSystem.spacingLarge),
                    Text(
                      'Пока нет отзывов',
                      style: AppTextStyles.body(
                        color: AppDesignSystem.greyColor,
                      ),
                    ),
                    SizedBox(height: AppDesignSystem.spacingSmall),
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
            ..._reviews.map((review) => _buildReviewItem(
              review.authorName,
              review.rating.toDouble(),
              review.text,
              review.formattedDate,
            )),
      ],
    );
  }

  Widget _buildReviewItem(String name, double rating, String comment, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDesignSystem.borderRadius),
        color: const Color(0xFFF8F8F8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: AppTextStyles.body(
                  fontWeight: AppDesignSystem.fontWeightSemiBold,
                ),
              ),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/star.svg',
                    width: 14,
                    height: 13,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: AppDesignSystem.spacingTiny),
                  Text(
                    _formatRating(rating),
                    style: AppTextStyles.small(
                      color: Colors.black,
                      fontWeight: AppDesignSystem.fontWeightRegular,
                      letterSpacing: -0.28,
                    ).copyWith(
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppDesignSystem.spacingSmall),
          Text(
            comment,
            style: AppTextStyles.small(),
          ),
          SizedBox(height: AppDesignSystem.spacingSmall),
          Text(
            date,
            style: AppTextStyles.error(
              color: AppDesignSystem.greyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }
}

class PlaceTypeWidget extends StatelessWidget {
  const PlaceTypeWidget({
    super.key,
    required this.widget,
  });

  final PlaceDetailsSheet widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDesignSystem.spacingMedium, vertical: AppDesignSystem.spacingTiny + 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDesignSystem.borderRadiusLarge),
        color: AppDesignSystem.primaryColor.withValues(alpha: 0.12),
      ),
      child: Text(
        widget.place.type,
        style: AppTextStyles.small(
          color: AppDesignSystem.primaryColor,
        ),
      ),
    );
  }
}

class PlaceNameAndRatingWidget extends StatelessWidget {
  const PlaceNameAndRatingWidget({
    super.key,
    required this.widget,
  });

  final PlaceDetailsSheet widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.place.name,
            style: AppTextStyles.title(),
          ),
        ),
        SizedBox(width: AppDesignSystem.spacingXLarge),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDesignSystem.spacingSmall, vertical: AppDesignSystem.spacingTiny),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDesignSystem.borderRadiusSmall),
            color: AppDesignSystem.backgroundColorSecondary,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/star.svg',
                width: 14,
                height: 13,
                fit: BoxFit.contain,
              ),
              SizedBox(width: AppDesignSystem.spacingTiny),
              Text(
                widget.place.rating.toStringAsFixed(1),
                style: AppTextStyles.small(
                  color: Colors.black,
                  fontWeight: AppDesignSystem.fontWeightRegular,
                  letterSpacing: -0.28,
                ).copyWith(
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}