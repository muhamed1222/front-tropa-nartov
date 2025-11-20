import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/menu_constants.dart';
import '../../../../utils/smooth_border_radius.dart';

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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Первый абзац
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.body(
                        color: const Color(0xFF000000), // #000
                        fontWeight: AppDesignSystem.fontWeightRegular, // normal (400)
                      ).copyWith(
                        height: 1.2, // 120% line-height
                      ),
                      children: [
                        TextSpan(
                          text: '«Тропа Нартов»',
                          style: AppTextStyles.body(
                            color: const Color(0xFF000000), // #000
                            fontWeight: AppDesignSystem.fontWeightRegular, // normal (400)
                          ).copyWith(
                            height: 1.2, // 120% line-height
                          ),
                        ),
                        TextSpan(
                          text: ' — это туристическое приложение, созданное для того, чтобы открыть богатство и красоту республик Северного Кавказа. Идея проекта появилась из желания собрать в одном месте все маршруты, достопримечательности и культурное наследие региона, сделать путешествия удобными и понятными для каждого.',
                          style: AppTextStyles.body(
                            color: const Color(0xFF000000), // #000
                            fontWeight: AppDesignSystem.fontWeightRegular, // normal (400)
                          ).copyWith(
                            height: 1.2, // 120% line-height
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Заголовок "Наше приложение помогает:"
                  Text(
                    'Наше приложение помогает:',
                    style: AppTextStyles.body(
                      color: const Color(0xFF000000), // #000
                      fontWeight: AppDesignSystem.fontWeightRegular, // normal (400)
                    ).copyWith(
                      height: 1.2, // 120% line-height
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
                    style: AppTextStyles.body(
                      color: const Color(0xFF000000), // #000
                      fontWeight: AppDesignSystem.fontWeightRegular, // normal (400)
                    ).copyWith(
                      height: 1.2, // 120% line-height
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Контакты
                  Text(
                    'Найти нас:',
                    style: AppTextStyles.body(
                      color: const Color(0xFF000000), // #000
                      fontWeight: AppDesignSystem.fontWeightRegular, // normal (400)
                    ).copyWith(
                      height: 1.2, // 120% line-height
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
                        child: SmoothContainer(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(5),
                          borderRadius: 8,
                          color: const Color(0xFFE4F4F3),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: SvgPicture.asset(
                                'assets/elements.svg',
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Кнопка Телеграм
                      GestureDetector(
                        onTap: () => _openUrl(context, MenuConstants.telegramUrl),
                        child: SmoothContainer(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(5),
                          borderRadius: 8,
                          color: const Color(0xFFE4F4F3),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: SvgPicture.asset(
                                'assets/elements_telegram.svg',
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ],
                    ),
                    
                    // Нижний padding
                    const SizedBox(height: 44),
                  ],
                ),
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
            style: AppTextStyles.body(
              color: const Color(0xFF000000), // #000
              fontWeight: AppDesignSystem.fontWeightRegular, // normal (400)
            ).copyWith(
              height: 1.2, // 120% line-height
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body(
                color: const Color(0xFF000000), // #000
                fontWeight: AppDesignSystem.fontWeightRegular, // normal (400)
              ).copyWith(
                height: 1.2, // 120% line-height
              ),
            ),
          ),
        ],
      ),
    );
  }
}