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

  /// Статический метод для показа диалога оценки
  static void show(BuildContext context, Place place, {VoidCallback? onReviewAdded}) {
    // Создаем экземпляр виджета для доступа к контроллеру и методам
    final key = GlobalKey<_RatingDialogState>();
    BuildContext? dialogContext;
    
    // Получаем root Navigator и его overlay context для открытия диалога поверх bottom sheet
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final rootContext = rootNavigator.overlay?.context ?? context;
    
    final ratingDialog = RatingDialog(
      key: key,
      place: place,
      onReviewAdded: onReviewAdded,
    );
    
    // Временно показываем виджет в диалоге, чтобы получить доступ к состоянию
    // Этот диалог будет сразу закрыт, когда покажется форма оценки
    // Используем rootNavigator: true, чтобы диалог открывался поверх bottom sheet
    final Future<dynamic> intermediateDialogFuture = showDialog(
      context: rootContext, // Используем root context для открытия в root Navigator
      barrierColor: Colors.transparent, // Прозрачный фон, чтобы не было видно промежуточного диалога
      barrierDismissible: false,
      useRootNavigator: true, // Используем root navigator, чтобы диалог был поверх bottom sheet
      builder: (BuildContext buildContext) {
        dialogContext = buildContext; // Сохраняем контекст промежуточного диалога
        return ratingDialog;
      },
    );
    
    // После первого кадра вызываем метод показа формы оценки из состояния
    // и закрываем промежуточный диалог
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (key.currentState != null && key.currentState!.mounted && dialogContext != null) {
        // Закрываем промежуточный диалог используя его собственный контекст
        Navigator.of(dialogContext!, rootNavigator: true).pop();
        // Показываем форму оценки используя root context
        key.currentState!._showRatingDialog(rootContext);
      }
    });
  }
}

class _RatingDialogState extends State<RatingDialog> {
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;
  NavigatorState? _dialogNavigator; // Сохраняем Navigator диалога
  
  @override
  void initState() {
    super.initState();
    // initState не используется для показа формы при использовании через статический метод show
    // Форма показывается напрямую из статического метода после создания виджета
  }

  void _showRatingDialog(BuildContext parentContext) {
    int selectedStars = 1;

    showDialog(
      context: parentContext,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      useRootNavigator: true, // Используем root navigator, чтобы диалог был поверх bottom sheet
      builder: (BuildContext dialogContext) {
        // Сохраняем Navigator диалога для явного управления
        _dialogNavigator = Navigator.of(dialogContext, rootNavigator: true);
        
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {

            // Функция для закрытия диалога и сброса значений
            void closeDialog() {
              if (_dialogNavigator != null && _dialogNavigator!.canPop()) {
                _dialogNavigator!.pop();
                _resetDialogValues();
              }
            }

            // Функция для отправки отзыва
            void submitRating() async {
              debugPrint('submitRating called');
              final token = await AuthService.getToken();
              debugPrint('Token: ${token != null ? "found" : "null"}');
              
              if (token == null) {
                if (dialogContext.mounted) {
                  AppSnackBar.showError(dialogContext, 'Необходимо авторизоваться');
                }
                return;
              }

              setDialogState(() {
                _isSubmitting = true;
              });

              try {
                debugPrint('Sending review...');
                await ApiService.addReview(
                  placeId: widget.place.id,
                  text: _reviewController.text.isNotEmpty ? _reviewController.text : 'Без комментария',
                  rating: selectedStars,
                  token: token,
                );
                debugPrint('Review sent successfully');

                // Не проверяем mounted от RatingDialogState, так как виджет может быть уже размонтирован
                // Проверяем только возможность закрытия диалога через навигатор
                if (_dialogNavigator != null && _dialogNavigator!.canPop()) {
                  debugPrint('Closing dialog and showing thank you');
                  _dialogNavigator!.pop();
                  // Используем parentContext вместо dialogContext, так как диалог уже закрыт
                  _showThankYouDialog(parentContext);
                  widget.onReviewAdded?.call();
                } else {
                  debugPrint('Cannot close dialog: _dialogNavigator is null or cannot pop');
                }
              } catch (e) {
                debugPrint('Error submitting review: $e');
                if (mounted && dialogContext.mounted) {
                  AppSnackBar.showError(dialogContext, 'Ошибка отправки отзыва: $e');
                }
              } finally {
                // Используем dialogContext.mounted или просто setDialogState, если это безопасно
                // В данном случае, если диалог закрывается, setDialogState может вызвать ошибку,
                // поэтому проверяем dialogContext.mounted
                if (dialogContext.mounted) {
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

  /// Функция для показa окна благодарности
  void _showThankYouDialog(BuildContext parentContext) {
    NavigatorState? thankYouNavigator;
    showGeneralDialog(
      context: parentContext,
      barrierColor: Colors.transparent, // Прозрачный барьер, так как у нас свой фон
      barrierDismissible: true, // Можно закрыть кликом мимо
      barrierLabel: 'Закрыть',
      useRootNavigator: true, // Используем root navigator
      transitionDuration: const Duration(milliseconds: 200), // Анимация появления
      pageBuilder: (BuildContext dialogContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        thankYouNavigator = Navigator.of(dialogContext, rootNavigator: true);
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              // Размытый и затемненный фон на весь экран (игнорируя SafeArea)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                ),
              ),
              
              // Контент диалога по центру
              // Оборачиваем в SafeArea, чтобы контент не залезал под челку, но фон оставался на весь экран
              Center(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
                    child: SmoothContainer(
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
                  ),
                ),
              ),
              
              // Прозрачный GestureDetector на фон для закрытия (если barrierDismissible не сработает как ожидается из-за нашего Stack)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (thankYouNavigator != null && thankYouNavigator!.canPop()) {
                      thankYouNavigator!.pop();
                    }
                    _resetDialogValues();
                  },
                  child: const SizedBox.expand(),
                ),
              ),
              // Повторяем контент поверх GestureDetector, чтобы клики по нему не закрывали диалог
              Center(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDesignSystem.paddingHorizontal),
                    child: GestureDetector(
                      onTap: () {}, // Перехватываем клики по самому диалогу
                      child: SmoothContainer(
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
                    ),
                  ),
                ),
              ),
            ],
          ),
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
    // Если виджет используется в showDialog (через статический метод show),
    // показываем пустой виджет, так как форма оценки будет показана из статического метода
    // Проверяем, находимся ли мы в модальном route (диалоге)
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent == false) {
      // Виджет используется в диалоге, возвращаем пустой виджет
      // Форма оценки показывается через _showRatingDialog() из статического метода
      return const SizedBox.shrink();
    }
    
    // Если виджет используется как кнопка (не в диалоге), показываем кнопку
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showRatingDialog(context),
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