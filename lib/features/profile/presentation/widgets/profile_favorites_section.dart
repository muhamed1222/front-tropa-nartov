import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tropanartov/models/api_models.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import 'package:flutter_svg/svg.dart';

/// Виджет секции избранного
class ProfileFavoritesSection extends StatelessWidget {
  final List<Place> favoritePlaces;
  final bool isLoading;
  final String? error;
  final bool isRemoving;
  final int maxItems;
  final VoidCallback onViewAll;
  final Function(Place) onPlaceTap;
  final Function(int) onRemove;
  final VoidCallback? onRetry;

  const ProfileFavoritesSection({
    super.key,
    required this.favoritePlaces,
    required this.isLoading,
    this.error,
    required this.isRemoving,
    required this.maxItems,
    required this.onViewAll,
    required this.onPlaceTap,
    required this.onRemove,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  onTap: onViewAll,
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
        isLoading
            ? _buildLoading()
            : error != null
            ? _buildError()
            : _buildFavoritesList(),
      ],
    );
  }

  Widget _buildLoading() {
    return SizedBox(
      height: AppDesignSystem.cardHeight,
      child: const LoadingStateWidget(),
    );
  }

  Widget _buildError() {
    return SizedBox(
      height: AppDesignSystem.cardHeight,
      child: ErrorStateWidget(
        message: error ?? 'Ошибка загрузки',
        onRetry: onRetry,
      ),
    );
  }

  Widget _buildFavoritesList() {
    if (favoritePlaces.isEmpty) {
      return _buildEmpty();
    }

    final displayPlaces = favoritePlaces.take(maxItems).toList();
    final hasMore = favoritePlaces.length > maxItems;

    return Column(
      children: [
        SizedBox(
          height: AppDesignSystem.cardHeight,
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
              'Показано ${displayPlaces.length} из ${favoritePlaces.length}',
              style: AppTextStyles.error(
                color: AppDesignSystem.textColorSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmpty() {
    return SizedBox(
      height: AppDesignSystem.cardHeight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/bookmark_empty.svg',
              width: 50,
              height: 50,
              colorFilter: const ColorFilter.mode(
                Color(0xFF24A79C),
                BlendMode.srcIn,
              ),
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

  Widget _buildFavoriteCard(Place place, int displayIndex) {
    final realIndex = favoritePlaces.indexOf(place);

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
          onTap: () => onPlaceTap(place),
          child: Container(
            width: AppDesignSystem.cardWidth,
            height: AppDesignSystem.cardHeight,
            margin: const EdgeInsets.only(right: AppDesignSystem.spacingSmall + 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDesignSystem.borderRadiusMedium),
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
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDesignSystem.borderRadiusMedium),
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
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.all(AppDesignSystem.spacingSmall + 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDesignSystem.borderRadiusMedium),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                              place.type,
                              style: AppTextStyles.error(
                                color: AppDesignSystem.textColorWhite,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: isRemoving
                                ? null
                                : () => onRemove(realIndex),
                            child: isRemoving
                                ? SizedBox(
                              width: AppDesignSystem.spacingLarge,
                              height: AppDesignSystem.spacingLarge,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppDesignSystem.textColorWhite,
                                ),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          Text(
                            place.description.length > 100
                                ? '${place.description.substring(0, 100)}...'
                                : place.description,
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
}