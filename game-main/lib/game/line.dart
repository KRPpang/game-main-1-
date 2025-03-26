import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Line extends PositionComponent {
  double x1, y1, x2, y2;
  bool isHorizontal;
  bool isVertical;

  Line(this.x1, this.y1, this.x2, this.y2)
      : isHorizontal = (y1 == y2),
        isVertical = (x1 == x2),
        super();

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3;
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
  }
}
