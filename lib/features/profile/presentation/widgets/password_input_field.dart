import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Переиспользуемое поле ввода пароля
class PasswordInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final bool isPasswordVisible;
  final VoidCallback onToggleVisibility;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final bool enabled;
  final bool showLoadingIndicator;
  final String? semanticLabel;
  final FocusNode? focusNode;

  const PasswordInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.errorText,
    required this.isPasswordVisible,
    required this.onToggleVisibility,
    this.onChanged,
    this.onEditingComplete,
    this.enabled = true,
    this.showLoadingIndicator = false,
    this.semanticLabel,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? hintText,
      textField: true,
      child: Material(
        color: AppDesignSystem.backgroundColorSecondary,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          height: 47,
          padding: const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
          decoration: BoxDecoration(
            color: AppDesignSystem.backgroundColorSecondary,
            borderRadius: BorderRadius.circular(10),
            border: errorText != null
                ? Border.all(color: AppDesignSystem.errorColor, width: 1.5)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  obscureText: !isPasswordVisible,
                  enabled: enabled,
                  style: AppTextStyles.body(),
                  decoration: InputDecoration.collapsed(
                    hintText: hintText,
                    hintStyle: AppTextStyles.hint(),
                  ),
                  onChanged: onChanged,
                  onEditingComplete: onEditingComplete,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.next,
                ),
              ),
              if (showLoadingIndicator)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppDesignSystem.primaryColor),
                  ),
                )
              else
                Semantics(
                  label: isPasswordVisible ? 'Скрыть пароль' : 'Показать пароль',
                  button: true,
                  child: GestureDetector(
                    onTap: onToggleVisibility,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: SvgPicture.asset(
                        isPasswordVisible ? 'assets/view-on.svg' : 'assets/view-off.svg',
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
