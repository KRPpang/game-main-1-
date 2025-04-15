// lib/pages/startup_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:game/pages/login_page.dart';
import 'package:game/widgets/pixel_button.dart'; // ✅ Import the button

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  StartupScreenState createState() => StartupScreenState();
}

class StartupScreenState extends State<StartupScreen>
    with SingleTickerProviderStateMixin {
  double _time = 0.0;
  late final Ticker _ticker;

  final List<String> _layerPaths = [
    'assets/images/1.png',
    'assets/images/2.png',
    'assets/images/3.png',
    'assets/images/4.png',
    'assets/images/5.png',
    'assets/images/6.png',
  ];

  final List<double> _parallaxFactors = [
    0.7,
    0.6,
    0.5,
    0.4,
    0.3,
    0.2,
  ];

  final double globalSpeed = 0.015;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      setState(() {
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    const double aspectRatio = 16 / 9;
    final double imageHeight = screenHeight * 0.85;
    final double imageWidth = imageHeight * aspectRatio;

    List<Widget> layers = [];
    for (int i = 0; i < _layerPaths.length; i++) {
      final double speed = imageWidth * _parallaxFactors[i] * globalSpeed;
      final double delta = (speed * _time) % imageWidth;

      layers.add(
        Transform.translate(
          offset: Offset(-delta, 0),
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            minWidth: 0,
            maxWidth: double.infinity,
            child: Image.asset(
              _layerPaths[i],
              height: imageHeight,
              width: imageWidth,
              fit: BoxFit.fill,
            ),
          ),
        ),
      );

      layers.add(
        Transform.translate(
          offset: Offset(-delta + imageWidth, 0),
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            minWidth: 0,
            maxWidth: double.infinity,
            child: Image.asset(
              _layerPaths[i],
              height: imageHeight,
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
          ...layers,
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

                // ✅ Pixel-style start button
                PixelButton(
                  label: 'START GAME',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const SizedBox(
                          width: 320,
                          height: 420,
                          child: LoginPage(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
