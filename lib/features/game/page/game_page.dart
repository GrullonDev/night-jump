import 'package:flutter/material.dart';

import 'package:flame/game.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/game/overlays/countdown_overlay.dart';
import 'package:night_jump/features/game/overlays/game_over_overlay.dart';
import 'package:night_jump/features/game/overlays/hud_overlay.dart';
import 'package:night_jump/features/game/overlays/menu_overlay.dart';
import 'package:night_jump/utils/theme/app_color.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final NightJumpGame _game = NightJumpGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.canvasBase,
              AppColor.canvasMidnight,
              AppColor.surface,
            ],
          ),
        ),
        child: GameWidget<NightJumpGame>(
          game: _game,
          overlayBuilderMap: {
            NightJumpGame.menuOverlay: (context, game) =>
                MenuOverlay(game: game),
            NightJumpGame.hudOverlay: (context, game) => HudOverlay(game: game),
            NightJumpGame.gameOverOverlay: (context, game) =>
                GameOverOverlay(game: game),
            NightJumpGame.countdownOverlay: (context, game) =>
                CountdownOverlay(game: game),
          },
        ),
      ),
    );
  }
}
