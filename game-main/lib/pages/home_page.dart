// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../game/game_screen.dart';
import '../pages/multiplayer_lobby_screen.dart';
import '../pages/high_score_page.dart'; // Import the High Scores page
import '../widgets/animated_pixel_background.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int highestScore2x2 = 0;
  int highestScore3x3 = 0;
  int highestScoreUniform3x3 = 0;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    fetchScores();
    // (Username check skipped for now)
  }

  Future<void> fetchScores() async {
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final progress = doc.data()?['progress'];
    setState(() {
      highestScore2x2 =
      (progress?['highestScore2x2'] is int) ? progress!['highestScore2x2'] as int : 0;
      highestScore3x3 =
      (progress?['highestScore3x3'] is int) ? progress!['highestScore3x3'] as int : 0;
      highestScoreUniform3x3 = (progress?['highestScoreUniform3x3'] is int)
          ? progress!['highestScoreUniform3x3'] as int
          : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedPixelBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile UI here (if needed)
                  // ...
                  const SizedBox(height: 20),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Welcome, ${user?.email ?? 'Guest'}",
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 20),
                            // Existing game mode buttons...
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const GameScreen(gridSize: 2)),
                                );
                              },
                              child: const Text("Play 2x2 Game"),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const GameScreen(gridSize: 3)),
                                );
                              },
                              child: const Text("Play 3x3 Game"),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const GameScreen(
                                        gridSize: 3,
                                        uniform: true,
                                      )),
                                );
                              },
                              child: const Text("Play Uniform 3x3 Game"),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const MultiplayerLobbyScreen()),
                                );
                              },
                              child: const Text("Play Multiplayer 2x2"),
                            ),
                            const SizedBox(height: 20),
                            // New High Scores Button:
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HighScoresPage(),
                                  ),
                                );
                              },
                              child: const Text("View High Scores"),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: () {
                                FirebaseAuth.instance.signOut();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text("Logout"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
