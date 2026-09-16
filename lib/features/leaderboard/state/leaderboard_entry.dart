import 'package:flutter/material.dart';

enum LeaderboardTier { champion, podium, multiplier, standard, player }

/// A single row in the leaderboard, either a ranked opponent or the
/// player's own entry.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.subtitle,
    required this.score,
    required this.avatarIcon,
    required this.avatarColor,
    this.tier = LeaderboardTier.standard,
    this.badgeLabel,
    this.isFriend = false,
  });

  final int rank;
  final String name;
  final String subtitle;
  final int score;
  final IconData avatarIcon;
  final Color avatarColor;
  final LeaderboardTier tier;
  final String? badgeLabel;
  final bool isFriend;
}
