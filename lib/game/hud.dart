// game/hud.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/input.dart';
import 'package:doom/game/doom_avance_game.dart';

class Hud extends PositionComponent {
  late TextComponent scoreText;
  late TextComponent lifeText;
  late TextComponent waveText;
  DoomAvanceGame? _game;

  @override
  Future<void> onLoad() async {
    // cache game reference for reliable button callbacks
    final g = findGame();
    if (g is DoomAvanceGame) _game = g;

    scoreText = TextComponent(
      text: "Score: 0",
      position: Vector2(0, 10),
      anchor: Anchor.topCenter,
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
      position: Vector2(0, 40),
      anchor: Anchor.topCenter,
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
    waveText = TextComponent(
      text: "Wave: 1",
      position: Vector2(0, 70),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(waveText);

    // Save / Load buttons (touch-friendly) using Flame's ButtonComponent
    // button sizing: make them wider on small screens for easier touch
    double availableWidth = 800.0;
    final game = _game ?? findGame();
    if (game != null) {
      try {
        availableWidth = (game as dynamic).size.x as double;
      } catch (_) {}
    }
    final buttonBaseWidth = (availableWidth * 0.08).clamp(56.0, 120.0);
    final buttonHeight = 36.0;
    final paddingRight = 12.0;

    final saveButton = ButtonComponent(
      button: RectangleComponent(
        size: Vector2(buttonBaseWidth, buttonHeight),
        paint: Paint()..color = const Color.fromRGBO(0, 0, 0, 0.6),
      ),
      onPressed: () async {
        final g = _game ?? findGame();
        if (g is DoomAvanceGame) {
          await g.saveGame();
        }
      },
      children: [
        TextComponent(
          text: 'Guardar',
          anchor: Anchor.center,
          position: Vector2(buttonBaseWidth / 2, buttonHeight / 2),
          textRenderer: TextPaint(
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    )..position = Vector2(availableWidth - buttonBaseWidth - paddingRight, 10);

    final loadButton =
        ButtonComponent(
            button: RectangleComponent(
              size: Vector2(buttonBaseWidth, buttonHeight),
              paint: Paint()..color = const Color.fromRGBO(0, 0, 0, 0.6),
            ),
            onPressed: () async {
              final g = _game ?? findGame();
              if (g is DoomAvanceGame) {
                await g.loadGame();
              }
            },
            children: [
              TextComponent(
                text: 'Cargar',
                anchor: Anchor.center,
                position: Vector2(buttonBaseWidth / 2, buttonHeight / 2),
                textRenderer: TextPaint(
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          )
          ..position = Vector2(
            availableWidth - buttonBaseWidth * 2 - paddingRight - 8,
            10,
          );

    add(saveButton);
    add(loadButton);
  }

  void updateScore(int score) {
    scoreText.text = "Score: $score";
  }

  void updateLife(int life) {
    lifeText.text = "Vida: $life";
  }

  void updateWave(int wave) {
    waveText.text = "Wave: $wave";
  }
}
