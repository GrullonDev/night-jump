import 'package:shared_preferences/shared_preferences.dart';

/// Persists player preferences that apply across the whole app: whether
/// sound/haptics are enabled, and clearing all saved progress.
class SettingsRepository {
  static const _soundEnabledKey = 'settings.sound_enabled';
  static const _hapticsEnabledKey = 'settings.haptics_enabled';
  static const _howToPlaySeenKey = 'settings.how_to_play_seen';
  static const _difficultyKey = 'settings.difficulty';
  static const _comfortDimKey = 'settings.comfort_dim';

  Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, value);
  }

  Future<bool> getHapticsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hapticsEnabledKey) ?? true;
  }

  Future<bool> getHowToPlaySeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_howToPlaySeenKey) ?? false;
  }

  Future<void> setHowToPlaySeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_howToPlaySeenKey, true);
  }

  Future<String> getDifficultyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_difficultyKey) ?? 'classic';
  }

  Future<void> setDifficultyId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_difficultyKey, id);
  }

  Future<bool> getComfortDim() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_comfortDimKey) ?? false;
  }

  Future<void> setComfortDim(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_comfortDimKey, value);
  }

  Future<void> setHapticsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsEnabledKey, value);
  }

  /// Clears every piece of local progress: high score, missions/stardust
  /// and unlocked/selected theme. Keeps the sound/haptics preferences
  /// and the tutorial-seen flag so a reset doesn't re-nag the player.
  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keysToKeep = {
      _soundEnabledKey,
      _hapticsEnabledKey,
      _howToPlaySeenKey,
      _difficultyKey,
      _comfortDimKey,
    };
    for (final key in prefs.getKeys()) {
      if (!keysToKeep.contains(key)) {
        await prefs.remove(key);
      }
    }
  }
}
