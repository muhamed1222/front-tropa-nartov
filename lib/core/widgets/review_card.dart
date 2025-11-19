import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/svg.dart';
import '../constants/app_design_system.dart';
import 'package:tropanartov/models/api_models.dart';

/// Карточка отзыва
/// Используется для отображения отзывов пользователей о местах
class ReviewCard extends StatefulWidget {
  final Review review;
  final int maxLines;
  final VoidCallback? onExpandTap;

  const ReviewCard({
    super.key,
    required this.review,
    this.maxLines = 3,
    this.onExpandTap,
  });

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool _isExpanded = false;

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      // Формат: дд.мм.гг (например, 12.03.25)
      final year = date.year.toString().substring(2); // Берем последние 2 цифры года
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.$year';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowExpand = widget.review.text.length > 100 && !_isExpanded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10.0), // По дизайну из Figma
      decoration: BoxDecoration(
        color: AppDesignSystem.backgroundColorSecondary, // #f6f6f6
        borderRadius: BorderRadius.circular(16.0), // По дизайну из Figma
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Верхняя часть: имя и рейтинг
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Имя пользователя
                  Text(
                    widget.review.authorName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppDesignSystem.textColorPrimary,
                      height: 1.2,
                    ),
                  ),
                  // Рейтинг со звездой
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/star.svg',
                        width: 14.0,
                        height: 13.0,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        widget.review.rating.toString(),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppDesignSystem.textColorPrimary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              // Текст отзыва
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.review.text,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppDesignSystem.textColorPrimary,
                      height: 1.2,
                    ),
                    maxLines: _isExpanded ? null : widget.maxLines,
                    overflow: _isExpanded ? null : TextOverflow.ellipsis,
                  ),
                  if (shouldShowExpand) ...[
                    const SizedBox(height: 8.0),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = true;
                        });
                        widget.onExpandTap?.call();
                      },
                      child: Text(
                        'Развернуть',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppDesignSystem.textColorSecondary.withValues(alpha: 0.6),
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          // Дата
          Text(
            _formatDate(widget.review.createdAt),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppDesignSystem.textColorSecondary.withValues(alpha: 0.4),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

