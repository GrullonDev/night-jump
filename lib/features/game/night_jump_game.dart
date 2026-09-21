import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'package:night_jump/features/game/components/obstacle_component.dart';
import 'package:night_jump/features/game/components/orb_component.dart';
import 'package:night_jump/features/game/components/shield_gem_component.dart';
import 'package:night_jump/features/game/components/starfield_component.dart';
import 'package:night_jump/features/game/state/game_difficulty.dart';
import 'package:night_jump/features/game/state/game_status.dart';
import 'package:night_jump/features/game/state/score_repository.dart';
import 'package:night_jump/features/game/state/sound_service.dart';
import 'package:night_jump/features/missions/state/missions_repository.dart';
import 'package:night_jump/features/settings/state/settings_repository.dart';
import 'package:night_jump/features/themes/state/neon_palette.dart';
import 'package:night_jump/features/themes/state/theme_repository.dart';

class NightJumpGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  NightJumpGame({
    ScoreRepository? scoreRepository,
    MissionsRepository? missionsRepository,
    SettingsRepository? settingsRepository,
    ThemeRepository? themeRepository,
  }) : scoreRepository = scoreRepository ?? ScoreRepository(),
       missionsRepository = missionsRepository ?? MissionsRepository(),
       settingsRepository = settingsRepository ?? SettingsRepository(),
       themeRepository = themeRepository ?? ThemeRepository();

  static const String menuOverlay = 'menu';
  static const String hudOverlay = 'hud';
  static const String gameOverOverlay = 'gameOver';
  static const String countdownOverlay = 'countdown';
  static const String pauseOverlay = 'pause';
  static const String shieldDialogueOverlay = 'shieldDialogue';

  final ScoreRepository scoreRepository;
  final MissionsRepository missionsRepository;
  final SettingsRepository settingsRepository;
  final ThemeRepository themeRepository;
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
  final ValueNotifier<NeonPalette> palette = ValueNotifier<NeonPalette>(
    NeonPalette.catalog.first,
  );
  final ValueNotifier<bool> comfortDim = ValueNotifier<bool>(false);

  // ── Shield System ──
  final ValueNotifier<int> shieldCount = ValueNotifier<int>(0);
  final ValueNotifier<bool> shieldActive = ValueNotifier<bool>(false);
  final ValueNotifier<bool> showShieldDialogue = ValueNotifier<bool>(false);
  int _obstaclesSinceLastGem = 0;
  bool _chillShieldGranted = false;

  // ── Run Stats ──
  final ValueNotifier<int> dustEarnedThisRun = ValueNotifier<int>(0);

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
    await refreshTheme();
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
    dustEarnedThisRun.value = 0;
    _spawnTimer = 0;
    _flightSeconds = 0;
    _obstaclesSinceLastGem = 0;
    _chillShieldGranted = false;
    shieldCount.value = difficulty.value.startingShields;
    shieldActive.value = false;
    showShieldDialogue.value = false;

    children.whereType<ObstacleComponent>().toList().forEach(
      (obstacle) => obstacle.removeFromParent(),
    );
    children.whereType<ShieldGemComponent>().toList().forEach(
      (gem) => gem.removeFromParent(),
    );
    orb.reset();

    overlays.remove(menuOverlay);
    overlays.remove(gameOverOverlay);
    overlays.remove(shieldDialogueOverlay);
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
    dustEarnedThisRun.value++;
    sound.score();
    // Award 1 dust per obstacle cleared
    missionsRepository.addDust(1);

    // Chill mode: auto-grant shield at score threshold
    final threshold = difficulty.value.shieldScoreThreshold;
    if (threshold > 0 &&
        !_chillShieldGranted &&
        score.value >= threshold &&
        shieldCount.value < difficulty.value.maxShields) {
      _chillShieldGranted = true;
      shieldCount.value = 1;
      sound.score();
    }
  }

  // ── Shield Methods ──

  void useShield() {
    if (shieldCount.value > 0 && !shieldActive.value) {
      shieldCount.value--;
      shieldActive.value = true;
      showShieldDialogue.value = false;
      overlays.remove(shieldDialogueOverlay);
      isPaused.value = false;
      resumeEngine();
      sound.ui();
    }
  }

  void activateShieldFromGem() {
    if (!shieldActive.value) {
      shieldActive.value = true;
      sound.score();
    }
  }

  void deactivateShield() {
    shieldActive.value = false;
  }

  void collectGem() {
    if (shieldCount.value < difficulty.value.maxShields) {
      shieldCount.value++;
    }
    activateShieldFromGem();
  }

  void onObstacleCleared() {
    // Reserved for future use
  }

  void showShieldOffer() {
    if (shieldCount.value > 0 && !showShieldDialogue.value) {
      showShieldDialogue.value = true;
      isPaused.value = true;
      overlays.add(shieldDialogueOverlay);
    } else {
      endGame();
    }
  }

  void dismissShieldDialogue() {
    showShieldDialogue.value = false;
    overlays.remove(shieldDialogueOverlay);
    isPaused.value = false;
    resumeEngine();
  }

  void rejectShield() {
    showShieldDialogue.value = false;
    overlays.remove(shieldDialogueOverlay);
    endGame();
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

  /// Re-reads the gallery choices (palette + comfort) after the player
  /// returns from the theme gallery.
  Future<void> refreshTheme() async {
    palette.value = NeonPalette.byId(
      await themeRepository.getSelectedPaletteId(),
    );
    comfortDim.value = await settingsRepository.getComfortDim();
  }

  Future<void> setComfortDim(bool value) async {
    comfortDim.value = value;
    await settingsRepository.setComfortDim(value);
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
    overlays.remove(shieldDialogueOverlay);
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
    children.whereType<ShieldGemComponent>().toList().forEach(
      (gem) => gem.removeFromParent(),
    );
    shieldActive.value = false;
    showShieldDialogue.value = false;
    orb.reset();
    overlays.remove(gameOverOverlay);
    overlays.remove(hudOverlay);
    overlays.remove(pauseOverlay);
    overlays.remove(shieldDialogueOverlay);
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
      final obstacle = ObstacleComponent(
        startX: size.x + ObstacleComponent.barWidth,
        screenHeight: size.y,
        random: random,
        gapHeight: difficulty.value.gapHeight,
      );
      add(obstacle);

      // Gem spawning (classic/intense only)
      final diff = difficulty.value;
      if (diff.gemSpawnInterval > 0) {
        _obstaclesSinceLastGem++;
        final firstThreshold = diff.gemSpawnAfterFirst;
        final interval = diff.gemSpawnInterval;

        bool shouldSpawn = false;
        if (_obstaclesSinceLastGem == firstThreshold) {
          shouldSpawn = true;
        } else if (_obstaclesSinceLastGem > firstThreshold &&
            (_obstaclesSinceLastGem - firstThreshold) % interval == 0) {
          shouldSpawn = true;
        }

        if (shouldSpawn &&
            shieldCount.value < diff.maxShields &&
            children.whereType<ShieldGemComponent>().length < 2) {
          _spawnGemInGap(obstacle);
        }
      }
    }
  }

  void _spawnGemInGap(ObstacleComponent obstacle) {
    final minX = obstacle.position.x + ObstacleComponent.barWidth + 40;
    final maxX = obstacle.position.x + ObstacleComponent.barWidth + 120;
    final gemX = minX + random.nextDouble() * (maxX - minX);

    final gapTop = obstacle.gapCenterY - obstacle.gapHeight / 2;
    final gapBottom = obstacle.gapCenterY + obstacle.gapHeight / 2;
    final margin = 30.0;
    final gemY =
        gapTop + margin + random.nextDouble() * (gapBottom - gapTop - margin * 2);

    add(
      ShieldGemComponent(
        position: Vector2(gemX, gemY),
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (status == GameStatus.playing) {
      orb.jump();
    }
  }
}
