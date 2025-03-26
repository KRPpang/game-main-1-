import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Coin extends PositionComponent {
  double radius;
  String type;

  Coin({required double x, required double y, this.radius = 25, this.type = "reward"})
      : super(position: Vector2(x, y), size: Vector2.all(radius * 2), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = (type == "reward") ? Colors.orange : Colors.green;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), radius, paint);
  }
}
