import 'package:flutter/material.dart';

import 'package:flame/game.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/game/overlays/countdown_overlay.dart';
import 'package:night_jump/features/game/overlays/game_over_overlay.dart';
import 'package:night_jump/features/game/overlays/hud_overlay.dart';
import 'package:night_jump/features/game/overlays/menu_overlay.dart';
import 'package:night_jump/features/game/overlays/pause_overlay.dart';
import 'package:night_jump/utils/theme/app_color.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key, this.game});
  final NightJumpGame? game;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with WidgetsBindingObserver {
  late final NightJumpGame _game = widget.game ?? NightJumpGame();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _game.setBackground(state != AppLifecycleState.resumed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _game.disposeResources();
    super.dispose();
  }

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
        child: SafeArea(
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 400,
                height: 720,
                child: GameWidget<NightJumpGame>(
                  game: _game,
                  overlayBuilderMap: {
                    NightJumpGame.menuOverlay: (context, game) =>
                        MenuOverlay(game: game),
                    NightJumpGame.hudOverlay: (context, game) =>
                        HudOverlay(game: game),
                    NightJumpGame.gameOverOverlay: (context, game) =>
                        GameOverOverlay(game: game),
                    NightJumpGame.countdownOverlay: (context, game) =>
                        CountdownOverlay(game: game),
                    NightJumpGame.pauseOverlay: (context, game) =>
                        PauseOverlay(game: game),
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
