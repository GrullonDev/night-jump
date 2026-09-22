import 'package:flutter/material.dart';

import 'package:night_jump/features/game/state/game_difficulty.dart';
import 'package:night_jump/features/game/state/score_repository.dart';
import 'package:night_jump/features/leaderboard/state/leaderboard_entry.dart';
import 'package:night_jump/features/leaderboard/state/leaderboard_snapshot.dart';
import 'package:night_jump/utils/theme/app_color.dart';

enum LeaderboardTab { global, friends, league }

/// Builds the leaderboard shown to the player.
///
/// Night Jump has no backend/multiplayer sync yet, so the other pilots
/// here are a fixed sample roster (not live data) meant to give the
/// screen a sense of competition. The player's own row always reflects
/// their real, locally saved high score.
class LeaderboardRepository {
  LeaderboardRepository({ScoreRepository? scoreRepository})
    : scoreRepository = scoreRepository ?? ScoreRepository();

  final ScoreRepository scoreRepository;

  static const seasonLabel = 'T4';
  static const modeLabel = 'Night Jump Velocity';
  static final _seasonEnd = DateTime.now().add(
    const Duration(days: 12, hours: 8),
  );

  static const _sampleRoster = [
    LeaderboardEntry(
      rank: 1,
      name: 'NovaStrike',
      subtitle: 'Racha Perfecta 34x',
      score: 148920,
      avatarIcon: Icons.rocket_launch_rounded,
      avatarColor: AppColor.electricCyan,
      tier: LeaderboardTier.champion,
      badgeLabel: 'CAMPEÓN',
    ),
    LeaderboardEntry(
      rank: 2,
      name: 'AstroViper',
      subtitle: 'Célula Hiper-Salto',
      score: 132450,
      avatarIcon: Icons.bolt_rounded,
      avatarColor: AppColor.intenseMagenta,
      tier: LeaderboardTier.multiplier,
      badgeLabel: 'Racha x4.8 Multi',
    ),
    LeaderboardEntry(
      rank: 3,
      name: 'NeonDrifter',
      subtitle: 'Orbital Racer',
      score: 118800,
      avatarIcon: Icons.auto_awesome_rounded,
      avatarColor: AppColor.slateWhite,
      tier: LeaderboardTier.podium,
      isFriend: true,
    ),
    LeaderboardEntry(
      rank: 4,
      name: 'Solaris_X',
      subtitle: 'Sector 18 • 186 Jumps',
      score: 98400,
      avatarIcon: Icons.rocket_rounded,
      avatarColor: AppColor.electricCyan,
      isFriend: true,
    ),
    LeaderboardEntry(
      rank: 5,
      name: 'CosmicRay',
      subtitle: 'Sector 14 • 142 Jumps',
      score: 87210,
      avatarIcon: Icons.flash_on_rounded,
      avatarColor: AppColor.neonRose,
    ),
    LeaderboardEntry(
      rank: 6,
      name: 'VoidRunner',
      subtitle: 'Sector 11 • 120 Jumps',
      score: 61500,
      avatarIcon: Icons.blur_circular_rounded,
      avatarColor: AppColor.slateGlow,
      isFriend: true,
    ),
    LeaderboardEntry(
      rank: 7,
      name: 'StarPulse',
      subtitle: 'Sector 9 • 97 Jumps',
      score: 40120,
      avatarIcon: Icons.star_rounded,
      avatarColor: AppColor.electricCyan,
    ),
  ];

  Future<LeaderboardSnapshot> loadSnapshot({
    LeaderboardTab tab = LeaderboardTab.global,
  }) async {
    final scoresByDifficulty = await Future.wait(
      GameDifficulty.values.map(scoreRepository.getHighScore),
    );
    final highScore = scoresByDifficulty.fold(0, (a, b) => a > b ? a : b);

    final roster = switch (tab) {
      LeaderboardTab.global => _sampleRoster,
      LeaderboardTab.friends => _sampleRoster.where((e) => e.isFriend).toList(),
      LeaderboardTab.league => _sampleRoster.take(5).toList(),
    };

    // Points still needed to beat the next roster entry above the player,
    // computed before ranks are reassigned below.
    LeaderboardEntry? nextAbove;
    for (final entry in roster) {
      if (entry.score > highScore &&
          (nextAbove == null || entry.score < nextAbove.score)) {
        nextAbove = entry;
      }
    }

    final tempPlayerEntry = LeaderboardEntry(
      rank: 0,
      name: 'Tú (AstroPilot)',
      subtitle: 'Récord de Salto Simple',
      score: highScore,
      avatarIcon: Icons.circle,
      avatarColor: AppColor.neonRose,
      tier: LeaderboardTier.player,
    );

    // Merge the player into the roster by score so every rank shown on
    // screen (including the player's) is contiguous and unique.
    final merged = [...roster, tempPlayerEntry]
      ..sort((a, b) => b.score.compareTo(a.score));

    LeaderboardEntry withRank(LeaderboardEntry entry, int rank) =>
        LeaderboardEntry(
          rank: rank,
          name: entry.name,
          subtitle: entry.subtitle,
          score: entry.score,
          avatarIcon: entry.avatarIcon,
          avatarColor: entry.avatarColor,
          tier: entry.tier,
          badgeLabel: entry.badgeLabel,
          isFriend: entry.isFriend,
        );

    final rankedRoster = <LeaderboardEntry>[];
    late LeaderboardEntry playerEntry;
    for (var i = 0; i < merged.length; i++) {
      final ranked = withRank(merged[i], i + 1);
      if (merged[i].tier == LeaderboardTier.player) {
        playerEntry = ranked;
      } else {
        rankedRoster.add(ranked);
      }
    }

    return LeaderboardSnapshot(
      seasonLabel: seasonLabel,
      seasonEndsIn: _seasonEnd.difference(DateTime.now()),
      modeLabel: modeLabel,
      topEntries: rankedRoster,
      playerEntry: playerEntry,
      pointsToNextRank: nextAbove == null ? 0 : nextAbove.score - highScore,
      nextRank: nextAbove == null ? playerEntry.rank : playerEntry.rank - 1,
    );
  }
}
