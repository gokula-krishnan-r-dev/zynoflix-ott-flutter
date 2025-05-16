import 'package:flutter/material.dart';
import 'dart:math';

// Custom painter for the play button logo
class PlayButtonPainter extends CustomPainter {
  final Color color;

  PlayButtonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    // Draw the main play triangle shape with rounded corners
    final Path trianglePath = Path();

    // Create a rounded triangle shape
    final double radius = size.width * 0.1;

    // Starting point (top-left with rounded corner)
    trianglePath.moveTo(size.width * 0.35 + radius, size.height * 0.2);

    // Line to top-right corner
    trianglePath.lineTo(size.width * 0.7, size.height * 0.4);

    // Round the corner at the right-middle point
    trianglePath.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.5,
      size.width * 0.7,
      size.height * 0.6,
    );

    // Line to bottom-left
    trianglePath.lineTo(size.width * 0.35 + radius, size.height * 0.8);

    // Rounded corner at bottom-left
    trianglePath.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.8,
      size.width * 0.35,
      size.height * 0.8 - radius,
    );

    // Line back to start, with rounded corner at top-left
    trianglePath.lineTo(size.width * 0.35, size.height * 0.2 + radius);
    trianglePath.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.2,
      size.width * 0.35 + radius,
      size.height * 0.2,
    );

    canvas.drawPath(trianglePath, paint);

    // Draw the pixel fragments (squares that trail behind the triangle)
    final Paint pixelPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    // Draw pixel squares in a pattern similar to the image
    _drawPixel(
      canvas,
      pixelPaint,
      size.width * 0.2,
      size.height * 0.4,
      size.width * 0.08,
    );
    _drawPixel(
      canvas,
      pixelPaint,
      size.width * 0.15,
      size.height * 0.5,
      size.width * 0.06,
    );
    _drawPixel(
      canvas,
      pixelPaint,
      size.width * 0.25,
      size.height * 0.6,
      size.width * 0.07,
    );
    _drawPixel(
      canvas,
      pixelPaint,
      size.width * 0.18,
      size.height * 0.7,
      size.width * 0.05,
    );
    _drawPixel(
      canvas,
      pixelPaint,
      size.width * 0.12,
      size.height * 0.35,
      size.width * 0.04,
    );

    // Draw white highlights on the triangle to give it dimension
    final Paint highlightPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    final Path highlightPath =
        Path()
          ..moveTo(size.width * 0.4, size.height * 0.3)
          ..lineTo(size.width * 0.6, size.height * 0.4)
          ..lineTo(size.width * 0.55, size.height * 0.45)
          ..lineTo(size.width * 0.38, size.height * 0.37)
          ..close();

    canvas.drawPath(highlightPath, highlightPaint);
  }

  void _drawPixel(Canvas canvas, Paint paint, double x, double y, double size) {
    // Round the corners of the pixels slightly
    final RRect pixelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, size, size),
      Radius.circular(size * 0.2),
    );
    canvas.drawRRect(pixelRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom wave painter
class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  WavePainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final double waveHeight = size.height * 0.8;
    final double waveWidth = size.width;

    final Path path = Path();
    path.moveTo(0, size.height);

    // Create the wave effect with multiple sine waves
    for (int i = 0; i < waveWidth.toInt(); i++) {
      final double x = i.toDouble();
      final double y =
          sin((x * 0.015) + (animationValue * 10)) * (waveHeight * 0.3) +
          sin((x * 0.03) + (animationValue * 5)) * (waveHeight * 0.2) +
          size.height -
          waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
