import 'package:flutter/material.dart';

import 'package:night_jump/features/home/widgets/actions_button.dart';
import 'package:night_jump/features/home/widgets/character_orb.dart';
import 'package:night_jump/features/home/widgets/headphone_icon.dart';
import 'package:night_jump/features/home/widgets/season_text.dart';
import 'package:night_jump/utils/responsive/responsive_extension.dart';
import 'package:night_jump/utils/theme/app_color.dart';

class HomeLayout extends StatelessWidget {
  const HomeLayout({
    super.key,
    this.onTapToPlay,
    this.highScore = 0,
    this.onTapRetos,
  });

  final VoidCallback? onTapToPlay;

  final int highScore;

  final VoidCallback? onTapRetos;

  @override
  Widget build(BuildContext context) {
    final orbSize = context.responsive(mobile: 180.0, tablet: 220.0);
    final titleFontSize = context.responsive(mobile: 48.0, tablet: 56.0);
    final horizontalPadding = context.responsive(mobile: 20.0, tablet: 32.0);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                _buildHeader(highScore),
                const SizedBox(height: 40),
                _buildTitle(titleFontSize),
                const Spacer(),
                GestureDetector(
                  onTap: onTapToPlay,
                  behavior: HitTestBehavior.opaque,
                  child: CharacterOrb(size: orbSize),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onTapToPlay,
                  behavior: HitTestBehavior.opaque,
                  child: _buildTapText(),
                ),
                const SizedBox(height: 20),
                HeadphoneIcon(),
                const SizedBox(height: 30),
                ButtonActions(onTapRetos: onTapRetos),
                const SizedBox(height: 24),
                SeasonText(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildHeader(int highScore) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColor.hudGlass.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColor.electricCyan.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events, color: AppColor.electricCyan, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BEST',
                  style: TextStyle(
                    color: AppColor.slateGlow,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
                Text(
                  '$highScore',
                  style: TextStyle(
                    color: AppColor.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const Spacer(),
      _buildIconCircle(Icons.volume_up_rounded),
      const SizedBox(width: 12),
      _buildIconCircle(Icons.settings_rounded),
    ],
  );
}

Widget _buildIconCircle(IconData icon) {
  return Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: AppColor.hudGlass.withValues(alpha: 0.6),
      shape: BoxShape.circle,
      border: Border.all(color: AppColor.electricCyan.withValues(alpha: 0.2)),
    ),
    child: Icon(icon, color: AppColor.slateWhite, size: 22),
  );
}

Widget _buildTapText() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.bolt, color: AppColor.electricCyan, size: 18),
      const SizedBox(width: 8),
      Text(
        'TOCA PARA SALTAR',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColor.onSurface,
          letterSpacing: 0.1,
          fontFamily: 'Space Grotesk',
        ),
      ),
      const SizedBox(width: 8),
      Icon(Icons.bolt, color: AppColor.electricCyan, size: 18),
    ],
  );
}

Widget _buildTitle(double titleFontSize) {
  return Column(
    children: [
      Text(
        'NIGHT JUMP',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: titleFontSize,
          fontWeight: FontWeight.w800,
          color: AppColor.electricCyan,
          letterSpacing: -0.02,
          fontFamily: 'Sora',
          shadows: [
            Shadow(
              color: AppColor.electricCyan.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 0),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 24, height: 2, color: AppColor.electricCyan),
          const SizedBox(width: 12),
          Text(
            'NEON GRAVITY ARCADE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColor.slateGlow,
              letterSpacing: 0.15,
              fontFamily: 'Space Grotesk',
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 24, height: 2, color: AppColor.electricCyan),
        ],
      ),
    ],
  );
}
