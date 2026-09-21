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
        return 'Hueco amplio. Minas, cohetes y escudos dinámicos.';
      case GameDifficulty.classic:
        return 'El ritmo original del juego.';
      case GameDifficulty.intense:
        return 'Rápido y con hueco justo. Solo expertos.';
    }
  }

  double get obstacleSpeed {
    switch (this) {
      case GameDifficulty.chill:
        return 140;
      case GameDifficulty.classic:
        return 180;
      case GameDifficulty.intense:
        return 235;
    }
  }

  double get spawnInterval {
    switch (this) {
      case GameDifficulty.chill:
        return 1.8;
      case GameDifficulty.classic:
        return 1.6;
      case GameDifficulty.intense:
        return 1.25;
    }
  }

  double get gapHeight {
    switch (this) {
      case GameDifficulty.chill:
        return 220;
      case GameDifficulty.classic:
        return 190;
      case GameDifficulty.intense:
        return 170;
    }
  }

  // ── Difficulty Ramp Multipliers ──
  // Controls how strongly the 90-second logarithmic ramp affects each
  // difficulty. 1.0 = full ramp (Classic baseline), <1.0 = gentler.

  /// Max additional scroll speed added by the ramp (base + this at 90s).
  double get rampSpeedDelta {
    switch (this) {
      case GameDifficulty.chill:
        return 60;
      case GameDifficulty.classic:
        return 100;
      case GameDifficulty.intense:
        return 100;
    }
  }

  /// Max spawn interval reduction from the ramp (base − this at 90s).
  double get rampSpawnDelta {
    switch (this) {
      case GameDifficulty.chill:
        return 0.3;
      case GameDifficulty.classic:
        return 0.5;
      case GameDifficulty.intense:
        return 0.5;
    }
  }

  /// Minimum spawn interval clamp (floor the ramp can't go below).
  double get minSpawnInterval {
    switch (this) {
      case GameDifficulty.chill:
        return 1.2;
      case GameDifficulty.classic:
        return 0.9;
      case GameDifficulty.intense:
        return 0.7;
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

  // ── Chill-Mode Hazard Config ──

  /// Seconds between mine spawns (chill only, 0 = disabled).
  double get mineSpawnInterval {
    switch (this) {
      case GameDifficulty.chill:
        return 2.5;
      case GameDifficulty.classic:
        return 0;
      case GameDifficulty.intense:
        return 0;
    }
  }

  /// Max mines on screen simultaneously (chill only).
  int get maxMines {
    switch (this) {
      case GameDifficulty.chill:
        return 5;
      case GameDifficulty.classic:
        return 0;
      case GameDifficulty.intense:
        return 0;
    }
  }

  /// Seconds between rocket spawns (chill only, 0 = disabled).
  double get rocketSpawnInterval {
    switch (this) {
      case GameDifficulty.chill:
        return 3.5;
      case GameDifficulty.classic:
        return 0;
      case GameDifficulty.intense:
        return 0;
    }
  }

  /// Max rockets on screen simultaneously (chill only).
  int get maxRockets {
    switch (this) {
      case GameDifficulty.chill:
        return 3;
      case GameDifficulty.classic:
        return 0;
      case GameDifficulty.intense:
        return 0;
    }
  }

  /// Seconds between floating mine spawns (chill only, 0 = disabled).
  double get floatingMineSpawnInterval {
    switch (this) {
      case GameDifficulty.chill:
        return 4.0;
      case GameDifficulty.classic:
        return 0;
      case GameDifficulty.intense:
        return 0;
    }
  }

  /// Max floating mines on screen simultaneously (chill only).
  int get maxFloatingMines {
    switch (this) {
      case GameDifficulty.chill:
        return 3;
      case GameDifficulty.classic:
        return 0;
      case GameDifficulty.intense:
        return 0;
    }
  }

  static GameDifficulty fromId(String? id) {
    for (final difficulty in GameDifficulty.values) {
      if (difficulty.id == id) return difficulty;
    }
    return GameDifficulty.classic;
  }
}
