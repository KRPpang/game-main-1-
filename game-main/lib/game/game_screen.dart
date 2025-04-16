import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'colors_in_mind.dart';
import 'dart:async';

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
                      // Back to Home Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Back to Home'),
                      ),
                      const SizedBox(height: 10),
                      // Replay Button
                      ElevatedButton(
                        onPressed: () {
                          game.restartGame();
                        },
                        child: const Text('Replay'),
                      ),
                    ],
                  ),
                );
              },
              // PatternLoadingOverlay with thin red bars.
              'PatternLoadingOverlay': (BuildContext context, ColorsInMind game) {
                final double topEmpty = (game.size.y - game.designHeight) / 2;
                const double barHeight = 40;
                final double topBarTop = (topEmpty - barHeight) / 2;
                final double bottomBarTop = game.size.y - topEmpty + ((topEmpty - barHeight) / 2);

                return Stack(
                  children: [
                    // Top thin red bar.
                    Positioned(
                      top: topBarTop,
                      left: 0,
                      right: 0,
                      height: barHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                        child: const Center(
                          child: Text(
                            'WAIT',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Bottom thin red bar.
                    Positioned(
                      top: bottomBarTop,
                      left: 0,
                      right: 0,
                      height: barHeight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                        child: const Center(
                          child: Text(
                            'WAIT',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              // New StartGameOverlay with a start button.
              'StartGameOverlay': (BuildContext context, ColorsInMind game) {
                return Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      onPressed: () {
                        game.startCountdown();
                      },
                      child: const Text(
                        'START',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              },
              // New CountdownOverlay which shows a countdown from 3 to 1.
              'CountdownOverlay': (BuildContext context, ColorsInMind game) {
                return CountdownOverlay(game: game);
              },
            },
          ),
          // Exit button at top left.
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

/// A countdown overlay widget that counts from 3 to 1 then starts the game.
class CountdownOverlay extends StatefulWidget {
  final ColorsInMind game;
  const CountdownOverlay({super.key, required this.game});

  @override
  _CountdownOverlayState createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  int _counter = 3;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Start a periodic timer to count down each second.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _counter--;
        if (_counter < 1) {
          _timer.cancel();
          // Remove the countdown overlay and start the game round.
          widget.game.overlays.remove('CountdownOverlay');
          widget.game.nextRound();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _counter.toString(),
        style: const TextStyle(
          fontSize: 80,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
