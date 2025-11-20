import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/menu_constants.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../services/preferences_service.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  bool _pushNotifications = true;
  bool _isLoadingSettings = true;
  String? _appVersion;
  bool _isLoadingVersion = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _isLoadingVersion = false;
      });
    } catch (e) {
      // В случае ошибки показываем значение по умолчанию
      setState(() {
        _appVersion = '1.0';
        _isLoadingVersion = false;
      });
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = PreferencesService.instance;
      setState(() {
        _pushNotifications = prefs.getBool(MenuConstants.pushNotificationsKey) ?? true;
        _isLoadingSettings = false;
      });
    } catch (e) {
      // В случае ошибки используем значение по умолчанию
      setState(() {
        _pushNotifications = true;
        _isLoadingSettings = false;
      });
    }
  }

  Future<void> _togglePushNotifications(bool value) async {
    setState(() {
      _pushNotifications = value;
    });

    try {
      final prefs = PreferencesService.instance;
      await prefs.setBool(MenuConstants.pushNotificationsKey, value);
    } catch (e) {
      // В случае ошибки возвращаем предыдущее значение
      if (mounted) {
        setState(() {
          _pushNotifications = !value;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось сохранить настройку'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _openUrl(Uri url) async {
    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Не удалось открыть ссылку'),
            action: SnackBarAction(
              label: 'Повторить',
              onPressed: () => _openUrl(url),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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
    return SizedBox(
      width: 412,
      height: 1010,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Строка для закрытия bottom sheet
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: ShapeDecoration(
                  color: AppDesignSystem.handleBarColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Заголовок
          Text(
            'Настройки',
            style: AppTextStyles.title(),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                // Блок "Версия приложения"
                SmoothContainer(
                  height: 56,
                  padding: const EdgeInsets.all(16),
                  borderRadius: AppDesignSystem.borderRadius,
                  color: AppDesignSystem.backgroundColorSecondary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Версия приложения',
                        style: AppTextStyles.small(
                          fontWeight: AppDesignSystem.fontWeightMedium,
                        ),
                      ),
                      _isLoadingVersion
                          ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppDesignSystem.primaryColor),
                        ),
                      )
                          : Text(
                        _appVersion ?? '1.0',
                        style: AppTextStyles.small(
                          color: AppDesignSystem.textColorSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Блок "PUSH-уведомления"
                SmoothContainer(
                  height: 56,
                  padding: const EdgeInsets.all(16),
                  borderRadius: AppDesignSystem.borderRadius,
                  color: AppDesignSystem.backgroundColorSecondary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PUSH-уведомления',
                        style: AppTextStyles.small(
                          fontWeight: AppDesignSystem.fontWeightMedium,
                        ),
                      ),
                      AppToggleSwitch(
                        value: _pushNotifications,
                        onChanged: _isLoadingSettings
                            ? null
                            : (value) => _togglePushNotifications(value),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 540),

                // Ссылки внизу
                Column(
                  children: [
                    GestureDetector(
                      onTap: () => _openUrl(Uri.parse(MenuConstants.privacyUrl)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Политика конфиденциальности',
                          style: AppTextStyles.link(
                            color: AppDesignSystem.textColorSecondary,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openUrl(Uri.parse(MenuConstants.termsUrl)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Условия использования',
                          style: AppTextStyles.link(
                            color: AppDesignSystem.textColorSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }
}