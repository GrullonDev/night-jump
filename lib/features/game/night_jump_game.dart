import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import 'package:night_jump/features/game/components/obstacle_component.dart';
import 'package:night_jump/features/game/components/orb_component.dart';
import 'package:night_jump/features/game/components/starfield_component.dart';
import 'package:night_jump/features/game/state/game_status.dart';
import 'package:night_jump/features/game/state/score_repository.dart';

/// Root Flame game for Night Jump. A single instance drives the three
/// screens (menu, gameplay, game over) through Flutter overlays instead of
/// separate routes, so the game world never rebuilds between states.
class NightJumpGame extends FlameGame
    with HasCollisionDetection, TapCallbacks {
  NightJumpGame({ScoreRepository? scoreRepository})
      : scoreRepository = scoreRepository ?? ScoreRepository();

  static const String menuOverlay = 'menu';
  static const String hudOverlay = 'hud';
  static const String gameOverOverlay = 'gameOver';

  static const double _obstacleInterval = 1.6;

  final ScoreRepository scoreRepository;
  final Random random = Random();

  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<int> highScore = ValueNotifier<int>(0);
  final ValueNotifier<bool> isNewHighScore = ValueNotifier<bool>(false);
  final ValueNotifier<Duration> flightTime = ValueNotifier<Duration>(
    Duration.zero,
  );

  GameStatus status = GameStatus.menu;

  late final OrbComponent orb;
  double _spawnTimer = 0;
  double _flightSeconds = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    highScore.value = await scoreRepository.getHighScore();

    add(StarfieldComponent());
    orb = OrbComponent();
    add(orb);
    orb.reset();

    overlays.add(menuOverlay);
    pauseEngine();
  }

  void startGame() {
    status = GameStatus.playing;
    score.value = 0;
    isNewHighScore.value = false;
    flightTime.value = Duration.zero;
    _spawnTimer = 0;
    _flightSeconds = 0;

    children.whereType<ObstacleComponent>().toList().forEach(
          (obstacle) => obstacle.removeFromParent(),
        );
    orb.reset();

    overlays.remove(menuOverlay);
    overlays.remove(gameOverOverlay);
    overlays.add(hudOverlay);
    resumeEngine();
  }

  void addScore() {
    score.value++;
  }

  Future<void> endGame() async {
    if (status != GameStatus.playing) return;
    status = GameStatus.gameOver;
    pauseEngine();
    overlays.remove(hudOverlay);

    final beatHighScore = await scoreRepository.saveScoreIfHigh(score.value);
    isNewHighScore.value = beatHighScore;
    if (beatHighScore) highScore.value = score.value;

    overlays.add(gameOverOverlay);
  }

  void returnToMenu() {
    status = GameStatus.menu;
    children.whereType<ObstacleComponent>().toList().forEach(
          (obstacle) => obstacle.removeFromParent(),
        );
    orb.reset();
    overlays.remove(gameOverOverlay);
    overlays.remove(hudOverlay);
    overlays.add(menuOverlay);
    pauseEngine();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (status != GameStatus.playing) return;

    _flightSeconds += dt;
    flightTime.value = Duration(milliseconds: (_flightSeconds * 1000).round());

    _spawnTimer += dt;
    if (_spawnTimer >= _obstacleInterval) {
      _spawnTimer = 0;
      add(ObstacleComponent(
        startX: size.x + ObstacleComponent.barWidth,
        screenHeight: size.y,
        random: random,
      ));
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (status == GameStatus.playing) {
      orb.jump();
    }
  }
}
