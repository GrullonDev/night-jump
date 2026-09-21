import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'package:night_jump/features/game/components/obstacle_component.dart';
import 'package:night_jump/features/game/components/orb_component.dart';
import 'package:night_jump/features/game/components/starfield_component.dart';
import 'package:night_jump/features/game/state/game_difficulty.dart';
import 'package:night_jump/features/game/state/game_status.dart';
import 'package:night_jump/features/game/state/score_repository.dart';
import 'package:night_jump/features/game/state/sound_service.dart';
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
  static const String pauseOverlay = 'pause';

  final ScoreRepository scoreRepository;
  final MissionsRepository missionsRepository;
  final SettingsRepository settingsRepository;
  final Random random = Random();

  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<int> highScore = ValueNotifier<int>(0);
  final ValueNotifier<bool> isNewHighScore = ValueNotifier<bool>(false);
  final ValueNotifier<GameDifficulty> difficulty =
      ValueNotifier<GameDifficulty>(GameDifficulty.classic);
  final ValueNotifier<bool> isPaused = ValueNotifier<bool>(false);
  final ValueNotifier<Duration> flightTime = ValueNotifier<Duration>(
    Duration.zero,
  );
  final ValueNotifier<bool> soundEnabled = ValueNotifier<bool>(true);
  final ValueNotifier<bool> hapticsEnabled = ValueNotifier<bool>(true);

  late final SoundService sound = SoundService(
    isEnabled: () => soundEnabled.value,
  );

  GameStatus status = GameStatus.menu;

  late final OrbComponent orb;
  double _spawnTimer = 0;
  double _flightSeconds = 0;

  /// Gentle logarithmic ramp over ~90s of flight. 0.0 at take-off,
  /// 1.0 at 90s. Pauses automatically since [_flightSeconds] only
  /// advances while playing.
  static const double _rampTimeConstant = 18.0;

  static double _rampFactor(double seconds) {
    const divisor =
        1.791759; // ln(1 + 90/18) = ln(6), i.e. factor hits 1.0 at ~90s
    final factor = log(1 + seconds / _rampTimeConstant) / divisor;
    return factor.clamp(0.0, 1.0);
  }

  /// Scroll speed: difficulty base + up to +100 (classic 180 → 280).
  double get currentObstacleSpeed =>
      difficulty.value.obstacleSpeed + 100 * _rampFactor(_flightSeconds);

  /// Spawn gap: difficulty base down to −0.5s (classic 1.6 → 1.1s).
  double get currentSpawnInterval =>
      (difficulty.value.spawnInterval - 0.5 * _rampFactor(_flightSeconds))
          .clamp(0.9, 4.0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    highScore.value = await scoreRepository.getHighScore();
    soundEnabled.value = await settingsRepository.getSoundEnabled();
    hapticsEnabled.value = await settingsRepository.getHapticsEnabled();
    difficulty.value = GameDifficultyX.fromId(
      await settingsRepository.getDifficultyId(),
    );
    await sound.preload();

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
    isPaused.value = false;
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
    sound.go();
  }

  void addScore() {
    score.value++;
    sound.score();
  }

  Future<void> toggleSound() async {
    soundEnabled.value = !soundEnabled.value;
    await settingsRepository.setSoundEnabled(soundEnabled.value);
  }

  Future<void> toggleHaptics() async {
    hapticsEnabled.value = !hapticsEnabled.value;
    await settingsRepository.setHapticsEnabled(hapticsEnabled.value);
  }

  Future<void> setDifficulty(GameDifficulty value) async {
    difficulty.value = value;
    await settingsRepository.setDifficultyId(value.id);
  }

  void togglePause() {
    if (status == GameStatus.playing) {
      pauseGame();
    } else if (status == GameStatus.paused) {
      sound.ui();
      resumeGame();
    }
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
    isPaused.value = false;
    pauseEngine();
    overlays.remove(hudOverlay);
    sound.gameOver();

    final beatHighScore = await scoreRepository.saveScoreIfHigh(score.value);
    isNewHighScore.value = beatHighScore;
    if (beatHighScore) highScore.value = score.value;
    await missionsRepository.recordRunFinished(obstaclesCleared: score.value);

    overlays.add(gameOverOverlay);
  }

  void returnToMenu() {
    status = GameStatus.menu;
    isPaused.value = false;
    children.whereType<ObstacleComponent>().toList().forEach(
      (obstacle) => obstacle.removeFromParent(),
    );
    orb.reset();
    overlays.remove(gameOverOverlay);
    overlays.remove(hudOverlay);
    overlays.remove(pauseOverlay);
    overlays.add(menuOverlay);
    pauseEngine();
  }

  void pauseGame() {
    if (status != GameStatus.playing) return;
    status = GameStatus.paused;
    isPaused.value = true;
    pauseEngine();
    overlays.add(pauseOverlay);
  }

  /// Resumes in place: no countdown, the frozen frame simply continues.
  void resumeGame() {
    if (status != GameStatus.paused) return;
    status = GameStatus.playing;
    isPaused.value = false;
    overlays.remove(pauseOverlay);
    resumeEngine();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (status != GameStatus.playing) return;

    _flightSeconds += dt;
    flightTime.value = Duration(milliseconds: (_flightSeconds * 1000).round());

    _spawnTimer += dt;
    if (_spawnTimer >= currentSpawnInterval) {
      _spawnTimer = 0;
      add(
        ObstacleComponent(
          startX: size.x + ObstacleComponent.barWidth,
          screenHeight: size.y,
          random: random,
          // Gap fixed per difficulty for the whole run: ramping never
          // punishes base skill, only speed and frequency rise.
          gapHeight: difficulty.value.gapHeight,
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
