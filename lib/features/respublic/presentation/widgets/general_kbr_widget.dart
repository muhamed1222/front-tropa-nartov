import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/widgets/widgets.dart';

class GeneralKbrWidget extends StatefulWidget {
  final ScrollController scrollController;

  const GeneralKbrWidget({
    super.key,
    required this.scrollController,
  });

  @override
  State<GeneralKbrWidget> createState() => _GeneralKbrWidgetState();
}

class _GeneralKbrWidgetState extends State<GeneralKbrWidget> {
  double _calculateFixedHeaderHeight() {
    // Без кнопок переключения: 8px (padding top) + 4px (padding bottom) + 4px (индикатор) + 10px (gap) + заголовок
    // Заголовок "Общее о Кабардино-Балкарии" может переноситься на 2 строки
    // padding vertical 16px (32px total) + высота текста 2 строки (20px * 1.2 * 2 = 48px) = 80px
    // Итого: 8 + 4 + 4 + 10 + 80 = 106px, используем 100px для безопасности
    return 82.0;
  }

  Widget _buildFixedHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 8, bottom: 4),
      color: AppDesignSystem.whiteColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Индикатор перетаскивания
          Center(
            child: DragIndicator(
              color: AppDesignSystem.handleBarColor,
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 10),

          // Заголовок с padding vertical 16px
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Center(
              child: Text(
                'Общее о Кабардино-Балкарии',
                style: TextStyle(
                  color: AppDesignSystem.textColorPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.20,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Отступ после заголовка (gap 12px, как между кнопками и контентом в других экранах)
        const SizedBox(height: 12),

        // Первый текст с выделением
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              color: AppDesignSystem.textColorPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.20,
            ),
            children: [
              const TextSpan(
                text: 'Кабардино-Балкарская Республика ',
              ),
              TextSpan(
                text: 'Кабардино-Балкария',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              const TextSpan(
                text: ' — субъект Российской Федерации, расположенный на Северном Кавказе. Столица республики — город ',
              ),
              TextSpan(
                text: 'Нальчик',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              const TextSpan(
                text: ', основанный в 1818 году. Республика граничит с Карачаево-Черкесией, Ставропольским краем, Северной Осетией и Грузией.\n\nКабардино-Балкария занимает площадь около 12,5 тысяч квадратных километров и является одной из самых маленьких республик России. Однако, несмотря на небольшую территорию, республика имеет богатое культурное и историческое наследие, уходящее корнями в древние времена.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Изображение
        SmoothContainer(
          width: double.infinity,
          height: 250,
          borderRadius: 16,
          color: AppDesignSystem.greyLight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/people.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppDesignSystem.greyPlaceholder,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: AppDesignSystem.primaryColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Второй текст
        RichText(
          text: const TextSpan(
            style: TextStyle(
              color: AppDesignSystem.textColorPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.20,
            ),
            children: [
              TextSpan(
                text: 'Республика расположена в предгорьях и горах Большого Кавказа. Высшая точка — гора ',
              ),
              TextSpan(
                text: 'Эльбрус',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              TextSpan(
                text: ' (5642 метра), которая является самой высокой горой России и Европы. Природа Кабардино-Балкарии отличается разнообразием: от степных равнин на севере до высокогорных ледников на юге. На территории республики находятся живописные ущелья, водопады, минеральные источники и уникальные карстовые озёра.\n\nНаселение республики составляет около 870 тысяч человек. Основные народы — ',
              ),
              TextSpan(
                text: 'кабардинцы',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              TextSpan(
                text: ' (около 57%) и ',
              ),
              TextSpan(
                text: 'балкарцы',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              TextSpan(
                text: ' (около 13%), которые имеют свои языки, культуру и традиции. В республике также проживают русские, осетины, турки и представители других народов.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Третий текст
        const Text(
          'Экономика Кабардино-Балкарии основана на сельском хозяйстве, туризме и горнодобывающей промышленности. Республика известна своими курортами в Приэльбрусье, которые привлекают туристов со всей России и мира. Развивается также производство минеральной воды, которая добывается из источников в горах. Кабардино-Балкария богата природными ресурсами, включая полезные ископаемые, леса и водные ресурсы, что создаёт основу для развития различных отраслей экономики.',
          style: TextStyle(
            color: AppDesignSystem.textColorPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.20,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SmoothBorderClipper(radius: 20),
      child: Container(
        color: AppDesignSystem.whiteColor,
        child: CustomScrollView(
          controller: widget.scrollController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            // Зафиксированный блок: индикатор и заголовок
            SliverAppBar(
              pinned: true,
              floating: false,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              backgroundColor: AppDesignSystem.whiteColor,
              automaticallyImplyLeading: false,
              expandedHeight: 0,
              toolbarHeight: _calculateFixedHeaderHeight(),
              flexibleSpace: _buildFixedHeader(),
            ),

            // Контент (скроллируется)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              sliver: SliverToBoxAdapter(
                child: _buildContent(),
              ),
            ),

            // Отступ снизу после контента
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 44),
            ),
          ],
        ),
      ),
    );
  }
}

