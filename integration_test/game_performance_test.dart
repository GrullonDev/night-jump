import 'dart:io' show ProcessInfo;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:night_jump/features/game/components/orb_component.dart';
import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/game/page/game_page.dart';
import 'package:night_jump/features/game/state/game_difficulty.dart';
import 'package:night_jump/features/game/state/game_status.dart';
import 'package:night_jump/features/settings/state/settings_repository.dart';
import 'package:night_jump/utils/progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Automated taps exercise real physics, rendering, hazards and audio. Run in
/// profile mode on hardware; debug/emulator results are not release evidence.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setPrefix('night_jump.qa.profile.1_0_1.');
  const seconds = int.fromEnvironment(
    'NIGHT_JUMP_QA_SECONDS',
    defaultValue: 600,
  );

  testWidgets('sustained gameplay in all modes', (tester) async {
    expect(kProfileMode, isTrue, reason: 'Use flutter drive --profile');
    expect(seconds, inInclusiveRange(30, 600));
    final prefs = await SharedPreferences.getInstance();
    expect(await prefs.setString(ProgressStore.key, '{}'), isTrue);
    final settings = SettingsRepository();
    await settings.setSoundEnabled(true);
    await settings.setHapticsEnabled(false);
    await settings.setComfortDim(false);
    await settings.setHowToPlaySeen();
    final game = NightJumpGame();
    await tester.pumpWidget(MaterialApp(home: GamePage(game: game)));
    final loadDeadline = DateTime.now().add(const Duration(seconds: 30));
    while (!game.overlays.isActive(NightJumpGame.menuOverlay) &&
        DateTime.now().isBefore(loadDeadline)) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(game.overlays.isActive(NightJumpGame.menuOverlay), isTrue);
    final samples = <String, Object>{'rss_start_bytes': ProcessInfo.currentRss};

    for (final difficulty in GameDifficulty.values) {
      await game.setDifficulty(difficulty);
      game.startGame(quick: true);
      var taps = 0, runs = 1, pauses = 0, gates = 0, lastScore = 0;
      final watch = Stopwatch();
      await binding.watchPerformance(() async {
        watch.start();
        while (watch.elapsed.inMilliseconds < seconds * 1000 ~/ 3) {
          if (game.status == GameStatus.gameOver && !game.saving) {
            game.playAgain();
            lastScore = 0;
            runs++;
          } else if (game.status == GameStatus.paused) {
            game.resumeGame();
            pauses++;
          } else if (game.status == GameStatus.playing &&
              game.orb.velocityY > 0 &&
              game.orb.position.y >= game.size.y / 2 + 26) {
            await tester.tapAt(
              tester.getCenter(find.byType(GameWidget<NightJumpGame>)),
            );
            taps++;
          }
          await tester.pump(const Duration(milliseconds: 16));
          if (game.score.value > lastScore) {
            gates += game.score.value - lastScore;
            lastScore = game.score.value;
          }
        }
        watch.stop();
      }, reportKey: '${difficulty.id}_frames');
      samples[difficulty.id] = {
        'elapsed_ms': watch.elapsedMilliseconds,
        'taps': taps,
        'gates': gates,
        'runs': runs,
        'safety_pauses': pauses,
        'rss_bytes': ProcessInfo.currentRss,
      };
      expect(gates, greaterThan(0));
      expect(game.children.whereType<OrbComponent>(), hasLength(1));
      while (game.saving) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      game.returnToMenu();
      await tester.pump();
    }
    binding.reportData ??= {};
    binding.reportData!['gameplay_samples'] = samples;
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
