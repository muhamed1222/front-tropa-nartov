import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tropanartov/features/home/presentation/bloc/home_bloc.dart';
import '../../../../utils/smooth_border_radius.dart';
import 'active_route_widget.dart';

class RouteInfoSheet extends StatelessWidget {
  final VoidCallback onRouteStarted;

  const RouteInfoSheet({
    super.key,
    required this.onRouteStarted,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
              Container(
                padding: const EdgeInsets.only(top: 14),
                child: Center(
                  child: SmoothContainer(
                    width: 40,
                    height: 4,
                    borderRadius: 2,
                    color: Colors.grey,
                    child: const SizedBox.shrink(),
                  ),
                ),
              ),
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
                              .walkingTime ?? '2 мин',
                        ),
                        const SizedBox(width: 12),
                        _buildTimeInfo(
                          iconAsset: 'assets/men.svg',
                          time: context
                              .read<HomeBloc>()
                              .state
                              .drivingTime ?? '12 минут',
                        ),
                      ],
                    ),
                    const SizedBox(height: 34),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 118,
                            height: 51,
                            child: OutlinedButton(
                              onPressed: () {
                                _closeAllSheets(context);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                side: const BorderSide(color: Color(0xFF24A79C)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Отменить',
                                style: TextStyle(
                                  color: Color(0xFF24A79C),
                                  fontSize: 16,

                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _startRoute(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF24A79C),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Начать маршрут',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,

                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 44),
                  ],
                ),
              ),
            ],
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
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black38,
                        fontWeight: FontWeight.w500,

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
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,

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
        color: const Color(0xFF24A79C).withOpacity(0.1), // фон с прозрачностью 10%
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconAsset,
            width: 20,
            height: 20,
            color: const Color(0xFF24A79C), // цвет иконки #24A79C
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF24A79C), // цвет текста #24A79C
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}