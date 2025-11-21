import 'package:flutter/material.dart';

/// Индикатор карусели изображений
/// Показывает текущую позицию в галерее
class ImageCarouselIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  
  const ImageCarouselIndicator({
    super.key,
    required this.itemCount,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Не показываем индикатор если только одно изображение
    if (itemCount <= 1) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF), // rgba(255,255,255,0.2)
        borderRadius: BorderRadius.circular(26),
        // Размытие фона
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(itemCount, (index) {
          final isActive = index == currentIndex;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: isActive ? 14 : 4,
            height: 4,
            decoration: BoxDecoration(
              color: isActive 
                  ? Colors.white 
                  : const Color(0x99FFFFFF), // rgba(255,255,255,0.6)
              borderRadius: BorderRadius.circular(17),
            ),
          );
        }),
      ),
    );
  }
}

