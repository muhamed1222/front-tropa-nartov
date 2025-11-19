import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tropanartov/models/api_models.dart' hide Image;
import 'package:tropanartov/services/api_service.dart';
import 'package:tropanartov/services/auth_service.dart';
import 'package:tropanartov/utils/smooth_border_radius.dart';
import 'package:tropanartov/features/home/domain/entities/place.dart' as home_entities;
import 'package:tropanartov/features/home/presentation/widgets/place_details_sheet_widget.dart';
import 'package:tropanartov/shared/domain/entities/image.dart' as shared_entities;
import 'package:tropanartov/shared/domain/entities/review.dart' as shared_entities;
import 'route_details_sheet_simple.dart';
import '../../../../core/widgets/widgets.dart';

class FavouritesWidget extends StatefulWidget {
  final ScrollController scrollController;

  const FavouritesWidget({
    super.key,
    required this.scrollController,
  });

  @override
  State<FavouritesWidget> createState() => _FavouritesWidgetState();
}

class _FavouritesWidgetState extends State<FavouritesWidget> with WidgetsBindingObserver {
  int _selectedButtonIndex = 0; // 0 - места, 1 - маршруты
  List<Place> _favoritePlaces = [];
  List<AppRoute> _favoriteRoutes = [];
  bool _isLoading = false;

  // Контроллер для скролла карточек
  late ScrollController _cardsScrollController;

