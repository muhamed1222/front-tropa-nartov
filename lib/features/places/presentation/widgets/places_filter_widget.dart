import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../models/api_models.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../../../../core/widgets/widgets.dart';

class FilterWidget extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> areas;
  final List<Map<String, dynamic>> tags;
  final PlaceFilters initialFilters;
  final Function(PlaceFilters) onFiltersApplied;
  final ScrollController? scrollController;

  const FilterWidget({
    super.key,
    required this.categories,
    required this.areas,
    required this.tags,
    required this.initialFilters,
    required this.onFiltersApplied,
    this.scrollController,
  });

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  late PlaceFilters _currentFilters;

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters;
  }

  void _resetFilters() {
    setState(() {
      _currentFilters = _currentFilters.reset();
    });
  }

  void _applyFilters() {
    widget.onFiltersApplied(_currentFilters);
    Navigator.of(context).pop();
  }

  void _toggleCategory(int categoryId) {
    setState(() {
      final newCategories = List<int>.from(_currentFilters.selectedCategories);
      if (newCategories.contains(categoryId)) {
        newCategories.remove(categoryId);
      } else {
        newCategories.add(categoryId);
      }
      _currentFilters = _currentFilters.copyWith(selectedCategories: newCategories);
    });
  }

  void _toggleArea(int areaId) {
    setState(() {
      final newAreas = List<int>.from(_currentFilters.selectedAreas);
      if (newAreas.contains(areaId)) {
        newAreas.remove(areaId);
      } else {
        newAreas.add(areaId);
      }
      _currentFilters = _currentFilters.copyWith(selectedAreas: newAreas);
    });
  }

  void _toggleTag(int tagId) {
    setState(() {
      final newTags = List<int>.from(_currentFilters.selectedTags);
      if (newTags.contains(tagId)) {
        newTags.remove(tagId);
      } else {
        newTags.add(tagId);
      }
      _currentFilters = _currentFilters.copyWith(selectedTags: newTags);
    });
  }

  Widget _buildCheckbox(bool isSelected) {
    return SmoothContainer(
      width: 18,
      height: 18,
      borderRadius: 4,
      color: isSelected ? const Color(0xFF24A79C) : const Color(0xFFF6F6F6),
      border: isSelected
          ? Border.all(color: const Color(0xFF24A79C), width: 2)
          : Border.all(color: const Color(0xFFF6F6F6), width: 2),
      child: isSelected
          ? const Icon(
        Icons.check,
        size: 14,
        color: Colors.white,
      )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final isSelected = _currentFilters.selectedCategories.contains(category['id']);
    return InkWell(
      onTap: () {
        _toggleCategory(category['id']);
      },
      child: Container(
        height: 19,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          children: [
            _buildCheckbox(isSelected),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                category['name'],
                style: GoogleFonts.inter(
                  color: AppDesignSystem.textColorPrimary,

                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaItem(Map<String, dynamic> area) {
    final isSelected = _currentFilters.selectedAreas.contains(area['id']);
    return InkWell(
      onTap: () {
        _toggleArea(area['id']);
      },
      child: Container(
        height: 19,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          children: [
            _buildCheckbox(isSelected),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                area['name'],
                style: GoogleFonts.inter(
                  color: AppDesignSystem.textColorPrimary,

                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SmoothBorderClipper(radius: 20),
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            // Основной контент
            SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.only(top: 95, bottom: 120), // Отступ сверху для фиксированного заголовка
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Категория
                        if (widget.categories.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            child: Text(
                              'Категория',
                              style: TextStyle(
                                color: AppDesignSystem.textColorPrimary,

                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 1.20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Column(
                              children: widget.categories.asMap().entries.map((entry) {
                                final index = entry.key;
                                final category = entry.value;
                                return Column(
                                  children: [
                                    _buildCategoryItem(category),
                                    if (index < widget.categories.length - 1) const SizedBox(height: 12),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                        if (widget.categories.isNotEmpty) const SizedBox(height: 24),

                        // Район
                        if (widget.areas.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            child: Text(
                              'Район',
                              style: TextStyle(
                                color: AppDesignSystem.textColorPrimary,

                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 1.20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Column(
                              children: widget.areas.asMap().entries.map((entry) {
                                final index = entry.key;
                                final area = entry.value;
                                return Column(
                                  children: [
                                    _buildAreaItem(area),
                                    if (index < widget.areas.length - 1) const SizedBox(height: 12),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                        if (widget.areas.isNotEmpty && widget.tags.isNotEmpty) const SizedBox(height: 24),

                        // Тег
                        if (widget.tags.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            child: Text(
                              'Тег',
                              style: TextStyle(
                                color: AppDesignSystem.textColorPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 1.20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Wrap(
                              spacing: 9,
                              runSpacing: 8,
                              children: widget.tags.map((tag) {
                                final isSelected = _currentFilters.selectedTags.contains(tag['id']);
                                return InkWell(
                                  onTap: () {
                                    _toggleTag(tag['id']);
                                  },
                                  child: Container(
                                    height: 33,
                                    child: SmoothContainer(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      borderRadius: 20,
                                      color: isSelected ? const Color(0xFF24A79C) : const Color(0xFFF6F6F6),
                                      child: IntrinsicWidth(
                                        child: Center(
                                          child: Text(
                                            tag['name'],
                                            style: TextStyle(
                                              color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              height: 1.20,
                                              letterSpacing: -0.28,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20), // Нижний отступ для контента
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Фиксированный заголовок с индикатором перетаскивания
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: SmoothBorderClipper(radius: 20),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Индикатор перетаскивания
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: DragIndicator(),
                      ),
                      // Заголовок
                      const Padding(
                        padding: EdgeInsets.only(top: 26, bottom: 28),
                        child: Text(
                          'Фильтры',
                          style: TextStyle(
                            color: AppDesignSystem.textColorPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 1.20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Контейнер с кнопками (зафиксирован внизу)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: SmoothBorderClipper(radius: 20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC0C0C0).withOpacity(0.10),
                        offset: const Offset(0, -2),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: BottomActionBar(
                      onCancel: _resetFilters,
                      onConfirm: _applyFilters,
                      cancelText: 'Сбросить',
                      confirmText: 'Применить',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}