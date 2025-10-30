import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'menu_page.dart';

/// Página que muestra la pantalla de fin de juego.
/// Incluye animaciones, puntaje final y opciones de reinicio o compartir.
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
                color: const Color(0xFF0E3B0E),
                elevation: 20,
                // Reemplazo: withOpacity -> withValues(alpha: ...)
                shadowColor: Colors.greenAccent.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🏆 Ícono principal con animación sutil
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.8, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, scale, _) => Transform.scale(
                          scale: scale,
                          child: const Icon(
                            Icons.emoji_events,
                            size: 80,
                            color: Color(0xFFFFD600),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 🕹️ Título principal
                      Text(
                        'GAME OVER',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.lightGreenAccent,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 💬 Subtítulo
                      Text(
                        '¡Buen intento, guerrero!',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // 🔢 Puntaje animado
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: score),
                        duration: const Duration(milliseconds: 1000),
                        builder: (context, value, _) => Text(
                          value.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 54,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black54,
                                offset: Offset(3, 3),
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

                      const SizedBox(height: 30),

                      // 🎮 Botones de acción principales
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.replay, size: 20),
                              label: const Text(
                                'Jugar de nuevo',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E6B0F),
                                foregroundColor: Colors.white,
                                elevation: 6,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
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
                          // 📤 Botón compartir
                          IconButton(
                            tooltip: 'Compartir puntaje',
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF3C8D0D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.share, size: 26),
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              await Clipboard.setData(
                                ClipboardData(
                                  text:
                                      '🎮 Mi puntaje en Doom fue $score puntos. ¡Desafíame si te atreves!',
                                ),
                              );
                              messenger.showSnackBar(
                                const SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.green,
                                  content: Text(
                                    'Puntaje copiado al portapapeles ✅',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 🔙 Volver al menú
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const MenuPage()),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Volver al menú principal',
                          style: TextStyle(
                            color: Colors.white70,
                            decoration: TextDecoration.underline,
                          ),
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
