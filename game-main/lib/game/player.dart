import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'brain.dart';

class Player extends PositionComponent {
  // Physics state.
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;

  // Jump-related variables.
  bool jumpHeld = false;
  double jumpTimer = 0; // Increases while jump is held (charge)
  // These flags are set by the on-screen controls.
  bool leftHeld = false;
  bool rightHeld = false;
  // While charging, the current left/right input is recorded in these flags.
  // (They determine horizontal jump momentum on release.)
  Brain? brain;

  // Constants based on your original JS:
  final double minJumpSpeed = 200; // Vertical jump speed when barely charged.
  final double maxJumpSpeed = 500; // Vertical jump speed when fully charged.
  final double maxJumpTimer = 30;  // Maximum charge (in frames equivalent).
  final double jumpSpeedHorizontal = 150; // Horizontal jump speed.
  // Gravity (adjusted for dt-based physics).
  final double gravity = 1000;
  final double runSpeed = 200; // Walking speed in pixels per second.

  Player({double startX = 180, double startY = 600})
      : super(size: Vector2(50, 65), anchor: Anchor.topLeft) {
    position = Vector2(startX, startY);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // If jump is held and on ground, increase jumpTimer.
    if (jumpHeld && isOnGround) {
      jumpTimer += dt * 60; // Simulate frame increments (assuming 60 fps).
      if (jumpTimer > maxJumpTimer) jumpTimer = maxJumpTimer;
    }

    // Apply gravity.
    velocity.y += gravity * dt;
    position += velocity * dt;

    // Clamp horizontal position to within game width (360).
    position.x = position.x.clamp(0, 360 - size.x);

    // Ground collision: assume ground is at y = 600.
    double groundY = 600;
    if (position.y + size.y >= groundY) {
      position.y = groundY - size.y;
      velocity.y = 0;
      isOnGround = true;
      // Reset horizontal velocity to avoid sliding.
      velocity.x = 0;
      if (!jumpHeld) {
        jumpTimer = 0;
      }
    } else {
      isOnGround = false;
    }
  }

  // Normal walking methods (only allowed when not charging jump).
  void moveLeft(double dt) {
    if (isOnGround && !jumpHeld) {
      position.x -= runSpeed * dt;
    }
  }
  void moveRight(double dt) {
    if (isOnGround && !jumpHeld) {
      position.x += runSpeed * dt;
    }
  }

  // On-screen control methods.
  void pressLeft() {
    leftHeld = true;
  }
  void releaseLeft() {
    leftHeld = false;
  }
  void pressRight() {
    rightHeld = true;
  }
  void releaseRight() {
    rightHeld = false;
  }
  void pressJump() {
    if (isOnGround && !jumpHeld) {
      jumpHeld = true;
      jumpTimer = 0;
      // Do not move horizontally while starting a jump.
    }
  }
  void releaseJump() {
    if (isOnGround && jumpHeld) {
      jumpHeld = false;
      // Map jumpTimer to a vertical jump speed.
      double verticalJumpSpeed =
          minJumpSpeed + ((maxJumpSpeed - minJumpSpeed) * (jumpTimer / maxJumpTimer));
      // Determine horizontal component based on held flags.
      double horizontal = 0;
      if (leftHeld && !rightHeld) {
        horizontal = -jumpSpeedHorizontal;
      } else if (rightHeld && !leftHeld) {
        horizontal = jumpSpeedHorizontal;
      }
      velocity = Vector2(horizontal, -verticalJumpSpeed);
      jumpTimer = 0;
      // Clear left/right flags to prevent lingering horizontal momentum.
      leftHeld = false;
      rightHeld = false;
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.blue;
    canvas.drawRect(size.toRect(), paint);

    // Draw jump charge bar if jump is held.
    if (jumpHeld) {
      final barWidth = size.x;
      const barHeight = 5.0;
      double ratio = jumpTimer / maxJumpTimer;
      if (ratio > 1) ratio = 1;
      final chargedWidth = barWidth * ratio;
      final chargePaint = Paint()..color = Colors.yellow;
      canvas.drawRect(Rect.fromLTWH(0, -10, chargedWidth, barHeight), chargePaint);
      final borderPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke;
      canvas.drawRect(Rect.fromLTWH(0, -10, barWidth, barHeight), borderPaint);
    }
  }
}
