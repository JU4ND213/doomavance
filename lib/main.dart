import 'package:flutter/material.dart';
import 'pages/menu_page.dart';
import 'pages/game_over_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Avance Doom',
      theme: ThemeData.dark(useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (_) => const MenuPage(),
        '/gameover': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>?;
          final score = args?['score'] ?? 0;
          return GameOverPage(score: score);
        },
      },
    );
  }
}
