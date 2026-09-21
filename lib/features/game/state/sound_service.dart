import 'package:flame_audio/flame_audio.dart';

/// Procedurally generated retro-neon SFX (see `assets/audio/`).
/// Every call is guarded by the player's sound preference, so the
/// settings toggle silences the whole game with no extra plumbing.
class SoundService {
  SoundService({required this.isEnabled});

  final bool Function() isEnabled;
  bool _loaded = false;

  static const _files = [
    'jump.wav',
    'score.wav',
    'go.wav',
    'game_over.wav',
    'ui.wav',
  ];

  Future<void> preload() async {
    if (_loaded) return;
    try {
      await FlameAudio.audioCache.loadAll(_files);
      _loaded = true;
    } catch (_) {
      // Audio is decoration: a missing codec must never break the game.
    }
  }

  Future<void> _play(String file, {double volume = 0.5}) async {
    if (!isEnabled()) return;
    try {
      await FlameAudio.play(file, volume: volume);
    } catch (_) {}
  }

  /// Soft upward chirp on every tap.
  Future<void> jump() => _play('jump.wav', volume: 0.3);

  /// Bright ding when clearing a gate.
  Future<void> score() => _play('score.wav', volume: 0.45);

  /// Rising triad when the countdown hits GO.
  Future<void> go() => _play('go.wav', volume: 0.5);

  /// Low descending thud on death.
  Future<void> gameOver() => _play('game_over.wav', volume: 0.5);

  /// Short click for menu / dialog picks.
  Future<void> ui() => _play('ui.wav', volume: 0.4);
}
