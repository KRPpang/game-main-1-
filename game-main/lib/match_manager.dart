// lib/match_manager.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Creates a new match (lobby) document with the creator’s UID.
  Future<String?> createMatch() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final docRef = _firestore.collection('matches').doc();
    await docRef.set({
      'players': [uid],
      'currentTurn': uid,
      'status': 'waiting', // waiting: lobby open; later becomes "ongoing"
      'sequence': [],
      'scores': {uid: 0},
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Joins an existing match (lobby) that is in waiting status.
  Future<String?> joinMatch(String matchId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final docRef = _firestore.collection('matches').doc(matchId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return null;

    final data = snapshot.data()!;
    List<dynamic> players = data['players'] ?? [];
    if (players.length < 2) {
      players.add(uid);
      Map<String, dynamic> scores =
      Map<String, dynamic>.from(data['scores'] ?? {});
      scores[uid] = 0;
      await docRef.update({
        'players': players,
        'scores': scores,
        'status': 'waiting', // still waiting for the owner to start.
      });
      return matchId;
    }
    return null;
  }

  /// Returns a stream to listen to match document updates.
  Stream<DocumentSnapshot> listenToMatch(String matchId) {
    return _firestore.collection('matches').doc(matchId).snapshots();
  }

  /// Updates the match document after a turn.
  Future<void> updateMatchAfterTurn({
    required String matchId,
    required List<int> newSequence,
    required String nextTurn,
    required Map<String, dynamic> updatedScores,
  }) async {
    final docRef = _firestore.collection('matches').doc(matchId);
    await docRef.update({
      'sequence': newSequence,
      'currentTurn': nextTurn,
      'scores': updatedScores,
    });
  }

  /// Starts the match by updating the status to "ongoing".
  Future<void> startMatch(String matchId) async {
    final docRef = _firestore.collection('matches').doc(matchId);
    await docRef.update({'status': 'ongoing'});
  }

  /// Marks the match as finished.
  Future<void> finishMatch(String matchId) async {
    final docRef = _firestore.collection('matches').doc(matchId);
    await docRef.update({'status': 'finished'});
  }
}
