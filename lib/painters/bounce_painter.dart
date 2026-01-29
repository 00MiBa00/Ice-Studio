import 'package:flutter/cupertino.dart';

class BouncePainter extends CustomPainter {
  final Offset ballPosition;
  final double ballRadius;
  final Color ballColor;
  final Size containerSize;

  BouncePainter({
    required this.ballPosition,
    required this.ballRadius,
    required this.ballColor,
    required this.containerSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw container boundary
    final boundaryPaint = Paint()
      ..color = ballColor.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, containerSize.width, containerSize.height),
        const Radius.circular(20),
      ),
      boundaryPaint,
    );

    // Ball shadow
    final shadowPaint = Paint()
      ..color = ballColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(ballPosition + const Offset(0, 5), ballRadius, shadowPaint);

    // Ball gradient
    final ballPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          _lightenColor(ballColor, 0.4),
          ballColor,
          _darkenColor(ballColor, 0.2),
        ],
      ).createShader(Rect.fromCircle(center: ballPosition, radius: ballRadius));
    
    canvas.drawCircle(ballPosition, ballRadius, ballPaint);

    // Highlight
    final highlightPaint = Paint()
      ..color = CupertinoColors.white.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(
      ballPosition + Offset(-ballRadius * 0.3, -ballRadius * 0.3),
      ballRadius * 0.25,
      highlightPaint,
    );
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
  bool shouldRepaint(BouncePainter oldDelegate) {
    return oldDelegate.ballPosition != ballPosition;
  }
}
