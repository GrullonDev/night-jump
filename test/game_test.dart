import 'package:flutter_test/flutter_test.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/game/state/game_difficulty.dart';
import 'package:night_jump/features/game/state/sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameDifficulty', () {
    test('classic matches the original tuning', () {
      expect(GameDifficulty.classic.obstacleSpeed, 180);
      expect(GameDifficulty.classic.spawnInterval, 1.6);
      expect(GameDifficulty.classic.gapHeight, 190);
    });

    test('chill is slower with a wider gap', () {
      expect(
        GameDifficulty.chill.obstacleSpeed,
        lessThan(GameDifficulty.classic.obstacleSpeed),
      );
      expect(
        GameDifficulty.chill.gapHeight,
        greaterThan(GameDifficulty.classic.gapHeight),
      );
    });

    test('intense is faster with a tighter gap', () {
      expect(
        GameDifficulty.intense.obstacleSpeed,
        greaterThan(GameDifficulty.classic.obstacleSpeed),
      );
      expect(
        GameDifficulty.intense.gapHeight,
        lessThan(GameDifficulty.classic.gapHeight),
      );
    });

    test('fromId parses known ids and falls back to classic', () {
      expect(GameDifficultyX.fromId('chill'), GameDifficulty.chill);
      expect(GameDifficultyX.fromId('intense'), GameDifficulty.intense);
      expect(GameDifficultyX.fromId('nope'), GameDifficulty.classic);
      expect(GameDifficultyX.fromId(null), GameDifficulty.classic);
    });
  });

  group('Difficulty ramp', () {
    test('run starts at the difficulty base values', () {
      final game = NightJumpGame();
      game.difficulty.value = GameDifficulty.classic;
      expect(game.currentObstacleSpeed, 180);
      expect(game.currentSpawnInterval, 1.6);
    });
  });

  group('SoundService', () {
    test('stays silent when disabled', () async {
      final sound = SoundService(isEnabled: () => false);
      await sound.preload();
      await sound.jump();
      await sound.score();
      await sound.go();
      await sound.gameOver();
      await sound.ui();
    });

    test('never throws without platform channels', () async {
      final sound = SoundService(isEnabled: () => true);
      await sound.preload();
      await sound.jump();
      await sound.score();
      await sound.go();
      await sound.gameOver();
      await sound.ui();
    });
  });
}
