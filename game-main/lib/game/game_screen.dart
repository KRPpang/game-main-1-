// lib/game/game_screen.dart

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'colors_in_mind.dart';

class GameScreen extends StatelessWidget {
  final int? gridSize;
  final int? rows;
  final int? columns;
  final bool uniform;

  const GameScreen({
    super.key,
    this.gridSize,
    this.rows,
    this.columns,
    this.uniform = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget<ColorsInMind>(
            game: ColorsInMind(
              gridSize: gridSize,
              rows: rows,
              columns: columns,
              uniform: uniform,
            ),
            overlayBuilderMap: {
              'GameStartedOverlay': (BuildContext context, ColorsInMind game) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.black54,
                    child: const Text(
                      'Game Started!',
                      style: TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                );
              },
              'CorrectOverlay': (BuildContext context, ColorsInMind game) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.black54,
                    child: const Text(
                      'Correct!',
                      style: TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                );
              },
              'GameOverOverlay': (BuildContext context, ColorsInMind game) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.black54,
                        child: const Text(
                          'Game Over!',
                          style: TextStyle(fontSize: 32, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Back to Home'),
                      )
                    ],
                  ),
                );
              },
            },
          ),
          // An exit button at top left.
          Positioned(
            top: 20,
            left: 20,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, size: 36, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
