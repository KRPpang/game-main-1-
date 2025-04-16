import 'package:flutter/material.dart';

class ColorfulMemorizationBackground extends StatefulWidget {
  const ColorfulMemorizationBackground({super.key});

  @override
  _ColorfulMemorizationBackgroundState createState() => _ColorfulMemorizationBackgroundState();
}

class _ColorfulMemorizationBackgroundState extends State<ColorfulMemorizationBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation1;
  late Animation<Color?> _colorAnimation2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    // Animate from a pink accent to a light blue accent.
    _colorAnimation1 = ColorTween(
      begin: Colors.pinkAccent,
      end: Colors.lightBlueAccent,
    ).animate(_controller);

    // Animate from a deep purple to an orange accent.
    _colorAnimation2 = ColorTween(
      begin: Colors.deepPurpleAccent,
      end: Colors.orangeAccent,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _colorAnimation1.value ?? Colors.pinkAccent,
                _colorAnimation2.value ?? Colors.deepPurpleAccent,
              ],
            ),
          ),
        );
      },
    );
  }
}
