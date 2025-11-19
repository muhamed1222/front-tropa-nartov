import 'package:flutter/material.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';

/// Нижняя панель действий для экрана редактирования профиля
/// Содержит кнопки "Отменить" и "Сохранить" с поддержкой состояния загрузки
class EditProfileActionBar extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback? onSave;
  final bool isSaving;
  final String cancelText;
  final String saveText;

  const EditProfileActionBar({
    super.key,
    required this.onCancel,
    this.onSave,
    this.isSaving = false,
    this.cancelText = 'Отменить',
    this.saveText = 'Сохранить',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 14,
        right: 14,
        top: 14,
      ),
      decoration: BoxDecoration(
        color: AppDesignSystem.whiteColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppDesignSystem.shadowColor.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 20,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 44),
        child: Row(
          children: [
            Expanded(
              child: SecondaryButton(
                text: cancelText,
                onPressed: onCancel,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PrimaryButton(
                text: saveText,
                onPressed: onSave,
                isLoading: isSaving,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

