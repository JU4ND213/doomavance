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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => GameOverPage(score: score)),
          );
        });
      },
      onMessage: (msg) {
        // show a SnackBar from the page context
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        });
      },
    );

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          // usar un método del juego para aplicar el movimiento y convertir a coordenadas del mundo si hace falta
          game.movePlayerBy(Vector2(details.delta.dx, details.delta.dy));
        },
        child: GameWidget(game: game),
      ),
    );
  }
}
