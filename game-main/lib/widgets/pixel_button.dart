import 'package:flutter/material.dart';

class PixelButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final double? width;
  final double? height;

  const PixelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
    this.height,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Increase scale by 10% when hovered or pressed.
    final scale = (_isHovered || _isPressed) ? 1.1 : 1.0;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _isPressed = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            _isPressed = false;
          });
          widget.onPressed();
        },
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: widget.width,
          height: widget.height,
          // Apply a scale transform to indicate hover/press.
          transform: Matrix4.identity()..scale(scale, scale),
          transformAlignment: Alignment.center,
          child: Stack(
            children: [
              // Base background with pixelated borders.
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Pixel-style corner "rounding" blocks.
              Positioned(top: 0, left: 0, child: _pixelCorner(6.0)),
              Positioned(top: 0, right: 0, child: _pixelCorner(6.0)),
              Positioned(bottom: 0, left: 0, child: _pixelCorner(6.0)),
              Positioned(bottom: 0, right: 0, child: _pixelCorner(6.0)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pixelCorner(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
      ),
    );
  }
}
