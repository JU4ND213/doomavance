import 'package:flame/components.dart';
import 'package:flutter/services.dart';

class Player extends SpriteComponent with KeyboardHandler {
  int life = 3;
  double speed = 200;

  Player()
    : super(
        size: Vector2(50, 50),
        position: Vector2(400, 300),
        anchor: Anchor.center,
      );

  @override
  Future<void> onLoad() async {
    // La ruta debe coincidir exactamente con pubspec.yaml
    sprite = await Sprite.load('mi_jugador.png');
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    Vector2 dir = Vector2.zero();

    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) dir.y = -1;
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) dir.y = 1;
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) dir.x = -1;
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) dir.x = 1;

    if (dir != Vector2.zero()) {
      position += dir.normalized() * speed * 0.016;
    }

    return true;
  }
}
