import 'package:flutter/material.dart';

enum MissionPeriod { daily, weekly }

class Mission {
  const Mission({
    required this.id,
    required this.period,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.target,
    required this.reward,
    required this.rewardLabel,
    this.claimed = false,
  });

  final String id;
  final MissionPeriod period;
  final IconData icon;
  final String title;
  final String subtitle;
  final int progress;
  final int target;

  final int reward;

  final String rewardLabel;

  final bool claimed;

  bool get isCompleted => progress >= target;

  double get progressRatio => target == 0 ? 0 : (progress / target).clamp(0, 1);
}
