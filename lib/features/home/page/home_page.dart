import 'package:flutter/material.dart';

import 'package:night_jump/features/home/page/home_layout.dart';
import 'package:night_jump/utils/theme/app_color.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    this.onTapToPlay,
    this.highScore = 0,
    this.onTapRetos,
  });

  final VoidCallback? onTapToPlay;
  final int highScore;

  /// Called when the player taps the "RETOS" button.
  final VoidCallback? onTapRetos;

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
        ),
      ),
    );
  }
}
