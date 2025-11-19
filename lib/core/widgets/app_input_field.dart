import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../constants/app_design_system.dart';
import '../constants/app_text_styles.dart';
import '../../utils/smooth_border_radius.dart';

/// Универсальное поле ввода приложения
/// Использует дизайн-систему для консистентного стиля
class AppInputField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;

  const AppInputField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.validator,
    this.autovalidateMode,
  });

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final hasValue = widget.controller?.text.isNotEmpty ?? false;
    final showError = hasError;
    final showPasswordToggle = widget.obscureText && (widget.suffixIcon == null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.small(
              fontWeight: AppDesignSystem.fontWeightMedium,
            ),
          ),
          SizedBox(height: AppDesignSystem.spacingTiny),
        ],
        SmoothContainer(
          height: 47.0, // По дизайну из Figma
          borderRadius: 10.0, // По дизайну из Figma
          color: AppDesignSystem.backgroundColorSecondary, // #f6f6f6
          border: showError
              ? Border.all(
                  color: AppDesignSystem.errorColor, // #ff4444
                  width: 1.0,
                )
              : null,
          padding: EdgeInsets.zero,
          child: TextField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            obscureText: widget.obscureText && !_isPasswordVisible,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            focusNode: _focusNode,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            cursorColor: AppDesignSystem.primaryColor, // #24a79c
            cursorWidth: 1.5, // По дизайну из Figma
            cursorHeight: 19.0, // По дизайну из Figma
            cursorRadius: const Radius.circular(10.0), // По дизайну из Figma
            style: AppTextStyles.body(), // 16px, черный
          decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.body(
                color: AppDesignSystem.greyMedium, // #919191
            ),
              filled: false, // Убираем стандартный fill, используем наш Container
              contentPadding: const EdgeInsets.all(14.0), // По дизайну из Figma
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              prefixIcon: widget.prefixIcon,
              suffixIcon: showPasswordToggle
                  ? Semantics(
                      label: _isPasswordVisible ? 'Скрыть пароль' : 'Показать пароль',
                      button: true,
                      child: GestureDetector(
                        onTap: _togglePasswordVisibility,
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: SvgPicture.asset(
                            _isPasswordVisible ? 'assets/view-on.svg' : 'assets/view-off.svg',
                            width: AppDesignSystem.passwordIconSize,
                            height: _isPasswordVisible
                                ? AppDesignSystem.passwordIconVisibleHeight
                                : AppDesignSystem.passwordIconSize,
                            fit: BoxFit.contain,
              ),
            ),
                      ),
                    )
                  : widget.suffixIcon,
              counterText: '',
            ),
          ),
        ),
        if (showError) ...[
          SizedBox(height: 6.0), // По дизайну из Figma
          Text(
            widget.errorText!,
            style: AppTextStyles.error(
              color: AppDesignSystem.errorColor, // #ff4444
            ), // 12px
          ),
        ],
      ],
    );
  }
}

/// Поле ввода с валидацией (TextFormField)
class AppFormField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;

  const AppFormField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.validator,
    this.autovalidateMode,
  });

  @override
  State<AppFormField> createState() => _AppFormFieldState();
}

class _AppFormFieldState extends State<AppFormField> {
  late FocusNode _focusNode;
  String? _errorText;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showError = _errorText != null && _errorText!.isNotEmpty;
    final showPasswordToggle = widget.obscureText && (widget.suffixIcon == null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.small(
              fontWeight: AppDesignSystem.fontWeightMedium,
            ),
          ),
          SizedBox(height: AppDesignSystem.spacingTiny),
        ],
        SmoothContainer(
          height: 47.0, // По дизайну из Figma
          borderRadius: 10.0, // По дизайну из Figma
          color: AppDesignSystem.backgroundColorSecondary, // #f6f6f6
          border: showError
              ? Border.all(
                  color: AppDesignSystem.errorColor, // #ff4444
                  width: 1.0,
                )
              : null,
          padding: EdgeInsets.zero,
          child: TextFormField(
            controller: widget.controller,
            onChanged: (value) {
              widget.onChanged?.call(value);
              if (widget.validator != null) {
                final error = widget.validator!(value);
                setState(() {
                  _errorText = error;
                });
              }
            },
            onFieldSubmitted: widget.onSubmitted,
            obscureText: widget.obscureText && !_isPasswordVisible,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            focusNode: _focusNode,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            validator: widget.validator,
            autovalidateMode: widget.autovalidateMode,
            cursorColor: AppDesignSystem.primaryColor, // #24a79c
            cursorWidth: 1.5, // По дизайну из Figma
            cursorHeight: 19.0, // По дизайну из Figma
            cursorRadius: const Radius.circular(10.0), // По дизайну из Figma
            style: AppTextStyles.body(), // 16px, черный
          decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.body(
                color: AppDesignSystem.greyMedium, // #919191
              ),
              filled: false, // Убираем стандартный fill, используем наш Container
              contentPadding: const EdgeInsets.all(14.0), // По дизайну из Figma
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              prefixIcon: widget.prefixIcon,
              suffixIcon: showPasswordToggle
                  ? Semantics(
                      label: _isPasswordVisible ? 'Скрыть пароль' : 'Показать пароль',
                      button: true,
                      child: GestureDetector(
                        onTap: _togglePasswordVisibility,
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: SvgPicture.asset(
                            _isPasswordVisible ? 'assets/view-on.svg' : 'assets/view-off.svg',
                            width: AppDesignSystem.passwordIconSize,
                            height: _isPasswordVisible
                                ? AppDesignSystem.passwordIconVisibleHeight
                                : AppDesignSystem.passwordIconSize,
                            fit: BoxFit.contain,
              ),
            ),
                      ),
                    )
                  : widget.suffixIcon,
              counterText: '',
            ),
          ),
        ),
        if (showError) ...[
          SizedBox(height: 6.0), // По дизайну из Figma
          Text(
            _errorText!,
            style: AppTextStyles.error(
              color: AppDesignSystem.errorColor, // #ff4444
            ), // 12px
          ),
        ],
      ],
    );
  }
}
