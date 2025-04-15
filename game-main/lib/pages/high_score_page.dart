// lib/pages/high_scores_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HighScoresPage extends StatefulWidget {
  const HighScoresPage({super.key});

  @override
  State<HighScoresPage> createState() => _HighScoresPageState();
}

class _HighScoresPageState extends State<HighScoresPage> {
  late Future<Map<String, dynamic>> highScoresFuture;

  @override
  void initState() {
    super.initState();
    highScoresFuture = fetchHighScores();
  }

  Future<Map<String, dynamic>> fetchHighScores() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {};
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return data['progress'] as Map<String, dynamic>? ?? {};
  }

  void refreshScores() {
    setState(() {
      highScoresFuture = fetchHighScores();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('High Scores'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshScores,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: highScoresFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text('No high score data available.'));
          } else {
            final progress = snapshot.data!;
            final hs2x2 = progress['highestScore2x2']?.toString() ?? '0';
            final hs3x3 = progress['highestScore3x3']?.toString() ?? '0';
            final hsUniform =
                progress['highestScoreUniform3x3']?.toString() ?? '0';

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'High Scores',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: const Icon(Icons.filter_2),
                    title: const Text('2x2 Mode'),
                    trailing: Text(
                      hs2x2,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.filter_3),
                    title: const Text('3x3 Mode'),
                    trailing: Text(
                      hs3x3,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.grid_on),
                    title: const Text('Uniform 3x3 Mode'),
                    trailing: Text(
                      hsUniform,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
