import 'package:flame/game.dart';
import 'player.dart';
import 'level.dart';
import 'line.dart';
import 'population.dart';
import 'test_platform.dart';

class JumpKingGame extends FlameGame {
  bool testingSinglePlayer = true;
  late Player player;
  late Population population;

  @override
  Future<void> onLoad() async {
    // Default ground platform (your original logic)
    Level level = Level();
    level.lines.add(Line(0, 600, 360, 600)); // ground line at bottom
    add(level);

    // ✅ Add a test platform lower on screen to visually test alignment
    add(TestPlatform());

    if (testingSinglePlayer) {
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
    // Movement is handled in Player.update()
  }

  // Input control hooks
  void onLeftPressed() => player.pressLeft();
  void onLeftReleased() => player.releaseLeft();
  void onRightPressed() => player.pressRight();
  void onRightReleased() => player.releaseRight();
  void onJumpPressed() => player.pressJump();
  void onJumpReleased() => player.releaseJump();
}
