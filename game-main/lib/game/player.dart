import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'enums.dart';
import 'dart:ui';

class Player extends PositionComponent with HasGameRef, CollisionCallbacks {
  static const double gravity = 1000;
  static const double jumpForceMax = 600;
  static const double moveSpeed = 150;

  Vector2 velocity = Vector2.zero();
  bool isGrounded = false;
  bool chargingJump = false;
  double jumpCharge = 0;
  final double chargeRate = 600;
  Direction facing = Direction.right;

  Player({required Vector2 position})
      : super(size: Vector2(40, 40), position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final bluePaint = Paint()..color = const Color(0xFF0000FF);
    add(RectangleComponent(size: size, paint: bluePaint));
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isGrounded) {
      velocity.y += gravity * dt;
    }

    if (chargingJump) {
      jumpCharge += chargeRate * dt;
      if (jumpCharge > jumpForceMax) jumpCharge = jumpForceMax;
    }

    position += velocity * dt;

    if (position.y > gameRef.size.y + 500) {
      position = Vector2(gameRef.size.x / 2, gameRef.size.y - 100);
      velocity = Vector2.zero();
    }
  }

  void startCharge() {
    if (isGrounded) {
      chargingJump = true;
      jumpCharge = 0;
    }
  }

  void releaseJump() {
    if (chargingJump && isGrounded) {
      chargingJump = false;
      isGrounded = false;
      velocity.y = -jumpCharge;
      velocity.x = (facing == Direction.right ? 1 : -1) * jumpCharge * 0.4;
      jumpCharge = 0;
    }
  }

  void moveLeft() => facing = Direction.left;
  void moveRight() => facing = Direction.right;

  void onGroundCollision() {
    isGrounded = true;
    velocity = Vector2.zero();
  }
}