  @override
  void initState() {
    super.initState();
    _cardsScrollController = widget.scrollController;
    WidgetsBinding.instance.addObserver(this);
    _loadFavoritePlaces();
    _loadFavoriteRoutes();

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // initState() уже вызывает _loadFavoritePlaces() при создании виджета
    // Добавление ключа в openBottomSheet гарантирует пересоздание виджета каждый раз
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Обновляем список при возвращении приложения в активное состояние
    if (state == AppLifecycleState.resumed) {
      _loadFavoritePlaces();
      _loadFavoriteRoutes();
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

  Future<void> _loadFavoritePlaces() async {
    final token = await AuthService.getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Необходима авторизация для просмотра избранного'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    if (mounted && _selectedButtonIndex == 0) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final places = await ApiService.getFavoritePlaces(token);
      if (mounted) {
        setState(() {
          _favoritePlaces = places;
        });
      }
    } catch (e) {
      if (mounted && _selectedButtonIndex == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Не удалось загрузить избранные места. Проверьте подключение к интернету.',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted && _selectedButtonIndex == 0) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadFavoriteRoutes() async {
    final token = await AuthService.getToken();
    if (token == null) {
      return;
    }

    if (mounted && _selectedButtonIndex == 1) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final routes = await ApiService.getFavoriteRoutes(token);
      if (mounted) {
        setState(() {
          _favoriteRoutes = routes;
        });
      }
    } catch (e) {
      if (mounted && _selectedButtonIndex == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Не удалось загрузить избранные маршруты. Проверьте подключение к интернету.',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted && _selectedButtonIndex == 1) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeFromFavorites(int index) async {
    final place = _favoritePlaces[index];
    final token = await AuthService.getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Необходима авторизация для удаления из избранного'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      await ApiService.removeFromFavorites(place.id, token);
      if (mounted) {
        setState(() {
          _favoritePlaces.removeAt(index);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось удалить из избранного'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showDeleteDialog(int index) {
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
                            'Вы точно хотите убрать это место из избранного?',
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
                                  _removeFromFavorites(index);
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

  // Конвертирует Place из api_models в Place из home/domain/entities
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
      history: apiPlace.history ?? '',
      latitude: apiPlace.latitude,
      longitude: apiPlace.longitude,
      reviews: apiPlace.reviews?.map((review) {
        // Конвертируем Review из api_models в shared_entities.Review
        // shared_entities.Review использует другую структуру полей
        return shared_entities.Review(
          id: review.id,
          text: review.text,
          authorId: review.userId ?? 0,
          authorName: review.authorName,
          authorAvatar: review.authorAvatar ?? '',
          rating: review.rating, // rating уже int в api_models
          createdAt: review.createdAt,
          updatedAt: review.updatedAt,
          isActive: review.isActive,
          placeId: review.placeId,
        );
      }).toList() ?? [],
      description: apiPlace.description,
      overview: apiPlace.overview ?? '',
    );
  }

  void _showPlaceDetails(Place place) {
    // Конвертируем Place из api_models в Place из home/domain/entities
    final homePlace = _convertPlaceToHomeEntity(place);
    
    // Используем тот же компонент, что и на карте
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceDetailsSheet(
        place: homePlace,
        fullScreen: false,
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
  // Для упрощения возвращаем пустую строку - изображения будут загружаться из API
  // В будущем можно добавить загрузку изображений из остановок маршрута
  String _getRouteImageUrl(AppRoute route) {
    // TODO: Реализовать загрузку изображений из остановок маршрута или из API
    return '';
  }

  Future<void> _removeRouteFromFavorites(int index) async {
    final route = _favoriteRoutes[index];
    final token = await AuthService.getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Необходима авторизация для удаления из избранного'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      await ApiService.removeRouteFromFavorites(route.id, token);
      if (mounted) {
        setState(() {
          _favoriteRoutes.removeAt(index);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось удалить из избранного'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showDeleteRouteDialog(int index) {
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
                            'Вы точно хотите убрать этот маршрут из избранного?',
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
                                  _removeRouteFromFavorites(index);
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
                    setState(() {
                      _selectedButtonIndex = 0;
                    });
                    _loadFavoritePlaces();
                  },
                  child: SmoothContainer(
                    padding: const EdgeInsets.all(10),
                    borderRadius: 10,
                    color: _selectedButtonIndex == 0
                        ? AppDesignSystem.primaryColor
                        : Colors.transparent,
                    child: Center(
                      child: Text(
                        'Места',
                        style: AppTextStyles.small(
                          color: _selectedButtonIndex == 0
                              ? AppDesignSystem.whiteColor
                              : AppDesignSystem.textColorPrimary,
                          fontWeight: _selectedButtonIndex == 0
                              ? AppDesignSystem.fontWeightMedium
                              : AppDesignSystem.fontWeightRegular,
                          letterSpacing: _selectedButtonIndex == 0
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
                    setState(() {
                      _selectedButtonIndex = 1;
                    });
                    _loadFavoriteRoutes();
                  },
                  child: SmoothContainer(
                    padding: const EdgeInsets.all(10),
                    borderRadius: 10,
                    color: _selectedButtonIndex == 1
                        ? AppDesignSystem.primaryColor
                        : Colors.transparent,
                    child: Center(
                      child: Text(
                        'Маршруты',
                        style: AppTextStyles.small(
                          color: _selectedButtonIndex == 1
                              ? AppDesignSystem.whiteColor
                              : AppDesignSystem.textColorPrimary,
                          fontWeight: _selectedButtonIndex == 1
                              ? AppDesignSystem.fontWeightMedium
                              : AppDesignSystem.fontWeightRegular,
                          letterSpacing: _selectedButtonIndex == 1
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
  Widget _buildScrollableContent() {
    final isEmpty = _selectedButtonIndex == 0
        ? _favoritePlaces.isEmpty
        : _favoriteRoutes.isEmpty;

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (isEmpty) {
      return _buildEmptyState();
    }

    if (_selectedButtonIndex == 0) {
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
        itemCount: _favoritePlaces.length,
        itemBuilder: (context, index) {
          return _buildPlaceCard(_favoritePlaces[index], index);
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
          childAspectRatio: 171 / 260, // Соответствует экрану маршрутов
        ),
        itemCount: _favoriteRoutes.length,
        itemBuilder: (context, index) {
          return _buildRouteCard(_favoriteRoutes[index], index);
        },
      );
    }
  }

  Widget _buildPlaceCard(Place place, int index) {
    return GestureDetector(
      onTap: () => _showPlaceDetails(place),
      child: SmoothContainer(
        width: 187,
        height: 260,
        borderRadius: 16,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Color(0x66000000),
            ],
            stops: [0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Фото места
            Positioned.fill(
              child: ClipPath(
                clipper: SmoothBorderClipper(radius: 16),
                child: place.images.isNotEmpty
                    ? Image.network(
                  place.images.first.url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppDesignSystem.greyPlaceholder,
                    child: Icon(Icons.photo_camera, size: 48, color: AppDesignSystem.primaryColor),
                  ),
                )
                    : Container(
                  color: AppDesignSystem.greyPlaceholder,
                  child: Icon(Icons.photo_camera, size: 48, color: AppDesignSystem.primaryColor),
                ),
              ),
            ),

            // Контент карточки
            SmoothContainer(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(10),
              borderRadius: 16,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33000000),
                    Color(0x66000000),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Верхняя часть - тип места и иконка избранного
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Кнопка типа места
                      SmoothContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        borderRadius: 26,
                        child: Text(
                          place.type,
                          style: AppTextStyles.small(
                            color: AppDesignSystem.whiteColor,
                          ),
                        ),
                      ),

                      // Иконка избранного
                      GestureDetector(
                        onTap: () {
                          _showDeleteDialog(index);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          Icons.bookmark,
                          color: AppDesignSystem.whiteColor,
                          size: 16,
                        ),
                      ),
                    ],
                  ),

                  // Нижняя часть - название и описание
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Название места
                      Text(
                        place.name,
                        style: AppTextStyles.small(
                          color: AppDesignSystem.whiteColor,
                          fontWeight: AppDesignSystem.fontWeightSemiBold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Описание места
                      Text(
                        place.description.length > 100
                            ? '${place.description.substring(0, 100)}...'
                            : place.description,
                        style: AppTextStyles.small(
                          color: AppDesignSystem.whiteColor.withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(AppRoute route, int index) {
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
                              Colors.black.withOpacity(0.6),
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
                          onTap: () => _showDeleteRouteDialog(index),
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
    return RefreshIndicator(
      onRefresh: () async {
        if (_selectedButtonIndex == 0) {
          await _loadFavoritePlaces();
        } else {
          await _loadFavoriteRoutes();
        }
      },
      child: Column(
        children: [
          // Статичная шапка
          _buildHeader(),

          // Скроллируемые карточки
          Expanded(
            child: _buildScrollableContent(),
          ),
        ],
      ),
    );
  }
}