import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/game_screen.dart';
import '../pages/high_score_page.dart';  // Ensure the file contains the HighScoresPage class.
import '../pages/achievements_page.dart';
import '../pages/startup_page.dart'; // Ensure StartupScreen is defined here.
import '../widgets/colorful_memorization_background.dart';
import '../widgets/pixel_button.dart';
import '../services/user_data_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int highestScore2x2 = 0;
  int highestScore3x3 = 0;
  int highestScoreUniform3x3 = 0;
  String _username = ''; // Holds the user's display username.
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final UserDataManager userDataManager = UserDataManager();

  bool _settingsVisible = false; // Whether the settings window is visible.

  @override
  void initState() {
    super.initState();
    fetchScores();
    _checkUsername();
  }

  Future<void> fetchScores() async {
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final progress = doc.data()?['progress'];
    setState(() {
      highestScore2x2 = (progress?['highestScore2x2'] is int)
          ? progress!['highestScore2x2'] as int
          : 0;
      highestScore3x3 = (progress?['highestScore3x3'] is int)
          ? progress!['highestScore3x3'] as int
          : 0;
      highestScoreUniform3x3 = (progress?['highestScoreUniform3x3'] is int)
          ? progress!['highestScoreUniform3x3'] as int
          : 0;
    });
  }

  Future<void> _checkUsername() async {
    if (uid == null) return;
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final doc = await docRef.get();
    final data = doc.data();
    if (data == null ||
        data['username'] == null ||
        (data['username'] as String).trim().isEmpty) {
      Future.delayed(Duration.zero, () => _promptUsername());
    } else {
      setState(() {
        _username = data['username'] as String;
      });
    }
  }

  Future<void> _promptUsername() async {
    String usernameInput = '';
    await showDialog(
      context: context,
      barrierDismissible: false, // Force the user to create a username.
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Username'),
          content: TextField(
            maxLength: 16,
            decoration: const InputDecoration(
              hintText: 'Enter a username (max 16 characters)',
            ),
            onChanged: (value) {
              usernameInput = value.trim();
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (usernameInput.isNotEmpty && usernameInput.length <= 16) {
                  // Save the username.
                  await userDataManager.setUsername(usernameInput);
                  setState(() {
                    _username = usernameInput;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Toggles the custom settings overlay.
  void _toggleSettings() {
    setState(() {
      _settingsVisible = !_settingsVisible;
    });
  }

  /// Called when the user taps outside of the settings overlay.
  void _onBackgroundTap() {
    if (_settingsVisible) {
      _toggleSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: GestureDetector(
        onTap: _onBackgroundTap,
        child: Stack(
          children: [
            // Colorful, relaxing background.
            const ColorfulMemorizationBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Settings button on left; username and achievements on right.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                          onPressed: _toggleSettings,
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _username.isEmpty ? user?.email ?? 'Guest' : _username,
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AchievementsPage()),
                                );
                              },
                              child: const CircleAvatar(
                                backgroundColor: Colors.black54,
                                radius: 20,
                                child: Icon(
                                  Icons.emoji_events,
                                  color: Colors.amber,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Game mode buttons using PixelButton with fixed sizes.
                              PixelButton(
                                label: "Classic",
                                width: 250,
                                height: 60,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const GameScreen(gridSize: 2),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              PixelButton(
                                label: "Hard",
                                width: 250,
                                height: 60,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const GameScreen(gridSize: 3),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              PixelButton(
                                label: "Colorless",
                                width: 250,
                                height: 60,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const GameScreen(
                                        gridSize: 3,
                                        uniform: true,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              PixelButton(
                                label: "View High Scores",
                                width: 250,
                                height: 60,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const HighScoresPage(),  // Correct reference.
                                    ),
                                  );
                                },
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
            // Custom settings overlay.
            if (_settingsVisible)
              Positioned.fill(
                child: _buildSettingsOverlay(),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the custom settings overlay.
  Widget _buildSettingsOverlay() {
    return Stack(
      children: [
        // Semi-transparent dark background.
        Container(
          color: Colors.black54,
        ),
        Center(
          child: Container(
            width: 300,
            height: 260,
            decoration: BoxDecoration(
              color: Colors.greenAccent.shade100,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 8,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    "OPTIONS",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PixelButton(
                    label: "RESUME",
                    width: 200,
                    height: 50,
                    onPressed: _toggleSettings,
                  ),
                  PixelButton(
                    label: "LOGOUT",
                    width: 200,
                    height: 50,
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const StartupScreen()),
                            (route) => false,
                      );
                    },
                  ),
                  PixelButton(
                    label: "EXIT",
                    width: 200,
                    height: 50,
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
