import 'package:flutter/material.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/game/overlays/difficulty_dialog.dart';
import 'package:night_jump/features/game/overlays/how_to_play_dialog.dart';
import 'package:night_jump/features/home/page/home_page.dart';
import 'package:night_jump/features/leaderboard/page/leaderboard_sheet.dart';
import 'package:night_jump/features/missions/page/missions_sheet.dart';
import 'package:night_jump/features/settings/page/settings_sheet.dart';
import 'package:night_jump/features/themes/page/theme_gallery_page.dart';
import 'package:night_jump/features/themes/state/theme_repository.dart';

class MenuOverlay extends StatefulWidget {
  const MenuOverlay({super.key, required this.game});

  final NightJumpGame game;

  @override
  State<MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<MenuOverlay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowHowToPlay());
  }

  Future<void> _maybeShowHowToPlay() async {
    if (!mounted) return;
    final seen = await widget.game.settingsRepository.getHowToPlaySeen();
    if (seen || !mounted) return;
    await widget.game.settingsRepository.setHowToPlaySeen();
    if (!mounted) return;
    showHowToPlayDialog(context, onPlay: _askDifficultyThenPlay);
  }

  void _showHowToPlayNow() {
    showHowToPlayDialog(context, onPlay: _askDifficultyThenPlay);
  }

  /// "Tap to jump" opens the difficulty picker; picking one persists
  /// the choice and starts the run immediately.
  void _askDifficultyThenPlay() {
    showDifficultyDialog(
      context,
      current: widget.game.difficulty.value,
      onSelected: (difficulty) async {
        await widget.game.setDifficulty(difficulty);
        widget.game.sound.ui();
        widget.game.startGame();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return ValueListenableBuilder<int>(
      valueListenable: game.highScore,
      builder: (context, highScore, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: game.soundEnabled,
          builder: (context, soundEnabled, _) {
            return HomePage(
              onTapToPlay: _askDifficultyThenPlay,
              highScore: highScore,
              onTapRetos: () => showMissionsSheet(
                context,
                repository: game.missionsRepository,
              ),
              onTapPalette: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ThemeGalleryPage(
                    themeRepository: ThemeRepository(),
                    missionsRepository: game.missionsRepository,
                  ),
                ),
              ),
              onTapRanking: () =>
                  showLeaderboardSheet(context, onPlayNow: game.startGame),
              soundEnabled: soundEnabled,
              onTapSound: game.toggleSound,
              onTapSettings: () => showSettingsSheet(context, game),
              onTapHelp: _showHowToPlayNow,
            );
          },
        );
      },
    );
  }
}
