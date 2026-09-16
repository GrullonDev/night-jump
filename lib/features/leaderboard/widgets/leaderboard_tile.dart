import 'package:flutter/material.dart';

import 'package:night_jump/features/leaderboard/state/leaderboard_entry.dart';
import 'package:night_jump/utils/theme/app_color.dart';

class LeaderboardTile extends StatelessWidget {
  const LeaderboardTile({super.key, required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final isPlayer = entry.tier == LeaderboardTier.player;
    final accentColor = _accentColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isPlayer
            ? AppColor.neonRose.withValues(alpha: 0.1)
            : AppColor.hudGlass.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: accentColor != null
            ? Border(left: BorderSide(color: accentColor, width: 3))
            : (isPlayer
                ? Border.all(color: AppColor.neonRose.withValues(alpha: 0.4))
                : null),
      ),
      child: Row(
        children: [
          SizedBox(
            width: isPlayer ? 44 : 32,
            child: isPlayer
                ? _RankChip(rank: entry.rank)
                : _RankOrMedal(rank: entry.rank, tier: entry.tier),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: entry.avatarColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: entry.avatarColor.withValues(alpha: 0.4)),
            ),
            child: Icon(entry.avatarIcon, color: entry.avatarColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColor.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                    ),
                    if (isPlayer) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: AppColor.electricCyan,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                if (entry.badgeLabel != null)
                  Text(
                    entry.badgeLabel!,
                    style: TextStyle(
                      color: entry.tier == LeaderboardTier.champion
                          ? const Color(0xFFFFC94D)
                          : AppColor.neonRose,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Space Grotesk',
                    ),
                  )
                else
                  Text(
                    entry.subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColor.slateGlow,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatScore(entry.score),
                style: TextStyle(
                  color: isPlayer ? AppColor.onSurface : AppColor.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Space Grotesk',
                ),
              ),
              Text(
                'PTS',
                style: TextStyle(
                  color: AppColor.slateGlow,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                  fontFamily: 'Space Grotesk',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color? _accentColor() {
    switch (entry.tier) {
      case LeaderboardTier.champion:
        return const Color(0xFFFFC94D);
      case LeaderboardTier.multiplier:
        return AppColor.neonRose;
      case LeaderboardTier.podium:
        return AppColor.electricCyan;
      case LeaderboardTier.standard:
      case LeaderboardTier.player:
        return null;
    }
  }

  String _formatScore(int score) {
    final text = score.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final fromEnd = text.length - i;
      buffer.write(text[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }
}

class _RankOrMedal extends StatelessWidget {
  const _RankOrMedal({required this.rank, required this.tier});

  final int rank;
  final LeaderboardTier tier;

  @override
  Widget build(BuildContext context) {
    IconData? icon;
    Color? color;
    switch (tier) {
      case LeaderboardTier.champion:
        icon = Icons.workspace_premium_rounded;
        color = const Color(0xFFFFC94D);
        break;
      case LeaderboardTier.multiplier:
        icon = Icons.military_tech_rounded;
        color = AppColor.neonRose;
        break;
      case LeaderboardTier.podium:
        icon = Icons.military_tech_rounded;
        color = AppColor.electricCyan;
        break;
      case LeaderboardTier.standard:
      case LeaderboardTier.player:
        icon = null;
    }

    if (icon != null) {
      return Column(
        children: [
          Icon(icon, color: color, size: 16),
          Text(
            '#$rank',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'Space Grotesk',
            ),
          ),
        ],
      );
    }

    return Center(
      child: Text(
        '#$rank',
        style: TextStyle(
          color: AppColor.slateGlow,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          fontFamily: 'Space Grotesk',
        ),
      ),
    );
  }
}

class _RankChip extends StatelessWidget {
  const _RankChip({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColor.neonRose,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'TÚ #$rank',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColor.canvasBase,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          fontFamily: 'Space Grotesk',
        ),
      ),
    );
  }
}
