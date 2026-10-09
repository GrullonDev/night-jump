import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:night_jump/features/game/state/game_difficulty.dart';
import 'package:night_jump/features/game/state/score_repository.dart';
import 'package:night_jump/features/leaderboard/state/leaderboard_repository.dart';
import 'package:night_jump/features/missions/state/missions_repository.dart';
import 'package:night_jump/features/settings/state/settings_repository.dart';
import 'package:night_jump/features/themes/state/neon_palette.dart';
import 'package:night_jump/features/themes/state/theme_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('weekly migration preserves progress and claims, resets on Monday across years', () async {
    var today = DateTime(2026, 10, 8);
    SharedPreferences.setMockInitialValues({
      'missions.weekly.key': '2026-W41',
      'missions.weekly.score': 250,
      'missions.claimed.weekly_master': true,
      'missions.stardust': 500,
    });
    final repository = MissionsRepository(now: () => today);
    var snapshot = await repository.loadSnapshot();
    expect(snapshot.weeklyMissions.single.progress, 250);
    expect(snapshot.weeklyMissions.single.claimed, isTrue);
    expect(snapshot.stardust, 500);
    today = DateTime(2026, 10, 12);
    snapshot = await repository.loadSnapshot();
    expect(snapshot.weeklyMissions.single.progress, 0);
    expect(snapshot.weeklyMissions.single.claimed, isFalse);
    today = DateTime(2026, 12, 31);
    await repository.recordRunFinished(obstaclesCleared: 8, runId: 'year-end');
    today = DateTime(2027, 1, 1);
    snapshot = await repository.loadSnapshot();
    expect(snapshot.weeklyMissions.single.progress, 8);
  });

  test(
    'migration retains separate records, legacy record, currency and themes',
    () async {
      SharedPreferences.setMockInitialValues({
        'night_jump.high_score.chill': 8,
        'night_jump.high_score.classic': 5,
        'night_jump.high_score.intense': 2,
        'night_jump.high_score': 17,
        'missions.stardust': 421,
        'theme.unlocked_palettes': ['aurora'],
        'theme.selected_palette': 'aurora',
      });
      final scores = await LeaderboardRepository().loadSnapshot();
      expect(scores, {
        GameDifficulty.chill: 8,
        GameDifficulty.classic: 5,
        GameDifficulty.intense: 2,
      });
      expect(await ScoreRepository().getLegacyScore(), 17);
      expect(await MissionsRepository().getStardust(), 421);
      expect(await ThemeRepository().getSelectedPaletteId(), 'aurora');
      expect(
        await ThemeRepository().getUnlockedPaletteIds(),
        contains('aurora'),
      );
      // New repository instances read the same persisted document.
      await ScoreRepository().saveScoreIfHigh(GameDifficulty.intense, 3);
      expect(await ScoreRepository().getHighScore(GameDifficulty.intense), 3);
      expect(await ScoreRepository().getHighScore(GameDifficulty.chill), 8);
    },
  );

  test('concurrent rewards and duplicate purchases never lose or double charge dust', () async {
    final missions = MissionsRepository();
    await missions.addDust(200);
    final operations = <Future<Object?>>[
      for (var i = 0; i < 50; i++) MissionsRepository().addDust(1),
      for (var i = 0; i < 20; i++)
        MissionsRepository().purchasePalette(NeonPalette.byId('aurora')),
    ];
    await Future.wait(operations);
    expect(await missions.getStardust(), 50);
    expect(await ThemeRepository().getUnlockedPaletteIds(), contains('aurora'));
  });

  test(
    'completed missions grant once and weekly target equals seven daily goals',
    () async {
      final missions = MissionsRepository();
      await Future.wait([
        missions.recordRunFinished(obstaclesCleared: 210, runId: 'one'),
        MissionsRepository().recordRunFinished(
          obstaclesCleared: 210,
          runId: 'one',
        ),
      ]);
      expect(await missions.getStardust(), 960);
      final snapshots = await Future.wait(
        List.generate(10, (_) => MissionsRepository().loadSnapshot()),
      );
      expect(snapshots.first.dailyMissions.length, 3);
      expect(snapshots.first.dailyMissions[1].progress, 1);
      expect(snapshots.first.weeklyMissions.single.target, 210);
      expect(await missions.getStardust(), 960);
    },
  );

  test(
    'insufficient balance and negative amounts cannot debit currency',
    () async {
      final missions = MissionsRepository();
      expect(
        await missions.purchasePalette(NeonPalette.byId('aurora')),
        isFalse,
      );
      await expectLater(missions.spendStardust(-1), throwsArgumentError);
      await expectLater(missions.addDust(-1), throwsArgumentError);
      expect(await missions.getStardust(), 0);
    },
  );

  test(
    'reset clears migrated progress while retaining preferences and tutorial',
    () async {
      final settings = SettingsRepository();
      await settings.setHowToPlaySeen();
      await settings.setHapticsEnabled(false);
      await MissionsRepository().addDust(100);
      await settings.resetProgress();
      expect(await MissionsRepository().getStardust(), 0);
      expect(await settings.getHapticsEnabled(), isFalse);
      expect(await settings.getHowToPlaySeen(), isTrue);
    },
  );
}
