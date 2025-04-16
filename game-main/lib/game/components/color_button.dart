import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import '../../game/colors_in_mind.dart';

class ColorButton extends PositionComponent
    with TapCallbacks, HoverCallbacks, HasGameRef<ColorsInMind> {
  final int id;
  final Color color;
  late Paint paint;
  bool isPressed = false;
  bool _isHovered = false;

  @override
  bool get isHovered => _isHovered;

  ColorButton({
    required this.id,
    required this.color,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    paint = Paint()..color = color;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), paint);
    if (isPressed) {
      final pressedIndicator = Paint()
        ..color = const Color.fromRGBO(255, 255, 255, 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawRect(size.toRect(), pressedIndicator);
    } else if (_isHovered) {
      final hoverIndicator = Paint()
        ..color = const Color.fromRGBO(255, 255, 255, 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(size.toRect(), hoverIndicator);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Check if game input is allowed before processing the tap.
    if (!gameRef.inputEnabled) return;

    // Process the tap only if the button is not already pressed.
    if (!isPressed) {
      isPressed = true;
      // Play a sound effect for player activation.
      FlameAudio.play('Retro8.mp3');
      gameRef.onUserInput(id);
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    isPressed = false;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    isPressed = false;
  }

  @override
  void onHoverEnter() {
    _isHovered = true;
  }

  @override
  void onHoverExit() {
    _isHovered = false;
  }

  /// Plays the flash effect when the button is activated as part of the pattern.
  /// The duration has been increased to 400ms so that the flash is slower
  /// and the player can better see it.
  Future<void> flash() async {
    FlameAudio.play('Retro8.mp3');
    final originalColor = paint.color;
    paint.color = Colors.white;
    await Future.delayed(const Duration(milliseconds: 400));
    paint.color = originalColor;
  }
}
