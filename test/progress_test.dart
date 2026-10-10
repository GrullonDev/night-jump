import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:night_jump/features/game/state/game_difficulty.dart';
import 'package:night_jump/features/game/state/score_repository.dart';
import 'package:night_jump/features/leaderboard/state/leaderboard_repository.dart';
import 'package:night_jump/features/missions/state/missions_repository.dart';
import 'package:night_jump/features/settings/state/settings_repository.dart';
import 'package:night_jump/features/themes/state/neon_palette.dart';
import 'package:night_jump/features/themes/state/theme_repository.dart';

class RejectedWriteStore extends InMemorySharedPreferencesStore {
  RejectedWriteStore({required this.throwsOnFailure}) : super.empty();
  final bool throwsOnFailure;
  bool rejectNextWrite = false;
  int rejectedReads = 0;

  @override
  Future<Map<String, Object>> getAll() async {
    if (rejectedReads > 0) {
      rejectedReads--;
      throw StateError('Simulated native reload failure');
    }
    return super.getAll();
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    if (rejectNextWrite) {
      rejectNextWrite = false;
      if (throwsOnFailure) throw StateError('Simulated native write failure');
      return false;
    }
    return super.setValue(valueType, key, value);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'casual 6 to 10 gate runs unlock the first theme in 3 to 5 games',
    () async {
      for (final (gates, expectedGames) in [(6, 5), (8, 4), (10, 3)]) {
        SharedPreferences.setMockInitialValues({});
        final missions = MissionsRepository(now: () => DateTime(2026, 10, 8));
        for (var run = 1; run <= expectedGames; run++) {
          await missions.recordRunFinished(
            obstaclesCleared: gates,
            runId: 'casual-$gates-$run',
          );
          final balance = await missions.getStardust();
          if (run < expectedGames) {
            expect(balance, lessThan(NeonPalette.byId('aurora').cost));
          } else {
            expect(
              balance,
              greaterThanOrEqualTo(NeonPalette.byId('aurora').cost),
            );
          }
        }
      }
    },
  );

  test(
    'transactions wait for durable recovery when cache reload also fails',
    () async {
      final previousStore = SharedPreferencesStorePlatform.instance;
      final store = RejectedWriteStore(throwsOnFailure: false);
      SharedPreferencesStorePlatform.instance = store;
      SharedPreferences.resetStatic();
      addTearDown(() {
        SharedPreferencesStorePlatform.instance = previousStore;
        SharedPreferences.resetStatic();
      });
      final missions = MissionsRepository();
      await missions.addDust(200);
      store.rejectNextWrite = true;
      store.rejectedReads = 2;
      await expectLater(
        missions.purchasePalette(NeonPalette.byId('aurora')),
        throwsStateError,
      );
      await expectLater(missions.getStardust(), throwsStateError);
      expect(await missions.getStardust(), 200);
      expect(
        await ThemeRepository().getUnlockedPaletteIds(),
        isNot(contains('aurora')),
      );
    },
  );

  for (final throwsOnFailure in [false, true]) {
    test(
      'a rejected purchase cannot poison cached progress ($throwsOnFailure)',
      () async {
        final previousStore = SharedPreferencesStorePlatform.instance;
        final store = RejectedWriteStore(throwsOnFailure: throwsOnFailure);
        SharedPreferencesStorePlatform.instance = store;
        SharedPreferences.resetStatic();
        addTearDown(() {
          SharedPreferencesStorePlatform.instance = previousStore;
          SharedPreferences.resetStatic();
        });
        final missions = MissionsRepository();
        await missions.addDust(200);
        store.rejectNextWrite = true;
        await expectLater(
          missions.purchasePalette(NeonPalette.byId('aurora')),
          throwsStateError,
        );
        expect(await missions.getStardust(), 200);
        expect(
          await ThemeRepository().getUnlockedPaletteIds(),
          isNot(contains('aurora')),
        );
        expect(
          await missions.purchasePalette(NeonPalette.byId('aurora')),
          isTrue,
        );
        expect(await missions.getStardust(), 0);
        expect(
          await ThemeRepository().getUnlockedPaletteIds(),
          contains('aurora'),
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.reload();
        expect(await MissionsRepository().getStardust(), 0);
      },
    );
  }

  test(
    'cumulative gate checkpoints recover missing writes without duplicates',
    () async {
      final missions = MissionsRepository();
      await missions.recordGateProgress(runId: 'flight', obstaclesCleared: 2);
      await missions.recordGateProgress(runId: 'flight', obstaclesCleared: 1);
      await missions.recordGateProgress(runId: 'flight', obstaclesCleared: 2);
      await missions.recordRunFinished(obstaclesCleared: 7, runId: 'flight');
      await missions.recordRunFinished(obstaclesCleared: 7, runId: 'flight');
      expect(await missions.getStardust(), 7);
      final snapshot = await missions.loadSnapshot();
      expect(snapshot.dailyMissions[0].progress, 7);
      expect(snapshot.dailyMissions[1].progress, 1);
      await missions.recordGateProgress(runId: 'next', obstaclesCleared: 1);
      expect(await missions.getStardust(), 8);
    },
  );

  test('reset does not delete a reward queued after it', () async {
    final missions = MissionsRepository();
    await missions.addDust(100);
    final reset = SettingsRepository().resetProgress();
    final reward = missions.addDust(7);
    await Future.wait([reset, reward]);
    expect(await MissionsRepository().getStardust(), 7);
  });

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
