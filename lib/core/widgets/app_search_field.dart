import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../constants/app_design_system.dart';
import '../constants/app_text_styles.dart';
import '../../utils/smooth_border_radius.dart';

/// Поле поиска приложения
/// Используется для поиска мест, маршрутов и другого контента
class AppSearchField extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final FocusNode? focusNode;
  final bool enabled;

  const AppSearchField({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.focusNode,
    this.enabled = true,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    try {
      // Сначала удаляем слушатели
      _controller.removeListener(_onTextChange);
      _focusNode.removeListener(_onFocusChange);
      
      // Потом dispose() только если создавали сами
      if (widget.controller == null) {
        _controller.dispose();
      }
      if (widget.focusNode == null) {
        _focusNode.dispose();
      }
    } catch (e) {
      // Игнорируем ошибки при dispose
    }
    
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  void _onTextChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _clearText() {
    if (!mounted) return;
    try {
      _controller.clear();
      if (widget.onChanged != null) {
        widget.onChanged!('');
      }
    } catch (e) {
      // Контроллер мог быть disposed, игнорируем ошибку
    }
  }

  @override
  Widget build(BuildContext context) {
    // Безопасная проверка текста контроллера
    bool hasText = false;
    try {
      hasText = _controller.text.isNotEmpty;
    } catch (e) {
      // Контроллер мог быть disposed, игнорируем ошибку
      hasText = false;
    }

    return SmoothContainer(
      height: 48.0, // По дизайну из Figma (4px padding top + 4px padding bottom + 40px button)
      borderRadius: 30.0, // По дизайну из Figma
      color: AppDesignSystem.backgroundColorSecondary, // #f6f6f6
      padding: const EdgeInsets.only(
        left: 14.0,
        right: 4.0,
        top: 4.0,
        bottom: 4.0,
      ),
      child: Row(
        children: [
          // Левая часть: иконка поиска или кнопка очистки + текст
          Expanded(
            child: Row(
              children: [
                // Иконка поиска (когда пусто) или кнопка очистки (когда есть текст)
                if (!hasText)
                  SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: SvgPicture.asset(
                      'assets/lupa.svg',
                      width: 20.0,
                      height: 20.0,
                      fit: BoxFit.contain,
                    ),
                  )
                else
                  GestureDetector(
                    onTap: _clearText,
                    child: Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        color: AppDesignSystem.primaryColor.withValues(alpha: 0.12), // rgba(36,167,156,0.12)
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/close_icon.svg',
                          width: 7.0,
                          height: 7.0,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                SizedBox(width: 6.0),
                // Поле ввода
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    enabled: widget.enabled,
                    cursorColor: AppDesignSystem.primaryColor, // #24a79c
                    cursorWidth: 1.5, // По дизайну из Figma
                    cursorHeight: 19.0, // По дизайну из Figma
                    cursorRadius: const Radius.circular(10.0), // По дизайну из Figma
                    style: AppTextStyles.body(), // 16px, черный
                    decoration: InputDecoration(
                      hintText: widget.hint ?? 'Поиск мест',
                      hintStyle: AppTextStyles.body(
                        color: AppDesignSystem.greyMedium, // #919191
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6.0),
          // Кнопка фильтра
          GestureDetector(
            onTap: widget.onFilterTap,
            child: Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: AppDesignSystem.primaryColor, // #24a79c
                borderRadius: BorderRadius.circular(40.0), // Круглая
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/filter_icon.svg',
                  width: 22.0,
                  height: 22.0,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

