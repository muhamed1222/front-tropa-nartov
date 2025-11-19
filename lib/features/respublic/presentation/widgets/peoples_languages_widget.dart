import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/widgets/widgets.dart';

class PeoplesLanguagesWidget extends StatefulWidget {
  final ScrollController scrollController;

  const PeoplesLanguagesWidget({
    super.key,
    required this.scrollController,
  });

  @override
  State<PeoplesLanguagesWidget> createState() => _PeoplesLanguagesWidgetState();
}

class _PeoplesLanguagesWidgetState extends State<PeoplesLanguagesWidget> {
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
                text: 'Кабардинский народ ',
              ),
              TextSpan(
                text: 'Кабардино-Балкарии',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              const TextSpan(
                text: ' является одним из крупнейших адыгских народов Северного Кавказа. Кабардинцы составляют около 57% населения республики и имеют богатую историю, уходящую корнями в древние времена. В XVI веке кабардинцы приняли российское подданство, что стало важным этапом в истории региона.\n\nКабардинцы говорят на ',
              ),
              TextSpan(
                text: 'кабардинском языке',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              const TextSpan(
                text: ', который относится к абхазо-адыгской языковой семье. Язык имеет богатую литературную традицию и является одним из государственных языков республики наряду с балкарским и русским. Кабардинский язык имеет несколько диалектов, которые различаются в зависимости от региона, но кабардинцы из разных районов республики легко понимают друг друга.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

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

        const Text(
          'Язык передаётся из поколения в поколение и активно используется в повседневной жизни, в школах, на телевидении и в печатных изданиях. Кабардинская культура тесно связана с языком, который является носителем традиций, обычаев и фольклора народа. В республике активно развивается изучение кабардинского языка в школах и вузах, что способствует сохранению культурного наследия. Кабардинский язык играет важную роль в сохранении идентичности народа и передаче культурных ценностей следующим поколениям.',
          style: TextStyle(
            color: AppDesignSystem.textColorPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.20,
          ),
        ),
        const SizedBox(height: 24),
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
                text: 'Балкарский народ ',
              ),
              TextSpan(
                text: 'Кабардино-Балкарии',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              const TextSpan(
                text: ' является тюркским народом, проживающим в высокогорных районах республики. Балкарцы составляют около 13% населения и имеют уникальную историю, связанную с жизнью в горах. В 1944 году балкарский народ был депортирован в Среднюю Азию и Казахстан, а в 1957 году вернулся на историческую родину.\n\nБалкарцы говорят на ',
              ),
              TextSpan(
                text: 'балкарском языке',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              const TextSpan(
                text: ', который относится к тюркской языковой семье (кипчакская группа). Язык имеет долгую историю и является одним из государственных языков республики наряду с кабардинским и русским. Балкарский язык тесно связан с карачаевским языком и вместе они образуют карачаево-балкарский язык.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

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

        const Text(
          'Балкарский язык имеет свои особенности, связанные с горными условиями жизни народа. Язык богат терминологией, связанной с животноводством, горным рельефом и природными явлениями, что отражает традиционный уклад жизни балкарцев в высокогорье. Несмотря на относительно небольшое число носителей, язык активно используется в повседневной жизни, в образовании и средствах массовой информации. Балкарская культура и язык тесно связаны с горными традициями народа, и в республике уделяется большое внимание изучению и сохранению балкарского языка, что способствует поддержанию культурной идентичности балкарского народа.',
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

  Widget _buildContent() {
    if (_selectedButtonIndex == 0) {
      return _buildKabardiansContent();
    } else {
      return _buildBalkarsContent();
    }
  }

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
                'Народы и языки',
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

