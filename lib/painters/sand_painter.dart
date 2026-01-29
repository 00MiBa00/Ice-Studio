import 'dart:math';
import 'package:flutter/cupertino.dart';

class SandTrailPoint {
  final Offset position;
  final int timestamp;
  final double thickness;

  SandTrailPoint({
    required this.position,
    required this.timestamp,
    this.thickness = 3.0,
  });
}

class SandPainter extends CustomPainter {
  final List<SandTrailPoint> trails;
  final Offset ballPosition;
  final double ballRadius;
  final Color trailColor;
  final Color ballColor;

  SandPainter({
    required this.trails,
    required this.ballPosition,
    required this.ballRadius,
    required this.trailColor,
    required this.ballColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw subtle noise texture background
    _drawNoiseTexture(canvas, size);

    // Draw trails
    if (trails.isNotEmpty) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final maxAge = 15000; // 15 seconds fade

      for (int i = 0; i < trails.length; i++) {
        final trail = trails[i];
        final age = now - trail.timestamp;
        
        if (age > maxAge) continue;

        final opacity = (1.0 - (age / maxAge)).clamp(0.0, 1.0);
        final width = trail.thickness * (0.7 + opacity * 0.3);

        final paint = Paint()
          ..color = trailColor.withOpacity(opacity * 0.7)
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;

        if (i > 0) {
          canvas.drawLine(trails[i - 1].position, trail.position, paint);
        }
      }
    }

    // Draw ball shadow
    final shadowPaint = Paint()
      ..color = ballColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(ballPosition + const Offset(0, 3), ballRadius, shadowPaint);

    // Draw ball
    final ballPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          _lightenColor(ballColor, 0.3),
          ballColor,
          _darkenColor(ballColor, 0.2),
        ],
      ).createShader(Rect.fromCircle(center: ballPosition, radius: ballRadius));
    
    canvas.drawCircle(ballPosition, ballRadius, ballPaint);

    // Ball highlight
    final highlightPaint = Paint()
      ..color = CupertinoColors.white.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(
      ballPosition + Offset(-ballRadius * 0.3, -ballRadius * 0.3),
      ballRadius * 0.25,
      highlightPaint,
    );
  }

  void _drawNoiseTexture(Canvas canvas, Size size) {
    final random = Random(42); // Fixed seed for consistent texture
    final paint = Paint()
      ..color = CupertinoColors.white.withOpacity(0.02);

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 1, paint);
    }
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
  bool shouldRepaint(SandPainter oldDelegate) {
    return oldDelegate.trails.length != trails.length ||
        oldDelegate.ballPosition != ballPosition;
  }
}
