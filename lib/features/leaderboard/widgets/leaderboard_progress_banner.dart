import 'package:flutter/material.dart';

import 'package:night_jump/utils/theme/app_color.dart';

/// Shows how close the player is to overtaking the next rank.
class LeaderboardProgressBanner extends StatelessWidget {
  const LeaderboardProgressBanner({
    super.key,
    required this.pointsToNextRank,
    required this.nextRank,
    required this.currentScore,
    required this.nextRankScore,
  });

  final int pointsToNextRank;
  final int nextRank;
  final int currentScore;
  final int nextRankScore;

  @override
  Widget build(BuildContext context) {
    if (pointsToNextRank <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColor.electricCyan.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.emoji_events_rounded,
              size: 16,
              color: AppColor.electricCyan,
            ),
            const SizedBox(width: 8),
            Text(
              'Vas a la cabeza de esta lista',
              style: TextStyle(
                color: AppColor.electricCyan,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'Space Grotesk',
              ),
            ),
          ],
        ),
      );
    }

    final progress = nextRankScore == 0
        ? 0.0
        : (currentScore / nextRankScore).clamp(0, 1).toDouble();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.hudGlass.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                size: 16,
                color: AppColor.neonRose,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'A solo $pointsToNextRank pts del Top $nextRank',
                  style: TextStyle(
                    color: AppColor.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ),
              Text(
                '$currentScore / $nextRankScore',
                style: TextStyle(
                  color: AppColor.slateGlow,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Space Grotesk',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColor.canvasMidnight,
              valueColor: const AlwaysStoppedAnimation(AppColor.neonRose),
            ),
          ),
        ],
      ),
    );
  }
}
