import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/doom_avance_game.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final game = DoomAvanceGame(
      onGameOver: (score) {
        Navigator.pushReplacementNamed(
          context,
          "/gameover",
          arguments: {"score": score},
        );
      },
    );

    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          // Solo aumentamos la posición del jugador según el dedo
          game.player.position += Vector2(details.delta.dx, details.delta.dy);
        },
        child: GameWidget(game: game),
      ),
    );
  }
}
