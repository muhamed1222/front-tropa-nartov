import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../constants/app_design_system.dart';
import '../constants/app_text_styles.dart';
import '../../utils/smooth_border_radius.dart';

/// Переиспользуемый виджет для состояния загрузки
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? AppDesignSystem.loadingIndicatorSize * 2,
            height: size ?? AppDesignSystem.loadingIndicatorSize * 2,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppDesignSystem.primaryColor,
              ),
              strokeWidth: 2,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: AppDesignSystem.spacingLarge),
            Text(
              message!,
              style: AppTextStyles.small(
                color: AppDesignSystem.textColorSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Переиспользуемый виджет для состояния ошибки с возможностью повтора
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final Color? iconColor;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
          Icon(
              icon,
              size: 30,
            color: iconColor ?? AppDesignSystem.errorColor,
            )
          else
            SvgPicture.asset(
              'assets/error_icon.svg',
              width: 30,
              height: 30,
              colorFilter: ColorFilter.mode(
                iconColor ?? AppDesignSystem.errorColor,
                BlendMode.srcIn,
              ),
          ),
          SizedBox(height: AppDesignSystem.spacingLarge),
          Text(
            message,
            style: AppTextStyles.small(
              color: AppDesignSystem.errorColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: AppDesignSystem.spacingSmall),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'Повторить',
                style: AppTextStyles.small(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


/// Skeleton loader для карточки профиля
class ProfileSkeletonWidget extends StatelessWidget {
  const ProfileSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Аватар с индикатором загрузки
        SmoothContainer(
          width: 90,
          height: 90,
          borderRadius: AppDesignSystem.borderRadius,
          color: AppDesignSystem.greyPlaceholder,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppDesignSystem.primaryColor,
              ),
            ),
          ),
        ),
        SizedBox(width: AppDesignSystem.spacingMedium),
        // Заглушка для текста
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmoothContainer(
                width: 150,
                height: 20,
                borderRadius: AppDesignSystem.spacingTiny,
                color: AppDesignSystem.greyLight,
                child: const SizedBox.shrink(),
              ),
              SizedBox(height: AppDesignSystem.spacingSmall),
              SmoothContainer(
                width: 100,
                height: 16,
                borderRadius: AppDesignSystem.spacingTiny,
                color: AppDesignSystem.greyLight,
                child: const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        // Кнопка редактирования скрыта при загрузке
        SizedBox(width: 30, height: 30),
      ],
    );
  }
}

/// Skeleton loader для статистики
class StatisticsSkeletonWidget extends StatelessWidget {
  const StatisticsSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SmoothContainer(
            height: 72,
            borderRadius: AppDesignSystem.borderRadius,
            color: AppDesignSystem.greyLight,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppDesignSystem.primaryColor,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: AppDesignSystem.spacingSmall + 2),
        Expanded(
          child: SmoothContainer(
            height: 72,
            borderRadius: AppDesignSystem.borderRadius,
            color: AppDesignSystem.greyLight,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppDesignSystem.primaryColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

