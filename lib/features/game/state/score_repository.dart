import 'package:night_jump/utils/progress_store.dart';

import 'package:night_jump/features/game/state/game_difficulty.dart';

/// Persists the player's best score per [GameDifficulty] across sessions.
class ScoreRepository {
  String _key(GameDifficulty d) => 'night_jump.high_score.${d.id}';

  Future<int> getHighScore(GameDifficulty difficulty) =>
      ProgressStore.transaction((prefs) async {
        return prefs.getInt(_key(difficulty)) ?? 0;
      });

  Future<int> getLegacyScore() => ProgressStore.transaction(
    (prefs) async => prefs.getInt('night_jump.high_score') ?? 0,
  );

  /// Saves [score] as the new high score if it beats the stored one.
  /// Returns true when a new high score was set.
  Future<bool> saveScoreIfHigh(GameDifficulty difficulty, int score) =>
      ProgressStore.transaction((prefs) async {
        final current = prefs.getInt(_key(difficulty)) ?? 0;
        if (score > current) {
          await prefs.setInt(_key(difficulty), score);
          return true;
        }
        return false;
      });
}
