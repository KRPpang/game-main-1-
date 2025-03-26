import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'jump_king_game.dart';
import 'game_controls.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final game = JumpKingGame();
    return Scaffold(
      // Optionally remove the AppBar for full-screen.
      appBar: AppBar(title: const Text('Jump King Flutter')),
      body: Stack(
        children: [
          // Wrap the GameWidget in a Focus widget to capture keyboard events.
          Focus(
            autofocus: true,
            child: GameWidget<JumpKingGame>(
              game: game,
            ),
          ),
          GameControls(game: game),
        ],
      ),
    );
  }
}
