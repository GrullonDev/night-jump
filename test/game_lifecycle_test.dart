import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/game/page/game_page.dart';
import 'package:night_jump/features/game/state/game_status.dart';
import 'package:night_jump/features/game/components/orb_component.dart';
import 'package:night_jump/features/game/components/obstacle_component.dart';
import 'package:night_jump/features/game/state/game_difficulty.dart';
import 'package:night_jump/features/missions/state/missions_repository.dart';
import 'package:night_jump/features/missions/state/missions_snapshot.dart';

class InterruptedMissionsRepository extends MissionsRepository {
  bool failGates = true;
  bool failSnapshot = true;

  @override
  Future<void> recordGateProgress({
    required String runId,
    required int obstaclesCleared,
  }) async {
    if (failGates) throw StateError('Simulated gate write failure');
    await super.recordGateProgress(
      runId: runId,
      obstaclesCleared: obstaclesCleared,
    );
  }

  @override
  Future<MissionsSnapshot> loadSnapshot() async {
    if (failSnapshot) {
      failSnapshot = false;
      throw StateError('Simulated read failure after awarding rewards');
    }
    return super.loadSnapshot();
  }
}

Future<NightJumpGame> mountGame(
  WidgetTester tester, {
  MissionsRepository? missionsRepository,
}) async {
  SharedPreferences.setMockInitialValues({
    'settings.tutorial_completed.v1': true,
    'settings.sound_enabled': false,
    'settings.haptics_enabled': false,
  });
  final game = NightJumpGame(missionsRepository: missionsRepository);
  for (final id in [
    NightJumpGame.menuOverlay,
    NightJumpGame.hudOverlay,
    NightJumpGame.gameOverOverlay,
    NightJumpGame.countdownOverlay,
    NightJumpGame.pauseOverlay,
  ]) {
    game.overlays.addEntry(id, (_, _) => const SizedBox.shrink());
  }
  await tester.runAsync(() async {
    game.onGameResize(Vector2(400, 720));
    // Flame exposes no public headless initialization API. Initialize before
    // widget attachment so native asset futures execute outside the fake clock.
    // ignore: invalid_use_of_internal_member
    await game.load();
  });
  await tester.pumpWidget(MaterialApp(home: GamePage(game: game)));
  await tester.pump();
  await tester.runAsync(game.ready);
  await tester.pump();
  return game;
}

