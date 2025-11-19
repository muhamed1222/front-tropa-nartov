import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tropanartov/features/respublic/presentation/widgets/respublic_choose_widget.dart';
import '../../../../core/helpers/open_bottom_sheet.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../../../../services/republic_service.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import 'culture_detail_widget.dart';
import 'national_cuisine_widget.dart';
import 'holidays_events_widget.dart';
import 'peoples_languages_widget.dart';
import 'general_kbr_widget.dart';

class AboutRespublicWidget extends StatefulWidget {
  final ScrollController scrollController;

  const AboutRespublicWidget({
    super.key,
    required this.scrollController,
  });

  @override
  State<AboutRespublicWidget> createState() => _AboutRespublicWidgetState();
}

class _AboutRespublicWidgetState extends State<AboutRespublicWidget> {
  String _selectedRepublic = 'Кабардино-Балкария';
  bool _isLoading = true;

  final List<Map<String, String>> _cards = [
    {'title': 'Традиционная культура и искусство', 'image': 'assets/culture_art.png'},
    {'title': 'Национальная кухня', 'image': 'assets/national_cuisine.png'},
    {'title': 'Праздники и события', 'image': 'assets/holidays_events.png'},
    {'title': 'Народы и языки', 'image': 'assets/peoples_languages.png'},
    {'title': 'Общее о Кабардино-Балкарии', 'image': 'assets/general_info.png'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedRepublic();

    // Устанавливаем светлый status bar при открытии
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    // Восстанавливаем темный status bar при закрытии
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    super.dispose();
  }

  Future<void> _loadSelectedRepublic() async {
    final selected = await RepublicService.getSelectedRepublicOrDefault();
    if (mounted) {
      setState(() {
        _selectedRepublic = selected;
        _isLoading = false;
      });
    }
  }

  Future<void> _onRepublicSelected() async {
    final selected = await openBottomSheet<String>(
      context,
      (c) => ChooseRespublicWidget(scrollController: c),
    );
    if (selected != null && mounted) {
      setState(() {
        _selectedRepublic = selected;
      });
    }
  }

  void _onCardTap(String title) {
    if (title == 'Традиционная культура и искусство') {
      _openCultureDetail();
    } else if (title == 'Национальная кухня') {
      _openNationalCuisine();
    } else if (title == 'Праздники и события') {
      _openHolidaysEvents();
    } else if (title == 'Народы и языки') {
      _openPeoplesLanguages();
    } else if (title == 'Общее о Кабардино-Балкарии') {
      _openGeneralKbr();
    }
  }

  void _openCultureDetail() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.0,
            maxChildSize: 0.9,
            expand: false,
            snap: true,
            snapSizes: const [0.0, 0.9],
            builder: (context, scrollController) => CultureDetailWidget(scrollController: scrollController),
          ),
    );
  }

  void _openNationalCuisine() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.0,
            maxChildSize: 0.9,
            expand: false,
            snap: true,
            snapSizes: const [0.0, 0.9],
            builder: (context, scrollController) => NationalCuisineWidget(scrollController: scrollController),
          ),
    );
  }

  void _openHolidaysEvents() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.0,
            maxChildSize: 0.9,
            expand: false,
            snap: true,
            snapSizes: const [0.0, 0.9],
            builder: (context, scrollController) => HolidaysEventsWidget(scrollController: scrollController),
          ),
    );
  }

  void _openPeoplesLanguages() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.0,
            maxChildSize: 0.9,
            expand: false,
            snap: true,
            snapSizes: const [0.0, 0.9],
            builder: (context, scrollController) => PeoplesLanguagesWidget(scrollController: scrollController),
          ),
    );
  }

  void _openGeneralKbr() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.0,
            maxChildSize: 0.9,
            expand: false,
            snap: true,
            snapSizes: const [0.0, 0.9],
            builder: (context, scrollController) => GeneralKbrWidget(scrollController: scrollController),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Используем SingleChildScrollView с scrollController для DraggableScrollableSheet,
    // но отключаем физику скролла, чтобы контент не скроллился
    return Stack(
      children: [
        // Основной контент в SingleChildScrollView для работы DraggableScrollableSheet
        SingleChildScrollView(
          controller: widget.scrollController,
          physics: const NeverScrollableScrollPhysics(), // Отключаем скролл контента
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DragIndicator(
                color: AppDesignSystem.handleBarColor,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 26),

              Center(
                child: Text(
                  'О республике',
                  style: AppTextStyles.title(),
                ),
              ),
              const SizedBox(height: 28),

              // Контент без прокрутки
              Row(
                children: [
                  Expanded(
                    child: _buildCard(_cards[0]),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildCard(_cards[1]),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildCard(_cards[2]),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildCard(_cards[3]),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              _buildLargeCard(_cards[4]),
              // Отступ снизу для кнопки выбора республики (44px + высота кнопки ~28px)
              const SizedBox(height: 72),
            ],
          ),
        ),

        // Кнопка выбора республики зафиксирована внизу экрана
        Positioned(
          left: 0, // Впритык к левому краю (padding уже есть в контейнере openBottomSheet)
          bottom: 44, // 44px от низа экрана
          child: GestureDetector(
            onTap: _onRepublicSelected,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/location.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF24A79C),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isLoading ? 'Загрузка...' : _selectedRepublic,
                  style: AppTextStyles.body(
                    color: AppDesignSystem.primaryColor,
                    fontWeight: AppDesignSystem.fontWeightMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, String> cardData) {
    return GestureDetector(
      onTap: () => _onCardTap(cardData['title']!),
      child: SmoothContainer(
        height: 180,
        borderRadius: 16,
        color: const Color(0xFFF6F6F6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: Text(
                cardData['title']!,
                style: AppTextStyles.body(
                  fontWeight: AppDesignSystem.fontWeightSemiBold,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: ClipPath(
                clipper: SmoothBorderClipper(radius: 16),
                child: _buildCardImage(cardData['image']!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeCard(Map<String, String> cardData) {
    return GestureDetector(
      onTap: () => _onCardTap(cardData['title']!),
      child: SmoothContainer(
        width: double.infinity,
        height: 180,
        borderRadius: 16,
        color: const Color(0xFFF6F6F6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: Text(
                cardData['title']!,
                style: AppTextStyles.body(
                  fontWeight: AppDesignSystem.fontWeightSemiBold,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: ClipPath(
                clipper: SmoothBorderClipper(radius: 16),
                child: _buildCardImage(cardData['image']!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardImage(String assetPath) {
    return Image.asset(
      assetPath,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(
              Icons.photo_camera,
              size: 32,
              color: Color(0xFF24A79C),
            ),
          ),
        );
      },
    );
  }
}
