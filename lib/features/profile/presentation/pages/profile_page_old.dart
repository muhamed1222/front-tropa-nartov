import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tropanartov/screens/auth/login_screen.dart';
import '../../../../core/helpers/open_bottom_sheet.dart';
import '../../../../services/auth_service.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../../../favourites/presentation/widgets/favourites_widget.dart';
import '../../../favourites/presentation/widgets/place_details_sheet_simple.dart';
import '../../../favourites/presentation/widgets/route_details_sheet_simple.dart';
import '../widgets/edit_profile_page.dart';
import 'package:tropanartov/models/api_models.dart' hide Image;
import 'package:tropanartov/services/api_service.dart';
import '../../../../services/republic_service.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/utils/logger.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Константы
  static const double _dialogWidth = AppDesignSystem.dialogWidth;
  static const double _favoritesCardHeight = AppDesignSystem.cardHeight;
  static const double _favoritesCardWidth = AppDesignSystem.cardWidth;
  static const int _maxHistoryItems = AppDesignSystem.maxHistoryItemsOnProfile;
  static const int _maxFavoriteItems = AppDesignSystem.maxFavoriteItemsOnProfile;

  User? _user;
  bool _isLoading = true;
  String _error = '';
  List<Place> _favoritePlaces = [];
  bool _isLoadingFavorites = false;
  bool _isRemovingFavorite = false;

  // Статистика
  int _visitedPlaces = 0;
  int _completedRoutes = 0;
  int _totalPlaces = 0;
  int _totalRoutes = 0;
  bool _isLoadingStatistics = false;
  String? _statisticsError;

  // История активности
  List<_ActivityItem>? _sortedActivities; // Кэшированный отсортированный список
  bool _isLoadingHistory = false;
  String? _historyError;

  // Выбранная республика
  String? _selectedRepublic;

  // Кэширование данных
  DateTime? _lastProfileLoad;
  DateTime? _lastStatisticsLoad;
  static const Duration _cacheDuration = AppDesignSystem.profileCacheDuration;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadFavoritePlaces();
    _loadStatistics();
    _loadActivityHistory();
    _loadSelectedRepublic();

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

  Future<void> _loadSelectedRepublic() async {
    final selected = await RepublicService.getSelectedRepublicOrDefault();
    if (mounted) {
      setState(() {
        _selectedRepublic = selected;
      });
    }
  }

  Future<void> _loadUserProfile({bool forceRefresh = false}) async {
    // Проверяем кэш
    if (!forceRefresh && _user != null && _lastProfileLoad != null && DateTime.now().difference(_lastProfileLoad!) < _cacheDuration) {
      return;
    }

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        setState(() {
          _error = 'Необходима авторизация';
          _isLoading = false;
        });
        return;
      }
      final user = await ApiService.getProfile(token);
      setState(() {
        _user = user;
        _isLoading = false;
        _error = '';
        _lastProfileLoad = DateTime.now();
      });
    } catch (e, stackTrace) {
      AppLogger.loadError('User Profile', e, stackTrace);
      setState(() {
        _error = 'Ошибка загрузки профиля';
        _isLoading = false;
      });
    }
  }

  String? _favoritesError;

  Future<void> _loadFavoritePlaces() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    if (mounted) {
      setState(() {
        _isLoadingFavorites = true;
        _favoritesError = null;
      });
    }

    try {
      final places = await ApiService.getFavoritePlaces(token);
      if (mounted) {
        setState(() {
          _favoritePlaces = places;
          _isLoadingFavorites = false;
          _favoritesError = null;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.loadError('Favorite Places', e, stackTrace);
      if (mounted) {
        setState(() {
          _isLoadingFavorites = false;
          _favoritesError = 'Ошибка загрузки избранного';
        });
      }
    }
  }

  Future<void> _loadStatistics({bool forceRefresh = false}) async {
    // Проверяем кэш
    if (!forceRefresh && _lastStatisticsLoad != null && DateTime.now().difference(_lastStatisticsLoad!) < _cacheDuration && _visitedPlaces > 0) {
      return;
    }

    final token = await AuthService.getToken();
    if (token == null) return;

    if (mounted) {
      setState(() {
        _isLoadingStatistics = true;
        _statisticsError = null;
      });
    }

    try {
      // Загружаем статистику пользователя и общее количество параллельно
      final results = await Future.wait([
        ApiService.getUserStatistics(token),
        ApiService.getPlaces(),
        ApiService.getRoutes(),
      ]);

      final statistics = results[0] as Map<String, int>;
      final allPlaces = results[1] as List<Place>;
      final allRoutes = results[2] as List<AppRoute>;

      if (mounted) {
        setState(() {
          _visitedPlaces = statistics['visitedPlaces'] ?? 0;
          _completedRoutes = statistics['completedRoutes'] ?? 0;
          _totalPlaces = allPlaces.length;
          _totalRoutes = allRoutes.length;
          _isLoadingStatistics = false;
          _statisticsError = null;
          _lastStatisticsLoad = DateTime.now();
        });
      }
    } catch (e, stackTrace) {
      AppLogger.loadError('User Statistics', e, stackTrace);
      if (mounted) {
        setState(() {
          _isLoadingStatistics = false;
          _statisticsError = 'Ошибка загрузки статистики';
        });
      }
    }
  }

  Future<void> _loadActivityHistory() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    if (mounted) {
      setState(() {
        _isLoadingHistory = true;
        _historyError = null;
      });
    }

    try {
      final history = await ApiService.getUserActivityHistory(token);
      if (mounted) {
        // Объединяем и сортируем сразу при загрузке (оптимизированная версия)
        final allActivities = <_ActivityItem>[
          ...history.places.map((p) => _PlaceActivityItem(p)),
          ...history.routes.map((r) => _RouteActivityItem(r)),
        ]..sort((a, b) => b.passedAt.compareTo(a.passedAt));

        setState(() {
          _sortedActivities = allActivities;
          _isLoadingHistory = false;
          _historyError = null;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.loadError('Activity History', e, stackTrace);
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
          _historyError = 'Ошибка загрузки истории активности';
        });
      }
    }
  }

  Future<void> _removeFromFavorites(int index) async {
    final place = _favoritePlaces[index];
    final token = await AuthService.getToken();
    if (token == null) return;

    if (mounted) {
      setState(() {
        _isRemovingFavorite = true;
      });
    }

    try {
      await ApiService.removeFromFavorites(place.id, token);
      if (mounted) {
        setState(() {
          _favoritePlaces.removeAt(index);
          _isRemovingFavorite = false;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.error('Remove from favorites', e, stackTrace);
      if (mounted) {
        setState(() {
          _isRemovingFavorite = false;
        });
        AppSnackBar.showError(context, 'Ошибка при удалении из избранного');
      }
    }
  }

  void _showDeleteDialog(int index) {
    _showConfirmationDialog(
      title: 'Вы действительно хотите убрать это место из избранного?',
      confirmText: 'Да',
      confirmColor: AppDesignSystem.primaryColor,
      onConfirm: () {
        _removeFromFavorites(index);
      },
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return _ConfirmationDialogWidget(
          title: title,
          confirmText: confirmText,
          confirmColor: confirmColor,
          onConfirm: onConfirm,
        );
      },
    );
  }

  // Метод для формирования полного имени
  String _getFullName() {
    if (_user == null) return 'Загрузка...';
    return _user!.fullName;
  }

  // Метод для получения ID пользователя
  String _getUserId() {
    if (_user == null) return 'ID: ...';
    // Показываем только последние 4 цифры для безопасности
    final idStr = _user!.id.toString();
    if (idStr.length <= 4) {
      return 'ID: $idStr';
    }
    return 'ID: ****${idStr.substring(idStr.length - 4)}';
  }

  // Метод для получения URL аватарки
  String? _getAvatarUrl() {
    if (_user == null || _user!.avatarUrl == null || _user!.avatarUrl!.isEmpty) {
      return null;
    }

    final avatarUrl = _user!.avatarUrl!;
    if (avatarUrl.startsWith('http')) {
      return avatarUrl;
    } else {
      return '${ApiService.baseUrl}$avatarUrl';
    }
  }

  void _openEditProfile() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => EditProfilePage(
            onProfileUpdated: _loadUserProfile,
          ),
    );
  }

  void _showExitConfirmationDialog() {
    _showConfirmationDialog(
      title: 'Вы действительно хотите выйти из профиля?',
      confirmText: 'Да',
      confirmColor: AppDesignSystem.errorColor,
      onConfirm: () async {
        // Выход из аккаунта
        await AuthService.forceLogout();

        // Переходим на экран авторизации
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const AuthAuthorizationScreen(),
          ),
          (route) => false,
        );
      },
    );
  }

  Widget _buildLoadingProfile() {
    return const ProfileSkeletonWidget();
  }

  Widget _buildErrorProfile() {
    return Padding(
      padding: const EdgeInsets.all(AppDesignSystem.spacingMedium),
      child: ErrorStateWidget(
        message: _error,
        onRetry: _loadUserProfile,
      ),
    );
  }

  Widget _buildUserProfile() {
    final avatarUrl = _getAvatarUrl();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Аватар (с фото или дефолтный)
        SmoothContainer(
          width: 90,
          height: 90,
          borderRadius: AppDesignSystem.borderRadius,
          color: avatarUrl != null ? Colors.transparent : AppDesignSystem.greyPlaceholder,
          child:
              avatarUrl != null
                  ? ClipPath(
                    clipper: SmoothBorderClipper(radius: AppDesignSystem.borderRadius),
                    child: CachedNetworkImage(
                      imageUrl: avatarUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppDesignSystem.primaryColor,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => SmoothContainer(
                        borderRadius: AppDesignSystem.borderRadius,
                        color: AppDesignSystem.greyPlaceholder,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: AppDesignSystem.greyColor,
                        ),
                      ),
                    ),
                  )
                  : Icon(
                    Icons.person,
                    size: 40,
                    color: AppDesignSystem.greyColor,
                  ),
        ),
        SizedBox(width: AppDesignSystem.spacingMedium),
        // Информация о пользователе
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: 'Имя пользователя: ${_getFullName()}',
                child: Text(
                  _getFullName(),
                  style: AppTextStyles.body(
                    fontWeight: AppDesignSystem.fontWeightSemiBold,
                  ),
                ),
              ),
              SizedBox(height: AppDesignSystem.spacingTiny),
              Semantics(
                label: 'ID пользователя: ${_getUserId()}',
                child: Text(
                  _getUserId(),
                  style: AppTextStyles.small(
                    color: AppDesignSystem.textColorTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Кнопка редактирования
        Semantics(
          button: true,
          label: 'Редактировать профиль',
          child: GestureDetector(
            onTap: _openEditProfile,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDesignSystem.borderRadiusInput),
                color: AppDesignSystem.primaryColor.withValues(alpha: 0.12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  'assets/pen.svg',
                  width: AppDesignSystem.spacingSmall,
                  height: AppDesignSystem.spacingSmall,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPlaceDetails(Place place) {
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceDetailsSheetSimple(place: place),
    );
  }

  Widget _buildFavoriteCard(Place place, int displayIndex) {
    // Находим реальный индекс в полном списке
    final realIndex = _favoritePlaces.indexOf(place);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(
        milliseconds: AppDesignSystem.animationDurationNormal.inMilliseconds + (displayIndex * 100),
      ),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.9 + (0.1 * value),
            child: child,
          ),
        );
      },
      child: Semantics(
        button: true,
        label: 'Избранное место: ${place.name}',
        child: GestureDetector(
          onTap: () => _showPlaceDetails(place),
          child: SmoothContainer(
            width: _favoritesCardWidth,
            height: _favoritesCardHeight,
            margin: const EdgeInsets.only(right: AppDesignSystem.spacingSmall + 2),
            borderRadius: AppDesignSystem.borderRadiusMedium,
            decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppDesignSystem.overlayDark,
              ],
              stops: [0.5, 1.0],
            ),
            ),
            child: Stack(
              children: [
                // Фото места
                Positioned.fill(
                  child: ClipPath(
                    clipper: SmoothBorderClipper(radius: AppDesignSystem.borderRadiusMedium),
                    child: place.images.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: place.images.first.url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppDesignSystem.greyLight,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppDesignSystem.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppDesignSystem.greyLight,
                            child: Icon(
                              Icons.photo_camera,
                              size: 48,
                              color: AppDesignSystem.primaryColor,
                            ),
                          ),
                        )
                      : Container(
                          color: AppDesignSystem.greyLight,
                          child: Icon(
                            Icons.photo_camera,
                            size: 48,
                            color: AppDesignSystem.primaryColor,
                          ),
                        ),
                  ),
                ),

                // Контент карточки
                SmoothContainer(
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.all(AppDesignSystem.spacingSmall + 2),
                  borderRadius: AppDesignSystem.borderRadiusMedium,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppDesignSystem.overlayDarkLight,
                        AppDesignSystem.overlayDark,
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
                            padding: const EdgeInsets.symmetric(horizontal: AppDesignSystem.spacingSmall, vertical: AppDesignSystem.spacingTiny),
                            borderRadius: AppDesignSystem.borderRadiusXXLarge,
                            color: AppDesignSystem.textColorWhite.withValues(alpha: 0.2),
                            child: Text(
                              place.type,
                              style: AppTextStyles.error(
                                color: AppDesignSystem.textColorWhite,
                              ),
                            ),
                          ),

                          // Иконка избранного
                          GestureDetector(
                            onTap:
                                _isRemovingFavorite
                                    ? null
                                    : () {
                                      _showDeleteDialog(realIndex);
                                    },
                            child:
                                _isRemovingFavorite
                                    ? SizedBox(
                                      width: AppDesignSystem.spacingLarge,
                                      height: AppDesignSystem.spacingLarge,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppDesignSystem.textColorWhite),
                                      ),
                                    )
                                    : const Icon(
                                      Icons.bookmark,
                                      color: Colors.white,
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
                              color: AppDesignSystem.textColorWhite,
                              fontWeight: AppDesignSystem.fontWeightSemiBold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          SizedBox(height: AppDesignSystem.spacingTiny),

                          // Описание места
                          Text(
                            place.description.length > 100 ? '${place.description.substring(0, 100)}...' : place.description,
                            style: AppTextStyles.error(
                              color: AppDesignSystem.overlayWhite,
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
        ),
      ),
    );
  }

  Widget _buildEmptyFavorites() {
    return SizedBox(
      height: _favoritesCardHeight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/bookmark_empty.svg',
              width: 50,
              height: 50,
            ),
            SizedBox(height: AppDesignSystem.spacingLarge),
            Text(
              'В избранном пока ничего нет',
              style: AppTextStyles.body(
                fontWeight: AppDesignSystem.fontWeightMedium,
              ),
            ),
            SizedBox(height: AppDesignSystem.spacingSmall),
            Text(
              'Добавляйте понравившиеся места в избранное',
              style: AppTextStyles.small(
                color: AppDesignSystem.textColorSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingFavorites() {
    return SizedBox(
      height: _favoritesCardHeight,
      child: const LoadingStateWidget(),
    );
  }

  Widget _buildFavoritesList() {
    if (_favoritePlaces.isEmpty) {
      return _buildEmptyFavorites();
    }

    // Ограничиваем количество элементов
    final displayPlaces = _favoritePlaces.take(_maxFavoriteItems).toList();
    final hasMore = _favoritePlaces.length > _maxFavoriteItems;

    return Column(
      children: [
        SizedBox(
          height: _favoritesCardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayPlaces.length,
            itemBuilder: (context, index) {
              return _buildFavoriteCard(displayPlaces[index], index);
            },
          ),
        ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: AppDesignSystem.spacingSmall),
            child: Text(
              'Показано ${displayPlaces.length} из ${_favoritePlaces.length}',
              style: AppTextStyles.error(
                color: AppDesignSystem.textColorSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFavoritesError() {
    return SizedBox(
      height: _favoritesCardHeight,
      child: ErrorStateWidget(
        message: _favoritesError ?? 'Ошибка загрузки',
        onRetry: _loadFavoritePlaces,
      ),
    );
  }

  Widget _buildActivityHistoryList() {
    // Используем кэшированный отсортированный список
    final allActivities = _sortedActivities ?? [];

    // Ограничиваем количество элементов
    final limitedActivities = allActivities.take(_maxHistoryItems).toList();

    // Показываем индикатор, если есть больше элементов
    final hasMore = allActivities.length > _maxHistoryItems;

    if (limitedActivities.isEmpty) {
      return SmoothContainer(
        padding: const EdgeInsets.all(AppDesignSystem.spacingXLarge),
        borderRadius: AppDesignSystem.borderRadius,
        color: AppDesignSystem.backgroundColorSecondary,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/history.svg',
                width: 50,
                height: 50,
              ),
              SizedBox(height: AppDesignSystem.spacingLarge),
              Text(
                'История активности пуста',
                style: AppTextStyles.body(
                  fontWeight: AppDesignSystem.fontWeightMedium,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDesignSystem.spacingSmall),
              Text(
                'Посещенные места и пройденные маршруты появятся здесь',
                style: AppTextStyles.small(
                  color: AppDesignSystem.textColorSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ...limitedActivities.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(
              milliseconds: AppDesignSystem.animationDurationNormal.inMilliseconds + (index * 50),
            ),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                _buildActivityCard(
                  title: activity.title,
                  date: _formatDate(activity.passedAt),
                  onTap: () {
                    if (!mounted) return;
                    Navigator.of(context).pop();
                    if (activity is _PlaceActivityItem) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => PlaceDetailsSheetSimple(place: activity.placeActivity.place),
                      );
                    } else if (activity is _RouteActivityItem) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => RouteDetailsSheetSimple(route: activity.routeActivity.route),
                      );
                    }
                  },
                ),
                SizedBox(height: AppDesignSystem.spacingSmall + 2),
              ],
            ),
          );
        }),
        // Индикатор, если есть больше элементов
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: AppDesignSystem.spacingSmall + 2),
            child: Text(
              'Показано ${limitedActivities.length} из ${allActivities.length}',
              style: AppTextStyles.error(
                color: AppDesignSystem.textColorSecondary,
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().substring(2);
    return '$day.$month.$year';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ClipPath(
      clipper: SmoothBorderClipper(radius: AppDesignSystem.borderRadiusLarge),
      child: Container(
        width: screenWidth > _dialogWidth + 28 ? _dialogWidth + 28 : screenWidth,
        color: AppDesignSystem.backgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Строка для закрытия bottom sheet
            Center(
              child: SmoothContainer(
                width: AppDesignSystem.handleBarWidth,
                height: AppDesignSystem.handleBarHeight,
                borderRadius: AppDesignSystem.borderRadiusTiny + 1,
                color: AppDesignSystem.greyColor,
                child: const SizedBox.shrink(),
              ),
            ),
            SizedBox(height: AppDesignSystem.spacingXXLarge + 2),

            // Заголовок
            Text(
              'Личный кабинет',
              style: AppTextStyles.title(),
            ),
            SizedBox(height: AppDesignSystem.spacingXXLarge + 4),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    _loadUserProfile(forceRefresh: true),
                    _loadFavoritePlaces(),
                    _loadStatistics(forceRefresh: true),
                    _loadActivityHistory(),
                  ]);
                },
                color: AppDesignSystem.primaryColor,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 0, bottom: 0),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Основной контент с gap 20px
                      Column(
                        children: [
                          // Профиль пользователя
                          SmoothContainer(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppDesignSystem.spacingSmall + 2),
                            borderRadius: AppDesignSystem.borderRadiusMedium,
                            color: AppDesignSystem.backgroundColorSecondary,
                            child:
                                _isLoading
                                    ? _buildLoadingProfile()
                                    : _error.isNotEmpty
                                    ? _buildErrorProfile()
                                    : _buildUserProfile(),
                          ),
                          SizedBox(height: AppDesignSystem.spacingXLarge),

                          // Статистика
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Статистика',
                                      style: AppTextStyles.body(
                                        fontWeight: AppDesignSystem.fontWeightSemiBold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/location.svg',
                                          width: 15,
                                          height: 15,
                                          colorFilter: ColorFilter.mode(AppDesignSystem.textColorTertiary, BlendMode.srcIn),
                                        ),
                                        SizedBox(width: AppDesignSystem.spacingTiny),
                                        Text(
                                          _selectedRepublic ?? 'Кабардино-Балкария',
                                          style: AppTextStyles.small(
                                            color: AppDesignSystem.textColorTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppDesignSystem.spacingSmall + 2),

                              // Прогресс маршрутов
                              _isLoadingStatistics
                                  ? const StatisticsSkeletonWidget()
                                  : _statisticsError != null
                                  ? Padding(
                                    padding: const EdgeInsets.all(AppDesignSystem.spacingLarge),
                                    child: ErrorStateWidget(
                                      message: _statisticsError!,
                                      onRetry: _loadStatistics,
                                    ),
                                  )
                                  : Row(
                                    children: [
                                      // Посещенные места
                                      Expanded(
                                        child: _buildStatisticsCard(
                                          current: _visitedPlaces,
                                          total: _totalPlaces,
                                          label: 'Посещенные места',
                                        ),
                                      ),
                                      SizedBox(width: AppDesignSystem.spacingSmall + 2),
                                      // Пройденные маршруты
                                      Expanded(
                                        child: _buildStatisticsCard(
                                          current: _completedRoutes,
                                          total: _totalRoutes,
                                          label: 'Пройденные маршруты',
                                        ),
                                      ),
                                    ],
                                  ),
                            ],
                          ),
                          SizedBox(height: AppDesignSystem.spacingXLarge),

                          // Избранное
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Избранное',
                                      style: AppTextStyles.body(
                                        fontWeight: AppDesignSystem.fontWeightSemiBold,
                                      ),
                                    ),
                                    Semantics(
                                      button: true,
                                      label: 'Смотреть все избранное',
                                      child: GestureDetector(
                                        onTap: () {
                                          // Навигация на страницу всех избранных
                                          openBottomSheet(context, (c) => FavouritesWidget(scrollController: c));
                                        },
                                        child: Text(
                                          'Смотреть все',
                                          style: AppTextStyles.small(
                                            color: AppDesignSystem.primaryColor,
                                            fontWeight: AppDesignSystem.fontWeightMedium,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppDesignSystem.spacingSmall + 2),

                              // Карточки избранного
                              _isLoadingFavorites
                                  ? _buildLoadingFavorites()
                                  : _favoritesError != null
                                  ? _buildFavoritesError()
                                  : _buildFavoritesList(),
                            ],
                          ),
                          SizedBox(height: AppDesignSystem.spacingXLarge),

                          // История активности
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'История активности',
                                style: AppTextStyles.body(
                                  fontWeight: AppDesignSystem.fontWeightSemiBold,
                                ),
                              ),
                              SizedBox(height: AppDesignSystem.spacingSmall + 2),

                              // Карточки истории
                              _isLoadingHistory
                                  ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(AppDesignSystem.spacingXLarge),
                                      child: CircularProgressIndicator(
                                        valueColor: const AlwaysStoppedAnimation<Color>(AppDesignSystem.primaryColor),
                                      ),
                                    ),
                                  )
                                  : _historyError != null
                                  ? Padding(
                                    padding: const EdgeInsets.all(AppDesignSystem.spacingLarge),
                                    child: ErrorStateWidget(
                                      message: _historyError!,
                                      onRetry: _loadActivityHistory,
                                    ),
                                  )
                                  : _buildActivityHistoryList(),
                            ],
                          ),
                        ],
                      ),

                      // Кнопка выхода
                      Padding(
                        padding: const EdgeInsets.only(top: AppDesignSystem.spacingXLarge),
                        child: Semantics(
                          button: true,
                          label: 'Выйти из профиля',
                          child: GestureDetector(
                            onTap: _showExitConfirmationDialog,
                            child: SmoothContainer(
                              padding: const EdgeInsets.all(AppDesignSystem.spacingSmall + 2),
                              borderRadius: AppDesignSystem.borderRadius,
                              color: AppDesignSystem.backgroundColorSecondary,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Выйти',
                                    style: AppTextStyles.body(
                                      color: AppDesignSystem.errorColor,
                                      fontWeight: AppDesignSystem.fontWeightMedium,
                                    ),
                                  ),
                                  SizedBox(width: AppDesignSystem.spacingSmall + 2),
                                  SvgPicture.asset(
                                    'assets/exit.svg',
                                    width: 18,
                                    height: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppDesignSystem.spacingLarge),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard({
    required int current,
    required int total,
    required String label,
  }) {
    // Вычисляем прогресс (от 0.0 до 1.0)
    double progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;

    // Минимальная ширина прогресса для видимости
    double progressWidth = progress < AppDesignSystem.progressBarMinWidth && progress > 0
        ? AppDesignSystem.progressBarMinWidth
        : progress;

    return SmoothContainer(
      height: 72,
      borderRadius: AppDesignSystem.borderRadius,
      color: AppDesignSystem.primaryColorLight, // Базовый цвет (светло-бирюзовый)
      child: Stack(
        children: [
          // Прогресс-бар (заполнение слева направо)
          FractionallySizedBox(
            widthFactor: progressWidth,
            child: SmoothContainer(
              borderRadius: AppDesignSystem.borderRadius,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppDesignSystem.primaryColorLight, // Светло-бирюзовый
                    AppDesignSystem.primaryColor, // Темно-бирюзовый
                  ],
                ),
              ),
              child: const SizedBox.shrink(),
            ),
          ),
          // Контент поверх прогресс-бара
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$current',
                    style: AppTextStyles.title(
                      color: AppDesignSystem.textColorWhite,
                      fontWeight: AppDesignSystem.fontWeightMedium,
                    ),
                  ),
                  if (total > 0)
                    Text(
                      '/$total',
                      style: AppTextStyles.bodyLarge(
                        color: AppDesignSystem.textColorWhite.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
              SizedBox(height: AppDesignSystem.spacingTiny + 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.small(
                  color: AppDesignSystem.textColorWhite,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String date,
    required VoidCallback onTap,
  }) {
    return SmoothContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDesignSystem.spacingSmall + 2),
      borderRadius: AppDesignSystem.borderRadius,
      color: AppDesignSystem.backgroundColorSecondary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: 'Активность: $title',
                  child: Text(
                    title,
                    style: AppTextStyles.body(
                      fontWeight: AppDesignSystem.fontWeightMedium,
                    ),
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacingSmall + 2),
                Semantics(
                  label: 'Дата: $date',
                  child: Text(
                    date,
                    style: AppTextStyles.error(
                      color: AppDesignSystem.textColorTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: 'Перейти к $title',
            child: GestureDetector(
              onTap: onTap,
              child: SmoothContainer(
                padding: const EdgeInsets.symmetric(horizontal: AppDesignSystem.paddingHorizontal, vertical: AppDesignSystem.spacingSmall),
                borderRadius: AppDesignSystem.borderRadiusLarge,
                color: AppDesignSystem.greyButton,
                child: Text(
                  'Перейти',
                  style: AppTextStyles.small(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Вспомогательный класс для типобезопасного хранения активности
sealed class _ActivityItem {
  final DateTime passedAt;
  final String title;

  _ActivityItem({required this.passedAt, required this.title});
}

class _PlaceActivityItem extends _ActivityItem {
  final PlaceActivity placeActivity;

  _PlaceActivityItem(this.placeActivity)
    : super(
        passedAt: placeActivity.passedAt,
        title: placeActivity.place.name,
      );
}

class _RouteActivityItem extends _ActivityItem {
  final RouteActivity routeActivity;

  _RouteActivityItem(this.routeActivity)
    : super(
        passedAt: routeActivity.passedAt,
        title: routeActivity.route.name,
      );
}

// Общий виджет для диалога подтверждения
class _ConfirmationDialogWidget extends StatelessWidget {
  final String title;
  final String confirmText;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const _ConfirmationDialogWidget({
    required this.title,
    required this.confirmText,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(color: Colors.transparent),
        ),
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
          child: Stack(
            children: [
              SmoothContainer(
                width: MediaQuery.of(context).size.width > 400.0 ? AppDesignSystem.dialogWidth : MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
                borderRadius: AppDesignSystem.borderRadiusLarge,
                color: AppDesignSystem.backgroundColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width > 400.0 ? 270.0 : MediaQuery.of(context).size.width * 0.7,
                      child: Text(
                        title,
                        style: AppTextStyles.title(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: AppDesignSystem.spacingXLarge),
                    Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            button: true,
                            label: 'Отмена',
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: SmoothContainer(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppDesignSystem.paddingVerticalMedium,
                                  horizontal: AppDesignSystem.spacingMedium,
                                ),
                                borderRadius: AppDesignSystem.borderRadius,
                                color: AppDesignSystem.backgroundColorSecondary,
                                child: Center(
                                  child: Text(
                                    'Нет',
                                    style: AppTextStyles.body(
                                      fontWeight: AppDesignSystem.fontWeightMedium,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: AppDesignSystem.spacingMedium),
                        Expanded(
                          child: Semantics(
                            button: true,
                            label: confirmText,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                onConfirm();
                              },
                              child: SmoothContainer(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppDesignSystem.paddingVerticalMedium,
                                  horizontal: AppDesignSystem.spacingMedium,
                                ),
                                borderRadius: AppDesignSystem.borderRadius,
                                color: confirmColor,
                                child: Center(
                                  child: Text(
                                    confirmText,
                                    style: AppTextStyles.button(),
                                  ),
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
              Positioned(
                top: AppDesignSystem.spacingMedium - 2,
                right: AppDesignSystem.spacingMedium - 2,
                child: Semantics(
                  button: true,
                  label: 'Закрыть',
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                        child: Icon(Icons.close, size: 18, color: AppDesignSystem.textColorTertiary),
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
  }
}
