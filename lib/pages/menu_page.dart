import 'package:flutter/material.dart';
import 'game_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menu Doom")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GamePage()),
            );
          },
          child: const Text("Iniciar Juego"),
        ),
      ),
    );
  }
}
