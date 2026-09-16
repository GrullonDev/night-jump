import 'package:flutter/material.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/home/page/home_page.dart';
import 'package:night_jump/features/missions/page/missions_sheet.dart';

class MenuOverlay extends StatelessWidget {
  const MenuOverlay({super.key, required this.game});

  final NightJumpGame game;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.highScore,
      builder: (context, highScore, _) {
        return HomePage(
          onTapToPlay: game.startGame,
          highScore: highScore,
          onTapRetos: () =>
              showMissionsSheet(context, repository: game.missionsRepository),
        );
      },
    );
  }
}
