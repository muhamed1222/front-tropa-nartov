import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tropanartov/features/home/domain/entities/place.dart';
import 'package:tropanartov/features/home/presentation/bloc/home_bloc.dart';
import 'package:tropanartov/features/home/presentation/widgets/rating_dialog.dart';
import 'package:tropanartov/services/api_service.dart';
import 'package:tropanartov/services/auth_service.dart';
import 'package:tropanartov/models/api_models.dart' hide Image, Place;
import 'dart:ui' as ui;
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';

/// Всплывающее окно с деталями места
/// Показывается снизу экрана и растягивается от 50% до 100%
class PlaceDetailsSheet extends StatefulWidget {
  final Place place;
  final bool fullScreen; // Если true, сразу открывается на весь экран

  const PlaceDetailsSheet({
    super.key,
    required this.place,
    this.fullScreen = false,
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

  // Добавляем состояние для отзывов
  List<Review> _reviews = [];
  bool _isLoadingReviews = false;
  String? _reviewsError;
  bool _reviewsLoaded = false; // Флаг, что отзывы уже загружались

  @override
  void initState() {
    super.initState();

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
        await ApiService.removeFromFavorites(widget.place.id, token);
        if (mounted) {
          setState(() {
            _isBookmarked = false;
          });
        }
      } else {
        await ApiService.addToFavorites(widget.place.id, token);
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
      final reviews = await ApiService.getReviewsForPlace(widget.place.id);

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
      final reviews = await ApiService.getReviewsForPlace(widget.place.id);
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

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  // Проверка доступности HomeBloc
  bool _hasHomeBloc(BuildContext context) {
    try {
      context.read<HomeBloc>();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Безопасное закрытие модального окна
  void _safePop(BuildContext context) {
    if (!mounted) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted && Navigator.canPop(context)) {
        try {
          Navigator.of(context).pop();
        } catch (e) {
          // Игнорируем ошибки закрытия
        }
      }
    });
  }

  // Построение кнопки маршрута с проверкой доступности HomeBloc
  Widget _buildRouteButton(BuildContext context) {
    // Проверяем доступность HomeBloc перед использованием BlocBuilder
    if (!_hasHomeBloc(context)) {
      // Если HomeBloc недоступен, показываем неактивную кнопку
      return InkWell(
        onTap: null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 91, vertical: AppDesignSystem.paddingVerticalLarge),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDesignSystem.borderRadius),
            color: AppDesignSystem.greyColor,
          ),
          child: Text(
            'Маршрут',
            style: AppTextStyles.button(),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Если HomeBloc доступен, используем BlocBuilder с BlocProvider.value для безопасности
    return BlocProvider.value(
      value: context.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final isRouteBuilding = state.isLoading && state.routePoints.length == 1;
        final currentPlaceInRoute = state.routePoints.any((p) => p.id == widget.place.id);
        // Кнопка всегда активна, кроме случая когда строится маршрут
        final canAddToRoute = !isRouteBuilding;

        return InkWell(
          onTap: canAddToRoute ? () {
            try {
              final homeBloc = context.read<HomeBloc>();
              final currentState = homeBloc.state;
              
              // Проверяем, есть ли местоположение пользователя
              if (currentState.myLocation == null) {
                // Показываем сообщение об ошибке
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Не удалось определить ваше местоположение. Включите геолокацию в настройках.'),
                    duration: Duration(seconds: 3),
                  ),
                );
                return;
              }

              // Маршрут всегда будет от моего местоположения до выбранного места
              homeBloc.add(AddRoutePoint(widget.place));

              // Закрываем PlaceDetailsSheet после добавления в маршрут
              _sheetController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
              Future.delayed(const Duration(milliseconds: 250), () {
                if (mounted) {
                  try {
                    context.read<HomeBloc>().add(const ClosePlaceDetails());
                  } catch (e) {
                    _safePop(context);
                  }
                }
              });
            } catch (e) {
              // Если HomeBloc недоступен, показываем сообщение
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Функция маршрута доступна только на главном экране с картой.'),
                  duration: Duration(seconds: 3),
                ),
              );
            }
          } : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 91, vertical: AppDesignSystem.paddingVerticalLarge),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDesignSystem.borderRadius),
              color: canAddToRoute ? AppDesignSystem.primaryColor : AppDesignSystem.greyColor,
              border: Border.all(color: canAddToRoute ? AppDesignSystem.primaryColor : AppDesignSystem.greyColor),
            ),
            child: isRouteBuilding
                ? Center(
                    child: SizedBox(
                      height: AppDesignSystem.loadingIndicatorSize,
                      width: AppDesignSystem.loadingIndicatorSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppDesignSystem.textColorWhite),
                      ),
                    ),
                  )
                : Text(
                    currentPlaceInRoute ? 'Маршрут' : 'Маршрут',
                    style: AppTextStyles.button(),
                    textAlign: TextAlign.center,
                  ),
          ),
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

            if (notification.extent < _closeThreshold && notification.extent > 0.0 && !_isInitialAnimation) {
              _sheetController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
              Future.delayed(const Duration(milliseconds: 250), () {
                if (mounted) {
                  // Закрываем через HomeBloc только если он доступен (когда открыт из home)
                  try {
                    context.read<HomeBloc>().add(const ClosePlaceDetails());
                  } catch (e) {
                    // Если HomeBloc недоступен (открыт через showModalBottomSheet), просто закрываем модальное окно
                    _safePop(context);
                  }
                }
              });
            }
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
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: imageHeight,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Фотография с изменяющимся закруглением
                            () {
                              final images = widget.place.images;
                              if (images.isNotEmpty) {
                                final firstImage = images.first;
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(imageBorderRadius),
                                      topRight: Radius.circular(imageBorderRadius),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(imageBorderRadius),
                                      topRight: Radius.circular(imageBorderRadius),
                                    ),
                                    child: Image.network(
                                      firstImage.url,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Container(
                                        color: AppDesignSystem.greyLight,
                                        child: Icon(Icons.image_not_supported, size: 50, color: AppDesignSystem.textColorPrimary),
                                      ),
                                    ),
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
                                    child: Icon(Icons.image_not_supported, size: 50, color: AppDesignSystem.textColorPrimary),
                                  ),
                                );
                              }
                            }(),
                            // Градиент поверх фото с тем же закруглением
                            Container(
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
                            Positioned(
                              bottom: 2,
                              left: 0,
                              right: 0,
                              child: DragIndicator(
                                color: AppDesignSystem.greyColor,
                                borderRadius: AppDesignSystem.borderRadiusTiny,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        color: AppDesignSystem.backgroundColor,
                        padding: const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                // Фиксированные кнопки внизу
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
                    decoration: BoxDecoration(
                      color: AppDesignSystem.backgroundColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Кнопка "Оценить" с диалогом
                        RatingDialog(
                          place: widget.place,
                          onReviewAdded: _refreshReviews, // Обновляем отзывы после добавления
                        ),
                        SizedBox(width: AppDesignSystem.spacingSmall + 2),
                        Expanded(
                          child: _buildRouteButton(context),
                        ),
                      ],
                    ),
                  ),
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
            color: const Color(0xFF919191),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Отзывы',
              style: AppTextStyles.bodyLarge(
                fontWeight: AppDesignSystem.fontWeightBold,
              ),
            ),
          ],
        ),
        SizedBox(height: AppDesignSystem.spacingLarge),

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
                    Icon(Icons.reviews_outlined, size: 64, color: AppDesignSystem.greyColor),
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
      margin: const EdgeInsets.only(bottom: AppDesignSystem.paddingVerticalMedium),
      padding: const EdgeInsets.all(AppDesignSystem.paddingVerticalMedium),
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
                  Icon(Icons.star, color: Colors.amber, size: AppDesignSystem.spacingLarge),
                  SizedBox(width: AppDesignSystem.spacingTiny),
                  Text(
                    _formatRating(rating),
                    style: AppTextStyles.small(
                      fontWeight: AppDesignSystem.fontWeightSemiBold,
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
              const Icon(Icons.star, color: Colors.amber, size: AppDesignSystem.spacingLarge),
              SizedBox(width: AppDesignSystem.spacingTiny),
              Text(
                widget.place.rating.toStringAsFixed(1),
                style: AppTextStyles.body(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}