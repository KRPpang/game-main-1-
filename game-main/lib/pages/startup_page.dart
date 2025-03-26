import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // For Ticker
import '../pages/home_page.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  StartupScreenState createState() => StartupScreenState();
}

class StartupScreenState extends State<StartupScreen> with SingleTickerProviderStateMixin {
  double _time = 0.0;
  late final Ticker _ticker;

  // Asset paths for the 9 parallax layers.
  final List<String> _layerPaths = [
    'assets/images/1.png',
    'assets/images/2.png',
    'assets/images/3fx.png',
    'assets/images/4.png',
    'assets/images/5.png',
    'assets/images/6fx.png',
    'assets/images/7.png',
    'assets/images/8fx.png',
    'assets/images/9.png',
  ];

  // Parallax factors for each layer. The nearest layer (factor 1.0) moves fastest.
  final List<double> _parallaxFactors = [
    1.0,
    0.9,
    0.8,
    0.7,
    0.6,
    0.5,
    0.4,
    0.3,
    0.2,
  ];

  // Global speed factor to adjust overall movement speed.
  final double globalSpeed = 0.015;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      setState(() {
        // Update _time in seconds continuously.
        _time = elapsed.inMilliseconds / 1000.0;
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions.
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth  = MediaQuery.of(context).size.width;
    // Assume a fixed aspect ratio (e.g., 16/9) for your parallax images.
    const double aspectRatio = 16 / 9;
    // Compute the image width when scaled to fill the screen height.
    final double imageWidth = screenHeight * aspectRatio;

    // Build parallax layers with an infinite loop effect.
    List<Widget> layers = [];
    for (int i = 0; i < _layerPaths.length; i++) {
      // Speed is the full image width multiplied by parallax factor and globalSpeed.
      final double speed = imageWidth * _parallaxFactors[i] * globalSpeed;
      // Calculate current horizontal offset (delta) that loops seamlessly.
      final double delta = (speed * _time) % imageWidth;

      // First copy.
      layers.add(
        Transform.translate(
          offset: Offset(-delta, 0),
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            minWidth: 0,
            maxWidth: double.infinity,
            child: Image.asset(
              _layerPaths[i],
              height: screenHeight,
              width: imageWidth,
              fit: BoxFit.fill,
            ),
          ),
        ),
      );
      // Second copy immediately to the right.
      layers.add(
        Transform.translate(
          offset: Offset(-delta + imageWidth, 0),
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            minWidth: 0,
            maxWidth: double.infinity,
            child: Image.asset(
              _layerPaths[i],
              height: screenHeight,
              width: imageWidth,
              fit: BoxFit.fill,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Parallax background layers.
          ...layers,
          // Dark overlay to reduce brightness; adjust opacity as needed.
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          // UI overlay: Logo and Start Game button.
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/DEPTHS.png',
                  width: screenWidth * 0.8,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: const SizedBox(
                          width: 320,
                          height: 420,
                          child: HomePage(),
                        ),
                      ),
                    );

                  },


                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Start Game',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
