import 'package:flutter/material.dart';

import 'package:night_jump/features/home/widgets/home_button.dart';
import 'package:night_jump/features/leaderboard/page/leaderboard_sheet.dart';
import 'package:night_jump/features/missions/page/missions_sheet.dart';

/// Home keeps a single action: changing the orb color.
/// Retos and Ranking were retired to keep the start screen calm.
class ButtonActions extends StatelessWidget {
  const ButtonActions({super.key, this.onTapPalette});

  final VoidCallback? onTapPalette;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        HomeButton(
          icon: Icons.flag_rounded,
          label: 'MISIONES',
          onTap: () => showMissionsSheet(context),
        ),
        HomeButton(
          icon: Icons.emoji_events_rounded,
          label: 'RÉCORDS',
          onTap: () => showLeaderboardSheet(context),
        ),
        HomeButton(
          icon: Icons.palette_rounded,
          label: 'COLOR',
          onTap: onTapPalette,
        ),
      ],
    );
  }
}
