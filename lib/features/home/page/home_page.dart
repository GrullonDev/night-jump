import 'package:flutter/material.dart';

import 'package:night_jump/features/home/page/home_layout.dart';
import 'package:night_jump/utils/theme/app_color.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    this.onTapToPlay,
    this.highScore = 0,
    this.onTapRetos,
    this.onTapPalette,
    this.onTapRanking,
    this.onTapSound,
    this.soundEnabled = true,
    this.onTapSettings,
  });

  final VoidCallback? onTapToPlay;
  final int highScore;

  final VoidCallback? onTapRetos;

  final VoidCallback? onTapPalette;

  final VoidCallback? onTapRanking;

  final VoidCallback? onTapSound;

  final bool soundEnabled;

  final VoidCallback? onTapSettings;

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
        child: HomeLayout(
          onTapToPlay: onTapToPlay,
          highScore: highScore,
          onTapRetos: onTapRetos,
          onTapPalette: onTapPalette,
          onTapRanking: onTapRanking,
          onTapSound: onTapSound,
          soundEnabled: soundEnabled,
          onTapSettings: onTapSettings,
        ),
      ),
    );
  }
}
