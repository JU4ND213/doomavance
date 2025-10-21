import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'dart:ui';
import 'player.dart';
import 'enemy.dart';

class Projectile extends RectangleComponent with CollisionCallbacks {
  final double speed;

  Projectile({required Vector2 position, this.speed = 500})
    : super(
        size: Vector2(6, 12),
        position: position,
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0xFFFFFF00),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Move upward
    position.add(Vector2(0, -speed * dt));

    // Remove if out of screen (game size may not be available yet)
    final g = findGame();
    if (g is FlameGame) {
      if (position.y + size.y < 0 || position.y - size.y > g.size.y) {
        removeFromParent();
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    // Don't collide with the player that fired the shot
    if (other is Player) return;
    // If we hit an Enemy, let the Enemy handle its own death and scoring.
    if (other is Enemy) {
      // Only remove the projectile; the enemy's onCollision will remove itself and award score.
      removeFromParent();
      return;
    }

    // For other things (obstacles, etc.) remove both by default
    other.removeFromParent();
    removeFromParent();
  }
}
