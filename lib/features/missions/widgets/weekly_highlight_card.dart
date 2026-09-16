import 'package:flutter/material.dart';

import 'package:night_jump/features/missions/state/mission.dart';
import 'package:night_jump/utils/theme/app_color.dart';

class WeeklyHighlightCard extends StatelessWidget {
  const WeeklyHighlightCard({super.key, required this.mission});

  final Mission mission;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.intenseMagenta.withValues(alpha: 0.15),
            AppColor.electricCyan.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.neonRose.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Pill(label: 'DESAFÍO SEMANAL', color: AppColor.electricCyan),
              const Spacer(),
              _Pill(
                icon: Icons.diamond_rounded,
                label: mission.rewardLabel,
                color: AppColor.neonRose,
              ),
              const SizedBox(width: 8),
              _Pill(
                icon: Icons.auto_awesome,
                label: '+${mission.reward}',
                color: AppColor.slateWhite,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            mission.title,
            style: TextStyle(
              color: AppColor.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'Sora',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            mission.subtitle,
            style: TextStyle(
              color: AppColor.slateGlow,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'Space Grotesk',
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: mission.progressRatio,
              minHeight: 6,
              backgroundColor: AppColor.canvasMidnight,
              valueColor: AlwaysStoppedAnimation(AppColor.neonRose),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${mission.progress} / ${mission.target} pts',
            style: TextStyle(
              color: AppColor.slateGlow,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Space Grotesk',
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({this.icon, required this.label, required this.color});

  final IconData? icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColor.canvasMidnight.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: 'Space Grotesk',
            ),
          ),
        ],
      ),
    );
  }
}
