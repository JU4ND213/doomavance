import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'menu_page.dart';

class GameOverPage extends StatelessWidget {
  final int score;

  const GameOverPage({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF081E08),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                color: const Color(0xFF0B3D0B),
                elevation: 16,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 68,
                        color: Color(0xFFFFD600),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'GAME OVER',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.lightGreenAccent,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '¡Buen intento!',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Animated score counter
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: score),
                        duration: const Duration(milliseconds: 900),
                        builder: (context, value, _) => Text(
                          value.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 6,
                                color: Colors.black45,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Puntaje final',
                        style: TextStyle(color: Colors.white70),
                      ),

                      const SizedBox(height: 26),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.replay),
                              label: const Text('Jugar de nuevo'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E6B0F),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                // Navigate back to menu which should handle starting a new game
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const MenuPage(),
                                  ),
                                  (route) => false,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            tooltip: 'Compartir puntaje',
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF3C8D0D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.share),
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              await Clipboard.setData(
                                ClipboardData(
                                  text: 'Mi puntaje en Doom: $score',
                                ),
                              );
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Puntaje copiado al portapapeles',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const MenuPage()),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Volver al menú',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
