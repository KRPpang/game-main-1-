import 'package:flame/components.dart';
import 'dart:math';
import 'platform.dart';
import 'player.dart';

class PlatformManager extends Component with HasGameRef {
  final Player player;
  final double screenWidth;
  final double chunkHeight = 800;
  final Map<int, List<PlatformBlock>> chunks = {};

  PlatformManager({required this.player, required this.screenWidth});

  void ensureChunksAround(double playerY) {
    final int currentChunk = (playerY / chunkHeight).floor();

    for (int i = currentChunk - 1; i <= currentChunk + 1; i++) {
      if (!chunks.containsKey(i)) {
        chunks[i] = generateChunk(i);
        for (final platform in chunks[i]!) {
          gameRef.add(platform);
        }
      }
    }
  }

  List<PlatformBlock> generateChunk(int chunkIndex) {
    final double baseY = chunkIndex * chunkHeight;
    final Random rand = Random();
    final List<PlatformBlock> platforms = [];

    double currentY = baseY + chunkHeight - 40;
    while (currentY > baseY) {
      double width = rand.nextDouble() * 60 + 40;
      double x = rand.nextDouble() * (screenWidth - width);
      platforms.add(PlatformBlock(position: Vector2(x, currentY), width: width));
      currentY -= rand.nextDouble() * 100 + 80;
    }

    return platforms;
  }
}
