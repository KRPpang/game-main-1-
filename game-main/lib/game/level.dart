import 'package:flame/components.dart';
import 'line.dart';
import 'coin.dart';
import 'package:flutter/material.dart';

class Level extends Component {
  // A level holds a background, a list of lines, and coins.
  List<Line> lines = [];
  List<Coin> coins = [];

  Level();

  @override
  void render(Canvas canvas) {
    // Draw a simple grey background.
    final bgPaint = Paint()..color = Colors.grey;
    canvas.drawRect(Rect.fromLTWH(0, 0, 360, 640), bgPaint);

    // Render each line.
    for (var line in lines) {
      line.render(canvas);
    }

    // Render coins.
    for (var coin in coins) {
      coin.render(canvas);
    }
  }
}
