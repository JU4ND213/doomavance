// pages/game_page.dart
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/doom_avance_game.dart';
import 'game_over_page.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final game = DoomAvanceGame(
      onGameOver: (score) {
        // Navegar a GameOverPage pasando score directamente
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => GameOverPage(score: score)),
        );
      },
    );

    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          game.player.position += Vector2(details.delta.dx, details.delta.dy);
        },
        child: GameWidget(game: game),
      ),
    );
  }
}
