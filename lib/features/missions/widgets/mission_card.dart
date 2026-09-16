import 'package:flutter/material.dart';

import 'package:night_jump/features/missions/state/mission.dart';
import 'package:night_jump/utils/theme/app_color.dart';

class MissionCard extends StatelessWidget {
  const MissionCard({super.key, required this.mission});

  final Mission mission;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.hudGlass.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mission.isCompleted
              ? AppColor.electricCyan.withValues(alpha: 0.4)
              : AppColor.electricCyan.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: mission.isCompleted
                      ? AppColor.electricCyan.withValues(alpha: 0.15)
                      : AppColor.canvasMidnight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  mission.icon,
                  color: mission.isCompleted
                      ? AppColor.electricCyan
                      : AppColor.slateWhite,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      style: TextStyle(
                        color: AppColor.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mission.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColor.slateGlow,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _RewardChip(
                label: mission.rewardLabel,
                highlighted: mission.isCompleted,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mission.isCompleted ? '¡COMPLETADO!' : 'Progreso',
                style: TextStyle(
                  color: mission.isCompleted
                      ? AppColor.electricCyan
                      : AppColor.slateGlow,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Space Grotesk',
                ),
              ),
              Text(
                '${mission.progress} / ${mission.target}',
                style: TextStyle(
                  color: AppColor.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Space Grotesk',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: mission.progressRatio,
              minHeight: 6,
              backgroundColor: AppColor.canvasMidnight,
              valueColor: AlwaysStoppedAnimation(
                mission.isCompleted
                    ? AppColor.electricCyan
                    : AppColor.intenseMagenta,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({required this.label, required this.highlighted});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColor.neonRose.withValues(alpha: 0.9)
            : AppColor.canvasMidnight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 12,
            color: highlighted ? AppColor.canvasBase : AppColor.electricCyan,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: highlighted ? AppColor.canvasBase : AppColor.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: 'Space Grotesk',
            ),
          ),
        ],
      ),
    );
  }
}
