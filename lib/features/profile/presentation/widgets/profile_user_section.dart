import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tropanartov/models/api_models.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../../../../services/api_service_static.dart';
import '../../../../config/app_config.dart';

/// Виджет секции профиля пользователя
class ProfileUserSection extends StatelessWidget {
  final User? user;
  final bool isLoading;
  final String? error;
  final VoidCallback onEdit;
  final VoidCallback? onRetry;

  const ProfileUserSection({
    super.key,
    required this.user,
    required this.isLoading,
    this.error,
    required this.onEdit,
    this.onRetry,
  });

  String _getFullName() {
    if (user == null) return 'Загрузка...';
    return user!.fullName;
  }

  String _getUserId() {
    if (user == null) return 'ID: ...';
    final idStr = user!.id.toString();
    if (idStr.length <= 4) {
      return 'ID: $idStr';
    }
    return 'ID: ****${idStr.substring(idStr.length - 4)}';
  }

  String? _getAvatarUrl() {
    if (user == null || user!.avatarUrl == null || user!.avatarUrl!.isEmpty) {
      return null;
    }

    final avatarUrl = user!.avatarUrl!;
    if (avatarUrl.startsWith('http')) {
      return avatarUrl;
    } else {
      return '${AppConfig.baseUrl}$avatarUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SmoothContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDesignSystem.spacingSmall + 2),
      borderRadius: AppDesignSystem.borderRadiusMedium,
      color: AppDesignSystem.backgroundColorSecondary,
      child: isLoading
          ? const ProfileSkeletonWidget()
          : error != null && error!.isNotEmpty
              ? _buildError()
              : _buildUserProfile(),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(AppDesignSystem.spacingMedium),
      child: ErrorStateWidget(
        message: error ?? 'Ошибка загрузки профиля',
        onRetry: onRetry,
      ),
    );
  }

  Widget _buildUserProfile() {
    final avatarUrl = _getAvatarUrl();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Аватар
        SmoothContainer(
          width: 90,
          height: 90,
          borderRadius: AppDesignSystem.borderRadius,
          color: avatarUrl != null ? Colors.transparent : AppDesignSystem.greyPlaceholder,
          child: avatarUrl != null
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
            onTap: onEdit,
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
}

