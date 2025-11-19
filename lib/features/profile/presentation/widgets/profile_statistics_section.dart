import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../utils/smooth_border_radius.dart';

/// Виджет секции статистики
class ProfileStatisticsSection extends StatelessWidget {
  final int visitedPlaces;
  final int completedRoutes;
  final int totalPlaces;
  final int totalRoutes;
  final String? selectedRepublic;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  const ProfileStatisticsSection({
    super.key,
    required this.visitedPlaces,
    required this.completedRoutes,
    required this.totalPlaces,
    required this.totalRoutes,
    this.selectedRepublic,
    required this.isLoading,
    this.error,
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
                'Статистика',
                style: AppTextStyles.body(
                  fontWeight: AppDesignSystem.fontWeightSemiBold,
                ),
              ),
              if (selectedRepublic != null)
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/location.svg',
                      width: 15,
                      height: 15,
                      colorFilter: ColorFilter.mode(
                        AppDesignSystem.textColorTertiary,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: AppDesignSystem.spacingTiny),
                    Text(
                      selectedRepublic!,
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
        isLoading
            ? const StatisticsSkeletonWidget()
            : error != null
                ? Padding(
                    padding: const EdgeInsets.all(AppDesignSystem.spacingLarge),
                    child: ErrorStateWidget(
                      message: error!,
                      onRetry: onRetry,
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildStatisticsCard(
                          current: visitedPlaces,
                          total: totalPlaces,
                          label: 'Посещенные места',
                        ),
                      ),
                      SizedBox(width: AppDesignSystem.spacingSmall + 2),
                      Expanded(
                        child: _buildStatisticsCard(
                          current: completedRoutes,
                          total: totalRoutes,
                          label: 'Пройденные маршруты',
                        ),
                      ),
                    ],
                  ),
      ],
    );
  }

  Widget _buildStatisticsCard({
    required int current,
    required int total,
    required String label,
  }) {
    double progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
    double progressWidth = progress < AppDesignSystem.progressBarMinWidth && progress > 0
        ? AppDesignSystem.progressBarMinWidth
        : progress;

    return SmoothContainer(
      height: 72,
      borderRadius: AppDesignSystem.borderRadius,
      color: AppDesignSystem.primaryColorLight,
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: progressWidth,
            child: SmoothContainer(
              borderRadius: AppDesignSystem.borderRadius,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppDesignSystem.primaryColorLight,
                    AppDesignSystem.primaryColor,
                  ],
                ),
              ),
              child: const SizedBox.shrink(),
            ),
          ),
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
}

