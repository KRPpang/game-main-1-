import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/collisions.dart';
import 'brain.dart';

enum PlayerState {
  idle,
  walk,
  jumpUp,
}

class Player extends SpriteAnimationGroupComponent<PlayerState> with HasGameRef {
  Vector2 velocity = Vector2.zero();

  bool isLeftHeld = false;
  bool isRightHeld = false;
  bool isOnGround = false;
  bool jumpHeld = false;
  double jumpTimer = 0;
  int jumpDirection = 0;
  bool hasBumped = false;

  final double minJumpSpeed = 200;
  final double maxJumpSpeed = 500;
  final double maxJumpTimer = 30;
  final double jumpSpeedHorizontal = 150;
  final double gravity = 1000;
  final double runSpeed = 200;
  final double bounceDamping = 0.5;

  Brain? brain;

  Player({double startX = 180, double startY = 600})
      : super(size: Vector2(64, 64), anchor: Anchor.bottomCenter) {
    // Shift slightly downward to compensate for visual offset inside the sprite
    position = Vector2(startX, startY + 8);
    scale = Vector2.all(1.5); // Final visual scale (96x96)
  }

  @override
  Future<void> onLoad() async {
    final idleSheet = SpriteSheet(
      image: await gameRef.images.load('Idle.png'),
      srcSize: Vector2(64, 64),
    );

    final walkSheet = SpriteSheet(
      image: await gameRef.images.load('Walk.png'),
      srcSize: Vector2(64, 64),
    );

    final jumpSheet = SpriteSheet(
      image: await gameRef.images.load('Crouch.png'),
      srcSize: Vector2(64, 64),
    );

    animations = {
      PlayerState.idle: idleSheet.createAnimation(row: 0, stepTime: 0.4, to: 2),
      PlayerState.walk: walkSheet.createAnimation(row: 0, stepTime: 0.12, to: 3),
      PlayerState.jumpUp: jumpSheet.createAnimation(row: 0, stepTime: 0.12, to: 3),
    };

    current = PlayerState.idle;

    // ✅ Accurate hitbox for the visible body (not full sprite frame)
    add(RectangleHitbox()
      ..size = Vector2(20, 30) // width and height of character's body, not the whole frame
      ..position = Vector2(0, -12) // shift it up so the bottom of the hitbox matches the sprite's feet
      ..anchor = Anchor.bottomCenter
      ..collisionType = CollisionType.active);

  }

  @override
  void update(double dt) {
    super.update(dt);

    if (jumpHeld && isOnGround) {
      jumpTimer += dt * 60;
      if (jumpTimer > maxJumpTimer) jumpTimer = maxJumpTimer;
    }

    velocity.y += gravity * dt;
    position += velocity * dt;

    // Use hitbox width (20px → half is 10) for accurate wall collision
    if (position.x - 10 < 0) {
      position.x = 10;
      velocity.x = -velocity.x * bounceDamping;
      hasBumped = true;
    } else if (position.x + 10 > 360) {
      position.x = 350;
      velocity.x = -velocity.x * bounceDamping;
      hasBumped = true;
    }

    double groundY = 600;
    if (position.y >= groundY) {
      position.y = groundY;
      velocity.y = 0;
      isOnGround = true;
      velocity.x = 0;
      hasBumped = false;
      if (!jumpHeld) jumpTimer = 0;
    } else {
      isOnGround = false;
    }

    if (isOnGround && !jumpHeld) {
      if (isLeftHeld) {
        velocity.x = -runSpeed;
      } else if (isRightHeld) {
        velocity.x = runSpeed;
      } else {
        velocity.x = 0;
      }
    }

    if (velocity.x < 0) {
      scale.x = -scale.x.abs();
    } else if (velocity.x > 0) {
      scale.x = scale.x.abs();
    }

    if (!isOnGround && velocity.y < 0 && current != PlayerState.jumpUp) {
      current = PlayerState.jumpUp;
    } else if (velocity.x != 0 && isOnGround && current != PlayerState.walk) {
      current = PlayerState.walk;
    } else if (velocity.x == 0 && isOnGround && current != PlayerState.idle) {
      current = PlayerState.idle;
    }
  }

  void pressLeft() => isLeftHeld = true;
  void releaseLeft() => isLeftHeld = false;
  void pressRight() => isRightHeld = true;
  void releaseRight() => isRightHeld = false;

  void pressJump() {
    if (isOnGround && !jumpHeld) {
      jumpHeld = true;
      jumpTimer = 0;
      jumpDirection = 0;
    }
  }

  void releaseJump() {
    if (isOnGround && jumpHeld) {
      jumpHeld = false;
      final verticalJumpSpeed = minJumpSpeed +
          ((maxJumpSpeed - minJumpSpeed) * (jumpTimer / maxJumpTimer));
      double horizontal = 0;
      if (isLeftHeld && !isRightHeld) {
        horizontal = -jumpSpeedHorizontal;
      } else if (isRightHeld && !isLeftHeld) {
        horizontal = jumpSpeedHorizontal;
      }
      velocity = Vector2(horizontal, -verticalJumpSpeed);
      jumpTimer = 0;
      isLeftHeld = false;
      isRightHeld = false;
    }
  }
}
