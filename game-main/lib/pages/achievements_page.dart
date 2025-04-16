import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  Future<Map<String, dynamic>> _fetchAchievements() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {};
    final doc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    return data['achievements'] as Map<String, dynamic>? ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Achievements"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchAchievements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No achievements yet."));
          }
          final achievements = snapshot.data!;
          return ListView(
            children: achievements.entries.map((entry) {
              return ListTile(
                leading: const Icon(Icons.emoji_events),
                title: Text(entry.key),
                trailing: entry.value == true
                    ? const Icon(Icons.check, color: Colors.green)
                    : const Icon(Icons.close, color: Colors.red),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
