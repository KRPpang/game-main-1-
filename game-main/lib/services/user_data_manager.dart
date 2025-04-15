// lib/user_data_manager.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initializes the user document with default values
  /// for the three game-mode high scores, settings, and achievements.
  Future<void> initUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'progress': {
          'highestScore2x2': 0,
          'highestScore3x3': 0,
          'highestScoreUniform3x3': 0,
        },
        'settings': {
          'volume': 1.0,
          'isMuted': false,
        },
        'achievements': {
          'first_high_score': false,
          'milestone_high_score': false,
        },
      });
    }
  }

  /// Increments the game high score for a specific mode by 1.
  ///
  /// [mode] should be one of: "2x2", "3x3", "uniform3x3".
  Future<void> incrementGameScore(String mode) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore.collection('users').doc(uid);

    // Determine which field to increment based on the mode.
    String fieldName;
    switch (mode) {
      case '2x2':
        fieldName = 'progress.highestScore2x2';
        break;
      case '3x3':
        fieldName = 'progress.highestScore3x3';
        break;
      case 'uniform3x3':
        fieldName = 'progress.highestScoreUniform3x3';
        break;
      default:
        fieldName = 'progress.highestScore2x2'; // Fallback mode.
    }

    // Atomically increment by 1.
    await docRef.update({
      fieldName: FieldValue.increment(1),
    });
  }
}
