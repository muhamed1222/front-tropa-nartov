import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../utils/smooth_border_radius.dart';
import 'package:tropanartov/models/api_models.dart' as api_models;

/// Экран со всеми виджетами дизайн-системы
class WidgetsShowcasePage extends StatefulWidget {
  const WidgetsShowcasePage({super.key});

  @override
  State<WidgetsShowcasePage> createState() => _WidgetsShowcasePageState();
}

class _WidgetsShowcasePageState extends State<WidgetsShowcasePage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _checkboxValue = false;
  bool _appSwitchValue = false;
  bool _toggleSwitchValue = false;
  int _selectedToggleGroupIndex = 0;
  int _selectedToggleGroup2Index = 0;
  bool _isFavorite = false;

  @override
  void dispose() {
    _textController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDDDDD),
      appBar: AppBar(
        title: Text(
          'Виджеты',
          style: AppTextStyles.title(),
        ),
        backgroundColor: const Color(0xFFDDDDDD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Text(
              'Дизайн-система',
              style: AppTextStyles.hero(),
            ),
            SizedBox(height: AppDesignSystem.spacingXXLarge),

            // Кнопки
            _buildSection(
              title: 'Кнопки',
              children: [
                PrimaryButton(
                  text: 'Primary Button',
                  onPressed: () {
                    AppSnackBar.showSuccess(context, 'Primary button pressed');
                  },
                ),
                SizedBox(height: AppDesignSystem.spacingMedium),
                SecondaryButton(
                  text: 'Secondary Button',
                  onPressed: () {
                    AppSnackBar.showInfo(context, 'Secondary button pressed');
                  },
                ),
                SizedBox(height: AppDesignSystem.spacingMedium),
                ActivityHistoryButton(
                  text: 'Перейти',
                  onPressed: () {
                    AppSnackBar.showInfo(context, 'Activity history button pressed');
                  },
                ),
              ],
            ),

            // Поля ввода
            _buildSection(
              title: 'Поля ввода',
              children: [
                AppInputField(
                  controller: _textController,
                  hint: 'Имя',
                ),
                SizedBox(height: AppDesignSystem.spacingMedium),
                AppInputField(
                  controller: _emailController,
                  hint: 'Email',
                  label: 'Email',
                ),
                SizedBox(height: AppDesignSystem.spacingMedium),
                AppInputField(
                  controller: _passwordController,
                  hint: 'Пароль',
                  label: 'Пароль',
                  obscureText: true,
                ),
                SizedBox(height: AppDesignSystem.spacingMedium),
                AppInputField(
                  controller: TextEditingController(),
                  hint: 'Поле с ошибкой',
                  errorText: 'Ошибка: неверный формат имени',
                ),
              ],
            ),

            // Поле поиска
            _buildSection(
              title: 'Поле поиска',
              children: [
                AppSearchField(
                  controller: _searchController,
                  hint: 'Поиск мест',
                  onFilterTap: () {
                    AppSnackBar.showInfo(context, 'Фильтр нажат');
                  },
                ),
              ],
            ),

            // Карточки отзывов
            _buildSection(
              title: 'Карточки отзывов',
              children: [
                ReviewCard(
                  review: api_models.Review(
                    id: 1,
                    text: 'В восторге от этого места. Невероятный колорит и атмосфера старого города. Советую идти ближе к вечеру, многие продукты и товары распродаются с большой скидкой',
                    rating: 5,
                    createdAt: '2025-03-12T00:00:00.000Z',
                    updatedAt: '2025-03-12T00:00:00.000Z',
                    isActive: true,
                    placeId: 1,
                    authorName: 'Магомед',
                  ),
                ),
              ],
            ),

            // Карточки
            _buildSection(
              title: 'Карточки',
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Card',
                        style: AppTextStyles.body(
                          fontWeight: AppDesignSystem.fontWeightSemiBold,
                        ),
                      ),
                      SizedBox(height: AppDesignSystem.spacingSmall),
                      Text(
                        'Это пример карточки из дизайн-системы',
                        style: AppTextStyles.small(
                          color: AppDesignSystem.textColorSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacingMedium),
                // Карточка места
                PlaceCard(
                  place: api_models.Place(
                    id: 1,
                    name: 'Уллу Гижгит',
                    type: 'Озеро',
                    rating: 4.5,
                    images: [
                      api_models.Image(
                        id: '1',
                        url: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=600&fit=crop',
                        createdAt: DateTime.now().toIso8601String(),
                        updatedAt: DateTime.now().toIso8601String(),
                      ),
                      api_models.Image(
                        id: '2',
                        url: 'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=400&h=600&fit=crop',
                        createdAt: DateTime.now().toIso8601String(),
                        updatedAt: DateTime.now().toIso8601String(),
                      ),
                      api_models.Image(
                        id: '3',
                        url: 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=400&h=600&fit=crop',
                        createdAt: DateTime.now().toIso8601String(),
                        updatedAt: DateTime.now().toIso8601String(),
                      ),
                      api_models.Image(
                        id: '4',
                        url: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400&h=600&fit=crop',
                        createdAt: DateTime.now().toIso8601String(),
                        updatedAt: DateTime.now().toIso8601String(),
                      ),
                    ],
                    address: 'Адрес',
                    hours: '9:00 - 18:00',
                    contacts: 'Контакты',
                    history: 'История',
                    latitude: 0.0,
                    longitude: 0.0,
                    reviews: [],
                    description: 'В сердце «Старого города» или «Эски шахар» находится одна из главных достопримечательностей Ташкента – огромный базар Чорсу, известный еще со времен Средневековья.',
                    overview: '',
                    typeId: 1,
                    areaId: 1,
                    isActive: true,
                    createdAt: DateTime.now(),
                  ),
                  isFavorite: false,
                  currentImageIndex: 0,
                  totalImages: 4,
                  onFavoriteTap: () {
                    AppSnackBar.showInfo(context, 'Избранное нажато');
                  },
                ),
              ],
            ),

            // Теги мест
            _buildSection(
              title: 'Теги мест',
              children: [
                Wrap(
                  spacing: AppDesignSystem.spacingSmall,
                  runSpacing: AppDesignSystem.spacingSmall,
                  children: [
                    PlaceTag(text: 'Озеро'),
                    PlaceTag(text: 'Гора'),
                    PlaceTag(text: 'Музей'),
                    PlaceTag(text: 'Парк'),
                  ],
                ),
              ],
            ),

            // Кнопка избранного
            _buildSection(
              title: 'Кнопка избранного',
              children: [
                FavoriteButton(
                  isFavorite: _isFavorite,
                  onTap: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                    AppSnackBar.showInfo(
                      context,
                      _isFavorite ? 'Добавлено в избранное' : 'Удалено из избранного',
                    );
                  },
                ),
              ],
            ),

            // Индикатор пагинации изображений
            _buildSection(
              title: 'Индикатор пагинации',
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImagePaginationIndicator(
                      currentIndex: 0,
                      totalCount: 4,
                    ),
                    SizedBox(height: AppDesignSystem.spacingMedium),
                    ImagePaginationIndicator(
                      currentIndex: 1,
                      totalCount: 4,
                    ),
                    SizedBox(height: AppDesignSystem.spacingMedium),
                    ImagePaginationIndicator(
                      currentIndex: 2,
                      totalCount: 4,
                    ),
                    SizedBox(height: AppDesignSystem.spacingMedium),
                    ImagePaginationIndicator(
                      currentIndex: 3,
                      totalCount: 4,
                    ),
                  ],
                ),
              ],
            ),

            // Чекбокс
            _buildSection(
              title: 'Чекбокс',
              children: [
                AppCheckbox(
                  value: _checkboxValue,
                  onChanged: (value) {
                    setState(() {
                      _checkboxValue = value;
                    });
                  },
                ),
              ],
            ),

            // Переключатель (Switch)
            _buildSection(
              title: 'Переключатель',
              children: [
                AppSwitch(
                  value: _appSwitchValue,
                  onChanged: (value) {
                    setState(() {
                      _appSwitchValue = value;
                    });
                  },
                ),
              ],
            ),

            // Toggle Switch
            _buildSection(
              title: 'Toggle Switch',
              children: [
                AppToggleSwitch(
                  value: _toggleSwitchValue,
                  onChanged: (value) {
                    setState(() {
                      _toggleSwitchValue = value;
                    });
                  },
                ),
              ],
            ),

            // Кнопка-переключатель
            _buildSection(
              title: 'Кнопка-переключатель',
              children: [
                Text(
                  'Группа переключателей (3 кнопки)',
                  style: AppTextStyles.title(),
                ),
                SizedBox(height: AppDesignSystem.spacingSmall),
                ToggleButtonGroup(
                  options: const ['Обзор', 'История', 'Отзывы'],
                  selectedIndex: _selectedToggleGroupIndex,
                  onSelected: (index) {
                    setState(() {
                      _selectedToggleGroupIndex = index;
                    });
                  },
                ),
                SizedBox(height: AppDesignSystem.spacingMedium),
                Text(
                  'Группа переключателей (2 кнопки)',
                  style: AppTextStyles.title(),
                ),
                SizedBox(height: AppDesignSystem.spacingSmall),
                ToggleButtonGroup(
                  options: const ['Обзор', 'Маршруты'],
                  selectedIndex: _selectedToggleGroup2Index,
                  onSelected: (index) {
                    setState(() {
                      _selectedToggleGroup2Index = index;
                    });
                  },
                ),
              ],
            ),

            // Метка на карте
            _buildSection(
              title: 'Метка на карте',
              children: [
                MapMarker(
                  imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=100&h=100&fit=crop',
                  onTap: () {
                    AppSnackBar.showInfo(context, 'Метка нажата');
                  },
                ),
                SizedBox(height: AppDesignSystem.spacingMedium),
                UserLocationMarker(),
              ],
            ),

            // Фильтры
            _buildSection(
              title: 'Фильтры',
              children: [
                Wrap(
                  spacing: AppDesignSystem.spacingSmall,
                  runSpacing: AppDesignSystem.spacingSmall,
                  children: [
                    AppFilterChip(
                      label: 'Гастротуризм',
                      onDelete: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Фильтр удален')),
                        );
                      },
                    ),
                    AppFilterChip(
                      label: 'Музеи',
                      onDelete: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Фильтр удален')),
                        );
                      },
                    ),
                    AppFilterChip(
                      label: 'Парки',
                      onDelete: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Фильтр удален')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),


            // Состояния загрузки
            _buildSection(
              title: 'Состояния загрузки',
              children: [
                const LoadingStateWidget(
                  message: 'Загрузка...',
                ),
                SizedBox(height: AppDesignSystem.spacingXLarge),
                ErrorStateWidget(
                  message: 'Ошибка загрузки данных',
                  onRetry: () {
                    AppSnackBar.showInfo(context, 'Повторная попытка');
                  },
                ),
              ],
            ),

            // Section Title
            _buildSection(
              title: 'Заголовки секций',
              children: [
                SectionTitle(
                  text: 'Section Title',
                ),
                SizedBox(height: AppDesignSystem.spacingMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SectionTitle(
                        text: 'Section Title с действием',
                        textAlign: TextAlign.left,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        AppSnackBar.showInfo(context, 'Action pressed');
                      },
                      child: Text(
                        'Смотреть все',
                        style: AppTextStyles.small(
                          color: AppDesignSystem.primaryColor,
                          fontWeight: AppDesignSystem.fontWeightMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Drag Indicator
            _buildSection(
              title: 'Drag Indicator',
              children: [
                Center(
                  child: DragIndicator(
                    color: AppDesignSystem.greyColor,
                  ),
                ),
              ],
            ),

            // Smooth Container примеры
            _buildSection(
              title: 'Smooth Container',
              children: [
                SmoothContainer(
                  padding: const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
                  borderRadius: AppDesignSystem.borderRadius,
                  color: AppDesignSystem.backgroundColorSecondary,
                  child: Text(
                    'Smooth Container с borderRadius',
                    style: AppTextStyles.body(),
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacingMedium),
                SmoothContainer(
                  padding: const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
                  borderRadius: AppDesignSystem.borderRadiusMedium,
                  color: AppDesignSystem.primaryColorLight,
                  child: Text(
                    'Smooth Container с другим цветом',
                    style: AppTextStyles.body(
                      color: AppDesignSystem.textColorWhite,
                    ),
                  ),
                ),
              ],
            ),

            // Типографика
            _buildSection(
              title: 'Типографика',
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовки
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Заголовки',
                            style: AppTextStyles.body(
                              color: AppDesignSystem.textColorPrimary.withValues(alpha: 0.5),
                            ),
                          ),
                          SizedBox(height: AppDesignSystem.spacingXLarge),
                          Text('H1 28px', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w600, height: 1.2)),
                          SizedBox(height: AppDesignSystem.spacingXLarge),
                          Text('H2 22px', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2)),
                          SizedBox(height: AppDesignSystem.spacingXLarge),
                          Text('H3 20px', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, height: 1.2)),
                          SizedBox(height: AppDesignSystem.spacingXLarge),
                          Text('H4 18px', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, height: 1.2)),
                          SizedBox(height: AppDesignSystem.spacingXLarge),
                          Text('H5 16px', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, height: 1.2)),
                          SizedBox(height: AppDesignSystem.spacingXLarge),
                          Text('H6 14px', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, height: 1.2)),
                          SizedBox(height: AppDesignSystem.spacingXLarge),
                          Text('H7 12px', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2)),
                        ],
                      ),
                    ),
                    SizedBox(width: 100),
                    // Подзаголовки
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Подзаголовки',
                            style: AppTextStyles.body(
                              color: AppDesignSystem.textColorPrimary.withValues(alpha: 0.5),
                            ),
                          ),
                          SizedBox(height: AppDesignSystem.spacingXLarge),
                          Text('S1 18px', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500, height: 1.2)),
                          SizedBox(height: AppDesignSystem.spacingXLarge),
                          Text('S2 16px', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, height: 1.2)),
                          SizedBox(height: AppDesignSystem.spacingXLarge),
                          Text('S3 14px', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, height: 1.2)),
                        ],
                      ),
                    ),
                    SizedBox(width: 100),
                    // Текст
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Текст',
                            style: AppTextStyles.body(
                              color: AppDesignSystem.textColorPrimary.withValues(alpha: 0.5),
                            ),
                          ),
                          SizedBox(height: AppDesignSystem.spacingXLarge),
                          Text('T1 16px', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, height: 1.2)),
                          SizedBox(height: AppDesignSystem.spacingXLarge),
                          Text('T2 14px', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.2, letterSpacing: -0.28)),
                          SizedBox(height: AppDesignSystem.spacingXLarge),
                          Text('T3 12px', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, height: 1.2)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Цвета
            _buildSection(
              title: 'Цвета',
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = (constraints.maxWidth - 90) / 4; // 90 = 3 gaps * 30px
                    return Wrap(
                      spacing: 30,
                      runSpacing: 30,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: _buildColorSwatch('#000000', const Color(0xFF000000)),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _buildColorSwatch('#919191', const Color(0xFF919191)),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _buildColorSwatch('#F6F6F6', const Color(0xFFF6F6F6)),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _buildColorSwatch('#FFFFFF', Colors.white, hasBorder: true),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _buildColorSwatch('#24A79C', const Color(0xFF24A79C)),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _buildColorSwatch('#FFC800', const Color(0xFFFFC800)),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _buildColorSwatch('#EB281E', const Color(0xFFEB281E)),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _buildColorSwatch('Тень', Colors.white, hasShadow: true),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

            // SnackBar примеры
            _buildSection(
              title: 'SnackBar',
              children: [
                PrimaryButton(
                  text: 'Success',
                  onPressed: () {
                    AppSnackBar.showSuccess(context, 'Операция выполнена успешно');
                  },
                ),
                SizedBox(height: AppDesignSystem.spacingMedium),
                PrimaryButton(
                  text: 'Error',
                  onPressed: () {
                    AppSnackBar.showError(context, 'Произошла ошибка');
                  },
                ),
                SizedBox(height: AppDesignSystem.spacingMedium),
                PrimaryButton(
                  text: 'Info',
                  onPressed: () {
                    AppSnackBar.showInfo(context, 'Информационное сообщение');
                  },
                ),
                SizedBox(height: AppDesignSystem.spacingMedium),
                PrimaryButton(
                  text: 'Custom',
                  onPressed: () {
                    AppSnackBar.show(
                      context,
                      'Кастомное сообщение',
                      backgroundColor: Colors.orange,
                    );
                  },
                ),
              ],
            ),

            // Dialog пример
            _buildSection(
              title: 'Диалоги',
              children: [
                PrimaryButton(
                  text: 'Открыть диалог',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AppDialog(
                        title: 'Пример диалога',
                        content: Text(
                          'Это пример диалога из дизайн-системы',
                          style: AppTextStyles.body(),
                        ),
                        confirmText: 'ОК',
                        onConfirm: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                ),
              ],
            ),

            // ActionButtonsPanel пример
            _buildSection(
              title: 'Панель действий',
              children: [
                ActionButtonsPanel(
                  onRate: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Оценить нажато')),
                    );
                  },
                  onRoute: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Маршрут нажато')),
                    );
                  },
                ),
              ],
            ),

            // BottomActionBar пример
            _buildSection(
              title: 'Нижняя панель действий',
              children: [
                BottomActionBar(
                  onCancel: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Отменить нажато')),
                    );
                  },
                  onConfirm: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Подтвердить нажато')),
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: AppDesignSystem.spacingXXLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.title(
            fontWeight: AppDesignSystem.fontWeightSemiBold,
          ),
        ),
        SizedBox(height: AppDesignSystem.spacingMedium),
        ...children,
        SizedBox(height: AppDesignSystem.spacingXXLarge),
      ],
    );
  }

  Widget _buildColorSwatch(String label, Color color, {bool hasBorder = false, bool hasShadow = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth;
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
                border: hasBorder
                    ? Border.all(
                        color: const Color(0xFFEAEAEA),
                        width: 1,
                      )
                    : null,
                boxShadow: hasShadow
                    ? [
                        BoxShadow(
                          color: const Color(0xFFC0C0C0).withValues(alpha: 0.1),
                          offset: const Offset(0, -2),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
            );
          },
        ),
        SizedBox(height: 15),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            height: 1.2,
            color: AppDesignSystem.textColorPrimary,
          ),
        ),
      ],
    );
  }
}

