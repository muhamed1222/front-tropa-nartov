import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tropanartov/models/api_models.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../../domain/profile_state_manager.dart' show ActivityItem, PlaceActivityItem, RouteActivityItem;

/// Виджет секции истории активности
class ProfileHistorySection extends StatelessWidget {
  final List<ActivityItem>? activities;
  final bool isLoading;
  final String? error;
  final int maxItems;
  final Function(Place) onPlaceTap;
  final Function(AppRoute) onRouteTap;
  final VoidCallback? onRetry;

  const ProfileHistorySection({
    super.key,
    this.activities,
    required this.isLoading,
    this.error,
    required this.maxItems,
    required this.onPlaceTap,
    required this.onRouteTap,
    this.onRetry,
  });

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().substring(2);
    return '$day.$month.$year';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'История активности',
          style: AppTextStyles.body(
            fontWeight: AppDesignSystem.fontWeightSemiBold,
          ),
        ),
        SizedBox(height: AppDesignSystem.spacingSmall + 2),
        isLoading
            ? _buildLoading()
            : error != null
                ? _buildError()
                : _buildHistoryList(),
      ],
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDesignSystem.spacingXLarge),
        child: CircularProgressIndicator(
          valueColor: const AlwaysStoppedAnimation<Color>(AppDesignSystem.primaryColor),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(AppDesignSystem.spacingLarge),
      child: ErrorStateWidget(
        message: error ?? 'Ошибка загрузки',
        onRetry: onRetry,
      ),
    );
  }

  Widget _buildHistoryList() {
    final allActivities = activities ?? [];
    final limitedActivities = allActivities.take(maxItems).toList();
    final hasMore = allActivities.length > maxItems;

    if (limitedActivities.isEmpty) {
      return _buildEmpty();
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
                    if (activity is PlaceActivityItem) {
                      onPlaceTap(activity.placeActivity.place);
                    } else if (activity is RouteActivityItem) {
                      onRouteTap(activity.routeActivity.route);
                    }
                  },
                ),
                SizedBox(height: AppDesignSystem.spacingSmall + 2),
              ],
            ),
          );
        }),
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

  Widget _buildEmpty() {
    return SmoothContainer(
      padding: const EdgeInsets.all(AppDesignSystem.spacingXLarge),
      borderRadius: AppDesignSystem.borderRadius,
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
            child: ActivityHistoryButton(
              text: 'Перейти',
              onPressed: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

