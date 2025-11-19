import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tropanartov/features/home/presentation/bloc/home_bloc.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/widgets/primary_button.dart';

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

  /// Форматирует расстояние в метрах в читаемый вид
  /// Примеры: "470 м", "1.2 км", "15 км"
  String _formatDistance(double meters) {
    if (meters < 1000) {
      // Меньше километра - показываем в метрах
      return '${meters.round()} м';
    } else {
      // Больше километра - показываем в километрах
      final kilometers = meters / 1000;
      if (kilometers < 10) {
        // До 10 км - один знак после запятой
        return '${kilometers.toStringAsFixed(1)} км';
      } else {
        // Больше 10 км - без знаков после запятой
        return '${kilometers.round()} км';
      }
    }
  }

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
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          // Форматируем расстояние
          final distance = state.routeDistance ?? 0.0;
          final formattedDistance = _formatDistance(distance);
          
          // Получаем время пешком (основной режим для активного маршрута)
          final time = state.walkingTime ?? '—';

          return SmoothContainer(
            height: 56,
            margin: const EdgeInsets.only(bottom: 44),
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
                      formattedDistance,
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
                      time,
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
          );
        },
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 14),
        child: ClipPath(
          clipper: SmoothBorderClipper(radius: 20),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Завершить маршрут?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title(),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: 'Отменить',
                        onPressed: onCancel,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: PrimaryButton(
                        text: 'Да, завершить',
                        onPressed: onConfirm,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}