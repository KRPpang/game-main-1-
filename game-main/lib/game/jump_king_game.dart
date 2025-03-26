import 'package:flame/game.dart';
import 'player.dart';
import 'level.dart';
import 'line.dart';
import 'population.dart';

class JumpKingGame extends FlameGame {
  // Toggle between single-player and AI mode.
  bool testingSinglePlayer = true;
  late Player player;
  late Population population;

  @override
  Future<void> onLoad() async {
    // Create a simple level with a ground at y = 600.
    Level level = Level();
    level.lines.add(Line(0, 600, 360, 600));
    add(level);

    if (testingSinglePlayer) {
      // Place the player at a visible location.
      player = Player(startX: 180, startY: 300);
      add(player);
    } else {
      population = Population(100);
      for (var p in population.players) {
        add(p);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // When the player is on the ground and not charging a jump,
    // allow normal walking.
    if (player.isOnGround && !player.jumpHeld) {
      if (player.leftHeld) player.moveLeft(dt);
      if (player.rightHeld) player.moveRight(dt);
    }
  }

  // On-screen control callbacks.
  void onLeftPressed() => player.pressLeft();
  void onLeftReleased() => player.releaseLeft();
  void onRightPressed() => player.pressRight();
  void onRightReleased() => player.releaseRight();
  void onJumpPressed() => player.pressJump();
  void onJumpReleased() => player.releaseJump();
}
