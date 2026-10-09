import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

/// Procedurally generated retro-neon SFX (see `assets/audio/`).
/// Every call is guarded by the player's sound preference, so the
/// settings toggle silences the whole game with no extra plumbing.
class SoundService {
  SoundService({required this.isEnabled});

  final bool Function() isEnabled;
  bool _loaded = false;
  bool _disposed = false;
  final Set<AudioPlayer> _players = {};
  final Map<AudioPlayer, StreamSubscription<void>> _subscriptions = {};

  static const _files = [
    'jump.wav',
    'score.wav',
    'go.wav',
    'game_over.wav',
    'ui.wav',
  ];

  Future<void> preload() async {
    if (_loaded || !isEnabled() || _disposed) return;
    try {
      // iOS defaults to the ambient session, which the mute switch silences.
      // Playback ignores the switch (proper game behavior on both stores);
      // Android gets the game usage so SFX duck correctly.
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: AudioContextIOS(category: AVAudioSessionCategory.playback),
        ),
      );
      await FlameAudio.audioCache.loadAll(_files);
      _loaded = true;
    } catch (_) {
      // Audio is decoration: a missing codec must never break the game.
    }
  }

  Future<void> _play(String file, {double volume = 0.5}) async {
    if (!isEnabled() || _disposed) return;
    try {
      final player = await FlameAudio.play(file, volume: volume);
      if (_disposed || !isEnabled()) {
        await player.dispose();
        return;
      }
      _players.add(player);
      _subscriptions[player] = player.onPlayerComplete.listen((_) async {
        _players.remove(player);
        await _subscriptions.remove(player)?.cancel();
        await player.dispose();
      }, onError: (Object _) {});
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

  Future<void> stop() async {
    final players = _players.toList();
    _players.clear();
    final subscriptions = _subscriptions.values.toList();
    _subscriptions.clear();
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    for (final player in players) {
      try {
        await player.stop();
        await player.dispose();
      } catch (_) {}
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    await stop();
  }
}
