import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tropanartov/models/api_models.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/widgets/place_card.dart';
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
              final place = displayPlaces[index];
              final realIndex = favoritePlaces.indexOf(place);
              
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(
                  milliseconds: AppDesignSystem.animationDurationNormal.inMilliseconds + (index * 100),
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
                child: Padding(
                  padding: const EdgeInsets.only(right: AppDesignSystem.spacingSmall + 2),
                  child: SizedBox(
                    width: AppDesignSystem.cardWidth,
                    height: AppDesignSystem.cardHeight,
                    child: PlaceCard(
                      place: place,
                      isFavorite: true, // Всегда true в избранном
                      isVisited: false, // TODO: добавить проверку посещенных мест
                      onTap: () => onPlaceTap(place),
                      onFavoriteTap: isRemoving ? null : () => onRemove(realIndex),
                    ),
                  ),
                ),
              );
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
                Color(0xFFD3EDEB),
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

}