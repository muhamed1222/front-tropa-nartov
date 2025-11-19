import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tropanartov/features/home/domain/entities/place.dart';
import 'package:tropanartov/services/api_service.dart';
import 'package:tropanartov/services/auth_service.dart';
import '../../../../utils/smooth_border_radius.dart';
import '../../../../core/constants/app_design_system.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';

/// Диалоговое окно для оценки места
class RatingDialog extends StatefulWidget {
  final Place place;
  final VoidCallback? onReviewAdded;

  const RatingDialog({super.key, required this.place, this.onReviewAdded});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  void _showRatingDialog() {
    int selectedStars = 1;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {

            // Функция для закрытия диалога и сброса значений
            void closeDialog() {
              Navigator.of(context).pop();
              _resetDialogValues();
            }

            // Функция для отправки отзыва
            void submitRating() async {
              final token = await AuthService.getToken();
              if (token == null) {
                if (context.mounted) {
                  AppSnackBar.showError(context, 'Необходимо авторизоваться');
                }
                return;
              }

              setDialogState(() {
                _isSubmitting = true;
              });

              try {
                await ApiService.addReview(
                  placeId: widget.place.id,
                  text: _reviewController.text.isNotEmpty ? _reviewController.text : 'Без комментария',
                  rating: selectedStars,
                  token: token,
                );

                if (mounted && context.mounted) {
                  Navigator.of(context).pop();
                  _showThankYouDialog();
                  widget.onReviewAdded?.call();
                }
              } catch (e) {
                if (mounted && context.mounted) {
                  AppSnackBar.showError(context, 'Ошибка отправки отзыва: $e');
                }
              } finally {
                if (mounted) {
                  setDialogState(() {
                    _isSubmitting = false;
                  });
                }
              }
            }

            return Material(
              type: MaterialType.transparency,
              child: Stack(
                children: [
                  // Размытый и затемненный фон НА ВЕСЬ ЭКРАН
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),

                  // Центрируем диалоговое окно
                  Center(
                    child: SingleChildScrollView(
                      child: SmoothContainer(
                        width: AppDesignSystem.dialogWidth,
                        padding: const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
                        borderRadius: AppDesignSystem.borderRadiusLarge,
                        color: AppDesignSystem.backgroundColor,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Текст "Оценить"
                            Padding(
                              padding: const EdgeInsets.only(right: AppDesignSystem.paddingHorizontal),
                              child: Text(
                                'Оценить место',
                                style: AppTextStyles.title(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: AppDesignSystem.spacingXLarge),

                            // Метка места (как на карте)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Основная рамка с изображением
                                Container(
                                  width: 80.0,
                                  height: 80.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppDesignSystem.primaryColor, width: 3.0),
                                    boxShadow: [BoxShadow(color: AppDesignSystem.blackColor.withValues(alpha: 0.2), blurRadius: 8.0, offset: const Offset(0, 4))],
                                  ),
                                  child: ClipOval(
                                    child: Stack(
                                      children: [
                                        // Изображение из данных
                                        widget.place.images.isNotEmpty
                                            ? Image.network(
                                                widget.place.images.first.url,
                                                width: 80.0,
                                                height: 80.0,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    width: 80.0,
                                                    height: 80.0,
                                                    color: AppDesignSystem.greyLight,
                                                    child: Icon(Icons.image_not_supported, color: AppDesignSystem.greyMedium, size: 30.0),
                                            );
                                          },
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Container(
                                              width: 80.0,
                                              height: 80.0,
                                              color: AppDesignSystem.greyLight,
                                              child: Center(child: CircularProgressIndicator(color: AppDesignSystem.primaryColor, strokeWidth: 2.0)),
                                            );
                                          },
                                        )
                                            : Container(
                                                width: 80.0,
                                                height: 80.0,
                                                color: AppDesignSystem.greyLight,
                                                child: Icon(Icons.image_not_supported, color: AppDesignSystem.greyMedium, size: 30.0),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Стрелочка вниз
                                CustomPaint(size: const Size(20.0, 14.0), painter: ArrowPainter(color: AppDesignSystem.primaryColor)),
                              ],
                            ),
                            SizedBox(height: AppDesignSystem.spacingLarge),

                            // Название места
                            Text(
                              widget.place.name,
                              style: AppTextStyles.body(),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: AppDesignSystem.spacingXLarge),

                            // Звезды рейтинга
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    setDialogState(() {
                                      selectedStars = index + 1;
                                    });
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    margin: const EdgeInsets.symmetric(horizontal: AppDesignSystem.spacingTiny),
                                    child: Icon(
                                      Icons.star,
                                      color: index < selectedStars
                                          ? const Color(0xFFFFC800)
                                          : AppDesignSystem.backgroundColorSecondary,
                                      size: 32,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height: AppDesignSystem.spacingXLarge),

                            // Текстовое поле для отзыва
                            SmoothContainer(
                              width: 344,
                              height: 140,
                              padding: const EdgeInsets.all(AppDesignSystem.spacingSmall + 2),
                              borderRadius: AppDesignSystem.borderRadiusSmall,
                              border: Border.all(color: AppDesignSystem.greyLight),
                              child: TextField(
                                controller: _reviewController,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Расскажите о своих впечатлениях...',
                                  hintStyle: AppTextStyles.hint(),
                                ),
                                style: AppTextStyles.body(),
                              ),
                            ),
                            SizedBox(height: AppDesignSystem.spacingXLarge),

                            // Кнопки "Отменить" и "Отправить"
                            Row(
                              children: [
                                // Кнопка "Отменить"
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _isSubmitting ? null : closeDialog,
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
                                          'Отменить',
                                          style: AppTextStyles.body(
                                            fontWeight: AppDesignSystem.fontWeightMedium,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: AppDesignSystem.spacingMedium),

                                // Кнопка "Отправить"
                                Expanded(
                                  child: PrimaryButton(
                                    text: 'Отправить',
                                    onPressed: _isSubmitting ? null : submitRating,
                                    isDisabled: _isSubmitting,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Функция для показа окна благодарности
  void _showThankYouDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Размытый фон
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
            // Диалоговое окно благодарности
            Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
              child: Stack(
                children: [
                  SmoothContainer(
                    width: AppDesignSystem.dialogWidth,
                    padding: const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
                    borderRadius: AppDesignSystem.borderRadiusLarge,
                      color: AppDesignSystem.backgroundColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Иконка сердца
                        SvgPicture.asset(
                          'assets/Heart.svg',
                          width: 60,
                          height: 60,
                        ),
                        SizedBox(height: AppDesignSystem.spacingLarge),

                        // Текст "Спасибо за вашу оценку!"
                        Text(
                          'Спасибо за вашу оценку!',
                          style: AppTextStyles.title(),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppDesignSystem.spacingLarge),

                        // Описание
                        Text(
                          'Она поможет другим туристам сделать правильный выбор.',
                          style: AppTextStyles.body(
                            color: AppDesignSystem.textColorTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Кнопка крестика справа сверху
                  Positioned(
                    top: AppDesignSystem.spacingMedium - 2,
                    right: AppDesignSystem.spacingMedium - 2,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        _resetDialogValues();
                      },
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(
                          Icons.close,
                          size: AppDesignSystem.iconSizeSmall,
                          color: AppDesignSystem.textColorPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Функция для сброса значений диалога
  void _resetDialogValues() {
    _reviewController.clear();
    _isSubmitting = false;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showRatingDialog,
      child: SmoothContainer(
        padding: const EdgeInsets.symmetric(horizontal: AppDesignSystem.paddingHorizontal, vertical: AppDesignSystem.paddingVerticalMedium),
        borderRadius: AppDesignSystem.borderRadius,
          color: AppDesignSystem.backgroundColor,
          border: Border.all(color: AppDesignSystem.primaryColor),
        child: Text(
          'Оценить',
          style: AppTextStyles.body(
            color: AppDesignSystem.primaryColor,
            fontWeight: AppDesignSystem.fontWeightMedium,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}

// Стрелочка под кружочком (аналогичная из PlaceMarkerWidget)
class ArrowPainter extends CustomPainter {
  final Color color;

  ArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
    Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final ui.Path path = ui.Path();

    // Рисуем треугольную стрелочку (поднята на 2 пикселя)
    path.moveTo(size.width / 2, size.height - 2); // Нижняя точка (острие стрелки) поднята на 2px
    path.lineTo(0, -2); // Левый верхний угол поднят на 2px
    path.lineTo(size.width, -2); // Правый верхний угол поднят на 2px
    path.close(); // Замыкаем путь

    // Рисуем тень
    final shadowPaint =
    Paint()
      ..color = AppDesignSystem.blackColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    canvas.save();
    canvas.translate(1.0, 1.0); // Смещение для тени
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Рисуем основную стрелочку
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}