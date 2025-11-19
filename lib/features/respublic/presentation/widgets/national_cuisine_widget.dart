import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/widgets/widgets.dart';

class NationalCuisineWidget extends StatefulWidget {
  final ScrollController scrollController;

  const NationalCuisineWidget({
    super.key,
    required this.scrollController,
  });

  @override
  State<NationalCuisineWidget> createState() => _NationalCuisineWidgetState();
}

class _NationalCuisineWidgetState extends State<NationalCuisineWidget> {
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
                text: 'Кабардинская кухня ',
              ),
              TextSpan(
                text: 'Кабардино-Балкарии',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              const TextSpan(
                text: ' богата разнообразными блюдами, отражающими традиции и образ жизни народа. Основу рациона составляют мясо (баранина, говядина, птица), овощи (картофель, фасоль, лук, чеснок) и разнообразные пряности, такие как сушёный молотый чабрец, красный и чёрный перец.\n\nОдним из самых известных блюд является ',
              ),
              TextSpan(
                text: 'хычин',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              const TextSpan(
                text: ' — тонкие лепёшки с начинкой из сыра, картофеля или мяса, обжаренные на сухой сковороде до золотистой корочки. Хычины подаются горячими и считаются одним из главных символов кабардинской кухни.',
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
                text: 'Другое популярное блюдо — ',
              ),
              TextSpan(
                text: 'гедлибже',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              TextSpan(
                text: ' — тушёная курица в сметанном соусе с добавлением чеснока и специй. Подаётся с густой пшённой кашей, которая впитывает ароматный соус. ',
              ),
              TextSpan(
                text: 'Лягур',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              TextSpan(
                text: ' — вяленое мясо, обжаренное с луком и специями, подаётся с тушёным картофелем. ',
              ),
              TextSpan(
                text: 'Шипс',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              TextSpan(
                text: ' — соус на основе индюшачьего бульона, пшеничной муки и красного перца, который подают к отварному мясу.\n\nТрадиционно во время застолья горцы не пользовались вилками: мясо резали кинжалом, а зелень и овощи брали руками. Эта традиция отражает уважение к еде и соблюдение древних обычаев.',
              ),
            ],
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
        const SizedBox(height: 12),

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
                text: 'Балкарская кухня ',
              ),
              TextSpan(
                text: 'Кабардино-Балкарии',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              const TextSpan(
                text: ' имеет свои уникальные особенности, сформированные под влиянием горных условий жизни. Балкарцы, проживающие в высокогорных районах, создали кухню, адаптированную к суровому климату и образу жизни в горах. Основу рациона составляют мясные блюда, молочные продукты и сытная выпечка.\n\nБалкарские ',
              ),
              TextSpan(
                text: 'хычины',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              const TextSpan(
                text: ' имеют свои особенности в приготовлении и начинках. Традиционно их готовят с картофелем, сыром или мясом, а процесс приготовления передаётся из поколения в поколение. Балкарские хычины отличаются особой тонкостью теста и насыщенностью начинки.',
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

        // Второй текст для балкарцев
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
                text: 'Особое место в балкарской кухне занимают мясные блюда, которые готовят на открытом огне или тушат с овощами и специями. Популярны также супы из баранины с фасолью, чесноком и зеленью. ',
              ),
              TextSpan(
                text: 'Лакумы',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              TextSpan(
                text: ' — пышки из дрожжевого теста, обжаренные в масле до золотистой корочки, подаются как в сладком варианте с мёдом, так и в нейтральном — с сыром и зеленью.\n\nМолочные продукты, такие как ',
              ),
              TextSpan(
                text: 'айран',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              TextSpan(
                text: ' — освежающий кисломолочный напиток, и традиционный сыр, также играют важную роль в балкарской кухне. Эти продукты помогают сохранять силы в условиях высокогорья и являются неотъемлемой частью повседневного рациона балкарцев.',
              ),
            ],
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
                'Национальная кухня',
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

