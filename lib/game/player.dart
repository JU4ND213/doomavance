import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import 'projectile.dart';
import 'package:flame/game.dart';
import 'package:sensors_plus/sensors_plus.dart'; // Para usar acelerómetro
import 'dart:async'; // Para manejar StreamSubscription

class Player extends SpriteComponent with KeyboardHandler, CollisionCallbacks {
  int life = 3;
  double speed = 200;
  double shootCooldown = 0.25; // segundos
  double _timeSinceLastShot = 0.0;
  bool doubleShip = false;

  // Variables para movimiento con acelerómetro
  StreamSubscription? _accelSub;
  double _tiltX = 0.0;

  Player() : super(size: Vector2(50, 50), anchor: Anchor.center);

  Player.doubleShip()
    : doubleShip = true,
      super(size: Vector2(50, 50), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Hitbox para colisiones
    add(RectangleHitbox());

    // Cargar sprite del jugador
    sprite = await Sprite.load('mi_jugador.png');

    // Posicionar jugador en el centro inferior de la pantalla
    final g = findGame();
    if (g is FlameGame) {
      position = Vector2(g.size.x / 2, g.size.y - 80);
    }

    // Escuchar el acelerómetro (API actualizada)
    _accelSub = accelerometerEventStream().listen((event) {
      _tiltX = event.x; // inclinación lateral
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timeSinceLastShot += dt;

    // Movimiento con inclinación del celular
    final g = findGame();
    if (g is FlameGame) {
      double move = -_tiltX * 150 * dt; // Ajusta sensibilidad con el valor 150
      position.x += move;

      // Evita que el jugador se salga de la pantalla
      position.x = position.x.clamp(size.x / 2, g.size.x - size.x / 2);
    }
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

    // Disparar con la barra espaciadora
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
      final leftX = (position.x - 12).clamp(4.0, g.size.x - 4.0);
      final rightX = (position.x + 12).clamp(4.0, g.size.x - 4.0);
      final centerX = position.x.clamp(4.0, g.size.x - 4.0);

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

  /// Método público para disparar (sin teclado)
  void shoot() {
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

  // Cancelar el stream del acelerómetro al eliminar el jugador
  @override
  void onRemove() {
    _accelSub?.cancel();
    super.onRemove();
  }
}
