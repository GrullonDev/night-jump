import 'package:night_jump/features/leaderboard/state/leaderboard_entry.dart';

/// Everything the leaderboard screen needs: the season info, the visible
/// top entries for the selected tab, and where the player currently
/// stands (including how far they are from the next rank).
class LeaderboardSnapshot {
  const LeaderboardSnapshot({
    required this.seasonLabel,
    required this.seasonEndsIn,
    required this.modeLabel,
    required this.topEntries,
    required this.playerEntry,
    required this.pointsToNextRank,
    required this.nextRank,
  });

  final String seasonLabel;
  final Duration seasonEndsIn;
  final String modeLabel;
  final List<LeaderboardEntry> topEntries;
  final LeaderboardEntry playerEntry;

  /// Points still needed to reach [nextRank]. Zero when already there.
  final int pointsToNextRank;
  final int nextRank;
}
