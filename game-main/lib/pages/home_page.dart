import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int highestScore = 0;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    fetchScore();
  }

  Future<void> fetchScore() async {
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final score = doc.data()?['progress']?['highestScore'];

    setState(() {
      highestScore = (score is int) ? score : 0;
    });
  }

  Future<void> increaseScore() async {
    if (uid == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);

    // Fetch current score from Firestore
    final snapshot = await docRef.get();
    final current = snapshot.data()?['progress']?['highestScore'] ?? 0;
    final updated = current + 100;

    // Write updated score to Firestore
    await docRef.set({
      'progress': {'highestScore': updated}
    }, SetOptions(merge: true));

    // Update local UI
    setState(() {
      highestScore = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome, ${user?.email ?? 'Guest'}"),
            SizedBox(height: 20),
            Text("Highest Score: $highestScore", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: increaseScore,
              child: Text("Add +100 to Highest Score"),
            ),
          ],
        ),
      ),
    );
  }
}
