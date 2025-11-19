import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tropanartov/features/home/presentation/bloc/home_bloc.dart';
import '../../../../utils/smooth_border_radius.dart';
import 'active_route_widget.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_design_system.dart';

class RouteInfoSheet extends StatelessWidget {
  final VoidCallback onRouteStarted;

  const RouteInfoSheet({
    super.key,
    required this.onRouteStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 14,
        right: 14,
        bottom: 44,
      ),
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! > 10) {
            _closeAllSheets(context);
          }
        },
        child: ClipPath(
          clipper: SmoothBorderClipper(radius: 20),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _buildRoutePointsRow(
                        from: 'Мое местоположение',
                        to: context
                            .read<HomeBloc>()
                            .state
                            .routeEndName ?? 'Выбранное место',
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildTimeInfo(
                            iconAsset: 'assets/car.svg',
                            time: context
                                .read<HomeBloc>()
                                .state
                                .drivingTime ?? '12 минут',
                          ),
                          const SizedBox(width: 8),
                          _buildTimeInfo(
                            iconAsset: 'assets/men.svg',
                            time: context
                                .read<HomeBloc>()
                                .state
                                .walkingTime ?? '2 мин',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          // Кнопка "Отменить" (outline стиль) - используем SecondaryButton
                          SizedBox(
                            width: 118,
                            child: SecondaryButton(
                              text: 'Отменить',
                              onPressed: () {
                                _closeAllSheets(context);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Кнопка "Начать маршрут" (filled стиль) - используем PrimaryButton
                          Expanded(
                            child: PrimaryButton(
                              text: 'Начать маршрут',
                              onPressed: () {
                                _startRoute(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }void _startRoute(BuildContext context) {
    final homeBloc = context.read<HomeBloc>();

    onRouteStarted();

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 16,
        left: 16,
        right: 16,
        child: ActiveRouteWidget(
          homeBloc: homeBloc,
          onClose: () {
            overlayEntry.remove();
          },
          onCompleteRoute: (context) {
            _completeRouteAndCloseAll(context, homeBloc);
          },
          onShowAgain: () {
            // Просто заново создаем OverlayEntry
            Overlay.of(context).insert(overlayEntry);
          },
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  void _completeRouteAndCloseAll(BuildContext context, HomeBloc homeBloc) {
    // Очищаем маршрут
    homeBloc.add(const ClearRoute());
  }

  void _closeAllSheets(BuildContext context) {
    final homeBloc = context.read<HomeBloc>();

    // Очищаем маршрут
    homeBloc.add(const ClearRoute());

  }

  Widget _buildRoutePointsRow({
    required String from,
    required String to,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Откуда: $from',
                      style: AppTextStyles.body(
                        color: Colors.black38,
                        fontWeight: AppDesignSystem.fontWeightMedium,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Куда: $to',
                      style: AppTextStyles.body(
                        color: Colors.black87,
                        fontWeight: AppDesignSystem.fontWeightMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInfo({required String iconAsset, required String time}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF24A79C).withValues(alpha: 0.1), // фон с прозрачностью 10%
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconAsset,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(
              Color(0xFF24A79C), // цвет иконки #24A79C
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: AppTextStyles.body(
              color: AppDesignSystem.primaryColor,
              fontWeight: AppDesignSystem.fontWeightSemiBold,
            ),
          ),
        ],
      ),
    );
  }
}