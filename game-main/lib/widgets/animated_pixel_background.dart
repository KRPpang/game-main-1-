import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedPixelBackground extends StatefulWidget {
  const AnimatedPixelBackground({super.key});

  @override
  State<AnimatedPixelBackground> createState() => _AnimatedPixelBackgroundState();
}

class _AnimatedPixelBackgroundState extends State<AnimatedPixelBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double time = 0.0;

  final int rows = 60;
  final int columns = 40;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )..addListener(() {
      setState(() {
        time += 0.01;
      });
    });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DiagonalPixelPainter(time, rows, columns),
      size: Size.infinite,
    );
  }
}

class _DiagonalPixelPainter extends CustomPainter {
  final double time;
  final int rows;
  final int columns;

  _DiagonalPixelPainter(this.time, this.rows, this.columns);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final double pixelWidth = size.width / columns;
    final double pixelHeight = size.height / rows;

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        // Diagonal shift based on row + column
        double diagonal = (row + col) * 0.2;
        double hue = (time * 60 + diagonal * 20) % 360;
        paint.color = HSVColor.fromAHSV(1.0, hue, 0.6, 0.9).toColor();

        final rect = Rect.fromLTWH(
          col * pixelWidth,
          row * pixelHeight,
          pixelWidth,
          pixelHeight,
        );

        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DiagonalPixelPainter oldDelegate) => true;
}
