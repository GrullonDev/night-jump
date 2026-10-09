import 'package:flutter/material.dart';

import 'package:night_jump/utils/progress_store.dart';
import 'package:night_jump/features/themes/state/neon_palette.dart';

import 'package:night_jump/features/missions/state/mission.dart';
import 'package:night_jump/features/missions/state/missions_snapshot.dart';

class MissionsRepository {
  MissionsRepository({DateTime Function()? now}) : _now = now ?? DateTime.now;
  final DateTime Function() _now;
  static const _stardustKey = 'missions.stardust';
  static const _dailyDateKey = 'missions.daily.date';
  static const _dailyObstaclesKey = 'missions.daily.obstacles';
  static const _dailyGamesKey = 'missions.daily.games';
  static const _dailyBestRunKey = 'missions.daily.best_run';
  static const _weeklyKeyKey = 'missions.weekly.key';
  static const _weeklyScoreKey = 'missions.weekly.score';
  static const _claimedPrefix = 'missions.claimed.';

  static const _dailyObstaclesTarget = 30;
  static const _dailyGamesTarget = 3;
  static const _dailyBestRunTarget = 10;
  // Seven daily obstacle goals (30 × 7): about 4–5 short runs/day at 7–8
  // gates/run. First paid theme costs less than a completed daily set.
  static const weeklyObstaclesTarget = 210;
  static const _weeklyScoreTarget = weeklyObstaclesTarget;

  Future<int> getStardust() => ProgressStore.transaction((prefs) async {
    return prefs.getInt(_stardustKey) ?? 0;
  });

  Future<void> addDust(int amount) => ProgressStore.transaction((prefs) async {
    if (amount < 0) throw ArgumentError.value(amount);
    final current = prefs.getInt(_stardustKey) ?? 0;
    await prefs.setInt(_stardustKey, current + amount);
  });

  Future<bool> spendStardust(int amount) =>
      ProgressStore.transaction((prefs) async {
        if (amount < 0) throw ArgumentError.value(amount);
        final current = prefs.getInt(_stardustKey) ?? 0;
        if (current < amount) return false;
        await prefs.setInt(_stardustKey, current - amount);
        return true;
      });

  /// Charge and unlock in the same durable write; repeated taps are idempotent.
  Future<bool> purchasePalette(NeonPalette palette) =>
      ProgressStore.transaction((prefs) async {
        final unlocked = (prefs.getStringList('theme.unlocked_palettes') ?? [])
            .toSet();
        if (palette.isFree || unlocked.contains(palette.id)) return true;
        final balance = prefs.getInt(_stardustKey) ?? 0;
        if (balance < palette.cost) return false;
        unlocked.add(palette.id);
        await prefs.setInt(_stardustKey, balance - palette.cost);
        await prefs.setStringList('theme.unlocked_palettes', unlocked.toList());
        return true;
      });

  Future<int> recordRunFinished({
    required int obstaclesCleared,
    String? runId,
    bool includeGateDust = true,
  }) => ProgressStore.transaction((prefs) async {
    if (obstaclesCleared < 0) throw ArgumentError.value(obstaclesCleared);
    if (runId != null && prefs.getString('missions.last_run') == runId) {
      return 0;
    }
    await _rolloverIfNeeded(prefs);
    final before = prefs.getInt(_stardustKey) ?? 0;
    await prefs.setInt(
      _stardustKey,
      before + (includeGateDust ? obstaclesCleared : 0),
    );

    await prefs.setInt(
      _dailyObstaclesKey,
      (prefs.getInt(_dailyObstaclesKey) ?? 0) + obstaclesCleared,
    );
    await prefs.setInt(_dailyGamesKey, (prefs.getInt(_dailyGamesKey) ?? 0) + 1);
    final bestRun = prefs.getInt(_dailyBestRunKey) ?? 0;
    if (obstaclesCleared > bestRun) {
      await prefs.setInt(_dailyBestRunKey, obstaclesCleared);
    }
    await prefs.setInt(
      _weeklyScoreKey,
      (prefs.getInt(_weeklyScoreKey) ?? 0) + obstaclesCleared,
    );

    await _grantCompletedRewards(prefs);
    if (runId != null) await prefs.setString('missions.last_run', runId);
    return (prefs.getInt(_stardustKey) ?? 0) - before;
  });

  Future<MissionsSnapshot> loadSnapshot() =>
      ProgressStore.transaction((prefs) async {
        await _rolloverIfNeeded(prefs);
        await _grantCompletedRewards(prefs);

        final now = _now();
        final nextReset = DateTime(
          now.year,
          now.month,
          now.day,
        ).add(const Duration(days: 1));

        return MissionsSnapshot(
          stardust: prefs.getInt(_stardustKey) ?? 0,
          timeUntilDailyReset: nextReset.difference(now),
          dailyMissions: _buildDailyMissions(prefs),
          weeklyMissions: _buildWeeklyMissions(prefs),
        );
      });

