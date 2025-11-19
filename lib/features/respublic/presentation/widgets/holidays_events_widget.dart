import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/widgets/widgets.dart';

class HolidaysEventsWidget extends StatefulWidget {
  final ScrollController scrollController;

  const HolidaysEventsWidget({
    super.key,
    required this.scrollController,
  });

  @override
  State<HolidaysEventsWidget> createState() => _HolidaysEventsWidgetState();
}

class _HolidaysEventsWidgetState extends State<HolidaysEventsWidget> {
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
                text: 'Кабардинские праздники и события ',
              ),
              TextSpan(
                text: 'Кабардино-Балкарии',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              const TextSpan(
                text: ' отражают богатую культурную традицию адыгского народа. Одним из главных официальных праздников является ',
              ),
              TextSpan(
                text: 'День адыгов (черкесов)',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              const TextSpan(
                text: ', который отмечается 20 сентября. Этот праздник был учреждён в 2014 году для сохранения и популяризации культуры адыгского народа. В этот день проводятся официальные мероприятия, концерты и народные гуляния.\n\nТрадиционные кабардинские обряды включают ',
              ),
              TextSpan(
                text: 'гущэхэпхэ',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              const TextSpan(
                text: ' — обряд укладывания ребёнка в колыбель, сопровождающийся благословениями и пожеланиями. ',
              ),
              TextSpan(
                text: 'Праздник первого шага',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              const TextSpan(
                text: ' отмечается, когда ребёнок делает первые шаги, и сопровождается семейным торжеством.',
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
          'Свадебные обряды кабардинцев включают множество традиций, таких как выкуп невесты, благословение родителей и праздничное застолье с национальными блюдами. Эти обряды подчёркивают уважение к старшим, семейным ценностям и сохранению культурного наследия. В кабардинской культуре большое значение придаётся народным фестивалям и праздникам, которые проводятся в различных сёлах республики и собирают тысячи людей, являясь важным средством передачи традиций следующим поколениям.',
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
                text: 'Балкарские праздники и события ',
              ),
              TextSpan(
                text: 'Кабардино-Балкарии',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              const TextSpan(
                text: ' тесно связаны с горными традициями и историей народа. Одним из самых значимых праздников является ',
              ),
              TextSpan(
                text: 'День возрождения балкарского народа',
                style: TextStyle(
                  color: AppDesignSystem.primaryColor,
                ),
              ),
              const TextSpan(
                text: ', который отмечается 28 марта. Этот день символизирует возвращение балкарского народа на историческую родину после депортации 1944 года. Праздник сопровождается официальными мероприятиями, концертами и народными гуляниями, подчёркивающими единство и гордость балкарского народа.\n\nТрадиционные балкарские праздники включают обряды, связанные с поклонением горам, природе и предкам. Особое место занимают праздники, связанные с животноводством и земледелием, которые отражают тесную связь балкарцев с горной природой и традиционным укладом жизни.',
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
          'Балкарские фестивали и праздники проводятся в высокогорных сёлах и привлекают множество участников из разных регионов. Эти мероприятия являются важным средством сохранения культурного наследия и передачи традиций молодёжи. Особое внимание уделяется народным танцам, музыке и обрядам, которые демонстрируют богатство балкарской культуры. Свадебные обряды балкарцев также сохраняют древние традиции, включая ритуалы благословения, почитания старших и праздничного застолья с национальными блюдами.',
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
                'Праздники и события',
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.1),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        )),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    key: ValueKey<int>(_selectedButtonIndex),
                    child: _buildContent(),
                  ),
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

