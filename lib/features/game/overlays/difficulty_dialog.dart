import 'package:flutter/material.dart';

import 'package:night_jump/features/game/state/game_difficulty.dart';
import 'package:night_jump/utils/responsive/responsive_extension.dart';
import 'package:night_jump/utils/theme/app_color.dart';

/// Difficulty picker shown when the player taps "tap to jump".
/// Selecting an option persists it and starts the run immediately.
Future<void> showDifficultyDialog(
  BuildContext context, {
  required GameDifficulty current,
  required Future<void> Function(GameDifficulty) onSelected,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) =>
        _DifficultyDialog(current: current, onSelected: onSelected),
  );
}

class _DifficultyDialog extends StatelessWidget {
  const _DifficultyDialog({required this.current, required this.onSelected});

  final GameDifficulty current;
  final Future<void> Function(GameDifficulty) onSelected;

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.responsive(mobile: 340.0, tablet: 420.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          decoration: BoxDecoration(
            color: AppColor.canvasMidnight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColor.electricCyan.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ELIGE TU RITMO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColor.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Sora',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Sin presión. Puedes cambiarlo cuando quieras.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColor.slateGlow,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Space Grotesk',
                ),
              ),
              const SizedBox(height: 20),
              for (final difficulty in GameDifficulty.values) ...[
                _DifficultyOption(
                  difficulty: difficulty,
                  selected: difficulty == current,
                  onTap: () async {
                    Navigator.of(context).pop();
                    await onSelected(difficulty);
                  },
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyOption extends StatelessWidget {
  const _DifficultyOption({
    required this.difficulty,
    required this.selected,
    required this.onTap,
  });

  final GameDifficulty difficulty;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColor.electricCyan.withValues(alpha: 0.15)
          : AppColor.hudGlass.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColor.electricCyan
                  : AppColor.electricCyan.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _iconFor(difficulty),
                color: AppColor.electricCyan,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      difficulty.label,
                      style: const TextStyle(
                        color: AppColor.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      difficulty.subtitle,
                      style: const TextStyle(
                        color: AppColor.slateGlow,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColor.electricCyan,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.chill:
        return Icons.spa_rounded;
      case GameDifficulty.classic:
        return Icons.bolt_rounded;
      case GameDifficulty.intense:
        return Icons.local_fire_department_rounded;
    }
  }
}
