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
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );

    lifeText = TextComponent(
      text: "Vida: 3",
      position: Vector2(10, 40),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.red, fontSize: 18),
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
