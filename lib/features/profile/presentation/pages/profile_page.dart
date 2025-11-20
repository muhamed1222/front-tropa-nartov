import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import 'package:flutter_svg/svg.dart';
import 'package:tropanartov/screens/auth/login_screen.dart';
import '../../../../core/helpers/open_bottom_sheet.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../../../favourites/presentation/widgets/favourites_widget.dart';
import '../../../favourites/presentation/bloc/favourites_bloc.dart';
import '../../../home/presentation/widgets/place_details_sheet_widget.dart';
import '../../../home/domain/entities/place.dart' as home_entities;
import '../../../../shared/domain/entities/image.dart' as shared_entities;
import '../../../../shared/domain/entities/review.dart' as shared_entities;
import '../../../favourites/presentation/widgets/route_details_sheet_simple.dart';
import '../widgets/edit_profile_page.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../services/auth_service.dart';
import 'package:tropanartov/models/api_models.dart' hide Image;
import '../../domain/profile_state_manager.dart';
import '../widgets/profile_user_section.dart';
import '../widgets/profile_statistics_section.dart';
import '../widgets/profile_favorites_section.dart';
import '../widgets/profile_history_section.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Константы
  static const double _dialogWidth = AppDesignSystem.dialogWidth;
  static const int _maxHistoryItems = AppDesignSystem.maxHistoryItemsOnProfile;
  static const int _maxFavoriteItems = AppDesignSystem.maxFavoriteItemsOnProfile;

  // State Manager
  final ProfileStateManager _stateManager = ProfileStateManager();

  // Состояния загрузки
  bool _isLoadingProfile = true;
  bool _isLoadingFavorites = false;
  bool _isLoadingStatistics = false;
  bool _isLoadingHistory = false;
  bool _isRemovingFavorite = false;

  // Ошибки
  String? _profileError;
  String? _favoritesError;
  String? _statisticsError;
  String? _historyError;

  @override
  void initState() {
    super.initState();
    _loadAllData();

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

  /// Загрузка всех данных с приоритетами
  /// Оптимизированная последовательная загрузка для предотвращения перегрузки сети
  Future<void> _loadAllData({bool forceRefresh = false}) async {
    if (!mounted) return;
    
    // Проверяем авторизацию перед загрузкой данных
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!isLoggedIn) {
      if (mounted) {
        // Закрываем bottom sheet
        Navigator.of(context).pop();
        // Перенаправляем на экран авторизации через root navigator
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const AuthLoginScreen(),
          ),
          (route) => false,
        );
      }
      return;
    }
    
    // Приоритет 1: Профиль пользователя (критично для отображения)
    await _loadUserProfile(forceRefresh: forceRefresh);
    if (!mounted) return;
    
    // Если профиль не загрузился (нет авторизации), прекращаем загрузку
    if (_stateManager.user == null && _profileError == 'Необходима авторизация') {
      if (mounted) {
        // Закрываем bottom sheet
        Navigator.of(context).pop();
        // Перенаправляем на экран авторизации через root navigator
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const AuthLoginScreen(),
          ),
          (route) => false,
        );
      }
      return;
    }
    
    // Приоритет 2: Республика и статистика (параллельно, менее критично)
    await Future.wait([
      _loadSelectedRepublic(),
      _loadStatistics(forceRefresh: forceRefresh),
    ]);
    if (!mounted) return;
    
    // Приоритет 3: Избранное и история (параллельно, можно загружать после)
    await Future.wait([
      _loadFavoritePlaces(forceRefresh: forceRefresh),
      _loadActivityHistory(forceRefresh: forceRefresh),
    ]);
  }

  Future<void> _loadSelectedRepublic() async {
    try {
      await _stateManager.loadSelectedRepublic();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Ошибка не критична, просто не показываем республику
    }
  }

  Future<void> _loadUserProfile({bool forceRefresh = false}) async {
    if (mounted) {
      setState(() {
        _isLoadingProfile = true;
        _profileError = null;
      });
    }

    try {
      final user = await _stateManager.loadUserProfile(forceRefresh: forceRefresh);
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
          // Если пользователь null, это может быть из-за отсутствия авторизации
          if (user == null) {
            _profileError = 'Необходима авторизация';
          } else {
          _profileError = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
          _profileError = 'Ошибка загрузки профиля';
        });
      }
    }
  }

  Future<void> _loadFavoritePlaces({bool forceRefresh = false}) async {
    if (mounted) {
      setState(() {
        _isLoadingFavorites = true;
        _favoritesError = null;
      });
    }

    try {
      await _stateManager.loadFavoritePlaces(forceRefresh: forceRefresh);
      if (mounted) {
        setState(() {
          _isLoadingFavorites = false;
          _favoritesError = _stateManager.favoritesError;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFavorites = false;
          _favoritesError = _stateManager.favoritesError ?? 'Ошибка загрузки избранного';
        });
      }
    }
  }

  Future<void> _loadStatistics({bool forceRefresh = false}) async {
    if (mounted) {
      setState(() {
        _isLoadingStatistics = true;
        _statisticsError = null;
      });
    }

    try {
      await _stateManager.loadStatistics(forceRefresh: forceRefresh);
      if (mounted) {
        setState(() {
          _isLoadingStatistics = false;
          _statisticsError = _stateManager.statisticsError;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStatistics = false;
          _statisticsError = _stateManager.statisticsError ?? 'Ошибка загрузки статистики';
        });
      }
    }
  }

  Future<void> _loadActivityHistory({bool forceRefresh = false}) async {
    if (mounted) {
      setState(() {
        _isLoadingHistory = true;
        _historyError = null;
      });
    }

    try {
      await _stateManager.loadActivityHistory(forceRefresh: forceRefresh);
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
          _historyError = _stateManager.historyError;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
          _historyError = _stateManager.historyError ?? 'Ошибка загрузки истории активности';
        });
      }
    }
  }

  Future<void> _removeFromFavorites(int index) async {
    if (index < 0 || index >= _stateManager.favoritePlaces.length) {
      return;
    }

    if (mounted) {
      setState(() {
        _isRemovingFavorite = true;
      });
    }

    try {
      await _stateManager.removeFromFavorites(index);
      // Кэш уже инвалидирован в stateManager.removeFromFavorites
      if (mounted) {
        setState(() {
          _isRemovingFavorite = false;
        });
      }
    } catch (e) {
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

  void _openEditProfile() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfilePage(
        onProfileUpdated: () {
          // Инвалидируем кэш и перезагружаем данные
          _stateManager.invalidateProfileCache();
          _loadUserProfile(forceRefresh: true);
        },
      ),
    );
  }

  void _showExitConfirmationDialog() {
    _showConfirmationDialog(
      title: 'Вы действительно хотите выйти из профиля?',
      confirmText: 'Да',
      confirmColor: AppDesignSystem.errorColor,
      onConfirm: () async {
        await AuthService.forceLogout();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const AuthLoginScreen(),
          ),
          (route) => false,
        );
      },
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
        return shared_entities.Review(
          id: review.id,
          text: review.text,
          authorId: review.userId ?? 0,
          authorName: review.authorName,
          authorAvatar: review.authorAvatar ?? '',
          rating: review.rating,
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
    Navigator.of(context).pop();
    // Конвертируем Place из api_models в Place из home/domain/entities
    final homePlace = _convertPlaceToHomeEntity(place);
    
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
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RouteDetailsSheetSimple(route: route),
    );
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
            // Индикатор перетаскивания на самом верху с отступом 8px
               DragIndicator(
                color: AppDesignSystem.handleBarColor,
                padding: EdgeInsets.zero,
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
                  await _loadAllData(forceRefresh: true);
                },
                color: AppDesignSystem.primaryColor,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 0, bottom: 0),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          // Профиль пользователя
                          ProfileUserSection(
                            user: _stateManager.user,
                            isLoading: _isLoadingProfile,
                            error: _profileError,
                            onEdit: _openEditProfile,
                            onRetry: () => _loadUserProfile(forceRefresh: true),
                          ),
                          SizedBox(height: AppDesignSystem.spacingXLarge),

                          // Статистика
                          ProfileStatisticsSection(
                            visitedPlaces: _stateManager.visitedPlaces,
                            completedRoutes: _stateManager.completedRoutes,
                            totalPlaces: _stateManager.totalPlaces,
                            totalRoutes: _stateManager.totalRoutes,
                            selectedRepublic: _stateManager.selectedRepublic,
                            isLoading: _isLoadingStatistics,
                            error: _statisticsError,
                            onRetry: () => _loadStatistics(forceRefresh: true),
                          ),
                          SizedBox(height: AppDesignSystem.spacingXLarge),

                          // Избранное
                          ProfileFavoritesSection(
                            favoritePlaces: _stateManager.favoritePlaces,
                            isLoading: _isLoadingFavorites,
                            error: _favoritesError,
                            isRemoving: _isRemovingFavorite,
                            maxItems: _maxFavoriteItems,
                            onViewAll: () {
                              openBottomSheet(
                                context,
                                (ScrollController scrollController) {
                                  return BlocProvider(
                                    create: (BuildContext context) {
                                      final bloc = di.sl<FavouritesBloc>();
                                      bloc.add(const LoadFavoritePlaces(forceRefresh: false)); // Используем кеш при открытии
                                      bloc.add(const LoadFavoriteRoutes(forceRefresh: false));
                                      return bloc;
                                    },
                                    child: FavouritesWidget(scrollController: scrollController),
                                  );
                                },
                              );
                            },
                            onPlaceTap: _showPlaceDetails,
                            onRemove: _showDeleteDialog,
                            onRetry: () => _loadFavoritePlaces(forceRefresh: true),
                          ),
                          SizedBox(height: AppDesignSystem.spacingXLarge),

                          // История активности
                          ProfileHistorySection(
                            activities: _stateManager.sortedActivities,
                            isLoading: _isLoadingHistory,
                            error: _historyError,
                            maxItems: _maxHistoryItems,
                            onPlaceTap: _showPlaceDetails,
                            onRouteTap: _showRouteDetails,
                            onRetry: () => _loadActivityHistory(forceRefresh: true),
                          ),
                        ],
                      ),

                      // Кнопка выхода
                      Container(
                        padding: const EdgeInsets.only(top: AppDesignSystem.spacingXLarge),
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 99,
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
                      ),
                      SizedBox(height: 44),
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
        Container(
          color: Colors.black.withValues(alpha: 0.4),
        ),
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
          child: Stack(
            children: [
              SmoothContainer(
                width: MediaQuery.of(context).size.width > 400.0
                    ? AppDesignSystem.dialogWidth
                    : MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
                borderRadius: AppDesignSystem.borderRadiusLarge,
                color: AppDesignSystem.backgroundColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width > 400.0
                          ? 270.0
                          : MediaQuery.of(context).size.width * 0.7,
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
                          child: SecondaryButton(
                            text: 'Нет',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        SizedBox(width: AppDesignSystem.spacingMedium),
                        Expanded(
                          child: PrimaryButton(
                            text: confirmText,
                            color: confirmColor,
                            onPressed: () {
                              Navigator.of(context).pop();
                              onConfirm();
                            },
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
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: AppDesignSystem.textColorTertiary,
                        ),
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

