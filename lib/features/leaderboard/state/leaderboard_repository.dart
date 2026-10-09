import 'package:night_jump/features/game/state/game_difficulty.dart';
import 'package:night_jump/features/game/state/score_repository.dart';

class LeaderboardRepository {
  LeaderboardRepository({ScoreRepository? scoreRepository})
    : scoreRepository = scoreRepository ?? ScoreRepository();
  final ScoreRepository scoreRepository;
  Future<Map<GameDifficulty, int>> loadSnapshot() async => {
    for (final mode in GameDifficulty.values)
      mode: await scoreRepository.getHighScore(mode),
  };
}
