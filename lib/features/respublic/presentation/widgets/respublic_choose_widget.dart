import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../../../../shared/data/datasources/republics_data_source.dart';
import '../../../../shared/domain/entities/republic.dart';
import '../../../../services/republic_service.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/widgets/widgets.dart';

class ChooseRespublicWidget extends StatefulWidget {
  final ScrollController scrollController;

  const ChooseRespublicWidget({
    super.key,
    required this.scrollController,
  });

  @override
  State<ChooseRespublicWidget> createState() => _ChooseRespublicWidgetState();
}

class _ChooseRespublicWidgetState extends State<ChooseRespublicWidget> {
  String? _selectedRepublic;
  bool _isLoading = true;
  List<Republic> _republics = [];

  @override
  void initState() {
    super.initState();
    _republics = RepublicsDataSource.getAllRepublics();
    _loadSelectedRepublic();

    // Устанавливаем светлый status bar при открытии
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    // Восстанавливаем темный status bar при закрытии
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    super.dispose();
  }

  Future<void> _loadSelectedRepublic() async {
    final selected = await RepublicService.getSelectedRepublic();
    if (mounted) {
      setState(() {
        _selectedRepublic = selected;
        _isLoading = false;
      });
    }
  }

  void _onRepublicSelected(String republicName, bool available) {
    if (!available) {
      return;
    }

    setState(() {
      _selectedRepublic = republicName;
    });
  }

  void _onCancel() {
    Navigator.of(context).pop();
  }

  Future<void> _onSave() async {
    if (_selectedRepublic != null) {
      await RepublicService.saveSelectedRepublic(_selectedRepublic!);
      if (mounted) {
        Navigator.of(context).pop(_selectedRepublic);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Выберите республику для сохранения',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildRepublicImage(String imagePath) {
    return Image.asset(
      imagePath,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppDesignSystem.greyLight,
          child: Center(
            child: Icon(
              Icons.image_not_supported,
              size: 32,
              color: AppDesignSystem.handleBarColor,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок с единым стилем
        Container(
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Индикатор перетаскивания
              Center(
                child: DragIndicator(
                  color: AppDesignSystem.handleBarColor,
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 10),

              // Заголовок с padding vertical 16px
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Выбор республики',
                    style: GoogleFonts.inter(
                      color: AppDesignSystem.textColorPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
            controller: widget.scrollController,
            physics: const NeverScrollableScrollPhysics(), // Отключаем скроллинг
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Всегда 3 колонки
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 1.0, // Квадратные блоки
            ),
            itemCount: _republics.length,
            itemBuilder: (context, index) {
              final republic = _republics[index];
              final isSelected = _selectedRepublic == republic.name;

              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: isSelected
                        ? AppDesignSystem.primaryColor.withOpacity(0.1)
                        : AppDesignSystem.greyLight,
                    child: ClipRect(
                      child: GestureDetector(
                        onTap: () => _onRepublicSelected(
                          republic.name,
                          republic.isAvailable,
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Transform.scale(
                                scale: 1.02,
                                child: ClipPath(
                                  clipper: SmoothBorderClipper(radius: 12),
                                  child: _buildRepublicImage(republic.imagePath),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                republic.name,
                                style: GoogleFonts.inter(
                                  color: isSelected
                                      ? AppDesignSystem.primaryColor
                                      : AppDesignSystem.textColorPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.20,
                                ),
                                textAlign: TextAlign.left,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!republic.isAvailable)
                    Positioned(
                      left: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppDesignSystem.primaryColor,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Text(
                          'Скоро',
                          style: GoogleFonts.inter(
                            color: AppDesignSystem.textColorWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.20,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        BottomActionBar(
          onCancel: _onCancel,
          onConfirm: _onSave,
          cancelText: 'Отменить',
          confirmText: 'Сохранить',
        ),
      ],
    );
  }
}