// lib/pages/multiplayer_lobby_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../match_manager.dart';
import 'lobby_detail_screen.dart';

class MultiplayerLobbyScreen extends StatelessWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MatchManager matchManager = MatchManager();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby Selector'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const MultiplayerLobbyScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              final matchId = await matchManager.createMatch();
              if (matchId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LobbyDetailScreen(matchId: matchId, isOwner: true),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to create lobby")),
                );
              }
            },
            child: const Text("Create Lobby"),
          ),
          const SizedBox(height: 20),
          const Text("Available Lobbies", style: TextStyle(fontSize: 20)),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('matches')
                  .where('status', isEqualTo: 'waiting')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading lobbies'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final lobbies = snapshot.data!.docs;
                if (lobbies.isEmpty) {
                  return const Center(child: Text('No active lobbies'));
                }
                return ListView.builder(
                  itemCount: lobbies.length,
                  itemBuilder: (context, index) {
                    final lobby = lobbies[index];
                    final data = lobby.data() as Map<String, dynamic>;
                    final List<dynamic> players = data['players'] ?? [];
                    final ownerId =
                    players.isNotEmpty ? players.first : 'unknown';
                    return ListTile(
                      title: Text("Lobby: $ownerId"),
                      subtitle: Text("Players: ${players.join(', ')}"),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          String? joinedId =
                          await matchManager.joinMatch(lobby.id);
                          if (joinedId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LobbyDetailScreen(
                                    matchId: joinedId, isOwner: false),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Could not join lobby")),
                            );
                          }
                        },
                        child: const Text("Join"),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
