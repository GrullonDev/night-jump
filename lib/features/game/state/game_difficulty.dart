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
        return 'Hueco amplio. 1 escudo al llegar a 15 puntos.';
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
        return 250;
      case GameDifficulty.classic:
        return 190;
      case GameDifficulty.intense:
        return 170;
    }
  }

  // ── Shield Config ──

  /// Maximum shields a player can hold during a run.
  int get maxShields {
    switch (this) {
      case GameDifficulty.chill:
        return 1;
      case GameDifficulty.classic:
        return 5;
      case GameDifficulty.intense:
        return 5;
    }
  }

  /// Starting shield count granted at run start.
  int get startingShields {
    switch (this) {
      case GameDifficulty.chill:
        return 0;
      case GameDifficulty.classic:
        return 1;
      case GameDifficulty.intense:
        return 1;
    }
  }

  /// For chill: auto-grant shield at this score threshold (0 = disabled).
  /// For classic/intense: 0 (gems are used instead).
  int get shieldScoreThreshold {
    switch (this) {
      case GameDifficulty.chill:
        return 15;
      case GameDifficulty.classic:
        return 0;
      case GameDifficulty.intense:
        return 0;
    }
  }

  /// Number of obstacles to clear before the first gem spawns (classic/intense).
  int get gemSpawnAfterFirst {
    switch (this) {
      case GameDifficulty.chill:
        return 0; // No gems in chill
      case GameDifficulty.classic:
        return 3;
      case GameDifficulty.intense:
        return 3;
    }
  }

  /// Interval (in obstacles) for subsequent gem spawns after the first.
  int get gemSpawnInterval {
    switch (this) {
      case GameDifficulty.chill:
        return 0; // No gems in chill
      case GameDifficulty.classic:
        return 5;
      case GameDifficulty.intense:
        return 5;
    }
  }

  static GameDifficulty fromId(String? id) {
    for (final difficulty in GameDifficulty.values) {
      if (difficulty.id == id) return difficulty;
    }
    return GameDifficulty.classic;
  }
}
