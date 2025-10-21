import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class Explosion extends PositionComponent {
  Explosion({required Vector2 position})
    : super(position: position, size: Vector2(24, 24), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final rect = RectangleComponent(
      size: size,
      anchor: Anchor.center,
      paint: Paint()..color = Colors.orangeAccent,
    );
    add(rect);

    // Scale up and fade out
    add(ScaleEffect.to(Vector2.all(1.8), EffectController(duration: 0.28)));
    rect.add(OpacityEffect.to(0.0, EffectController(duration: 0.28)));

    // Optional sfx hook if the game exposes one
    try {
      final g = findGame();
      if (g != null) (g as dynamic).playSfx?.call('explosion');
    } catch (_) {}

    // Remove after animation
    Future.delayed(const Duration(milliseconds: 320), () => removeFromParent());
  }
}
