/// Selectable speed presets. Classic matches the original tuning;
/// chill is slower with a wider gap, intense is faster with a tighter gap.
enum GameDifficulty { chill, classic, intense }

extension GameDifficultyX on GameDifficulty {
  String get id => name;

  String get label {
    switch (this) {
      case GameDifficulty.chill:
        return 'Tranquilo';
      case GameDifficulty.classic:
        return 'Clásico';
      case GameDifficulty.intense:
        return 'Intenso';
    }
  }

  String get subtitle {
    switch (this) {
      case GameDifficulty.chill:
        return 'Lento y con hueco amplio. Para relajarse.';
      case GameDifficulty.classic:
        return 'El ritmo original del juego.';
      case GameDifficulty.intense:
        return 'Rápido y con hueco justo. Solo expertos.';
    }
  }

  double get obstacleSpeed {
    switch (this) {
      case GameDifficulty.chill:
        return 130;
      case GameDifficulty.classic:
        return 180;
      case GameDifficulty.intense:
        return 235;
    }
  }

  double get spawnInterval {
    switch (this) {
      case GameDifficulty.chill:
        return 2.0;
      case GameDifficulty.classic:
        return 1.6;
      case GameDifficulty.intense:
        return 1.25;
    }
  }

  double get gapHeight {
    switch (this) {
      case GameDifficulty.chill:
        return 230;
      case GameDifficulty.classic:
        return 190;
      case GameDifficulty.intense:
        return 170;
    }
  }

  static GameDifficulty fromId(String? id) {
    for (final difficulty in GameDifficulty.values) {
      if (difficulty.id == id) return difficulty;
    }
    return GameDifficulty.classic;
  }
}
