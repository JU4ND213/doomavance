import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import 'projectile.dart';
import 'package:flame/game.dart';

class Player extends SpriteComponent with KeyboardHandler, CollisionCallbacks {
  int life = 3;
  double speed = 200;
  double shootCooldown = 0.25; // seconds
  double _timeSinceLastShot = 0.0;
  bool doubleShip = false;

  Player() : super(size: Vector2(50, 50), anchor: Anchor.center);

  Player.doubleShip()
    : doubleShip = true,
      super(size: Vector2(50, 50), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Agregamos el hitbox para detectar colisiones
    add(RectangleHitbox());

    // La ruta debe coincidir exactamente con pubspec.yaml
    sprite = await Sprite.load('mi_jugador.png');
    // place player centered horizontally, and near bottom with a margin
    final g = findGame();
    if (g is FlameGame) {
      position = Vector2(g.size.x / 2, g.size.y - 80);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timeSinceLastShot += dt;
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    Vector2 dir = Vector2.zero();

    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) dir.y = -1;
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) dir.y = 1;
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) dir.x = -1;
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) dir.x = 1;

    if (dir != Vector2.zero()) {
      // Use game's delta approximation: try to get the game's dt via parent update is not available here,
      // so use a safe step based on 60fps for input steps; major movement happens in update loop when integrating velocity.
      position += dir.normalized() * speed * 0.016;
    }

    // Shoot when space is pressed
    if (keysPressed.contains(LogicalKeyboardKey.space)) {
      _tryShoot();
    }

    return true;
  }

  void _tryShoot() {
    if (_timeSinceLastShot < shootCooldown) return;
    _timeSinceLastShot = 0.0;

    final g = findGame();
    if (g is FlameGame) {
      // Spawn projectile a bit above the player and clamp X so projectile is visible
      final leftX = (position.x - 12).clamp(0.0 + 4.0, g.size.x - 4.0);
      final rightX = (position.x + 12).clamp(0.0 + 4.0, g.size.x - 4.0);
      final centerX = position.x.clamp(0.0 + 4.0, g.size.x - 4.0);

      if (doubleShip) {
        final left = Vector2(leftX, position.y - size.y / 2 - 8);
        final right = Vector2(rightX, position.y - size.y / 2 - 8);
        g.add(Projectile(position: left));
        g.add(Projectile(position: right));
      } else {
        final projPos = Vector2(centerX, position.y - size.y / 2 - 8);
        g.add(Projectile(position: projPos));
      }
    }
  }

  /// Public shoot method so the game or input handlers can trigger a shot.
  void shoot() {
    // Reuse _tryShoot logic but bypass keyboard check
    if (_timeSinceLastShot < shootCooldown) return;
    _timeSinceLastShot = 0.0;

    final g = findGame();
    if (g is FlameGame) {
      if (doubleShip) {
        final left = Vector2(position.x - 12, position.y - size.y / 2 - 8);
        final right = Vector2(position.x + 12, position.y - size.y / 2 - 8);
        g.add(Projectile(position: left));
        g.add(Projectile(position: right));
      } else {
        final projPos = Vector2(position.x, position.y - size.y / 2 - 8);
        g.add(Projectile(position: projPos));
      }
    }
  }
}
