import 'package:shared_preferences/shared_preferences.dart';

/// Persists the player's best score across sessions.
class ScoreRepository {
  static const _highScoreKey = 'night_jump.high_score';

  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  /// Saves [score] as the new high score if it beats the stored one.
  /// Returns true when a new high score was set.
  Future<bool> saveScoreIfHigh(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_highScoreKey) ?? 0;
    if (score > current) {
      await prefs.setInt(_highScoreKey, score);
      return true;
    }
    return false;
  }
}
