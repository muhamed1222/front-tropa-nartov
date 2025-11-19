import 'package:flutter/material.dart';
import '../constants/app_design_system.dart';
import '../constants/app_text_styles.dart';
import '../../utils/smooth_border_radius.dart';

/// Универсальный диалог приложения
/// Использует дизайн-систему для консистентного стиля
class AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isErrorStyle;
  final bool showCloseButton;

  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isErrorStyle = false,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
      child: Stack(
        children: [
          SmoothContainer(
            width: MediaQuery.of(context).size.width > 400.0
                ? AppDesignSystem.dialogWidth
                : MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
            borderRadius: AppDesignSystem.borderRadiusLarge,
            color: AppDesignSystem.backgroundColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Заголовок
                Text(
                  title,
                  style: AppTextStyles.title(),
                  textAlign: TextAlign.center,
                ),

                // Контент
                if (message != null || content != null) ...[
                  SizedBox(height: AppDesignSystem.spacingXLarge),
                  if (message != null)
                    Text(
                      message!,
                      style: AppTextStyles.body(),
                      textAlign: TextAlign.center,
                    )
                  else
                    content!,
                ],

                // Кнопки
                if (confirmText != null || cancelText != null) ...[
                  SizedBox(height: AppDesignSystem.spacingXLarge),
                  Row(
                    children: [
                      if (cancelText != null) ...[
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (onCancel != null) {
                                onCancel!();
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            child: SmoothContainer(
                              width: double.infinity,
                              height: AppDesignSystem.buttonHeight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDesignSystem.paddingHorizontal,
                                vertical: AppDesignSystem.paddingVerticalMedium,
                              ),
                              borderRadius: AppDesignSystem.borderRadius,
                              color: AppDesignSystem.backgroundColorSecondary,
                              child: Center(
                                child: Text(
                                  cancelText!,
                                  style: AppTextStyles.body(
                                    fontWeight: AppDesignSystem.fontWeightMedium,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (confirmText != null)
                          SizedBox(width: AppDesignSystem.spacingMedium),
                      ],
                      if (confirmText != null)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (onConfirm != null) {
                                onConfirm!();
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            child: SmoothContainer(
                              width: double.infinity,
                              height: AppDesignSystem.buttonHeight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDesignSystem.paddingHorizontal,
                                vertical: AppDesignSystem.paddingVerticalMedium,
                              ),
                              borderRadius: AppDesignSystem.borderRadius,
                              color: isErrorStyle ? AppDesignSystem.errorColor : AppDesignSystem.primaryColor,
                              child: Center(
                                child: Text(
                                  confirmText!,
                                  style: AppTextStyles.button(),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Кнопка закрытия
          if (showCloseButton)
            Positioned(
              top: AppDesignSystem.spacingMedium - 2,
              right: AppDesignSystem.spacingMedium - 2,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: AppDesignSystem.textColorTertiary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Показать диалог подтверждения
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    String? message,
    String confirmText = 'Да',
    String cancelText = 'Отмена',
    bool isErrorStyle = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isErrorStyle: isErrorStyle,
        onConfirm: () {
          Navigator.of(context).pop(true);
        },
        onCancel: () {
          Navigator.of(context).pop(false);
        },
      ),
    );
  }

  /// Показать диалог с ошибкой
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    String? message,
    String confirmText = 'ОК',
  }) {
    return showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        isErrorStyle: true,
        cancelText: null,
        onConfirm: () => Navigator.of(context).pop(),
      ),
    );
  }
}

