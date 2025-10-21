// game/doom_avance_game.dart
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'player.dart';
import 'dart:async' as async;
import 'hud.dart';
import 'enemy.dart';
import 'package:doom/services/save_game_service.dart';

class DoomAvanceGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection, TapCallbacks {
  DoomAvanceGame({required this.onGameOver, this.onMessage});

  final Function(int score) onGameOver;
  // Optional message callback used by the UI to show SnackBars / Toasts
  final void Function(String message)? onMessage;
  Player? player;
  late Hud hud;
  int score = 0;
  final Random random = Random();
  int waveNumber = 1;
  int currentLevel = 1;
  final int maxLevel = 4;
  double levelEnemySpeed = 160;
  double levelCapturerSpeed = 120;
  bool playerCaptured = false;
  bool waveInProgress = false;
  int enemiesRemainingInWave = 0;
  int waveCountInLevel = 0;
  final int wavesPerLevel = 3;

  // Double tap detection
  double _lastTapTime = 0.0;
  final double _doubleTapThreshold = 0.3; // seconds

  // Timer for periodic dives
  async.Timer? _diveTimer;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Use the default viewport (Screen viewport) so the game auto-adjusts
    // to the device screen size instead of a fixed 800x600 resolution.

    // Fondo
    final bgImage = await images.load('doom_background.png');
    final imgW = bgImage.width.toDouble();
    final imgH = bgImage.height.toDouble();
    final gameW = size.x;
    final gameH = size.y;
    final scale = max(gameW / imgW, gameH / imgH);
    final bgSize = Vector2(imgW * scale, imgH * scale);
    final bgPosition = Vector2((gameW - bgSize.x) / 2, (gameH - bgSize.y) / 2);

    final background = SpriteComponent(
      sprite: Sprite(bgImage),
      size: bgSize,
      position: bgPosition,
      anchor: Anchor.topLeft,
    )..priority = 0;

    add(background);

    // Player
    player = Player();
    if (player != null) add(player!);

    // HUD
    hud = Hud();
    add(hud);

    // ⚠️ Eliminada la creación de obstáculos fuera de formación

    // Start first level
    startLevel(currentLevel);

