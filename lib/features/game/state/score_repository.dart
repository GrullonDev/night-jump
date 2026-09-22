import 'package:shared_preferences/shared_preferences.dart';

import 'package:night_jump/features/game/state/game_difficulty.dart';

/// Persists the player's best score per [GameDifficulty] across sessions.
class ScoreRepository {
  String _key(GameDifficulty d) => 'night_jump.high_score.${d.id}';

  Future<int> getHighScore(GameDifficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key(difficulty)) ?? 0;
  }

  /// Saves [score] as the new high score if it beats the stored one.
  /// Returns true when a new high score was set.
  Future<bool> saveScoreIfHigh(GameDifficulty difficulty, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_key(difficulty)) ?? 0;
    if (score > current) {
      await prefs.setInt(_key(difficulty), score);
      return true;
    }
    return false;
  }
}
