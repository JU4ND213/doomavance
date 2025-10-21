import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'dart:math';
import 'projectile.dart';
import 'player.dart';
import 'explosion.dart';

enum EnemyState { inFormation, diving, dead }

class Enemy extends SpriteComponent with CollisionCallbacks {
  EnemyState state = EnemyState.inFormation;
  final double diveSpeed;
  final Vector2 formationPosition;
  double _diveProgress = 0.0;
  bool _notifiedKilled = false; // ensure game is notified only once per enemy
  Vector2? _diveTarget;
  bool _homeToPlayer = false;

  double get diveProgress => _diveProgress;

  // Public constants for layout so other modules can align formations.
  static const double defaultWidth = 36.0;
  static const double defaultHeight = 28.0;

  Enemy({required this.formationPosition, this.diveSpeed = 180})
    : super(size: Vector2(defaultWidth, defaultHeight), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Optional: load a default enemy sprite if available
    final g = findGame();
    if (g is FlameGame) {
      try {
        final img = await g.images.load('enemy.png');
        sprite = Sprite(img);
      } catch (_) {}
    }
    add(RectangleHitbox());
    position = formationPosition.clone();
  }

  void startDive(Vector2 target) {
    if (state == EnemyState.inFormation) {
      state = EnemyState.diving;
      _diveProgress = 0.0;
      // If the game currently has a player, home towards them, otherwise
      // use the provided fallback target (e.g., bottom-center).
      final g = findGame();
      try {
        final player = (g as dynamic).player;
        if (player != null) {
          _homeToPlayer = true;
          _diveTarget = null;
          return;
        }
      } catch (_) {}
      _homeToPlayer = false;
      _diveTarget = target.clone();
    }
  }

  @override
  void onRemove() {
    // If this enemy is being removed for any reason and the game hasn't been
    // notified about its removal (killed or otherwise), notify so wave
    // bookkeeping stays correct.
    if (!_notifiedKilled) {
      try {
        final g = findGame();
        if (g != null) (g as dynamic).onEnemyKilled();
      } catch (_) {}
      _notifiedKilled = true;
    }

    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (state == EnemyState.diving) {
      // move towards the player's current position if available (homing),
      // otherwise move toward the stored target.
      _diveProgress += dt * diveSpeed;
      final g = findGame();
      Vector2? target;
      if (_homeToPlayer) {
        try {
          final player = (g as dynamic).player;
          if (player != null) target = player.position.clone();
        } catch (_) {}
      }
      target ??= _diveTarget;

      if (target != null) {
        final dir = (target - position);
        final dist = dir.length;
        if (dist > 1e-6) {
          final movement = dir.normalized() * diveSpeed * dt;
          position.add(movement);
        }

        // If we've reached the target (or gone below screen), remove
        if (dist < 18.0) {
          removeFromParent();
          return;
        }
      } else {
        // fallback: gentle downward movement
        position.add(
          Vector2(sin(_diveProgress / 30) * 30 * dt, diveSpeed * dt),
        );
      }

      // Remove if below the screen by a margin
      try {
        if (g != null && (g as dynamic).size != null) {
          final gy = (g as dynamic).size.y as double;
          if (position.y > gy + 50) {
            removeFromParent();
          }
        }
      } catch (_) {}
    } else if (state == EnemyState.inFormation) {
      // stay roughly at formation position (manual lerp)
      final diff = formationPosition.clone()..sub(position);
      position.add(diff..scale(0.08));
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    // If hit by projectile, die
    if (other is Projectile) {
      if (state == EnemyState.dead) return; // already processed
      state = EnemyState.dead;
      other.removeFromParent();
      _notifiedKilled = true; // we'll notify immediately below

      // Explosion feedback and award score
      final g = findGame();
      if (g is FlameGame) {
        g.add(Explosion(position: position.clone()));
        try {
          (g as dynamic).increaseScore();
          // notify game that an enemy has been removed (for wave tracking)
          try {
            (g as dynamic).onEnemyKilled();
          } catch (_) {}
        } catch (_) {}
      }

      // schedule removal after a short delay so explosion can show
      Future.delayed(
        const Duration(milliseconds: 50),
        () => removeFromParent(),
      );
      return;
    }

    // If colliding with player, deal damage
    if (other is Player) {
      try {
        final g = findGame();
        if (g != null) (g as dynamic).decreaseLife();
      } catch (_) {}
      // Optionally remove enemy on impact
      removeFromParent();
      return;
    }
  }
}

class CapturerEnemy extends Enemy {
  CapturerEnemy({required super.formationPosition, super.diveSpeed = 120});

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // Let base class handle projectile hits and deaths (it calls onEnemyKilled and spawn explosion)
    super.onCollision(intersectionPoints, other);

    // If collides with player, capture them
    if (other is Player) {
      // Remove player and notify game
      other.removeFromParent();
      try {
        final g = findGame();
        if (g != null) (g as dynamic).capturePlayer();
      } catch (_) {}
    }
  }
}
