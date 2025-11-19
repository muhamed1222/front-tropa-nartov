import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_design_system.dart';
import '../../../models/api_models.dart';
import '../../../utils/smooth_border_radius.dart';
import '../../../core/widgets/widgets.dart';

class RoutesFilterWidget extends StatefulWidget {
  final RouteFilters initialFilters;
  final Function(RouteFilters) onFiltersApplied;
  final ScrollController? scrollController;

  const RoutesFilterWidget({
    super.key,
    required this.initialFilters,
    required this.onFiltersApplied,
    this.scrollController,
  });

  @override
  State<RoutesFilterWidget> createState() => _RoutesFilterWidgetState();
}

class _RoutesFilterWidgetState extends State<RoutesFilterWidget> {
  late RouteFilters _currentFilters;
  final TextEditingController _minDistanceController = TextEditingController();
  final TextEditingController _maxDistanceController = TextEditingController();
  final FocusNode _minFocusNode = FocusNode();
  final FocusNode _maxFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters;
    _updateTextControllers();

    // Слушаем изменения фокуса для обновления значений
    _minFocusNode.addListener(() {
      if (!_minFocusNode.hasFocus && _minDistanceController.text.isNotEmpty) {
        _onMinDistanceChanged(_minDistanceController.text);
      }
    });

