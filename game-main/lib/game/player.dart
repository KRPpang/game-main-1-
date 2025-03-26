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
  bool leftHeld = false;
  bool rightHeld = false;
  // jumpDirection is determined when relezasing jump.
  int jumpDirection = 0;

  Brain? brain;

  // New flag to indicate a wall collision.
  bool hasBumped = false;

  // Constants (tune these as needed).
  final double minJumpSpeed = 200;  // vertical jump speed when barely charged.
  final double maxJumpSpeed = 500;  // vertical jump speed when fully charged.
  final double maxJumpTimer = 30;   // maximum charge value.
  final double jumpSpeedHorizontal = 150; // horizontal jump speed.

  // Gravity (pixels per second²).
  final double gravity = 1000;
  // Walking speed (pixels per second).
  final double runSpeed = 200;
  // Bounce damping factor when hitting walls.
  final double bounceDamping = 0.5;

  Player({double startX = 180, double startY = 600})
      : super(size: Vector2(50, 65), anchor: Anchor.topLeft) {
    position = Vector2(startX, startY);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // If jump is held and on the ground, increase the jump timer.
    if (jumpHeld && isOnGround) {
      jumpTimer += dt * 60; // assuming 60 fps as baseline.
      if (jumpTimer > maxJumpTimer) jumpTimer = maxJumpTimer;
    }

    // Apply gravity.
    velocity.y += gravity * dt;
    position += velocity * dt;

    // Handle horizontal boundaries (game area width = 360).
    // Instead of clamping, we bounce off walls.
    if (position.x < 0) {
      position.x = 0;
      velocity.x = -velocity.x * bounceDamping;
      hasBumped = true;
    } else if (position.x > 360 - size.x) {
      position.x = 360 - size.x;
      velocity.x = -velocity.x * bounceDamping;
      hasBumped = true;
    }

    // Ground collision: assume ground is at y = 600.
    double groundY = 600;
    if (position.y + size.y >= groundY) {
      position.y = groundY - size.y;
      velocity.y = 0;
      isOnGround = true;
      // Reset horizontal velocity upon landing to avoid lingering momentum.
      velocity.x = 0;
      // Reset bumped flag on landing.
      hasBumped = false;
      if (!jumpHeld) jumpTimer = 0;
    } else {
      isOnGround = false;
    }
  }

  // Normal walking is allowed only when not charging a jump.
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

  // Called by on-screen controls.
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
      // When starting a jump, we don't assign a horizontal component yet.
      jumpDirection = 0;
    }
  }

  void releaseJump() {
    if (isOnGround && jumpHeld) {
      jumpHeld = false;
      // Map jumpTimer to vertical jump speed.
      double verticalJumpSpeed =
          minJumpSpeed + ((maxJumpSpeed - minJumpSpeed) * (jumpTimer / maxJumpTimer));
      // Determine horizontal component based on held flags.
      double horizontal = 0;
      // Even if jump was pressed before directional keys, check flags now.
      if (leftHeld && !rightHeld) {
        horizontal = -jumpSpeedHorizontal;
      } else if (rightHeld && !leftHeld) {
        horizontal = jumpSpeedHorizontal;
      }
      velocity = Vector2(horizontal, -verticalJumpSpeed);
      jumpTimer = 0;
      // Clear directional flags so no lingering momentum occurs.
      leftHeld = false;
      rightHeld = false;
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.blue;
    canvas.drawRect(size.toRect(), paint);

    // Optionally, draw an indicator if bumped.
    if (hasBumped) {
      final bumpPaint = Paint()..color = Colors.red;
      canvas.drawRect(size.toRect(), bumpPaint..style = PaintingStyle.stroke..strokeWidth = 3);
    }

    // Draw a jump charge bar if jump is held.
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
