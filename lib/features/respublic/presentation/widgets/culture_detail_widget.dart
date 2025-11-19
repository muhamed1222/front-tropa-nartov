import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/widgets/widgets.dart';


class CultureDetailWidget extends StatefulWidget {
  final ScrollController scrollController;

  const CultureDetailWidget({
    super.key,
    required this.scrollController,
  });

  @override
  State<CultureDetailWidget> createState() => _CultureDetailWidgetState();
}

class _CultureDetailWidgetState extends State<CultureDetailWidget> {
  int _selectedButtonIndex = 0; // 0 - Кабардинцы, 1 - Балкарцы

  double _calculateFixedHeaderHeight() {
    // По дизайну Figma (точный расчет):
    // Padding сверху контейнера: 8px
    // Padding снизу контейнера: 4px
    // Индикатор: 4px (без дополнительного padding)
    // Gap после индикатора: 10px
    // Заголовок: padding vertical 16px (32px) + высота текста (20px * 1.2 = 24px) = 56px
    // Gap после заголовка: 10px
    // Кнопки: padding 4px (8px) + высота кнопки (текст 14px * 1.2 = ~17px + padding 10px * 2 = 20px) = 37px + 8px = 45px
    // Итого: 8 + 4 + 4 + 10 + 56 + 10 + 45 = 137px
    // Добавляем небольшой запас для безопасности: 145px
    return 145.0;
  }

  // Контент для кабардинцев
  Widget _buildKabardiansContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12), // Gap 12px между элементами контента

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
                text: 'Кабардино-Балкария — это не только живописные горные пейзажи, бурные реки и древние аулы, но и богатая кулинарная культура, которая формировалась веками. Национальная еда ',
              ),
              TextSpan(
                text: 'Кабардино-Балкарии',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              const TextSpan(
                text: ' — это отражение истории, климата и образа жизни местных народов. Она проста, сытна и наполнена ароматами горных трав, свежего мяса и домашнего хлеба.\n\nОдним из символов местной кухни является хычин — тонкая лепешка с начинкой, которая может быть как сытной, так и легкой. В Нальчике, столице республики, хычины готовят практически в каждом кафе, но чтобы почувствовать настоящий вкус, стоит отправиться в небольшие семейные заведения вроде кафе «Эльбрус» на проспекте Ленина. Здесь хычины подают горячими, с хрустящей корочкой, а начинка — картофель, сыр или мясо — тает во рту.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12), // Gap 12px между текстом и изображением

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
        const SizedBox(height: 12), // Gap 12px между изображением и текстом

        // Второй текст
        const Text(
          'Еще одно блюдо, которое нельзя пропустить — густой суп из баранины с добавлением фасоли, чеснока и зелени. Его готовят в каждом доме в селе Верхняя Балкария. Здесь, в тени гор, местные хозяйки варят суп на открытом огне, что придает ему особый аромат дыма и трав.\n\nЕсли вы окажетесь в Приэльбрусье, обязательно попробуйте жаркое из ягненка. В ресторане «Сосруко» в Терсколе это блюдо готовят по старинному рецепту: мясо тушат с луком, чесноком и специями до тех пор, пока оно не станет нежным и сочным. Подают его с гарниром из свежих овощей и домашнего хлеба.',
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

  // Контент для балкарцев
  Widget _buildBalkarsContent() {
    return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        const SizedBox(height: 12), // Gap 12px между элементами контента

        // Первый текст с выделением для балкарцев
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
                text: 'Балкарская культура ',
              ),
              TextSpan(
                text: 'Кабардино-Балкарии',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              const TextSpan(
                text: ' — это уникальное сочетание горных традиций, древних обычаев и современного искусства. Балкарский народ, проживающий в высокогорных селах, сохранил множество уникальных традиций и ремесел, которые передаются из поколения в поколение.\n\nОдним из важнейших элементов балкарской культуры является традиционная музыка и танцы. Балкарские песни, исполняемые под аккомпанемент национальных инструментов, рассказывают о жизни в горах, о любви к родной земле и о героях прошлого. Танцы балкарцев отличаются плавностью движений и выразительностью, каждый жест имеет свое значение.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12), // Gap 12px между текстом и изображением

        // Изображение (можно использовать другое изображение для балкарцев)
        SmoothContainer(
          width: double.infinity,
          height: 250,
          borderRadius: 16,
          color: AppDesignSystem.greyLight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/people.png', // Можно заменить на другое изображение
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
        const SizedBox(height: 12), // Gap 12px между изображением и текстом

        // Второй текст для балкарцев
        const Text(
          'Балкарские мастера славятся своим умением создавать изделия из шерсти, кожи и дерева. Традиционные балкарские ковры и паласы, сотканные вручную, отличаются сложными геометрическими узорами и яркими цветами. Эти изделия не только украшают дома, но и рассказывают историю народа.\n\nЕсли вы хотите познакомиться с балкарской культурой поближе, обязательно посетите музей в селе Верхний Баксан или примите участие в одном из традиционных праздников, которые регулярно проводятся в горных селах. Здесь вы сможете увидеть традиционные костюмы, услышать народную музыку и попробовать блюда балкарской кухни.',
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

  // Метод для построения контента в зависимости от выбранной кнопки
  Widget _buildContent() {
    if (_selectedButtonIndex == 0) {
      return _buildKabardiansContent();
    } else {
      return _buildBalkarsContent();
    }
  }

  // Метод для прокрутки наверх при переключении кнопок
  void _scrollToTop() {
    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
                'Традиционная культура и искусство',
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
          const SizedBox(height: 10),

          // Кнопки переключения
          ToggleButtonGroup(
            options: const ['Кабардинцы', 'Балкарцы'],
            selectedIndex: _selectedButtonIndex,
            onSelected: (index) {
              if (_selectedButtonIndex != index) {
                setState(() {
                  _selectedButtonIndex = index;
                });
                _scrollToTop();
              }
            },
          ),
        ],
      ),
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
            // Зафиксированный блок: индикатор, заголовок и кнопки
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

            // Контент (скроллируется) без анимации
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              sliver: SliverToBoxAdapter(
                  child: Container(
                    key: ValueKey<int>(_selectedButtonIndex),
                    child: _buildContent(),
                ),
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