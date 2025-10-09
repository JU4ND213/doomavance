import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'player.dart';
import 'hud.dart';

class DoomAvanceGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  DoomAvanceGame({required this.onGameOver});

  final Function(int score) onGameOver;

  late Player player;
  late Hud hud;
  int score = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Configurar viewport fijo
    camera.viewport = FixedResolutionViewport(resolution: Vector2(800, 600));

    // Jugador
    player = Player();
    add(player);

    // HUD
    hud = Hud();
    add(hud);
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