  List<Mission> _buildDailyMissions(ProgressData prefs) {
    final obstacles = prefs.getInt(_dailyObstaclesKey) ?? 0;
    final games = prefs.getInt(_dailyGamesKey) ?? 0;
    final bestRun = prefs.getInt(_dailyBestRunKey) ?? 0;

    return [
      Mission(
        id: 'daily_obstacles',
        period: MissionPeriod.daily,
        icon: Icons.check_circle_rounded,
        title: 'Supera $_dailyObstaclesTarget obstáculos',
        subtitle: 'Acumula obstáculos superados hoy',
        progress: obstacles,
        target: _dailyObstaclesTarget,
        reward: 150,
        rewardLabel: '+150',
        claimed: _isClaimed(prefs, 'daily_obstacles'),
      ),
      Mission(
        id: 'daily_games',
        period: MissionPeriod.daily,
        icon: Icons.nightlight_round,
        title: 'Vuelo Nocturno',
        subtitle: 'Juega $_dailyGamesTarget partidas hoy',
        progress: games,
        target: _dailyGamesTarget,
        reward: 80,
        rewardLabel: '+80',
        claimed: _isClaimed(prefs, 'daily_games'),
      ),
      Mission(
        id: 'daily_best_run',
        period: MissionPeriod.daily,
        icon: Icons.speed_rounded,
        title: 'Salto Perfecto',
        subtitle: 'Supera $_dailyBestRunTarget obstáculos en una partida',
        progress: bestRun,
        target: _dailyBestRunTarget,
        reward: 100,
        rewardLabel: '+100',
        claimed: _isClaimed(prefs, 'daily_best_run'),
      ),
    ];
  }

  List<Mission> _buildWeeklyMissions(ProgressData prefs) {
    final weeklyScore = prefs.getInt(_weeklyScoreKey) ?? 0;

    return [
      Mission(
        id: 'weekly_master',
        period: MissionPeriod.weekly,
        icon: Icons.diamond_rounded,
        title: 'Maestro de la Gravedad',
        subtitle:
            'Supera un total acumulado de $_weeklyScoreTarget '
            'obstáculos esta semana',
        progress: weeklyScore,
        target: _weeklyScoreTarget,
        reward: 500,
        rewardLabel: '+500 Stardust',
        claimed: _isClaimed(prefs, 'weekly_master'),
      ),
    ];
  }

  bool _isClaimed(ProgressData prefs, String missionId) =>
      prefs.getBool('$_claimedPrefix$missionId') ?? false;

  Future<void> _grantCompletedRewards(ProgressData prefs) async {
    var stardust = prefs.getInt(_stardustKey) ?? 0;

    for (final mission in [
      ..._buildDailyMissions(prefs),
      ..._buildWeeklyMissions(prefs),
    ]) {
      if (mission.isCompleted && !mission.claimed) {
        stardust += mission.reward;
        await prefs.setBool('$_claimedPrefix${mission.id}', true);
      }
    }

    await prefs.setInt(_stardustKey, stardust);
  }

  Future<void> _rolloverIfNeeded(ProgressData prefs) async {
    final now = _now();
    final today = _dateKey(now);
    if (prefs.getString(_dailyDateKey) != today) {
      await prefs.setString(_dailyDateKey, today);
      await prefs.setInt(_dailyObstaclesKey, 0);
      await prefs.setInt(_dailyGamesKey, 0);
      await prefs.setInt(_dailyBestRunKey, 0);
      await prefs.remove(
        '$_claimedPrefix'
        'daily_obstacles',
      );
      await prefs.remove(
        '$_claimedPrefix'
        'daily_games',
      );
      await prefs.remove(
        '$_claimedPrefix'
        'daily_best_run',
      );
    }

    final week = _weekKey(now);
    if (prefs.getString(_weeklyKeyKey) == _legacyWeekKey(now)) {
      await prefs.setString(_weeklyKeyKey, week);
    }
    if (prefs.getString(_weeklyKeyKey) != week) {
      await prefs.setString(_weeklyKeyKey, week);
      await prefs.setInt(_weeklyScoreKey, 0);
      await prefs.remove(
        '$_claimedPrefix'
        'weekly_master',
      );
    }
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _weekKey(DateTime date) {
    return _dateKey(
      DateTime(date.year, date.month, date.day - date.weekday + 1),
    );
  }

  String _legacyWeekKey(DateTime date) {
    final first = DateTime(date.year, 1, 1);
    final week = ((date.difference(first).inDays + first.weekday - 1) / 7)
        .ceil();
    return '${date.year}-W$week';
  }
}