void main() {
  testWidgets(
    'result retry recovers gate dust and keeps rewards exactly once',
    (tester) async {
      final missions = InterruptedMissionsRepository();
      final game = await mountGame(tester, missionsRepository: missions);
      game.startGame(quick: true);
      for (var gate = 0; gate < 10; gate++) {
        game.addScore();
      }
      await tester.pump();
      missions.failGates = false;
      await tester.runAsync(game.endGame);
      await tester.pump();
      expect(game.persistenceError, isNotNull);
      expect(find.text('REINTENTAR GUARDADO'), findsOneWidget);
      await tester.tap(find.text('REINTENTAR GUARDADO'));
      await tester.pumpAndSettle();
      await tester.runAsync(game.retrySaveResult);
      await tester.pump();
      expect(game.persistenceError, isNull);
      expect(game.highScore.value, 10);
      expect(game.isNewHighScore.value, isTrue);
      expect(game.dustEarnedThisRun.value, 110);
      expect(await tester.runAsync(missions.getStardust), 110);
      final snapshot = await tester.runAsync(missions.loadSnapshot);
      expect(snapshot!.dailyMissions[1].progress, 1);
      expect(find.text('REINTENTAR GUARDADO'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'leaving during result persistence does not cancel saved progress',
    (tester) async {
      final game = await mountGame(tester);
      game.startGame(quick: true);
      game.score.value = 7;
      await tester.runAsync(() async {
        final saving = game.endGame();
        game.disposeResources();
        await saving;
        expect(
          await game.scoreRepository.getHighScore(game.difficulty.value),
          7,
        );
        final missions = await game.missionsRepository.loadSnapshot();
        expect(missions.dailyMissions[1].progress, 1);
      });
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'practice requires real taps and never changes records or currency',
    (tester) async {
      final game = await mountGame(tester);
      game.startGame(practice: true);
      await tester.pump();
      for (var gate = 0; gate < 3; gate++) {
        await tester.tapAt(
          tester.getCenter(find.byType(GameWidget<NightJumpGame>)),
        );
        // Drain Flutter's 40ms multitap gesture tracker before disposing the tree.
        await tester.pump(const Duration(milliseconds: 50));
        game.addScore();
        await tester.pump();
      }
      expect(game.tutorialCompleted, isTrue);
      expect(game.status, GameStatus.paused);
      expect(
        await tester.runAsync(game.settingsRepository.getHowToPlaySeen),
        isTrue,
      );
      expect(await tester.runAsync(game.missionsRepository.getStardust), 0);
      expect(game.highScore.value, 0);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('jump haptics follow the actual preference', (tester) async {
    final game = await mountGame(tester);
    var haptics = 0;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') haptics++;
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    game.orb.jump();
    await tester.pump();
    expect(haptics, 0);
    await tester.runAsync(game.toggleHaptics);
    game.orb.jump();
    await tester.pump();
    expect(haptics, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('shield callbacks consume once and expire only while playing', (
    tester,
  ) async {
    final game = await mountGame(tester);
    game.startGame(quick: true);
    game.shieldCount.value = 2;
    game.hit('Barrera');
    game.hit('Mina');
    game.hit('Techo');
    expect(game.shieldCount.value, 1);
    expect(game.shieldActive.value, isTrue);
    expect(game.orb.position.x, 120);
    expect(game.orb.position.y, 360);
    game.setBackground(true);
    game.update(0.05);
    expect(game.status, GameStatus.paused);
    game.setBackground(false);
    expect(game.status, GameStatus.paused);
    game.resumeGame();
    for (var i = 0; i < 31; i++) {
      game.orb.position.y = 360;
      game.orb.velocityY = 0;
      game.update(0.05);
    }
    expect(game.shieldActive.value, isFalse);
    game.hit('Cohete');
    expect(game.shieldCount.value, 0);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('background freezes countdown and requires explicit resume', (
    tester,
  ) async {
    final game = await mountGame(tester);
    game.startGame();
    await tester.pump();
    game.countdownStep = 1;
    game.lifecycleStateChange(AppLifecycleState.inactive);
    await tester.pump();
    game.beginPlaying();
    expect(game.status, GameStatus.paused);
    game.lifecycleStateChange(AppLifecycleState.resumed);
    expect(game.status, GameStatus.paused);
    expect(game.paused, isTrue);
    game.resumeGame();
    expect(game.status, GameStatus.countdown);
    expect(game.countdownStep, 1);
    game.returnToMenu();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'retry preserves mode and removes pending and mounted old gates',
    (tester) async {
      final game = await mountGame(tester);
      await tester.runAsync(() => game.setDifficulty(GameDifficulty.intense));
      for (var run = 0; run < 5; run++) {
        game.startGame(quick: true);
        for (var i = 0; i < 30; i++) {
          game.orb.position.y = 360;
          game.orb.velocityY = 0;
          game.update(0.05);
        }
        game.returnToMenu();
        await tester.runAsync(game.ready);
        expect(game.children.whereType<ObstacleComponent>(), isEmpty);
        expect(game.children.whereType<OrbComponent>().length, 1);
      }
      expect(game.difficulty.value, GameDifficulty.intense);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final size in [
    const Size(320, 568),
    const Size(430, 932),
    const Size(768, 1024),
    const Size(844, 390),
  ]) {
    testWidgets('home and results fit $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final game = await mountGame(tester);
      expect(tester.takeException(), isNull);
      game.startGame(quick: true);
      game.shieldCount.value = 0;
      await tester.runAsync(game.endGame);
      await tester.pump();
      expect(find.text('JUGAR OTRA VEZ'), findsOneWidget);
      expect(find.text('COMPARTIR RESULTADO'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
