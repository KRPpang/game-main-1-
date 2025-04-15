import 'package:flutter/material.dart';

class PixelButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const PixelButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const double blockSize = 6.0;

    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        children: [
          // Base background
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Pixel-style corner "rounding" blocks
          Positioned(top: 0, left: 0, child: _pixelCorner(blockSize)),
          Positioned(top: 0, right: 0, child: _pixelCorner(blockSize)),
          Positioned(bottom: 0, left: 0, child: _pixelCorner(blockSize)),
          Positioned(bottom: 0, right: 0, child: _pixelCorner(blockSize)),
        ],
      ),
    );
  }

  Widget _pixelCorner(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
      ),
    );
  }
}
