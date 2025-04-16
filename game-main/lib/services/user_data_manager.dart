import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initializes the user document with default values for scores, settings,
  /// achievements, and username.
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
          // Achievements that unlock when a score of 25 is reached for each mode.
          'score25_2x2': false,
          'score25_3x3': false,
          'score25_uniform3x3': false,
        },
        'username': '',
      });
    }
  }

  /// Updates or sets a specific achievement for the current user.
  Future<void> setAchievement(String achievementKey, bool value) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final docRef = _firestore.collection('users').doc(uid);
    await docRef.update({'achievements.$achievementKey': value});
  }

  /// Sets or updates the username for the current user.
  Future<void> setUsername(String username) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final docRef = _firestore.collection('users').doc(uid);
    await docRef.update({'username': username});
  }

  /// Increments the game high score for a specific mode by 1.
  Future<void> incrementGameScore(String mode) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore.collection('users').doc(uid);
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
        fieldName = 'progress.highestScore2x2';
    }
    await docRef.update({
      fieldName: FieldValue.increment(1),
    });
  }
}
