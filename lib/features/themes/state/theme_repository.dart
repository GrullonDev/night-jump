import 'package:shared_preferences/shared_preferences.dart';

import 'package:night_jump/features/themes/state/neon_palette.dart';

/// Persists which palette is active and which paid palettes the player
/// has already unlocked.
class ThemeRepository {
  static const _selectedKey = 'theme.selected_palette';
  static const _unlockedKey = 'theme.unlocked_palettes';

  Future<String> getSelectedPaletteId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedKey) ?? NeonPalette.catalog.first.id;
  }

  Future<void> selectPalette(String paletteId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedKey, paletteId);
  }

  Future<Set<String>> getUnlockedPaletteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_unlockedKey) ?? const [];
    return {
      ...stored,
      for (final palette in NeonPalette.catalog)
        if (palette.isFree) palette.id,
    };
  }

  Future<void> unlockPalette(String paletteId) async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = (prefs.getStringList(_unlockedKey) ?? const []).toSet();
    unlocked.add(paletteId);
    await prefs.setStringList(_unlockedKey, unlocked.toList());
  }
}
