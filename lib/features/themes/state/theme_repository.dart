import 'package:night_jump/utils/progress_store.dart';

import 'package:night_jump/features/themes/state/neon_palette.dart';

/// Persists which palette is active and which paid palettes the player
/// has already unlocked.
class ThemeRepository {
  static const _selectedKey = 'theme.selected_palette';
  static const _unlockedKey = 'theme.unlocked_palettes';

  Future<String> getSelectedPaletteId() =>
      ProgressStore.transaction((prefs) async {
        return prefs.getString(_selectedKey) ?? NeonPalette.catalog.first.id;
      });

  Future<void> selectPalette(String paletteId) =>
      ProgressStore.transaction((prefs) async {
        final unlocked = prefs.getStringList(_unlockedKey) ?? [];
        final palette = NeonPalette.byId(paletteId);
        if (palette.id != paletteId ||
            (!palette.isFree && !unlocked.contains(paletteId))) {
          return;
        }
        await prefs.setString(_selectedKey, paletteId);
      });

  Future<Set<String>> getUnlockedPaletteIds() =>
      ProgressStore.transaction((prefs) async {
        final stored = prefs.getStringList(_unlockedKey) ?? const [];
        return {
          ...stored,
          for (final palette in NeonPalette.catalog)
            if (palette.isFree) palette.id,
        };
      });

  Future<void> unlockPalette(String paletteId) => ProgressStore.transaction((
    prefs,
  ) async {
    final unlocked = (prefs.getStringList(_unlockedKey) ?? const []).toSet();
    unlocked.add(paletteId);
    await prefs.setStringList(_unlockedKey, unlocked.toList());
  });
}
