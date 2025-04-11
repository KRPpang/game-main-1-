import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/painting.dart';

class TestPlatform extends PositionComponent with CollisionCallbacks {
  TestPlatform()
      : super(
    size: Vector2(200, 10),
    position: Vector2(80, 400),
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Add a hitbox so it can collide with other components
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = const Color(0xFFFF0000);
    canvas.drawRect(size.toRect(), paint);
  }
}
