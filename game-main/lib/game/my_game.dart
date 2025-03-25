import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/camera.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame/collisions.dart';

import 'player.dart';
import 'platform.dart';
import 'platform_manager.dart';

class MyGame extends FlameGame with HasCollisionDetection {
  // Designed resolution of your game world
  final Vector2 mapSize = Vector2(256, 448);

  // Create the camera immediately.
  final CameraComponent cameraComponent = CameraComponent();

  late final Player player;
  late final World world;

  // Each tile is 16 pixels; reserve 8 tiles (128 pixels) for controls at the bottom.
  static const double tileSize = 16.0;
  static const double controlOffset = 8 * tileSize; // 128 pixels

  double currentScale = 1.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create and add the world container.
    world = World();
    add(world);

    // Assign the world to the camera and add it.
    cameraComponent.world = world;
    add(cameraComponent);

    // Set the viewfinder's anchor so that the follow target appears higher.
    // Default is Anchor.center (i.e. (0.5, 0.5)). Changing to (0.5, 0.35)
    // will shift the map upward, leaving space at the bottom for controls.
    cameraComponent.viewfinder.anchor = Anchor(0.5, 0.35);

    // Load and add your Tiled map.
    final map = await TiledComponent.load('2.tmx', Vector2.all(tileSize));
    map.position = Vector2.zero();
    world.add(map);

    // Create and add the player.
    player = Player(position: Vector2(mapSize.x / 2, 300));
    world.add(player);

    // Add a ground platform so the player doesn't fall off.
    final ground = PlatformBlock(
      position: Vector2(0, 340),
      width: mapSize.x,
    );
    world.add(ground);

    // Add the procedural platform manager.
    add(PlatformManager(player: player, screenWidth: mapSize.x));

    // Follow the player directly.
    cameraComponent.follow(player);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    // Compute horizontal scale based on the full width,
    // and vertical scale based on the available height (screen height minus reserved control space).
    final scaleX = size.x / mapSize.x;
    final scaleY = (size.y - controlOffset) / mapSize.y;
    // Use the smaller scale factor to ensure the entire game world fits.
    currentScale = math.min(scaleX, scaleY);

    // Apply the computed zoom.
    cameraComponent.viewfinder.zoom = currentScale;
  }
}
