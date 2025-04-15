// lib/pages/lobby_detail_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../match_manager.dart';
import '../game/multiplayer_game_screen.dart';

class LobbyDetailScreen extends StatelessWidget {
  final String matchId;
  final bool isOwner;
  const LobbyDetailScreen({super.key, required this.matchId, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    final MatchManager matchManager = MatchManager();
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('matches').doc(matchId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List<dynamic> players = data['players'] ?? [];
          final ownerId = players.isNotEmpty ? players.first : 'unknown';
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text("Lobby Name: $ownerId",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Your ID: $myUid"),
                const SizedBox(height: 20),
                const Text("Players in Lobby:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                for (var player in players)
                  ListTile(
                    title: Text(player.toString()),
                  ),
                const Spacer(),
                if (isOwner)
                  ElevatedButton(
                    onPressed: () async {
                      await matchManager.startMatch(matchId);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MultiplayerGameScreen(matchId: matchId),
                        ),
                      );
                    },
                    child: const Text("Start Game"),
                  )
                else
                  const Text("Waiting for lobby owner to start...",
                      style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Back to Lobby Selector"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
