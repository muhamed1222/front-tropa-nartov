import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';

/// Заголовок секции
/// Используется для заголовков разделов в приложении
class SectionTitle extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;

  const SectionTitle({
    super.key,
    required this.text,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign ?? TextAlign.center,
      style: AppTextStyles.title(),
    );
  }
}

