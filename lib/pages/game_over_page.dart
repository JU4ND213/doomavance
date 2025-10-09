import 'package:flutter/material.dart';
import 'menu_page.dart';

class GameOverPage extends StatelessWidget {
  final int score;

  const GameOverPage({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Game Over")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Puntaje final: $score", style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MenuPage()),
                  (_) => false,
                );
              },
              child: const Text("Volver al menú"),
            ),
          ],
        ),
      ),
    );
  }
}
