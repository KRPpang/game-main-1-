// lib/game/multiplayer_game_screen.dart

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'multiplayer_colors_in_mind.dart';

class MultiplayerGameScreen extends StatelessWidget {
  final String matchId;
  const MultiplayerGameScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiplayer Game'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GameWidget<MultiplayerColorsInMind>(
        game: MultiplayerColorsInMind(matchId: matchId, myUid: myUid),
      ),
    );
  }
}
