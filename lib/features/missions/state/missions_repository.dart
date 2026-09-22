import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:night_jump/features/missions/state/mission.dart';
import 'package:night_jump/features/missions/state/missions_snapshot.dart';

class MissionsRepository {
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
  static const _weeklyScoreTarget = 50000;

  Future<int> getStardust() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_stardustKey) ?? 0;
  }

  Future<void> addDust(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_stardustKey) ?? 0;
    await prefs.setInt(_stardustKey, current + amount);
  }

  Future<bool> spendStardust(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_stardustKey) ?? 0;
    if (current < amount) return false;
    await prefs.setInt(_stardustKey, current - amount);
    return true;
  }

  Future<void> recordRunFinished({required int obstaclesCleared}) async {
    final prefs = await SharedPreferences.getInstance();
    await _rolloverIfNeeded(prefs);

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
  }

  Future<MissionsSnapshot> loadSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    await _rolloverIfNeeded(prefs);
    await _grantCompletedRewards(prefs);

    final now = DateTime.now();
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
  }

  List<Mission> _buildDailyMissions(SharedPreferences prefs) {
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

  List<Mission> _buildWeeklyMissions(SharedPreferences prefs) {
    final weeklyScore = prefs.getInt(_weeklyScoreKey) ?? 0;

    return [
      Mission(
        id: 'weekly_master',
        period: MissionPeriod.weekly,
        icon: Icons.diamond_rounded,
        title: 'Maestro de la Gravedad',
        subtitle:
            'Alcanza un total acumulado de $_weeklyScoreTarget '
            'puntos esta semana',
        progress: weeklyScore,
        target: _weeklyScoreTarget,
        reward: 500,
        rewardLabel: 'Cofre Épico',
        claimed: _isClaimed(prefs, 'weekly_master'),
      ),
    ];
  }

  bool _isClaimed(SharedPreferences prefs, String missionId) =>
      prefs.getBool('$_claimedPrefix$missionId') ?? false;

  Future<void> _grantCompletedRewards(SharedPreferences prefs) async {
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

  Future<void> _rolloverIfNeeded(SharedPreferences prefs) async {
    final today = _dateKey(DateTime.now());
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

    final week = _weekKey(DateTime.now());
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
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceStart = date.difference(firstDayOfYear).inDays;
    final weekNumber = ((daysSinceStart + firstDayOfYear.weekday - 1) / 7)
        .ceil();
    return '${date.year}-W$weekNumber';
  }
}
