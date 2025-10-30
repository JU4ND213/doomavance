import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

/// Componente visual para representar una explosión corta.
/// Incluye una animación de expansión y desvanecimiento,
/// y se elimina automáticamente tras completarse.
class Explosion extends PositionComponent {
  /// Tamaño base de la explosión.
  static const double baseSize = 24.0;

  /// Crea una explosión en la posición indicada.
  Explosion({required Vector2 position})
    : super(
        position: position,
        size: Vector2.all(baseSize),
        anchor: Anchor.center,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Crea un rectángulo brillante como base de la explosión.
    final rect = RectangleComponent(
      size: size,
      anchor: Anchor.center,
      paint: Paint()
        ..color = Colors.orangeAccent.withAlpha((0.9 * 255).round()),
    );
    add(rect);

    // Animación: se expande y se desvanece simultáneamente.
    add(
      ScaleEffect.to(
        Vector2.all(1.8),
        EffectController(duration: 0.28, curve: Curves.easeOut),
      ),
    );

    rect.add(
      OpacityEffect.to(
        0.0,
        EffectController(duration: 0.28, curve: Curves.easeOut),
      ),
    );

    // Intenta reproducir un efecto de sonido (si el juego lo define).
    try {
      final g = findGame();
      if (g != null) (g as dynamic).playSfx?.call('explosion');
    } catch (_) {
      // Silencio: el sonido es opcional
    }

    // Elimina la explosión tras completarse la animación.
    Future.delayed(const Duration(milliseconds: 320), () {
      removeFromParent();
    });
  }
}
