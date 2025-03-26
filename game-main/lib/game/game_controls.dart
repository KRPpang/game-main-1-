import 'package:flutter/material.dart';
import 'jump_king_game.dart';

class GameControls extends StatefulWidget {
  final JumpKingGame game;
  const GameControls({Key? key, required this.game}) : super(key: key);

  @override
  State<GameControls> createState() => _GameControlsState();
}

class _GameControlsState extends State<GameControls> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    bool leftActive = widget.game.player.leftHeld;
    bool rightActive = widget.game.player.rightHeld;
    bool jumpActive = widget.game.player.jumpHeld;

    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTapDown: (_) => widget.game.onLeftPressed(),
                onTapUp: (_) => widget.game.onLeftReleased(),
                onTapCancel: () => widget.game.onLeftReleased(),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: leftActive ? Colors.blueAccent : Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_left, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTapDown: (_) => widget.game.onRightPressed(),
                onTapUp: (_) => widget.game.onRightReleased(),
                onTapCancel: () => widget.game.onRightReleased(),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: rightActive ? Colors.blueAccent : Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_right, color: Colors.white),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTapDown: (_) => widget.game.onJumpPressed(),
            onTapUp: (_) => widget.game.onJumpReleased(),
            onTapCancel: () => widget.game.onJumpReleased(),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: jumpActive ? Colors.greenAccent : Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
