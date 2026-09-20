import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'package:night_jump/features/game/components/obstacle_component.dart';
import 'package:night_jump/features/game/components/orb_component.dart';
import 'package:night_jump/features/game/components/starfield_component.dart';
import 'package:night_jump/features/game/state/game_status.dart';
import 'package:night_jump/features/game/state/score_repository.dart';
import 'package:night_jump/features/missions/state/missions_repository.dart';
import 'package:night_jump/features/settings/state/settings_repository.dart';

class NightJumpGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  NightJumpGame({
    ScoreRepository? scoreRepository,
    MissionsRepository? missionsRepository,
    SettingsRepository? settingsRepository,
  }) : scoreRepository = scoreRepository ?? ScoreRepository(),
       missionsRepository = missionsRepository ?? MissionsRepository(),
       settingsRepository = settingsRepository ?? SettingsRepository();

  static const String menuOverlay = 'menu';
  static const String hudOverlay = 'hud';
  static const String gameOverOverlay = 'gameOver';
  static const String countdownOverlay = 'countdown';

  static const double _obstacleInterval = 1.6;

  final ScoreRepository scoreRepository;
  final MissionsRepository missionsRepository;
  final SettingsRepository settingsRepository;
  final Random random = Random();

  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<int> highScore = ValueNotifier<int>(0);
  final ValueNotifier<bool> isNewHighScore = ValueNotifier<bool>(false);
  final ValueNotifier<Duration> flightTime = ValueNotifier<Duration>(
    Duration.zero,
  );
  final ValueNotifier<bool> soundEnabled = ValueNotifier<bool>(true);
  final ValueNotifier<bool> hapticsEnabled = ValueNotifier<bool>(true);

  GameStatus status = GameStatus.menu;

  late final OrbComponent orb;
  double _spawnTimer = 0;
  double _flightSeconds = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    highScore.value = await scoreRepository.getHighScore();
    soundEnabled.value = await settingsRepository.getSoundEnabled();
    hapticsEnabled.value = await settingsRepository.getHapticsEnabled();

    add(StarfieldComponent());
    orb = OrbComponent();
    add(orb);
    orb.reset();

    overlays.add(menuOverlay);
    pauseEngine();
  }

  void startGame() {
    status = GameStatus.countdown;
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
    overlays.add(countdownOverlay);
    resumeEngine();
  }

  /// Called by [CountdownOverlay] when the 3-2-1 animation finishes.
  void beginPlaying() {
    status = GameStatus.playing;
    overlays.remove(countdownOverlay);
  }

  void addScore() {
    score.value++;
  }

  Future<void> toggleSound() async {
    soundEnabled.value = !soundEnabled.value;
    await settingsRepository.setSoundEnabled(soundEnabled.value);
  }

  Future<void> toggleHaptics() async {
    hapticsEnabled.value = !hapticsEnabled.value;
    await settingsRepository.setHapticsEnabled(hapticsEnabled.value);
  }

  /// Clears all local progress (high score, missions/stardust, themes)
  /// and refreshes in-memory state to match.
  Future<void> resetProgress() async {
    await settingsRepository.resetProgress();
    highScore.value = 0;
    isNewHighScore.value = false;
  }

  Future<void> endGame() async {
    if (status != GameStatus.playing) return;
    status = GameStatus.gameOver;
    pauseEngine();
    overlays.remove(hudOverlay);

    final beatHighScore = await scoreRepository.saveScoreIfHigh(score.value);
    isNewHighScore.value = beatHighScore;
    if (beatHighScore) highScore.value = score.value;
    await missionsRepository.recordRunFinished(obstaclesCleared: score.value);

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
      add(
        ObstacleComponent(
          startX: size.x + ObstacleComponent.barWidth,
          screenHeight: size.y,
          random: random,
        ),
      );
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
