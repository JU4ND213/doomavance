// game/doom_avance_game.dart
import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'dart:math';
import 'dart:ui';
import 'player.dart';
import 'hud.dart';

class Obstacle extends PositionComponent with CollisionCallbacks {
  final VoidCallback onHit;

  Obstacle({required this.onHit, required Vector2 position})
    : super(position: position, size: Vector2(50, 50), anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    // Hitbox para colisión
    add(RectangleHitbox());
    // Representación visual del obstáculo
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFFFF0000),
      ),
    );
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player) {
      onHit();
      removeFromParent();
    }
  }
}

class DoomAvanceGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  DoomAvanceGame({required this.onGameOver});

  final Function(int score) onGameOver;
  late Player player;
  late Hud hud;
  int score = 0;
  final Random random = Random();

  @override
  Future<void> onLoad() async {
    camera.viewport = FixedResolutionViewport(resolution: Vector2(800, 600));

    player = Player();
    add(player);

    hud = Hud();
    add(hud);

    // Obstáculos iniciales
    for (int i = 0; i < 5; i++) {
      addObstacle();
    }
  }

  void addObstacle() {
    final pos = Vector2(
      random.nextDouble() * (800 - 50),
      random.nextDouble() * (600 - 50),
    );
    add(Obstacle(position: pos, onHit: decreaseLife));
  }

  void increaseScore() {
    score += 10;
    hud.updateScore(score);
  }

  void decreaseLife() {
    player.life -= 1;
    hud.updateLife(player.life);
    if (player.life <= 0) {
      onGameOver(score);
    }
  }
}
