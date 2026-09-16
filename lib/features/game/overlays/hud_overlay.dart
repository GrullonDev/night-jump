import 'package:flutter/material.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/utils/responsive/responsive_extension.dart';
import 'package:night_jump/utils/theme/app_color.dart';

/// Minimalist score counter shown during gameplay ('hud' overlay).
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  final NightJumpGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          top: context.responsive(mobile: 20.0, tablet: 32.0),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ValueListenableBuilder<int>(
            valueListenable: game.score,
            builder: (context, score, _) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColor.hudGlass.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColor.electricCyan.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '$score',
                  style: TextStyle(
                    color: AppColor.electricCyan,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Sora',
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
