/// Centralized mode balance. IDs remain stable for existing records.
enum GameDifficulty { chill, classic, intense }

extension GameDifficultyX on GameDifficulty {
  String get id => name;
  String get label => switch (this) {
    GameDifficulty.chill => 'Tranquilo',
    GameDifficulty.classic => 'Clásico',
    GameDifficulty.intense => 'Intenso',
  };
  String get subtitle => switch (this) {
    GameDifficulty.chill => 'Ritmo suave, huecos amplios y pocos obstáculos.',
    GameDifficulty.classic => 'El ritmo original, con progresión suave.',
    GameDifficulty.intense => 'Más velocidad y peligros anunciados.',
  };
  double get obstacleSpeed => switch (this) {
    GameDifficulty.chill => 130,
    GameDifficulty.classic => 180,
    GameDifficulty.intense => 235,
  };
  double get spawnInterval => switch (this) {
    GameDifficulty.chill => 2.2,
    GameDifficulty.classic => 1.6,
    GameDifficulty.intense => 1.4,
  };
  double get gapHeight => switch (this) {
    GameDifficulty.chill => 240,
    GameDifficulty.classic => 190,
    GameDifficulty.intense => 170,
  };
  double get rampSpeedDelta => switch (this) {
    GameDifficulty.chill => 30,
    GameDifficulty.classic => 70,
    GameDifficulty.intense => 80,
  };
  double get rampSpawnDelta => switch (this) {
    GameDifficulty.chill => 0.2,
    GameDifficulty.classic => 0.25,
    GameDifficulty.intense => 0.2,
  };
  double get minSpawnInterval => spawnInterval - rampSpawnDelta;
  int get maxShields => 3;
  int get startingShields => 1;
  int get shieldScoreThreshold => 0;
  int get gemSpawnAfterFirst => 4;
  int get gemSpawnInterval => 6;
  // Extra hazards are spawned as isolated encounters, never overlaid on gates.
  int get hazardEvery => this == GameDifficulty.intense ? 6 : 0;
  static GameDifficulty fromId(String? id) => GameDifficulty.values.firstWhere(
    (d) => d.id == id,
    orElse: () => GameDifficulty.classic,
  );
}
