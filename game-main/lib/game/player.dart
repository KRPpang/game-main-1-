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
    // Set the starting position so that the bottom of the sprite lines up with the ground.
    position = Vector2(startX, startY);
    // Scale up the sprite; note that we update our hitbox dimensions accordingly.
    scale = Vector2.all(1.5); // Final visual size (96x96)
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

    // Adjust the hitbox to align with the visible sprite.
    // Multiply the hitbox size by the scale factor (1.5) so they match up.
    const double scaleFactor = 1.5;
    add(RectangleHitbox()
      ..size = Vector2(20 * scaleFactor, 30 * scaleFactor)
    // Removing the upward offset so that the hitbox bottom aligns with the sprite's bottom (feet)
      ..position = Vector2.zero()
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

    // Use half the scaled hitbox width for accurate wall collision.
    // The original hitbox width is 20px, so half is 10 (multiplied by the scale factor).
    final double effectiveHalfWidth = (20 * scale.x) / 2;
    if (position.x - effectiveHalfWidth < 0) {
      position.x = effectiveHalfWidth;
      velocity.x = -velocity.x * bounceDamping;
      hasBumped = true;
    } else if (position.x + effectiveHalfWidth > 360) {
      position.x = 360 - effectiveHalfWidth;
      velocity.x = -velocity.x * bounceDamping;
      hasBumped = true;
    }

    // Ground collision: Ensure that the player's bottom aligns with the platform at y = 600.
    const double groundY = 600;
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

    // Horizontal movement when on the ground and no jump input is held.
    if (isOnGround && !jumpHeld) {
      if (isLeftHeld) {
        velocity.x = -runSpeed;
      } else if (isRightHeld) {
        velocity.x = runSpeed;
      } else {
        velocity.x = 0;
      }
    }

    // Flip the sprite based on the direction of horizontal movement.
    if (velocity.x < 0) {
      scale.x = -scale.x.abs();
    } else if (velocity.x > 0) {
      scale.x = scale.x.abs();
    }

    // Update animation state.
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
