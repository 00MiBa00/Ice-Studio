import 'dart:math';
import 'package:flutter/cupertino.dart';

class SquishBallPainter extends CustomPainter {
  final double squishX;
  final double squishY;
  final double rotation;
  final Color baseColor;

  SquishBallPainter({
    required this.squishX,
    required this.squishY,
    required this.rotation,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.scale(squishX, squishY);
    canvas.translate(-center.dx, -center.dy);

    // Shadow
    final shadowPaint = Paint()
      ..color = baseColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(
      center + const Offset(0, 10),
      radius * 0.9,
      shadowPaint,
    );

    // Gradient fill
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          _lightenColor(baseColor, 0.3),
          baseColor,
          _darkenColor(baseColor, 0.2),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, gradientPaint);

    // Highlight
    final highlightPaint = Paint()
      ..color = CupertinoColors.white.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(
      center + Offset(-radius * 0.3, -radius * 0.3),
      radius * 0.3,
      highlightPaint,
    );

    canvas.restore();
  }

  Color _lightenColor(Color color, double amount) {
    return Color.fromRGBO(
      (color.red + (255 - color.red) * amount).round().clamp(0, 255),
      (color.green + (255 - color.green) * amount).round().clamp(0, 255),
      (color.blue + (255 - color.blue) * amount).round().clamp(0, 255),
      color.opacity,
    );
  }

  Color _darkenColor(Color color, double amount) {
    return Color.fromRGBO(
      (color.red * (1 - amount)).round().clamp(0, 255),
      (color.green * (1 - amount)).round().clamp(0, 255),
      (color.blue * (1 - amount)).round().clamp(0, 255),
      color.opacity,
    );
  }

  @override
  bool shouldRepaint(SquishBallPainter oldDelegate) {
    return oldDelegate.squishX != squishX ||
        oldDelegate.squishY != squishY ||
        oldDelegate.rotation != rotation;
  }
}
