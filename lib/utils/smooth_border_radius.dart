import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

/// Глобальное значение corner smoothing по умолчанию
/// ИДЕАЛЬНОЕ ЗНАЧЕНИЕ: 0.65
/// Измените это значение, чтобы настроить smoothing для всех элементов
/// Диапазон: 0.0 - 1.0 (где 1.0 = обычное скругление, 0.0 = максимальное сглаживание)
const double defaultCornerSmoothing = 0.70;

/// CustomClipper для создания плавных скругленных углов с corner smoothing
class SmoothBorderClipper extends CustomClipper<Path> {
  final double radius;
  final double smoothing;

  SmoothBorderClipper({
    required this.radius,
    this.smoothing = defaultCornerSmoothing,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final r = radius;
    final s = smoothing;

    // Вычисляем контрольные точки для плавных углов
    final controlPoint = r * (1 - s);

    // Верхний левый угол
    path.moveTo(r, 0);
    path.lineTo(size.width - r, 0);
    
    // Верхний правый угол
    path.cubicTo(
      size.width - controlPoint,
      0,
      size.width,
      controlPoint,
      size.width,
      r,
    );
    path.lineTo(size.width, size.height - r);
    
    // Нижний правый угол
    path.cubicTo(
      size.width,
      size.height - controlPoint,
      size.width - controlPoint,
      size.height,
      size.width - r,
      size.height,
    );
    path.lineTo(r, size.height);
    
    // Нижний левый угол
    path.cubicTo(
      controlPoint,
      size.height,
      0,
      size.height - controlPoint,
      0,
      size.height - r,
    );
    path.lineTo(0, r);
    
    // Завершаем верхний левый угол
    path.cubicTo(
      0,
      controlPoint,
      controlPoint,
      0,
      r,
      0,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(SmoothBorderClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.smoothing != smoothing;
  }
}

/// Утилита для создания плавных скругленных контейнеров
class SmoothContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? color;
  final BoxDecoration? decoration;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;
  /// Corner smoothing значение (по умолчанию используется defaultCornerSmoothing)
  /// Диапазон: 0.0 - 1.0
  /// ИДЕАЛЬНОЕ ЗНАЧЕНИЕ: 0.65
  /// Можно переопределить для каждого элемента индивидуально
  final double? smoothing;

  const SmoothContainer({
    super.key,
    required this.child,
    required this.borderRadius,
    this.color,
    this.decoration,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.border,
    this.smoothing,
  });

  @override
  Widget build(BuildContext context) {
    final smoothingValue = smoothing ?? defaultCornerSmoothing;
    
    // Создаем decoration без borderRadius, так как скругление применяется через ClipPath
    BoxDecoration? finalDecoration;
    if (decoration != null) {
      finalDecoration = BoxDecoration(
        color: decoration!.color ?? color,
        image: decoration!.image,
        gradient: decoration!.gradient,
        boxShadow: decoration!.boxShadow,
        shape: decoration!.shape,
        border: decoration!.border,
      );
    } else if (color != null) {
      finalDecoration = BoxDecoration(color: color);
    }
    
    Widget content = ClipPath(
      clipper: SmoothBorderClipper(
        radius: borderRadius,
        smoothing: smoothingValue,
      ),
      child: Container(
        width: width,
        height: height,
        decoration: finalDecoration,
        padding: padding,
        child: child,
      ),
    );

    if (border != null) {
      content = CustomPaint(
        painter: SmoothBorderPainter(
          radius: borderRadius,
          border: border!,
          smoothing: smoothingValue,
        ),
        child: content,
      );
    }

    if (margin != null) {
      content = Padding(
        padding: margin!,
        child: content,
      );
    }

    return content;
  }
}

/// CustomPainter для отрисовки плавных границ
class SmoothBorderPainter extends CustomPainter {
  final double radius;
  final Border border;
  final double smoothing;

  SmoothBorderPainter({
    required this.radius,
    required this.border,
    this.smoothing = defaultCornerSmoothing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderWidth = border.top.width;
    if (borderWidth <= 0) return;

    final paint = Paint()
      ..color = border.top.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = _createSmoothPath(size);
    canvas.drawPath(path, paint);
  }

  Path _createSmoothPath(Size size) {
    final path = Path();
    final r = radius;
    final s = smoothing;
    final controlPoint = r * (1 - s);

    path.moveTo(r, 0);
    path.lineTo(size.width - r, 0);
    
    path.cubicTo(
      size.width - controlPoint,
      0,
      size.width,
      controlPoint,
      size.width,
      r,
    );
    path.lineTo(size.width, size.height - r);
    
    path.cubicTo(
      size.width,
      size.height - controlPoint,
      size.width - controlPoint,
      size.height,
      size.width - r,
      size.height,
    );
    path.lineTo(r, size.height);
    
    path.cubicTo(
      controlPoint,
      size.height,
      0,
      size.height - controlPoint,
      0,
      size.height - r,
    );
    path.lineTo(0, r);
    
    path.cubicTo(
      0,
      controlPoint,
      controlPoint,
      0,
      r,
      0,
    );

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(SmoothBorderPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.border != border ||
        oldDelegate.smoothing != smoothing;
  }
}

/// InputBorder для TextField с плавными скругленными углами
class SmoothOutlineInputBorder extends InputBorder {
  final double borderRadius;
  final double smoothing;
  final BorderSide borderSide;
  final BorderSide? gapPadding;

  const SmoothOutlineInputBorder({
    this.borderRadius = 12.0,
    this.smoothing = defaultCornerSmoothing,
    this.borderSide = const BorderSide(),
    this.gapPadding,
  }) : super(borderSide: borderSide);

  @override
  SmoothOutlineInputBorder copyWith({
    BorderSide? borderSide,
    double? borderRadius,
    double? smoothing,
    InputBorder? gapBorder,
    double? gapPadding,
  }) {
    return SmoothOutlineInputBorder(
      borderSide: borderSide ?? this.borderSide,
      borderRadius: borderRadius ?? this.borderRadius,
      smoothing: smoothing ?? this.smoothing,
      gapPadding: gapPadding != null ? BorderSide(width: gapPadding) : this.gapPadding,
    );
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderSide.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _createSmoothPath(rect.deflate(borderSide.width), borderRadius, smoothing);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _createSmoothPath(rect, borderRadius, smoothing);
  }

  Path _createSmoothPath(Rect rect, double radius, double smoothing) {
    final path = Path();
    final r = radius;
    final s = smoothing;
    final controlPoint = r * (1 - s);

    // Верхний левый угол
    path.moveTo(rect.left + r, rect.top);
    path.lineTo(rect.right - r, rect.top);
    
    // Верхний правый угол
    path.cubicTo(
      rect.right - controlPoint,
      rect.top,
      rect.right,
      rect.top + controlPoint,
      rect.right,
      rect.top + r,
    );
    path.lineTo(rect.right, rect.bottom - r);
    
    // Нижний правый угол
    path.cubicTo(
      rect.right,
      rect.bottom - controlPoint,
      rect.right - controlPoint,
      rect.bottom,
      rect.right - r,
      rect.bottom,
    );
    path.lineTo(rect.left + r, rect.bottom);
    
    // Нижний левый угол
    path.cubicTo(
      rect.left + controlPoint,
      rect.bottom,
      rect.left,
      rect.bottom - controlPoint,
      rect.left,
      rect.bottom - r,
    );
    path.lineTo(rect.left, rect.top + r);
    
    // Завершаем верхний левый угол
    path.cubicTo(
      rect.left,
      rect.top + controlPoint,
      rect.left + controlPoint,
      rect.top,
      rect.left + r,
      rect.top,
    );

    path.close();
    return path;
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    if (borderSide.style == BorderStyle.none) return;

    final paint = borderSide.toPaint();
    final path = getOuterPath(rect, textDirection: textDirection);
    canvas.drawPath(path, paint);
  }

  @override
  bool get isOutline => true;

  @override
  ShapeBorder scale(double t) {
    return SmoothOutlineInputBorder(
      borderRadius: borderRadius * t,
      smoothing: smoothing,
      borderSide: borderSide.scale(t),
      gapPadding: gapPadding?.scale(t),
    );
  }
}

/// ShapeBorder для Material кнопок с плавными скругленными углами
class SmoothRoundedRectangleBorder extends OutlinedBorder {
  final double borderRadius;
  final double smoothing;

  const SmoothRoundedRectangleBorder({
    this.borderRadius = 12.0,
    this.smoothing = defaultCornerSmoothing,
    super.side,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _createSmoothPath(rect.deflate(side.width), borderRadius, smoothing);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _createSmoothPath(rect, borderRadius, smoothing);
  }

  Path _createSmoothPath(Rect rect, double radius, double smoothing) {
    final path = Path();
    final r = radius;
    final s = smoothing;
    final controlPoint = r * (1 - s);

    // Верхний левый угол
    path.moveTo(rect.left + r, rect.top);
    path.lineTo(rect.right - r, rect.top);
    
    // Верхний правый угол
    path.cubicTo(
      rect.right - controlPoint,
      rect.top,
      rect.right,
      rect.top + controlPoint,
      rect.right,
      rect.top + r,
    );
    path.lineTo(rect.right, rect.bottom - r);
    
    // Нижний правый угол
    path.cubicTo(
      rect.right,
      rect.bottom - controlPoint,
      rect.right - controlPoint,
      rect.bottom,
      rect.right - r,
      rect.bottom,
    );
    path.lineTo(rect.left + r, rect.bottom);
    
    // Нижний левый угол
    path.cubicTo(
      rect.left + controlPoint,
      rect.bottom,
      rect.left,
      rect.bottom - controlPoint,
      rect.left,
      rect.bottom - r,
    );
    path.lineTo(rect.left, rect.top + r);
    
    // Завершаем верхний левый угол
    path.cubicTo(
      rect.left,
      rect.top + controlPoint,
      rect.left + controlPoint,
      rect.top,
      rect.left + r,
      rect.top,
    );

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none) return;
    
    final paint = side.toPaint();
    final path = getOuterPath(rect, textDirection: textDirection);
    canvas.drawPath(path, paint);
  }

  @override
  SmoothRoundedRectangleBorder copyWith({
    BorderSide? side,
    double? borderRadius,
    double? smoothing,
  }) {
    return SmoothRoundedRectangleBorder(
      side: side ?? this.side,
      borderRadius: borderRadius ?? this.borderRadius,
      smoothing: smoothing ?? this.smoothing,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return SmoothRoundedRectangleBorder(
      borderRadius: borderRadius * t,
      smoothing: smoothing,
      side: side.scale(t),
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is SmoothRoundedRectangleBorder) {
      return SmoothRoundedRectangleBorder(
        borderRadius: lerpDouble(a.borderRadius, borderRadius, t) ?? borderRadius,
        smoothing: lerpDouble(a.smoothing, smoothing, t) ?? smoothing,
        side: BorderSide.lerp(a.side, side, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is SmoothRoundedRectangleBorder) {
      return SmoothRoundedRectangleBorder(
        borderRadius: lerpDouble(borderRadius, b.borderRadius, t) ?? borderRadius,
        smoothing: lerpDouble(smoothing, b.smoothing, t) ?? smoothing,
        side: BorderSide.lerp(side, b.side, t),
      );
    }
    return super.lerpTo(b, t);
  }
}

