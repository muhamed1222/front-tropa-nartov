import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/menu_constants.dart';

class AboutProjectWidget extends StatelessWidget {
  const AboutProjectWidget({super.key});

  Future<void> _openUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Не удалось открыть ссылку'),
              action: SnackBarAction(
                label: 'Повторить',
                onPressed: () => _openUrl(context, url),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
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

          // Заголовок
          const SizedBox(height: 26),
          Center(
            child: Text(
              'О проекте',
              style: AppTextStyles.title(),
            ),
          ),
          const SizedBox(height: 20),

          // Основной контент
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Первый абзац
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.small(),
                      children: [
                        TextSpan(
                          text: '«Тропа Нартов»',
                          style: AppTextStyles.small(
                            fontWeight: AppDesignSystem.fontWeightSemiBold,
                          ),
                        ),
                        TextSpan(
                          text: ' — это туристическое приложение, созданное для того, чтобы открыть богатство и красоту республик Северного Кавказа. Идея проекта появилась из желания собрать в одном месте все маршруты, достопримечательности и культурное наследие региона, сделать путешествия удобными и понятными для каждого.',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Заголовок "Наше приложение помогает:"
                  Text(
                    'Наше приложение помогает:',
                    style: AppTextStyles.small(
                      fontWeight: AppDesignSystem.fontWeightSemiBold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Список преимуществ
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BulletPoint(text: 'Легко находить интересные места и маршруты;'),
                        _BulletPoint(text: 'Узнавать об истории, традициях и кухне народов;'),
                        _BulletPoint(text: 'Планировать поездки и сохранять понравившиеся места;'),
                        _BulletPoint(text: 'Открывать новые стороны Северного Кавказа даже тем, кто живёт здесь давно.'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Второй абзац
                  Text(
                    '«Тропа Нартов» объединяет туризм и культуру. Это не просто навигатор по достопримечательностям, а проводник в атмосферу Кавказа — с его народами, праздниками, легендами и уникальной природой. Проект вдохновлён любовью к родному краю и стремлением показать его гостям и жителям с новой стороны. Мы верим, что путешествия делают людей ближе друг к другу, а знание своей культуры — сильнее.',
                    style: AppTextStyles.small(),
                  ),

                  const SizedBox(height: 30),

                  // Контакты
                  Text(
                    'Найти нас:',
                    style: AppTextStyles.small(
                      fontWeight: AppDesignSystem.fontWeightSemiBold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Ссылка на сайт
                  GestureDetector(
                    onTap: () => _openUrl(context, MenuConstants.websiteUrl),
                    child: Text(
                      'tropanartov.ru',
                      style: AppTextStyles.link(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Кнопки соцсетей
                  Row(
                    children: [
                      // Кнопка ВКонтакте
                      GestureDetector(
                        onTap: () => _openUrl(context, MenuConstants.vkUrl),
                        child: Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppDesignSystem.backgroundColorSecondary,
                          ),
                          child: SvgPicture.asset(
                            'assets/elements.svg',
                            width: 21.5,
                            height: 13.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Кнопка Телеграм
                      GestureDetector(
                        onTap: () => _openUrl(context, MenuConstants.telegramUrl),
                        child: Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppDesignSystem.backgroundColorSecondary,
                          ),
                          child: SvgPicture.asset(
                            'assets/elements_telegram.svg',
                            width: 21,
                            height: 19.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
            ),
          ),
        ],
      ),
    );
  }
}

// Виджет для пунктов списка с буллетами
class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: AppTextStyles.small(),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.small(),
            ),
          ),
        ],
      ),
    );
  }
}