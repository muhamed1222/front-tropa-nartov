import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tropanartov/features/home/presentation/bloc/home_bloc.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/injection_container.dart' as di;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tropanartov/features/places/presentation/widgets/places_main_widget.dart';

import '../../../../core/helpers/open_bottom_sheet.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../../../favourites/presentation/widgets/favourites_widget.dart';
import '../../../favourites/presentation/bloc/favourites_bloc.dart';
import '../../../respublic/presentation/widgets/respublic_about_widget.dart';
import '../../../routes/widgets/routes_main_widget.dart';
import '../../../routes/presentation/bloc/routes_bloc.dart';

class HomeBottomSheetWidget extends StatefulWidget {
  const HomeBottomSheetWidget({
    super.key,
  });

  @override
  State<HomeBottomSheetWidget> createState() => _HomeBottomSheetWidgetState();
}

class _HomeBottomSheetWidgetState extends State<HomeBottomSheetWidget> {
  final TextEditingController _searchController = TextEditingController();

  static const List<Map<String, dynamic>> menuItems = [
    {
      'title': 'Маршруты',
      'icon': 'assets/map.svg', // Убедитесь что файлы в корне assets/
      'route': '/routes',
    },
    {'title': 'Места', 'icon': 'assets/place.svg', 'route': '/places'},
    {'title': 'О республике', 'icon': 'assets/book.svg', 'route': '/about'},
  ];

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      // Получаем HomeBloc из текущего контекста
      HomeBloc? homeBloc;
      try {
        homeBloc = context.read<HomeBloc>();
      } catch (e) {
        // Если HomeBloc недоступен, ничего не делаем
      }

      openBottomSheet(
        context,
        (c) => PlacesMainWidget(
          scrollController: c,
          initialSearchQuery: query.trim(),
          homeBloc: homeBloc, // Передаем HomeBloc явно
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFC0C0C0).withValues(alpha: 0.10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC0C0C0).withValues(alpha: 0.10),
            offset: const Offset(0, -2),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.only(left: 14, right: 14, top: 14, bottom: 44),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SearchWidget(
                  controller: _searchController,
                  onSubmitted: _onSearchSubmitted,
                ),
                SizedBox(width: 8), // Исправлено: spacing -> SizedBox
                FavoritesWidget(),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MenuItemWidget(item: menuItems[0]),
                ),
                SizedBox(width: 8), // Отступ 8px между кнопками
                Expanded(
                  child: MenuItemWidget(item: menuItems[1]),
                ),
                SizedBox(width: 8), // Отступ 8px между кнопками
                Expanded(
                  child: MenuItemWidget(item: menuItems[2]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Пункт меню
class MenuItemWidget extends StatelessWidget {
  final Map<String, dynamic> item;

  const MenuItemWidget({
    required this.item,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (item['route'] == '/places') {
            // Получаем HomeBloc из текущего контекста
            HomeBloc? homeBloc;
            try {
              homeBloc = context.read<HomeBloc>();
            } catch (e) {
              // Если HomeBloc недоступен, ничего не делаем
            }
            
            openBottomSheet(context, (c) => PlacesMainWidget(
              scrollController: c,
              homeBloc: homeBloc, // Передаем HomeBloc явно
            ));
            return;
          }
          if (item['route'] == '/routes') {
            openBottomSheet(
              context,
              (ScrollController scrollController) {
                return BlocProvider(
                  create: (BuildContext context) {
                    final bloc = di.sl<RoutesBloc>();
                    bloc.add(const LoadRoutes(forceRefresh: false)); // Используем кеш при первом открытии
                    return bloc;
                  },
                  child: RoutesMainWidget(scrollController: scrollController),
                );
              },
            );
            return;
          }
          if (item['route'] == '/about') {
            openBottomSheet(context, (c) => AboutRespublicWidget(scrollController: c));
            return;
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: SmoothContainer(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          borderRadius: 12,
          color: Color(0xFFF6F6F6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                item['icon'],
                width: 24,
                height: 24,
                colorFilter: null,
                placeholderBuilder: (context) => Icon(Icons.image, size: 24),
              ),
              SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item['title'],
                  style: AppTextStyles.small(
                    color: AppDesignSystem.textColorPrimary,
                    letterSpacing: -0.28,
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

// Кнопка "Избранное"
class FavoritesWidget extends StatelessWidget {
  const FavoritesWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Получаем HomeBloc из текущего контекста
          HomeBloc? homeBloc;
          try {
            homeBloc = context.read<HomeBloc>();
          } catch (e) {
            // Если HomeBloc недоступен, ничего не делаем
          }
          
          openBottomSheet(
            context,
            (ScrollController scrollController) {
              return BlocProvider(
                create: (BuildContext context) {
                  final bloc = di.sl<FavouritesBloc>();
                  bloc.add(const LoadFavoritePlaces(forceRefresh: false)); // Используем кеш при первом открытии
                  bloc.add(const LoadFavoriteRoutes(forceRefresh: false));
                  return bloc;
                },
                child: FavouritesWidget(
                  scrollController: scrollController,
                  homeBloc: homeBloc, // Передаем HomeBloc явно
                ),
              );
            },
          );
        },
        customBorder: CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF24A79C).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/favorite.svg',
                width: 20,
                height: 20,
                colorFilter: null,
                placeholderBuilder: (context) => Icon(Icons.favorite_border, size: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Строка поиска
class SearchWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  const SearchWidget({
    required this.controller,
    required this.onSubmitted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 44,
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.text,
          onSubmitted: onSubmitted,
          style: AppTextStyles.small(
            color: AppDesignSystem.textColorPrimary,
            letterSpacing: -0.28,
          ),
          decoration: InputDecoration(
            hintText: 'Поиск маршрутов и мест',
            hintStyle: AppTextStyles.body(
              color: AppDesignSystem.textColorTertiary,
            ),
            filled: true,
            fillColor: Color.fromRGBO(246, 246, 246, 1),
            contentPadding: const EdgeInsets.only(left: 0, right: 4, top: 12, bottom: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 6),
              child: SvgPicture.asset(
                'assets/lupa.svg',
                width: 20,
                height: 20,
                colorFilter: null,
                placeholderBuilder: (context) => Icon(Icons.search, size: 20),
              ),
            ),
            prefixIconConstraints: BoxConstraints(
              minWidth: 40,
              minHeight: 20,
            ),
          ),
        ),
      ),
    );
  }
}
