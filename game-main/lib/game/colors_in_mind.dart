import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../services/user_data_manager.dart';
import 'components/color_button.dart';

class ColorsInMind extends FlameGame {
  final int rows;
  final int columns;
  final bool uniform;

  late final double squareSize;
  late final double gap;
  late final double margin;
  late final double designWidth;
  late final double designHeight;

  List<ColorButton> buttons = [];
  List<int> sequence = [];
  int sequenceIndex = 0;
  int score = 0;
  late final TextComponent scoreText;

  // Flag to block input while the sequence is showing.
  bool _isShowingPattern = false;
  // Input enabled flag: only allow user taps when no overlay or pattern is active.
  bool _inputEnabled = false;

  // Public getter so buttons can check if input is allowed.
  bool get inputEnabled => _inputEnabled;

  final UserDataManager userDataManager = UserDataManager();

  ColorsInMind({int? gridSize, int? rows, int? columns, this.uniform = false})
      : rows = rows ?? (gridSize ?? 2),
        columns = columns ?? (gridSize ?? 2);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await userDataManager.initUserData();

    margin = 25;
    gap = 25;
    squareSize = 125;
    designWidth = margin + columns * (squareSize + gap) - gap + margin;
    designHeight = margin + rows * (squareSize + gap) - gap + margin;

    final offset = Vector2(
      (size.x - designWidth) / 2,
      (size.y - designHeight) / 2,
    );

    // Add score display above the grid.
    scoreText = TextComponent(
      text: 'Score: $score',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
    );
    scoreText.position = Vector2(size.x / 2, offset.y - 30);
    add(scoreText);

    // Determine button colors.
    List<Color> modeColors;
    if (uniform) {
      modeColors = List.filled(rows * columns, Colors.blue);
    } else if (rows == 2 && columns == 2) {
      modeColors = [Colors.red, Colors.green, Colors.blue, Colors.yellow];
    } else if (rows == 3 && columns == 3) {
      modeColors = [
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.yellow,
        Colors.purple,
        Colors.orange,
        Colors.teal,
        Colors.pink,
        Colors.lime,
      ];
    } else {
      modeColors = List.generate(
        rows * columns,
            (index) => Colors.primaries[index % Colors.primaries.length],
      );
    }

    // Create grid of buttons.
    buttons = [];
    for (int rowIndex = 0; rowIndex < rows; rowIndex++) {
      for (int colIndex = 0; colIndex < columns; colIndex++) {
        int index = rowIndex * columns + colIndex;
        Vector2 pos = offset +
            Vector2(
              margin + colIndex * (squareSize + gap),
              margin + rowIndex * (squareSize + gap),
            );
        ColorButton button = ColorButton(
          id: index,
          color: modeColors[index],
          position: pos,
          size: Vector2.all(squareSize),
        );
        buttons.add(button);
      }
    }
    for (final button in buttons) {
      add(button);
    }

    // Instead of auto-starting the game, show the start overlay.
    overlays.add('StartGameOverlay');
  }

  /// Called by the start button overlay when the player is ready.
  void startCountdown() {
    overlays.remove('StartGameOverlay');
    overlays.add('CountdownOverlay');
  }

  /// Resets the game state so the user can replay.
  void restartGame() {
    // Reset game state.
    sequence.clear();
    sequenceIndex = 0;
    score = 0;
    scoreText.text = 'Score: $score';

    // Resume the engine if it was paused.
    resumeEngine();

    // Remove any game over overlay and show the start overlay.
    overlays.remove('GameOverOverlay');
    overlays.add('StartGameOverlay');
  }

  void nextRound() {
    // Disable input while showing the sequence.
    _inputEnabled = false;
    _isShowingPattern = true;
    overlays.add('PatternLoadingOverlay');

    // Append a new button to the Simon sequence.
    int newButtonId = Random().nextInt(buttons.length);
    sequence.add(newButtonId);
    playSequence();
  }

  Future<void> playSequence() async {
    sequenceIndex = 0;
    for (final buttonId in sequence) {
      final button = buttons.firstWhere((b) => b.id == buttonId);
      await button.flash();
      await Future.delayed(const Duration(milliseconds: 400));
    }
    // Once the sequence is shown, enable user input.
    _isShowingPattern = false;
    _inputEnabled = true;
    overlays.remove('PatternLoadingOverlay');
  }

  // Process user button taps.
  void onUserInput(int buttonId) {
    if (!_inputEnabled) return;

    if (sequenceIndex < sequence.length && sequence[sequenceIndex] == buttonId) {
      sequenceIndex++;
      if (sequenceIndex == sequence.length) {
        // Disable further input immediately.
        _inputEnabled = false;
        score++;
        scoreText.text = 'Score: $score';

        String mode;
        if (uniform) {
          mode = 'uniform3x3';
        } else if (rows == 2 && columns == 2) {
          mode = '2x2';
        } else if (rows == 3 && columns == 3) {
          mode = '3x3';
        } else {
          mode = 'default';
        }

        // Update high score in Firestore.
        userDataManager.incrementGameScore(mode);

        // Check and unlock achievement when score reaches 25.
        if (score == 25) {
          if (mode == '2x2') {
            userDataManager.setAchievement('score25_2x2', true);
          } else if (mode == '3x3') {
            userDataManager.setAchievement('score25_3x3', true);
          } else if (mode == 'uniform3x3') {
            userDataManager.setAchievement('score25_uniform3x3', true);
          }
        }

        overlays.add('CorrectOverlay');
        Future.delayed(const Duration(seconds: 1), () {
          overlays.remove('CorrectOverlay');
          Future.delayed(const Duration(milliseconds: 800), nextRound);
        });
      }
    } else {
      // Incorrect input: reset the game.
      resetGame();
    }
  }

  void resetGame() {
    overlays.add('GameOverOverlay');
    pauseEngine();
  }
}
