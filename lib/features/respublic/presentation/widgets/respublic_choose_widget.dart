import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
    // Загружаем выбранную республику синхронно, чтобы избежать лишних перерисовок
    _loadSelectedRepublicSync();

    // Устанавливаем светлый status bar при открытии
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  // Синхронная загрузка выбранной республики
  void _loadSelectedRepublicSync() async {
    final selected = await RepublicService.getSelectedRepublic();
    if (mounted) {
      // Устанавливаем значения и вызываем setState один раз
      setState(() {
        _selectedRepublic = selected;
        _isLoading = false;
      });
    }
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
    return RepaintBoundary(
      child: Image.asset(
      imagePath,
      width: double.infinity,
      fit: BoxFit.cover,
        cacheWidth: 300, // Кешируем изображения для оптимизации
        cacheHeight: 300,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
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
                : RepaintBoundary(
                    child: GridView.builder(
            controller: widget.scrollController,
            physics: const BouncingScrollPhysics(), // Включаем скроллинг
            padding: EdgeInsets.zero,
            addAutomaticKeepAlives: false, // Отключаем автоматическое сохранение состояния
            addRepaintBoundaries: true, // Добавляем границы перерисовки
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

              return _RepublicCard(
                key: ValueKey(republic.name),
                republic: republic,
                isSelected: isSelected,
                onTap: () => _onRepublicSelected(
                  republic.name,
                  republic.isAvailable,
                ),
                imageBuilder: _buildRepublicImage,
              );
            },
                  ),
                ),
          ),
          BottomActionBar(
            onCancel: _onCancel,
            onConfirm: _onSave,
            cancelText: 'Отменить',
            confirmText: 'Сохранить',
          ),
        ],
      ),
    );
  }
}

// Отдельный виджет для карточки республики для оптимизации перерисовок
class _RepublicCard extends StatelessWidget {
  final Republic republic;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget Function(String) imageBuilder;

  const _RepublicCard({
    super.key,
    required this.republic,
    required this.isSelected,
    required this.onTap,
    required this.imageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
            decoration: BoxDecoration(
                    color: isSelected
                  ? AppDesignSystem.primaryColor.withValues(alpha: 0.1)
                        : AppDesignSystem.greyLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
                      child: GestureDetector(
                onTap: onTap,
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Transform.scale(
                                scale: 1.02,
                        child: imageBuilder(republic.imagePath),
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
      ),
    );
  }
}