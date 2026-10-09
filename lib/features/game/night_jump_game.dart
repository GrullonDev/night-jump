import 'dart:math';
import 'dart:ui' show AppLifecycleState;

import 'package:flutter/foundation.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:night_jump/features/game/components/floating_mine_component.dart';
import 'package:night_jump/features/game/components/mine_component.dart';
import 'package:night_jump/features/game/components/obstacle_component.dart';
import 'package:night_jump/features/game/components/orb_component.dart';
import 'package:night_jump/features/game/components/rocket_component.dart';
import 'package:night_jump/features/game/components/shield_gem_component.dart';
import 'package:night_jump/features/game/components/starfield_component.dart';
import 'package:night_jump/features/game/state/game_difficulty.dart';
import 'package:night_jump/features/game/state/game_status.dart';
import 'package:night_jump/features/game/state/gate_planner.dart';
import 'package:night_jump/features/game/state/score_repository.dart';
import 'package:night_jump/features/game/state/sound_service.dart';
import 'package:night_jump/features/missions/state/missions_repository.dart';
import 'package:night_jump/features/missions/state/missions_snapshot.dart';
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
       themeRepository = themeRepository ?? ThemeRepository() {
    // App resume must wait for the player's explicit action.
    pauseWhenBackgrounded = false;
  }

  static const menuOverlay = 'menu',
      hudOverlay = 'hud',
      gameOverOverlay = 'gameOver',
      countdownOverlay = 'countdown',
      pauseOverlay = 'pause';
  final ScoreRepository scoreRepository;
  final MissionsRepository missionsRepository;
  final SettingsRepository settingsRepository;
  final ThemeRepository themeRepository;
  final random = Random();
  final score = ValueNotifier<int>(0), highScore = ValueNotifier<int>(0);
  final isNewHighScore = ValueNotifier<bool>(false),
      isPaused = ValueNotifier<bool>(false);
  final difficulty = ValueNotifier<GameDifficulty>(GameDifficulty.classic);
  final flightTime = ValueNotifier<Duration>(Duration.zero);
  final soundEnabled = ValueNotifier<bool>(true),
      hapticsEnabled = ValueNotifier<bool>(true);
  final palette = ValueNotifier<NeonPalette>(NeonPalette.catalog.first);
  final comfortDim = ValueNotifier<bool>(false);
  final shieldCount = ValueNotifier<int>(0);
  final shieldActive = ValueNotifier<bool>(false);
  final dustEarnedThisRun = ValueNotifier<int>(0);
  final speedLevel = ValueNotifier<int>(0);
  final cue = ValueNotifier<String>('');
  final tutorial = ValueNotifier<bool>(false);
  late final sound = SoundService(
    isEnabled: () => soundEnabled.value && !_background && !_disposed,
  );
  GameStatus status = GameStatus.menu;
  late final OrbComponent orb;
  double _spawnTimer = 0, _flightSeconds = 0, _protection = 0, _cueTime = 0;
  double _lastCenter = 360;
  int _spawned = 0, _taps = 0;
  bool _tutorialReady = false,
      _disposed = false,
      _saving = false,
      _background = false;
  GameStatus _beforePause = GameStatus.playing;
  String _runId = '';
  String lossCause = '';
  int countdownStep = 0;
  final Set<Component> _runComponents = {};
  String? persistenceError;
  MissionsSnapshot? resultMissions;
  List<NeonPalette> affordableThemes = [];
  bool get isBackground => _background;
  bool get waitingForTutorialTap => tutorial.value && _taps == 0;
  bool get tutorialCompleted => tutorial.value && _tutorialReady;
  bool get saving => _saving;
  static double _rampFactor(double seconds) =>
      (log(1 + seconds / 18) / log(6)).clamp(0.0, 1.0);
  double get currentObstacleSpeed => tutorial.value
      ? 110
      : difficulty.value.obstacleSpeed +
            difficulty.value.rampSpeedDelta * _rampFactor(_flightSeconds);
  double get currentSpawnInterval => tutorial.value
      ? 2.8
      : difficulty.value.spawnInterval -
            difficulty.value.rampSpawnDelta * _rampFactor(_flightSeconds);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    soundEnabled.value = await settingsRepository.getSoundEnabled();
    hapticsEnabled.value = await settingsRepository.getHapticsEnabled();
    difficulty.value = GameDifficultyX.fromId(
      await settingsRepository.getDifficultyId(),
    );
    highScore.value = await scoreRepository.getHighScore(difficulty.value);
    await refreshTheme();
    await sound.preload();
    await add(StarfieldComponent());
    orb = OrbComponent();
    await add(orb);
    orb.reset();
    overlays.add(menuOverlay);
    pauseEngine();
  }

  void _addRunComponent(Component component) {
    _runComponents.add(component);
    add(component);
  }

  void _clearHazards() {
    for (final child in _runComponents.toList()) {
      child.removeFromParent();
    }
    _runComponents.clear();
  }

  void startGame({bool practice = false, bool quick = false}) {
    if (_saving ||
        _disposed ||
        (status != GameStatus.menu && status != GameStatus.gameOver)) {
      return;
    }
    tutorial.value = practice;
    _tutorialReady = false;
    _taps = 0;
    countdownStep = 0;
    status = quick || practice ? GameStatus.playing : GameStatus.countdown;
    score.value = 0;
    isNewHighScore.value = false;
    isPaused.value = false;
    flightTime.value = Duration.zero;
    dustEarnedThisRun.value = 0;
    _spawnTimer = 0;
    _flightSeconds = 0;
    _protection = 0;
    _spawned = 0;
    _lastCenter = size.y / 2;
    _runId = DateTime.now().microsecondsSinceEpoch.toString();
    resultMissions = null;
    affordableThemes = [];
    persistenceError = null;
    lossCause = '';
    speedLevel.value = 0;
    shieldCount.value = difficulty.value.startingShields;
    shieldActive.value = false;
    _clearHazards();
    orb.reset();
    for (final id in [
      menuOverlay,
      gameOverOverlay,
      pauseOverlay,
      countdownOverlay,
    ]) {
      overlays.remove(id);
    }
    overlays.add(hudOverlay);
    if (status == GameStatus.countdown) overlays.add(countdownOverlay);
    showCue(
      practice ? 'Toca para saltar • práctica sin perder' : '',
      seconds: 5,
    );
    resumeEngine();
    if (_background) pauseGame();
  }

  void playAgain() => startGame(quick: true);
  void beginPlaying() {
    if (status != GameStatus.countdown || _background) return;
    status = GameStatus.playing;
    overlays.remove(countdownOverlay);
    orb.jump();
    sound.go();
  }

  void showCue(String text, {double seconds = 2}) {
    cue.value = text;
    _cueTime = seconds;
  }

  void addScore() {
    if (status != GameStatus.playing) return;
    score.value++;
    sound.score();
    if (tutorial.value) {
      if (score.value == 1) {
        showCue(
          'Escudo: se usa solo al chocar • protección de 1,5 s',
          seconds: 5,
        );
      }
      if (score.value >= 3 && _taps >= 3 && !_tutorialReady) {
        _tutorialReady = true;
        settingsRepository.setHowToPlaySeen();
        pauseGame();
      }
      return;
    }
    // Persist each cleared gate in order; interruption does not lose earned dust.
    missionsRepository.addDust(1).catchError((Object _) {
      persistenceError = 'No se pudo guardar Stardust.';
    });
    dustEarnedThisRun.value++;
    if (score.value > highScore.value && !isNewHighScore.value) {
      isNewHighScore.value = true;
      showCue('¡Nuevo récord!');
    } else if (score.value % 10 == 0) {
      showCue('${score.value} obstáculos ✦');
    }
  }

  /// All collision sources share one atomic guard and recovery rule.
  void hit(String cause) {
    if (status != GameStatus.playing || _protection > 0) return;
    if (tutorial.value || shieldCount.value > 0) {
      if (shieldCount.value > 0) shieldCount.value--;
      _protection = GatePlanner.recoverySeconds;
      shieldActive.value = true;
      // Remove the entire nearby field instead of teleporting into another bar.
      _clearHazards();
      orb.reset();
      _spawnTimer = -0.8;
      _lastCenter = size.y / 2;
      showCue('Escudo usado • sigue tocando', seconds: 1.5);
      sound.ui();
    } else {
      lossCause = cause;
      endGame();
    }
  }

  void collectGem() {
    if (status != GameStatus.playing) return;
    if (shieldCount.value < difficulty.value.maxShields) shieldCount.value++;
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
    highScore.value = await scoreRepository.getHighScore(value);
  }

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

  Future<void> resetProgress() async {
    await settingsRepository.resetProgress();
    highScore.value = 0;
    isNewHighScore.value = false;
    await refreshTheme();
  }

  Future<void> endGame() async {
    if (status != GameStatus.playing || _saving) return;
    status = GameStatus.gameOver;
    _saving = true;
    isPaused.value = false;
    pauseEngine();
    overlays.remove(hudOverlay);
    sound.gameOver();
    final finalScore = score.value;
    final finalDifficulty = difficulty.value;
    final finalRunId = _runId;
    try {
      final beat = await scoreRepository.saveScoreIfHigh(
        finalDifficulty,
        finalScore,
      );
      final best = await scoreRepository.getHighScore(finalDifficulty);
      final rewards = await missionsRepository.recordRunFinished(
        obstaclesCleared: finalScore,
        runId: finalRunId,
        includeGateDust: false,
      );
      resultMissions = await missionsRepository.loadSnapshot();
      final unlocked = await themeRepository.getUnlockedPaletteIds();
      affordableThemes = NeonPalette.catalog
          .where(
            (p) =>
                !unlocked.contains(p.id) && p.cost <= resultMissions!.stardust,
          )
          .toList();
      if (!_disposed) {
        isNewHighScore.value = beat;
        highScore.value = best;
        dustEarnedThisRun.value += rewards;
      }
    } catch (_) {
      persistenceError =
          'No se pudo guardar el resultado. Revisa el espacio del dispositivo.';
    } finally {
      _saving = false;
      if (!_disposed) overlays.add(gameOverOverlay);
    }
  }

  void returnToMenu() {
    if (_saving) return;
    status = GameStatus.menu;
    tutorial.value = false;
    isPaused.value = false;
    _clearHazards();
    shieldActive.value = false;
    orb.reset();
    for (final id in [
      gameOverOverlay,
      hudOverlay,
      pauseOverlay,
      countdownOverlay,
    ]) {
      overlays.remove(id);
    }
    overlays.add(menuOverlay);
    pauseEngine();
  }

  void togglePause() {
    if (status == GameStatus.paused) {
      resumeGame();
    } else {
      pauseGame();
    }
  }

  void pauseGame() {
    if (status != GameStatus.playing && status != GameStatus.countdown) return;
    _beforePause = status;
    status = GameStatus.paused;
    isPaused.value = true;
    pauseEngine();
    overlays.remove(countdownOverlay);
    overlays.add(pauseOverlay);
  }

  void resumeGame() {
    if (status != GameStatus.paused || _background) return;
    status = _beforePause;
    isPaused.value = false;
    overlays.remove(pauseOverlay);
    if (status == GameStatus.countdown) overlays.add(countdownOverlay);
    resumeEngine();
  }

  void setBackground(bool background) {
    _background = background;
    if (background) {
      pauseGame();
      sound.stop();
    }
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);
    setBackground(state != AppLifecycleState.resumed);
  }

  @override
  void update(double dt) {
    // Large foreground deltas must not tunnel through bars or expire protection.
    if (dt > 0.1 && status == GameStatus.playing) {
      pauseGame();
      return;
    }
    super.update(dt);
    if (status != GameStatus.playing) return;
    _runComponents.removeWhere((component) => component.isRemoved);
    if (tutorial.value && _taps == 0) return;
    _flightSeconds += dt;
    flightTime.value = Duration(milliseconds: (_flightSeconds * 1000).round());
    if (_protection > 0) {
      _protection = max(0, _protection - dt);
      if (_protection == 0) shieldActive.value = false;
    }
    if (_cueTime > 0) {
      _cueTime -= dt;
      if (_cueTime <= 0) cue.value = '';
    }
    speedLevel.value = (_rampFactor(_flightSeconds) * 5).floor();
    _spawnTimer += dt;
    if (_spawnTimer < currentSpawnInterval) return;
    _spawnTimer -= currentSpawnInterval;
    _spawned++;
    final diff = difficulty.value;
    final extra =
        !tutorial.value &&
        diff.hazardEvery > 0 &&
        _spawned % diff.hazardEvery == 0;
    if (extra) {
      // Outer lanes leave the central certified flight corridor unobstructed.
      final y = (_spawned ~/ diff.hazardEvery).isEven ? 90.0 : size.y - 90;
      final pos = Vector2(size.x + 70, y);
      switch ((_spawned ~/ diff.hazardEvery) % 3) {
        case 0:
          _addRunComponent(MineComponent(position: pos));
        case 1:
          _addRunComponent(RocketComponent(position: pos, targetY: y));
        case 2:
          _addRunComponent(
            FloatingMineComponent(
              position: pos,
              bounceSpeed: 35,
              laneCenter: y,
            ),
          );
      }
      showCue('Peligro en el borde • mantén el centro', seconds: 2);
      return;
    }
    final gap = GatePlanner.effectiveGap(
      tutorial.value ? 300 : diff.gapHeight,
      size.y,
    );
    _lastCenter = GatePlanner.nextCenter(
      previous: _lastCenter,
      height: size.y,
      gap: gap,
      interval: diff.minSpawnInterval,
      maxSpeed: diff.obstacleSpeed + diff.rampSpeedDelta,
      random: random,
    );
    final obstacle = ObstacleComponent(
      startX: size.x + ObstacleComponent.barWidth,
      screenHeight: size.y,
      random: random,
      gapHeight: gap,
      centerY: _lastCenter,
    );
    _addRunComponent(obstacle);
    if (_spawned >= diff.gemSpawnAfterFirst &&
        (_spawned - diff.gemSpawnAfterFirst) % diff.gemSpawnInterval == 0 &&
        shieldCount.value < diff.maxShields) {
      _addRunComponent(
        ShieldGemComponent(
          position: Vector2(obstacle.position.x + 32, _lastCenter),
        ),
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (status == GameStatus.playing) {
      _taps++;
      orb.jump();
    }
  }

  void disposeResources() {
    if (_disposed) return;
    _disposed = true;
    pauseEngine();
    sound.dispose();
    for (final notifier in <ChangeNotifier>[
      score,
      highScore,
      isNewHighScore,
      difficulty,
      isPaused,
      flightTime,
      soundEnabled,
      hapticsEnabled,
      palette,
      comfortDim,
      shieldCount,
      shieldActive,
      dustEarnedThisRun,
      speedLevel,
      cue,
      tutorial,
    ]) {
      notifier.dispose();
    }
  }
}
