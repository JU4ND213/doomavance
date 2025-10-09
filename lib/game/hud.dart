// game/hud.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Hud extends PositionComponent {
  late TextComponent scoreText;
  late TextComponent lifeText;

  @override
  Future<void> onLoad() async {
    scoreText = TextComponent(
      text: "Score: 0",
      position: Vector2(10, 10),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.lightGreenAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 4,
              color: Color(0xFF0B3D0B),
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    );

    lifeText = TextComponent(
      text: "Vida: 3",
      position: Vector2(10, 40),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 4,
              color: Color(0xFF3C8D0D),
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    );

    add(scoreText);
    add(lifeText);
  }

  void updateScore(int score) {
    scoreText.text = "Score: $score";
  }

  void updateLife(int life) {
    lifeText.text = "Vida: $life";
  }
}
