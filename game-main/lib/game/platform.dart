import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'dart:ui';
import 'player.dart';

class PlatformBlock extends PositionComponent with CollisionCallbacks, HasGameRef {
  final double width;

  PlatformBlock({required Vector2 position, required this.width})
      : super(position: position, size: Vector2(width, 20), anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(RectangleHitbox());
    add(RectangleComponent(size: size, paint: Paint()..color = const Color(0xFF00FF00)));
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Player) {
      final playerBottom = other.position.y + other.size.y / 2;
      final platformTop = position.y;

      if (playerBottom <= platformTop + 10) {
        other.position.y = platformTop - other.size.y / 2;
        other.onGroundCollision();
      }
    }
  }
}