    _maxFocusNode.addListener(() {
      if (!_maxFocusNode.hasFocus && _maxDistanceController.text.isNotEmpty) {
        _onMaxDistanceChanged(_maxDistanceController.text);
      }
    });
  }

  @override
  void dispose() {
    _minDistanceController.dispose();
    _maxDistanceController.dispose();
    _minFocusNode.dispose();
    _maxFocusNode.dispose();
    super.dispose();
  }

  void _updateTextControllers() {
    _minDistanceController.text = _currentFilters.minDistance.toInt().toString();
    _maxDistanceController.text = _currentFilters.maxDistance.toInt().toString();
  }

  void _resetFilters() {
    setState(() {
      _currentFilters = _currentFilters.reset();
      _updateTextControllers();
    });
  }

  void _applyFilters() {
    widget.onFiltersApplied(_currentFilters);
    Navigator.of(context).pop();
  }

  void _updateSelectedType(String type, bool isSelected) {
    setState(() {
      final newSelectedTypes = List<String>.from(_currentFilters.selectedTypes);
      if (isSelected) {
        newSelectedTypes.add(type);
      } else {
        newSelectedTypes.remove(type);
      }
      _currentFilters = _currentFilters.copyWith(selectedTypes: newSelectedTypes);
    });
  }

  void _updateDistanceRange(double min, double max) {
    setState(() {
      _currentFilters = _currentFilters.copyWith(
        minDistance: min,
        maxDistance: max,
      );
      _updateTextControllers();
    });
  }

  void _onMinDistanceChanged(String value) {
    if (value.isEmpty) {
      _updateDistanceRange(1, _currentFilters.maxDistance);
      return;
    }

    final minValue = double.tryParse(value);
    if (minValue != null && minValue >= 1 && minValue <= 30) {
      if (minValue <= _currentFilters.maxDistance) {
        _updateDistanceRange(minValue, _currentFilters.maxDistance);
      } else {
        _updateDistanceRange(_currentFilters.maxDistance, _currentFilters.maxDistance);
      }
    }
  }

  void _onMaxDistanceChanged(String value) {
    if (value.isEmpty) {
      _updateDistanceRange(_currentFilters.minDistance, 30);
      return;
    }

    final maxValue = double.tryParse(value);
    if (maxValue != null && maxValue >= 1 && maxValue <= 30) {
      if (maxValue >= _currentFilters.minDistance) {
        _updateDistanceRange(_currentFilters.minDistance, maxValue);
      } else {
        _updateDistanceRange(_currentFilters.minDistance, _currentFilters.minDistance);
      }
    }
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

  Widget _buildRouteTypeItem(String type) {
    final isSelected = _currentFilters.selectedTypes.contains(type);
    return InkWell(
      onTap: () {
        _updateSelectedType(type, !isSelected);
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
                type,
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
              padding: const EdgeInsets.only(bottom: 120), // Отступ для кнопок
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Индикатор перетаскивания (зафиксирован вверху)
                  const DragIndicator(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Заголовок
                        const Center(
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
                        const SizedBox(height: 28),

                        // Тип маршрута
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          child: Text(
                            'Тип маршрута',
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
                            children: ['Пеший', 'Авто', 'Комбинированный'].asMap().entries.map((entry) {
                              final index = entry.key;
                              final type = entry.value;
                              return Column(
                                children: [
                                  _buildRouteTypeItem(type),
                                  if (index < 2) const SizedBox(height: 12),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Протяженность
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          child: Text(
                            'Протяженность',
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
                            children: [
                              // Поля "от" и "до" в одной строке
                              Row(
                                children: [
                                  // Поле "от"
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        _minFocusNode.requestFocus();
                                      },
                                      child: SmoothContainer(
                                        height: 39,
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        borderRadius: 8,
                                        color: const Color(0xFFF6F6F6),
                                        child: Row(
                                          children: [
                                            Text(
                                              'от ',
                                              style: TextStyle(
                                                color: const Color(0xFF000000).withOpacity(0.5),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                height: 1.20,
                                                letterSpacing: -0.28,
                                              ),
                                            ),
                                            Expanded(
                                              child: TextField(
                                                controller: _minDistanceController,
                                                focusNode: _minFocusNode,
                                                keyboardType: TextInputType.number,
                                                decoration: const InputDecoration(
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.zero,
                                                  border: InputBorder.none,
                                                  focusedBorder: InputBorder.none,
                                                  enabledBorder: InputBorder.none,
                                                  errorBorder: InputBorder.none,
                                                  disabledBorder: InputBorder.none,
                                                ),
                                                style: GoogleFonts.inter(
                                                  color: AppDesignSystem.textColorPrimary,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.20,
                                                ),
                                                textAlign: TextAlign.left,
                                                onSubmitted: _onMinDistanceChanged,
                                              ),
                                            ),
                                            Text(
                                              ' км',
                                              style: GoogleFonts.inter(
                                                color: AppDesignSystem.textColorPrimary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                height: 1.20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Поле "до"
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        _maxFocusNode.requestFocus();
                                      },
                                      child: SmoothContainer(
                                        height: 39,
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        borderRadius: 8,
                                        color: const Color(0xFFF6F6F6),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              'до ',
                                              style: TextStyle(
                                                color: const Color(0xFF000000).withOpacity(0.5),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                height: 1.20,
                                                letterSpacing: -0.28,
                                              ),
                                            ),
                                            Expanded(
                                              child: TextField(
                                                controller: _maxDistanceController,
                                                focusNode: _maxFocusNode,
                                                keyboardType: TextInputType.number,
                                                decoration: const InputDecoration(
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.zero,
                                                  border: InputBorder.none,
                                                  focusedBorder: InputBorder.none,
                                                  enabledBorder: InputBorder.none,
                                                  errorBorder: InputBorder.none,
                                                  disabledBorder: InputBorder.none,
                                                ),
                                                style: GoogleFonts.inter(
                                                  color: AppDesignSystem.textColorPrimary,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.20,
                                                ),
                                                textAlign: TextAlign.right,
                                                onSubmitted: _onMaxDistanceChanged,
                                              ),
                                            ),
                                            Text(
                                              ' км',
                                              style: GoogleFonts.inter(
                                                color: AppDesignSystem.textColorPrimary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                height: 1.20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Слайдеры для выбора диапазона
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4), // Отступы по 4px справа и слева
                                child: SizedBox(
                                  height: 40,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Фоновая линия
                                      SmoothContainer(
                                        height: 3,
                                        width: double.infinity,
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        borderRadius: 2,
                                        color: const Color(0xFFF6F6F6),
                                        child: const SizedBox.shrink(),
                                      ),

                                      // Слайдер для минимального значения
                                      Positioned(
                                        left: (_currentFilters.minDistance - 1) / 29 * (MediaQuery.of(context).size.width - 56), // Учитываем отступы
                                        child: GestureDetector(
                                          onHorizontalDragUpdate: (details) {
                                            final newPosition = (_currentFilters.minDistance + details.delta.dx / (MediaQuery.of(context).size.width - 56) * 29).clamp(1.0, _currentFilters.maxDistance);
                                            _updateDistanceRange(newPosition, _currentFilters.maxDistance);
                                          },
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFF24A79C),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Слайдер для максимального значения
                                      Positioned(
                                        left: (_currentFilters.maxDistance - 1) / 29 * (MediaQuery.of(context).size.width - 56), // Учитываем отступы
                                        child: GestureDetector(
                                          onHorizontalDragUpdate: (details) {
                                            final newPosition = (_currentFilters.maxDistance + details.delta.dx / (MediaQuery.of(context).size.width - 56) * 29).clamp(_currentFilters.minDistance, 30.0);
                                            _updateDistanceRange(_currentFilters.minDistance, newPosition);
                                          },
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFF24A79C),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20), // Нижний отступ для контента
                      ],
                    ),
                  ),
                ],
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