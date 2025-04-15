// lib/game/components/color_button.dart

import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
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
  }) : super(
    position: position,
    size: size,
  );

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
    isPressed = true;
    gameRef.onUserInput(id);
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

  Future<void> flash() async {
    final originalColor = paint.color;
    paint.color = Colors.white;
    await Future.delayed(const Duration(milliseconds: 200));
    paint.color = originalColor;
  }
}
