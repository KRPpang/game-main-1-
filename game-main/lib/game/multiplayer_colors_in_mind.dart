// lib/game/multiplayer_colors_in_mind.dart

import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../match_manager.dart'; // Relative import
import 'components/color_button.dart';

class MultiplayerColorsInMind extends FlameGame {
  final String matchId;
  final String myUid;
  final MatchManager matchManager = MatchManager();

  // 2x2 grid.
  final int rows = 2;
  final int columns = 2;
  late List<ColorButton> buttons;

  List<int> sequence = [];
  int sequenceIndex = 0;
  int localScore = 0;
  bool myTurn = false;

  MultiplayerColorsInMind({required this.matchId, required this.myUid});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final squareSize = 125.0;
    final gap = 25.0;
    final margin = 25.0;
    final designWidth = margin + columns * (squareSize + gap) - gap + margin;
    final designHeight = margin + rows * (squareSize + gap) - gap + margin;
    final offset = Vector2(
      (size.x - designWidth) / 2,
      (size.y - designHeight) / 2,
    );

    List<Color> modeColors = [Colors.red, Colors.green, Colors.blue, Colors.yellow];
    buttons = [];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        int index = r * columns + c;
        Vector2 pos = offset +
            Vector2(margin + c * (squareSize + gap), margin + r * (squareSize + gap));
        ColorButton button = ColorButton(
          id: index,
          color: modeColors[index],
          position: pos,
          size: Vector2.all(squareSize),
        );
        buttons.add(button);
        add(button);
      }
    }

    // Listen for match updates.
    matchManager.listenToMatch(matchId).listen((docSnapshot) {
      final data = docSnapshot.data() as Map<String, dynamic>?;
      if (data == null) return;
      String currentTurn = data['currentTurn'] ?? '';
      myTurn = (currentTurn == myUid);
      List<dynamic> seqData = data['sequence'] ?? [];
      sequence = seqData.cast<int>();
    });
  }

  void onUserInput(int buttonId) {
    if (!myTurn) return;

    if (sequenceIndex < sequence.length && sequence[sequenceIndex] == buttonId) {
      sequenceIndex++;
      if (sequenceIndex == sequence.length) {
        localScore++;
        int newMove = Random().nextInt(buttons.length);
        sequence.add(newMove);
        Map<String, dynamic> newScores = { myUid: localScore };

        // Determine opponent's UID (replace with actual logic in production)
        String otherPlayerUid = (myUid == 'testUid1') ? 'testUid2' : 'testUid1';

        matchManager.updateMatchAfterTurn(
          matchId: matchId,
          newSequence: sequence,
          nextTurn: otherPlayerUid,
          updatedScores: newScores,
        );
        sequenceIndex = 0;
      }
    } else {
      matchManager.finishMatch(matchId);
      pauseEngine();
    }
  }
}
