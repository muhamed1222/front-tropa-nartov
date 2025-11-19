import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:tropanartov/core/di/injection_container.dart';
import 'package:tropanartov/features/home/presentation/bloc/home_bloc.dart';
import 'package:tropanartov/features/home/presentation/widgets/bottom_sheet_widget.dart';
import 'package:tropanartov/features/home/presentation/widgets/map_widget.dart';
import 'package:tropanartov/features/home/presentation/widgets/place_details_sheet_widget.dart';
import 'package:tropanartov/features/home/presentation/widgets/route_info_sheet.dart';
import 'package:tropanartov/features/menu/presentation/pages/menu_page.dart';
import '../../../../core/helpers/open_bottom_sheet.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../respublic/presentation/widgets/respublic_choose_widget.dart';
import '../../../../services/republic_service.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_design_system.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeBloc>()..add(const LoadMainData()),
      child: const HomePageView(),
    );
  }
}

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}
class _HomePageViewState extends State<HomePageView> with TickerProviderStateMixin {
  final MapController mapController = MapController();
  String _selectedRegion = 'Кабардино-Балкария';
  static const double _locationThreshold = 0.0001;
  late final AnimationController animationController;

  double sheetExtent = 0.5;
  bool _isRouteActive = false;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadSelectedRegion();
  }

  Future<void> _loadSelectedRegion() async {
    final selected = await RepublicService.getSelectedRepublicOrDefault();
    if (mounted) {
      setState(() {
        _selectedRegion = selected;
      });
    }
  }

  Future<void> _onRegionSelected() async {
    final selected = await openBottomSheet<String>(
      context,
      (c) => ChooseRespublicWidget(scrollController: c),
    );
    if (selected != null && mounted) {
      setState(() {
        _selectedRegion = selected;
      });
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HomePageView oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveMapToMyLocation(context.read<HomeBloc>().state.myLocation);
    });
    super.didUpdateWidget(oldWidget);
  }

  bool _isAlreadyAtLocation(LatLng targetLocation, double targetZoom) {
    final LatLng currentCenter = mapController.camera.center;

    final double latDiff = (currentCenter.latitude - targetLocation.latitude).abs();
    final double lngDiff = (currentCenter.longitude - targetLocation.longitude).abs();

    return latDiff < _locationThreshold && lngDiff < _locationThreshold;
  }

  void _moveMapToMyLocation(LatLng? myLocation, {double? zoom}) {
    if (myLocation == null) return;

    final double targetZoom = zoom ?? 17.0;

    if (_isAlreadyAtLocation(myLocation, targetZoom)) {
      return;
    }

    final LatLng currentCenter = mapController.camera.center;
    final double currentZoom = mapController.camera.zoom;

    animationController.reset();

    final animation = CurvedAnimation(parent: animationController, curve: Curves.easeInOut);

    final latTween = Tween<double>(begin: currentCenter.latitude, end: myLocation.latitude);
    final lngTween = Tween<double>(begin: currentCenter.longitude, end: myLocation.longitude);
    final zoomTween = Tween<double>(begin: currentZoom, end: targetZoom);

    animation.addListener(() {
      mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animationController.forward();
  }

  // void _zoomIn() {
  //   final double currentZoom = mapController.camera.zoom;
  //   final double newZoom = currentZoom + 1.0;
  //   mapController.move(mapController.camera.center, newZoom);
  // }
  //
  // void _zoomOut() {
  //   final double currentZoom = mapController.camera.zoom;
  //   final double newZoom = currentZoom - 1.0;
  //   mapController.move(mapController.camera.center, newZoom);
  // }

  void _onRouteStarted() {
    setState(() {
      _isRouteActive = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {

        if (!state.isRouteBuilt && _isRouteActive) {
          setState(() {
            _isRouteActive = false;
          });
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          // print('HomePage build - isRouteBuilt: ${state.isRouteBuilt}, routeCoordinates: ${state.routeCoordinates?.length}');

          if (state.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Ошибка загрузки данных',
                      style: AppTextStyles.error(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.error!,
                      style: AppTextStyles.body(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HomeBloc>().add(const LoadMainData());
                      },
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // Показываем сообщение, если места не загрузились
          if (!state.isLoading && state.places.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Места не найдены',
                      style: AppTextStyles.title(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Сервер вернул пустой список мест.\nПроверьте, что сервер запущен и в базе данных есть места.',
                      style: AppTextStyles.body(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HomeBloc>().add(const LoadMainData());
                      },
                      child: const Text('Обновить'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            body: Stack(
              children: [
                GestureDetector(
                  onScaleUpdate: (details) {
                    if (details.scale != 1.0) {
                      final double currentZoom = mapController.camera.zoom;
                      final double scaleFactor = details.scale > 1 ? 0.1 : -0.1;
                      final double newZoom = (currentZoom + scaleFactor).clamp(3.0, 18.0);
                      mapController.move(mapController.camera.center, newZoom);
                    }
                  },
                  child: MapWidget(
                    key: ValueKey('map_${state.routeCoordinates?.length ?? 0}_${state.isRouteBuilt}'),
                    mapController: mapController,
                    state: state,
                  ),
                ),

                // Кнопки зума (исправленные - без FloatingActionButton)
                // Positioned(
                //   right: 14.0,
                //   bottom: 500.0,
                //   child: Column(
                //     children: [
                //       Container(
                //         width: 40,
                //         height: 40,
                //         // decoration: BoxDecoration(
                //         //   color: Colors.white,
                //         //   borderRadius: BorderRadius.circular(20),
                //         //   boxShadow: [
                //         //     BoxShadow(
                //         //       color: Colors.black26,
                //         //       blurRadius: 4,
                //         //       offset: const Offset(0, 2),
                //         //     ),
                //         //   ],
                //         // ),
                //       //   child: IconButton(
                //       //     onPressed: _zoomIn,
                //       //     icon: const Icon(Icons.add, color: Colors.teal, size: 20),
                //       //     padding: EdgeInsets.zero,
                //       //   ),
                //       // ),
                //       // const SizedBox(height: 8),
                //       // Container(
                //       //   width: 40,
                //       //   height: 40,
                //       //   decoration: BoxDecoration(
                //       //     color: Colors.white,
                //       //     borderRadius: BorderRadius.circular(20),
                //       //     boxShadow: [
                //       //       BoxShadow(
                //       //         color: Colors.black26,
                //       //         blurRadius: 4,
                //       //         offset: const Offset(0, 2),
                //       //       ),
                //       //     ],
                //       //   ),
                //       //   child: IconButton(
                //       //     onPressed: _zoomOut,
                //       //     icon: const Icon(Icons.remove, color: Colors.teal, size: 20),
                //       //     padding: EdgeInsets.zero,
                //       //   ),
                //       ),
                //     ],
                //   ),
                // ),

                Positioned(
                  top: 67.0,
                  left: 14.0,
                  right: 14.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const MenuPage()),
                          );
                        },
                        child: SmoothContainer(
                          width: 40,
                          height: 40,
                          borderRadius: 10,
                            color: Colors.white,
                          child: Image.asset(
                            'assets/menu.png',
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),

                      InkWell(
                        onTap: () {
                          openBottomSheet(context, (c) => const ProfilePage());
                        },
                        child: SmoothContainer(
                          width: 40,
                          height: 40,
                          borderRadius: 10,
                            color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: SvgPicture.asset(
                              'assets/user.svg',
                              width: 16,
                              height: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (!state.isRouteBuilt && !_isRouteActive)
                  // Positioned(
                  //   bottom: 0.0,
                  //   left: 0.0,
                  //   right: 0.0,
                  //   child: Column(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       Padding(
                  //         padding: const EdgeInsets.all(14),
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //           crossAxisAlignment: CrossAxisAlignment.end,
                  //           children: [
                  //             SelectRegionWidget(
                  //               selectedRegion: _selectedRegion,
                  //               onTap: _onRegionSelected,
                  //             ),
                  //             GetCurrentLocationWidget(moveFunc: () => _moveMapToMyLocation(state.myLocation)),
                  //           ],
                  //         ),
                  //       ),
                  //       const HomeBottomSheetWidget(),
                  //     ],
                  //   ),
                  // ),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SelectRegionWidget(
                                selectedRegion: _selectedRegion,
                                onTap: _onRegionSelected,
                              ),
                              GetCurrentLocationWidget(
                                moveFunc: () => _moveMapToMyLocation(state.myLocation),
                                myLocation: state.myLocation,
                                mapController: mapController,
                              ),
                            ],
                          ),
                        ),
                        const HomeBottomSheetWidget(),
                      ],
                    ),
                  ),

                // Детали места показываются только если маршрут не построен И маршрут не активен
                if (state.showPlaceDetails && state.selectedPlace != null && !state.isRouteBuilt && !_isRouteActive)
                  PlaceDetailsSheet(place: state.selectedPlace!),

                // Информация о маршруте показывается когда маршрут построен И маршрут не активен
                if (state.isRouteBuilt && !_isRouteActive)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: RouteInfoSheet(
                      onRouteStarted: _onRouteStarted,
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
//
// class GetCurrentLocationWidget extends StatelessWidget {
//   final Function moveFunc;
//
//   const GetCurrentLocationWidget({
//     super.key,
//     required this.moveFunc,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.center,
//       child: Container(
//         width: 54,
//         height: 54,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           shape: BoxShape.circle,
//         ),
//         child: InkWell(
//           onTap: () {
//             moveFunc();
//           },
//           borderRadius: BorderRadius.circular(27),
//           child: Center(
//             child: SvgPicture.asset(
//               'assets/locate.svg',
//               width: 19,
//               height: 21,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// class GetCurrentLocationWidget extends StatelessWidget {
//   final Function moveFunc;
//   final LatLng? myLocation;
//   final MapController mapController;
//
//   const GetCurrentLocationWidget({
//     super.key,
//     required this.moveFunc,
//     required this.myLocation,
//     required this.mapController,
//   });
//
//   bool _isUserLocationVisible() {
//     if (myLocation == null) return false;
//
//     final bounds = mapController.camera.visibleBounds;
//     return bounds.contains(myLocation!);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isVisible = _isUserLocationVisible();
//
//     return Align(
//       alignment: Alignment.center,
//       child: Container(
//         width: 54,
//         height: 54,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           shape: BoxShape.circle,
//         ),
//         child: InkWell(
//           onTap: () {
//             moveFunc();
//           },
//           borderRadius: BorderRadius.circular(27),
//           child: Center(
//             child: SvgPicture.asset(
//               isVisible ? 'assets/locatehere.svg' : 'assets/locate.svg',
//               width: 19,
//               height: 21,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class GetCurrentLocationWidget extends StatefulWidget {
  final Function moveFunc;
  final LatLng? myLocation;
  final MapController mapController;

  const GetCurrentLocationWidget({
    super.key,
    required this.moveFunc,
    required this.myLocation,
    required this.mapController,
  });

  @override
  State<GetCurrentLocationWidget> createState() => _GetCurrentLocationWidgetState();
}

class _GetCurrentLocationWidgetState extends State<GetCurrentLocationWidget> {
  bool _isVisible = false;
  bool _isAnimating = false;
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    // Слушаем события карты
    widget.mapController.mapEventStream.listen(_handleMapEvent);
    _updateVisibility();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  void _handleMapEvent(MapEvent event) {
    if (event is MapEventMove || event is MapEventRotate || event is MapEventFlingAnimation) {
      _updateVisibility();
    }
  }

  void _updateVisibility() {
    if (widget.myLocation == null) {
      if (_isVisible) {
        setState(() => _isVisible = false);
      }
      return;
    }

    final bounds = widget.mapController.camera.visibleBounds;
    final newVisibility = bounds.contains(widget.myLocation!);

    if (newVisibility != _isVisible) {
      setState(() => _isVisible = newVisibility);
    }
  }

  void _onTap() {
    // Вызываем функцию перемещения
    widget.moveFunc();

    // Показываем анимацию на 5 секунд
    setState(() {
      _isAnimating = true;
    });

    _animationTimer?.cancel();
    _animationTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(GetCurrentLocationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.myLocation != oldWidget.myLocation) {
      _updateVisibility();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Определяем какая иконка должна отображаться
    final String assetPath;
    if (_isAnimating) {
      // Во время анимации показываем locatehere.svg
      assetPath = 'assets/locatehere.svg';
    } else {
      // В обычном состоянии показываем в зависимости от видимости
      assetPath = _isVisible ? 'assets/locatehere.svg' : 'assets/locate.svg';
    }

    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: InkWell(
          onTap: _onTap,
          borderRadius: BorderRadius.circular(27),
          child: Center(
            child: SvgPicture.asset(
              assetPath,
              width: 19,
              height: 21,
            ),
          ),
        ),
      ),
    );
  }
}

class SelectRegionWidget extends StatelessWidget {
  const SelectRegionWidget({
    super.key,
    required this.selectedRegion,
    required this.onTap,
  });

  final String selectedRegion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SmoothContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        height: 35,
        borderRadius: 20.0,
          color: Colors.teal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/location.svg',
              width: 16,
              height: 16,
            ),
            const SizedBox(width: 5),
            Text(
              selectedRegion,
              style: AppTextStyles.body(
                color: Colors.white,
                fontWeight: AppDesignSystem.fontWeightMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}