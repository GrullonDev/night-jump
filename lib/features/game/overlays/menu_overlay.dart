import 'package:flutter/material.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/home/page/home_page.dart';
import 'package:night_jump/features/leaderboard/page/leaderboard_sheet.dart';
import 'package:night_jump/features/missions/page/missions_sheet.dart';
import 'package:night_jump/features/settings/page/settings_sheet.dart';
import 'package:night_jump/features/themes/page/theme_gallery_page.dart';
import 'package:night_jump/features/themes/state/theme_repository.dart';

class MenuOverlay extends StatelessWidget {
  const MenuOverlay({super.key, required this.game});

  final NightJumpGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.highScore,
      builder: (context, highScore, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: game.soundEnabled,
          builder: (context, soundEnabled, _) {
            return HomePage(
              onTapToPlay: game.startGame,
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
            );
          },
        );
      },
    );
  }
}
