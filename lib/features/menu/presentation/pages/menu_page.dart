import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tropanartov/features/profile/presentation/pages/profile_page.dart';
import '../../../../core/constants/menu_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/helpers/open_bottom_sheet.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../widgets/settings_widget.dart';
import '../widgets/about_project_widget.dart';
import 'widgets_showcase_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  Future<void> _openFeedbackUrl(BuildContext context) async {
    try {
      final uri = Uri.parse(MenuConstants.feedbackUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Не удалось открыть ссылку'),
            action: SnackBarAction(
              label: 'Повторить',
              onPressed: () => _openFeedbackUrl(context),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при открытии ссылки: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _openSponsorUrl(BuildContext context) async {
    try {
      final uri = Uri.parse(MenuConstants.sponsorUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Не удалось открыть ссылку'),
            action: SnackBarAction(
              label: 'Повторить',
              onPressed: () => _openSponsorUrl(context),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при открытии ссылки: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MenuConstants.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            // Шапка с кнопкой назад и заголовком
            Container(
                    padding: EdgeInsets.symmetric(
                horizontal: MenuConstants.paddingHorizontal,
                vertical: MenuConstants.paddingVertical,
              ),
              child: Row(
                children: [
                  // Кнопка назад
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: SmoothContainer(
                      width: MenuConstants.buttonIconSize,
                      height: MenuConstants.buttonIconSize,
                      borderRadius: MenuConstants.borderRadiusSmall,
                        color: MenuConstants.whiteColor,
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/back.svg',
                          width: MenuConstants.iconSizeSmall,
                          height: MenuConstants.iconSizeSmall,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Меню',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.title(
                          color: MenuConstants.textColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MenuConstants.buttonIconSize, height: MenuConstants.buttonIconSize),
                ],
              ),
            ),

            SizedBox(height: MenuConstants.spacingMedium),

            // Основной контейнер с кнопками меню
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MenuConstants.paddingHorizontal),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Кнопка "Личный кабинет"
                  _MenuButton(
                    iconPath: 'assets/user2.svg',
                    text: 'Личный кабинет',
                    onTap: () => openBottomSheet(context, (c) => const ProfilePage()),
                  ),
                  SizedBox(height: MenuConstants.spacingSmall),

                  // Кнопка "Обратная связь"
                  _MenuButton(
                    iconPath: 'assets/support2.svg',
                    text: 'Обратная связь',
                    onTap: () => _openFeedbackUrl(context),
                  ),
                  SizedBox(height: MenuConstants.spacingSmall),

                  // Кнопка "О проекте"
                  _MenuButton(
                    iconPath: 'assets/about_project.svg',
                    text: 'О проекте',
                    onTap: () => openBottomSheet(context, (c) => AboutProjectWidget()),
                  ),
                  SizedBox(height: MenuConstants.spacingSmall),

                  // Кнопка "Настройки"
                  _MenuButton(
                    iconPath: 'assets/config.svg',
                    text: 'Настройки',
                    onTap: () => openBottomSheet(context, (c) => SettingsWidget()),
                  ),
                  SizedBox(height: MenuConstants.spacingSmall),

                  // Кнопка "Виджеты"
                  _MenuButton(
                    iconPath: 'assets/elements.svg',
                    text: 'Виджеты',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WidgetsShowcasePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Добавляем отступ между настройками и блоком спонсорства
            SizedBox(height: MenuConstants.spacingMedium),

            // Блок спонсорства
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MenuConstants.paddingHorizontal),
              child: GestureDetector(
                onTap: () => _openSponsorUrl(context),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: MenuConstants.sponsorBlockMinHeight,
                  ),
                  child: ClipPath(
                    clipper: SmoothBorderClipper(radius: MenuConstants.borderRadiusLarge),
                    child: Container(
                  width: double.infinity,
                    color: MenuConstants.primaryColor,
                    child: Stack(
                      children: [
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                                // Используем MediaQuery для ширины, так как Positioned может давать бесконечную ширину
                                final screenWidth = MediaQuery.of(context).size.width;
                                final imageWidth = screenWidth * 0.4;
                                final imageHeight = constraints.maxHeight.isFinite 
                                    ? constraints.maxHeight 
                                    : 171.0; // Fallback высота
                                return ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: imageWidth,
                                    maxHeight: imageHeight,
                                ),
                                  child: SizedBox(
                                    width: imageWidth,
                                    height: imageHeight,
                                    child: ClipPath(
                                      clipper: SmoothBorderClipper(radius: MenuConstants.borderRadiusLarge),
                                  child: Image.asset(
                                    'assets/Cone.png',
                                    width: imageWidth,
                                    height: imageHeight,
                                    fit: BoxFit.cover,
                                      ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.all(MenuConstants.paddingHorizontal),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.65,
                                child: Text(
                                  'Станьте спонсором проекта "Тропа Нартов"',
                                  style: AppTextStyles.bodyLarge(
                                    color: MenuConstants.whiteColor,
                                    fontWeight: AppDesignSystem.fontWeightSemiBold,
                                  ),
                                ),
                              ),
                              SizedBox(height: MenuConstants.paddingSmall),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Text(
                                  'Ваше участие поможет сделать проект масштабнее, а ваш бренд — заметнее.',
                                  style: AppTextStyles.small(
                                    color: MenuConstants.whiteColor,
                                    letterSpacing: AppDesignSystem.letterSpacingTight,
                                  ),
                                ),
                              ),
                              SizedBox(height: MenuConstants.spacingMedium),
                                SmoothContainer(
                                padding: EdgeInsets.symmetric(
                                  horizontal: MenuConstants.paddingHorizontal,
                                  vertical: MenuConstants.paddingSmall,
                                ),
                                  borderRadius: MenuConstants.borderRadiusButton,
                                  color: MenuConstants.sponsorOverlayColor,
                                child: Text(
                                  'Подробнее',
                                  style: AppTextStyles.small(
                                    color: MenuConstants.whiteColor,
                                    fontWeight: AppDesignSystem.fontWeightMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      ),
                    ),
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

// Виджет кнопки меню
class _MenuButton extends StatelessWidget {
  final String iconPath;
  final String text;
  final VoidCallback onTap;

  const _MenuButton({
    required this.iconPath,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MenuConstants.borderRadius),
        child: SmoothContainer(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: MenuConstants.paddingHorizontal,
            horizontal: MenuConstants.paddingHorizontal,
          ),
          borderRadius: MenuConstants.borderRadius,
            color: MenuConstants.backgroundColor,
          child: Row(
            children: [
              SizedBox(
                width: MenuConstants.iconSizeSmall,
                height: MenuConstants.iconSizeSmall,
                child: SvgPicture.asset(
                  iconPath,
                  width: MenuConstants.iconSizeSmall,
                  height: MenuConstants.iconSizeSmall,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    MenuConstants.primaryColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text(
                text,
                style: AppTextStyles.bodyLarge(
                  color: MenuConstants.textColor,
                  fontWeight: AppDesignSystem.fontWeightMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}