import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'progress': {
          'highestScore': 0,
          'highestPlatform': 0,
        },
        'unlocks': {
          'unlockedSkins': ['default'],
          'currentSkin': 'default',
        },
        'settings': {
          'volume': 1.0,
          'isMuted': false,
        },
        'achievements': {
          'first_jump': false,
          'reached_1000': false,
          'no_miss_run': false,
        },
      });
    }
  }

  Future<void> updateScore(int score, int platform) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docRef = _firestore.collection('users').doc(uid).collection('progress');

    await _firestore.collection('users').doc(uid).update({
      'progress.highestScore': FieldValue.increment(score),
      'progress.highestPlatform': platform,
    });
  }

  Future<void> unlockSkin(String skinName) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).update({
      'unlocks.unlockedSkins': FieldValue.arrayUnion([skinName])
    });
  }

  Future<void> setAchievement(String achievementId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).update({
      'achievements.$achievementId': true,
    });
  }
}
