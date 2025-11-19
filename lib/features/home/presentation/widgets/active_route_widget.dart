import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tropanartov/features/home/presentation/bloc/home_bloc.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';

class ActiveRouteWidget extends StatefulWidget {
  final HomeBloc homeBloc;
  final VoidCallback onClose;
  final Function(BuildContext) onCompleteRoute;
  final VoidCallback onShowAgain;

  const ActiveRouteWidget({
    super.key,
    required this.homeBloc,
    required this.onClose,
    required this.onCompleteRoute,
    required this.onShowAgain,
  });

  @override
  State<ActiveRouteWidget> createState() => _ActiveRouteWidgetState();
}

class _ActiveRouteWidgetState extends State<ActiveRouteWidget> {
  bool _isVisible = true;

  void _showCloseConfirmationDialog(BuildContext context) {
    // Временно скрываем виджет вместо полного закрытия
    setState(() {
      _isVisible = false;
    });

    // Показываем диалог
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return ActiveRouteDialog(
          onConfirm: () {
            Navigator.of(context).pop(true);
          },
          onCancel: () {
            Navigator.of(context).pop(false);
          },
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        // Пользователь подтвердил завершение маршрута
        widget.onCompleteRoute(context);
      } else {
        // Пользователь отменил - снова показываем виджет
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return BlocProvider.value(
      value: widget.homeBloc,
      child: SmoothContainer(
        height: 56,
        margin: const EdgeInsets.fromLTRB(AppDesignSystem.paddingHorizontal, 0, AppDesignSystem.paddingHorizontal, 44),
        padding: const EdgeInsets.symmetric(horizontal: AppDesignSystem.spacingMedium, vertical: AppDesignSystem.spacingSmall),
        borderRadius: AppDesignSystem.borderRadiusMedium,
        color: AppDesignSystem.backgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Общий путь',
                  style: AppTextStyles.error(
                    color: AppDesignSystem.textColorSecondary,
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacingTiny / 2),
                Text(
                  '470 м',
                  style: AppTextStyles.small(
                    fontWeight: AppDesignSystem.fontWeightSemiBold,
                  ),
                ),
              ],
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Время в пути',
                  style: AppTextStyles.error(
                    color: AppDesignSystem.textColorSecondary,
                  ),
                ),
                SizedBox(height: AppDesignSystem.spacingTiny / 2),
                Text(
                  '2 мин',
                  style: AppTextStyles.small(
                    fontWeight: AppDesignSystem.fontWeightSemiBold,
                  ),
                ),
              ],
            ),

            GestureDetector(
              onTap: () {
                _showCloseConfirmationDialog(context);
              },
              child: SmoothContainer(
                width: 32,
                height: 32,
                borderRadius: AppDesignSystem.spacingSmall + 2,
                color: AppDesignSystem.greyLight,
                child: Icon(
                  Icons.close,
                  size: AppDesignSystem.spacingLarge,
                  color: AppDesignSystem.textColorPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActiveRouteDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ActiveRouteDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 384,
          height: 131,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Завершить маршрут?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Inter',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ),
                      // Крестик прижат к правому краю
                      GestureDetector(
                        onTap: onCancel,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppDesignSystem.greyLight,
                            borderRadius: BorderRadius.circular(AppDesignSystem.spacingSmall + 2),
                          ),
                          child: Icon(
                            Icons.close,
                            size: AppDesignSystem.spacingLarge,
                            color: AppDesignSystem.textColorPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFF24A79C),
                              width: 1,
                            ),
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: onCancel,
                            child: Text(
                              'Отменить',
                              style: TextStyle(
                                color: Color(0xFF24A79C),
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 12),

                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Color(0xFF24A79C),
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: onConfirm,
                            child: Text(
                              'Да, завершить',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}