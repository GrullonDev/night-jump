import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/game/page/game_page.dart';
import 'package:night_jump/features/game/state/game_difficulty.dart';
import 'package:night_jump/features/game/state/score_repository.dart';
import 'package:night_jump/features/missions/state/missions_repository.dart';
import 'package:night_jump/features/settings/state/settings_repository.dart';
import 'package:night_jump/features/themes/state/neon_palette.dart';
import 'package:night_jump/features/themes/state/theme_repository.dart';
import 'package:night_jump/utils/progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Run seed and verify as separate native processes. This deliberately uses
/// real platform storage, but a dedicated prefix never touches player data.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setPrefix('night_jump.qa.1_0_1.');
  const phase = String.fromEnvironment(
    'NIGHT_JUMP_QA_PHASE',
    defaultValue: 'verify',
  );

  testWidgets('native progress survives a second launch ($phase)', (
    tester,
  ) async {
    expect(phase, anyOf('seed', 'verify'));
    final prefs = await SharedPreferences.getInstance();
    final missions = MissionsRepository(now: () => DateTime(2026, 10, 9));
    final scores = ScoreRepository();
    final settings = SettingsRepository();
    final themes = ThemeRepository();

    if (phase == 'seed') {
      // Only the QA document is replaced, not flutter.* production progress.
      expect(await prefs.setString(ProgressStore.key, '{}'), isTrue);
      await settings.setSoundEnabled(false);
      await settings.setHapticsEnabled(false);
      await settings.setHowToPlaySeen();
      await settings.setDifficultyId('classic');
      await settings.setComfortDim(true);
      await scores.saveScoreIfHigh(GameDifficulty.chill, 7);
      await scores.saveScoreIfHigh(GameDifficulty.classic, 13);
      await scores.saveScoreIfHigh(GameDifficulty.intense, 5);
      await missions.recordGateProgress(
        runId: 'native-qa',
        obstaclesCleared: 30,
      );
      await missions.recordRunFinished(
        obstaclesCleared: 30,
        runId: 'native-qa',
      );
      await missions.addDust(250);
      expect(
        await missions.purchasePalette(NeonPalette.byId('aurora')),
        isTrue,
      );
      await themes.selectPalette('aurora');
      expect(await prefs.setString('qa.phase', 'seeded'), isTrue);
    } else {
      // A missing marker is a failure, not an excuse to seed in the read test.
      expect(prefs.getString('qa.phase'), 'seeded');
    }

    await prefs.reload();
    expect(await scores.getHighScore(GameDifficulty.chill), 7);
    expect(await scores.getHighScore(GameDifficulty.classic), 13);
    expect(await scores.getHighScore(GameDifficulty.intense), 5);
    expect(await missions.getStardust(), 330);
    expect(await themes.getSelectedPaletteId(), 'aurora');
    expect(await themes.getUnlockedPaletteIds(), contains('aurora'));
    expect(await settings.getSoundEnabled(), isFalse);
    expect(await settings.getHapticsEnabled(), isFalse);
    expect(await settings.getHowToPlaySeen(), isTrue);
    expect(await settings.getComfortDim(), isTrue);
    final snapshot = await missions.loadSnapshot();
    expect(snapshot.dailyMissions[0].claimed, isTrue);
    expect(snapshot.dailyMissions[1].progress, 1);
    expect(snapshot.dailyMissions[2].claimed, isTrue);
    await missions.recordRunFinished(obstaclesCleared: 30, runId: 'native-qa');
    expect(await missions.getStardust(), 330);

    final game = NightJumpGame();
    await tester.pumpWidget(MaterialApp(home: GamePage(game: game)));
    final deadline = DateTime.now().add(const Duration(seconds: 30));
    while (!game.overlays.isActive(NightJumpGame.menuOverlay) &&
        DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump();
    expect(game.overlays.isActive(NightJumpGame.menuOverlay), isTrue);
    expect(game.highScore.value, 13);
    expect(game.palette.value.id, 'aurora');
    expect(game.soundEnabled.value, isFalse);
    expect(find.text('RÉCORD • Clásico'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