    // Periodic dive timer
    _diveTimer = async.Timer.periodic(const Duration(seconds: 3), (timer) {
      final enemies = children.whereType<Enemy>().toList();
      if (enemies.isNotEmpty) {
        final rnd = Random();
        final pick = enemies[rnd.nextInt(enemies.length)];
        pick.startDive(Vector2(size.x / 2, size.y));
      }
    });
  }

  Future<void> saveGame() async {
    final enemies = children.whereType<Enemy>().toList();
    final enemyStates = enemies.map((e) {
      return {
        'x': e.position.x,
        'y': e.position.y,
        'type': e is CapturerEnemy ? 'capturer' : 'enemy',
        'state': e.state.toString(),
        'diveProgress': e.diveProgress,
      };
    }).toList();

    final state = {
      'player': player == null
          ? null
          : {
              'x': player!.position.x,
              'y': player!.position.y,
              'life': player!.life,
            },
      'score': score,
      'currentLevel': currentLevel,
      'waveNumber': waveNumber,
      'waveCountInLevel': waveCountInLevel,
      'enemies': enemyStates,
    };

    await SaveGameService.save(state);
    // notify UI
    onMessage?.call('Partida guardada');
  }

  Future<void> loadGame() async {
    final s = SaveGameService.load();
    if (s == null) return;

    // Clear current enemies
    children.whereType<Enemy>().toList().forEach((e) => e.removeFromParent());

    // Restore basic fields
    score = s['score'] ?? 0;
    hud.updateScore(score);
    currentLevel = s['currentLevel'] ?? 1;
    waveNumber = s['waveNumber'] ?? 1;
    waveCountInLevel = s['waveCountInLevel'] ?? 0;

    final p = s['player'];
    if (p == null) {
      player?.removeFromParent();
      player = null;
    } else {
      final px = (p['x'] as num).toDouble();
      final py = (p['y'] as num).toDouble();
      final life = p['life'] ?? 3;
      player ??= Player();
      player!.position = Vector2(px, py);
      player!.life = life;
      if (!children.contains(player)) add(player!);
      hud.updateLife(player!.life);
    }

    // Restore enemies
    final enemies = s['enemies'] as List? ?? [];
    for (final en in enemies) {
      final x = (en['x'] as num).toDouble();
      final y = (en['y'] as num).toDouble();
      final type = en['type'] as String? ?? 'enemy';
      if (type == 'capturer') {
        add(
          CapturerEnemy(
            formationPosition: Vector2(x, y),
            diveSpeed: levelCapturerSpeed,
          ),
        );
      } else {
        add(
          Enemy(formationPosition: Vector2(x, y), diveSpeed: levelEnemySpeed),
        );
      }
    }

    hud.updateWave(waveNumber);
    hud.updateScore(score);
    onMessage?.call('Partida cargada');
  }

  @override
  void onRemove() {
    _diveTimer?.cancel();
    _diveTimer = null;
    super.onRemove();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (waveInProgress && enemiesRemainingInWave <= 0) {
      waveInProgress = false;
      waveCountInLevel += 1;
      // small delay before next wave or level transition
      Future.delayed(const Duration(seconds: 2), () {
        if (waveCountInLevel >= wavesPerLevel) {
          // level complete
          if (currentLevel < maxLevel) {
            waveCountInLevel = 0;
            startLevel(currentLevel + 1);
          } else {
            // final level complete -> game over
            onGameOver(score);
          }
        } else {
          startNextWave();
        }
      });
    }
  }

  void onEnemyKilled() {
    enemiesRemainingInWave = (enemiesRemainingInWave - 1).clamp(0, 99999);
  }

  void showWaveBanner(int wave) {
    final text = TextComponent(
      text: 'Wave $wave',
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(text);
    Future.delayed(
      const Duration(milliseconds: 1200),
      () => text.removeFromParent(),
    );
  }

  void showCountdown(int seconds, VoidCallback onComplete) {
    int remaining = seconds;
    TextComponent? comp;

    void tick() {
      comp?.text = remaining.toString();
      remaining -= 1;
      if (remaining < 0) {
        comp?.removeFromParent();
        onComplete();
        return;
      }
      Future.delayed(const Duration(seconds: 1), tick);
    }

    comp = TextComponent(
      text: remaining.toString(),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2 - 40),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(comp);
    Future.delayed(const Duration(milliseconds: 10), tick);
  }

  void spawnFormation({
    int rows = 3,
    int cols = 6,
    double capturerChance = 0.08,
    double enemyDiveSpeed = 160,
    double capturerDiveSpeed = 120,
  }) {
    final enemyW = Enemy.defaultWidth;
    final enemyH = Enemy.defaultHeight;
    final spacingX = enemyW + 20.0;
    final spacingY = enemyH + 16.0;
    final formationWidth = (cols - 1) * spacingX;
    final formationHeight = (rows - 1) * spacingY;
    final startX = (size.x - formationWidth) / 2.0;
    final topMargin = (size.y * 0.10).clamp(24.0, 120.0);
    final startY = topMargin.clamp(0.0, size.y - formationHeight - topMargin);

    int spawned = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final x = startX + c * spacingX;
        final y = startY + r * spacingY;
        if (random.nextDouble() < capturerChance) {
          add(
            CapturerEnemy(
              formationPosition: Vector2(x, y),
              diveSpeed: capturerDiveSpeed,
            ),
          );
        } else {
          add(
            Enemy(formationPosition: Vector2(x, y), diveSpeed: enemyDiveSpeed),
          );
        }
        spawned++;
      }
    }
    enemiesRemainingInWave = spawned;
    waveInProgress = true;
  }

  void startNextWave() {
    waveNumber += 1;
    hud.updateWave(waveNumber);
    showWaveBanner(waveNumber);

    final rows = 2 + (waveNumber / 3).floor();
    final cols = 4 + (waveNumber / 2).floor();
    final capturerChance = (0.05 + waveNumber * 0.01).clamp(0.03, 0.25);

    showCountdown(3, () {
      spawnFormation(
        rows: rows,
        cols: cols,
        capturerChance: capturerChance,
        enemyDiveSpeed: levelEnemySpeed,
        capturerDiveSpeed: levelCapturerSpeed,
      );
    });

    if (_diveTimer != null) {
      _diveTimer?.cancel();
      final interval = Duration(
        milliseconds: (max(800, 3000 - waveNumber * 150)),
      );
      _diveTimer = async.Timer.periodic(interval, (timer) {
        final enemies = children.whereType<Enemy>().toList();
        if (enemies.isNotEmpty) {
          final rnd = Random();
          final pick = enemies[rnd.nextInt(enemies.length)];
          pick.startDive(Vector2(size.x / 2, size.y));
        }
      });
    }
  }

  void startLevel(int level) {
    currentLevel = level;
    waveNumber = 0;
    // For each level we can adjust base speeds and other parameters
    // Level mapping: 1..4 (easy -> hard)
    levelEnemySpeed = (140 + (level - 1) * 30).toDouble();
    levelCapturerSpeed = (110 + (level - 1) * 20).toDouble();
    // Start first wave of this level
    startNextWave();

    // Also update dive timer to be a bit faster based on level
    _diveTimer?.cancel();
    final interval = Duration(milliseconds: max(600, 3000 - level * 400));
    _diveTimer = async.Timer.periodic(interval, (timer) {
      final enemies = children.whereType<Enemy>().toList();
      if (enemies.isNotEmpty) {
        final rnd = Random();
        final pick = enemies[rnd.nextInt(enemies.length)];
        pick.startDive(Vector2(size.x / 2, size.y));
      }
    });
  }

  void capturePlayer() {
    playerCaptured = true;
    player = null;
    hud.updateLife(0);
  }

  void releaseDoublePlayer() {
    playerCaptured = false;
    if (player != null) {
      player!.doubleShip = true;
      hud.updateLife(player!.life);
      return;
    }

    final p = Player.doubleShip();
    p.position = Vector2(size.x / 2, size.y - 80);
    player = p;
    add(player!);
    hud.updateLife(player!.life);
  }

  @override
  void onTapDown(TapDownEvent event) {
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    if (now - _lastTapTime <= _doubleTapThreshold) {
      player?.shoot();
      _lastTapTime = 0.0;
    } else {
      _lastTapTime = now;
    }
    super.onTapDown(event);
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    // Save (S) and Load (L)
    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
        saveGame();
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyL)) {
        loadGame();
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  void increaseScore() {
    score += 10;
    hud.updateScore(score);
  }

  void decreaseLife() {
    if (player == null) return;
    player!.life -= 1;
    hud.updateLife(player!.life);
    if (player!.life <= 0) {
      onGameOver(score);
    }
  }

  void movePlayerBy(Vector2 vector2) {}
}
