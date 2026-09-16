import 'package:flutter/material.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/utils/responsive/responsive_extension.dart';
import 'package:night_jump/utils/theme/app_color.dart';

/// Game over summary shown as the 'gameOver' overlay: status, final score,
/// high score badge, run stats and clear primary/secondary actions.
class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});

  final NightJumpGame game;

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.responsive(
      mobile: double.infinity,
      tablet: 480.0,
    );
    final horizontalPadding = context.responsive(mobile: 24.0, tablet: 32.0);
    final titleFontSize = context.responsive(mobile: 32.0, tablet: 40.0);

    return Container(
      color: AppColor.canvasBase.withValues(alpha: 0.9),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StatusBadge(),
                  const SizedBox(height: 20),
                  Text(
                    '¡GAME OVER!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColor.electricCyan,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Sora',
                      shadows: [
                        Shadow(
                          color: AppColor.electricCyan.withValues(alpha: 0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tu salto terminó aquí. ¡Puedes hacerlo mejor!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColor.slateGlow,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SummaryCard(game: game),
                  const SizedBox(height: 28),
                  _PrimaryButton(
                    label: 'REINTENTAR',
                    icon: Icons.refresh_rounded,
                    color: AppColor.intenseMagenta,
                    onTap: game.startGame,
                  ),
                  const SizedBox(height: 12),
                  _PrimaryButton(
                    label: 'MENÚ PRINCIPAL',
                    icon: Icons.home_rounded,
                    color: AppColor.electricCyan,
                    onTap: game.returnToMenu,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.hudGlass.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.neonRose.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: AppColor.neonRose, size: 8),
          const SizedBox(width: 8),
          Text(
            'PARTIDA FINALIZADA',
            style: TextStyle(
              color: AppColor.slateWhite,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              fontFamily: 'Space Grotesk',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.game});

  final NightJumpGame game;

  @override
  Widget build(BuildContext context) {
    final cardPadding = context.responsive(mobile: 20.0, tablet: 28.0);
    final scoreFontSize = context.responsive(mobile: 56.0, tablet: 68.0);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: cardPadding),
      decoration: BoxDecoration(
        color: AppColor.hudGlass.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColor.electricCyan.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, color: AppColor.electricCyan, size: 16),
              const SizedBox(width: 6),
              Text(
                'PUNTUACIÓN FINAL',
                style: TextStyle(
                  color: AppColor.slateGlow,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.15,
                  fontFamily: 'Space Grotesk',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<int>(
            valueListenable: game.score,
            builder: (context, score, _) => Text(
              '$score',
              style: TextStyle(
                color: AppColor.onSurface,
                fontSize: scoreFontSize,
                fontWeight: FontWeight.w800,
                fontFamily: 'Sora',
                shadows: [
                  Shadow(
                    color: AppColor.onSurface.withValues(alpha: 0.3),
                    blurRadius: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: game.highScore,
                builder: (context, highScore, _) => _Chip(
                  icon: Icons.emoji_events_rounded,
                  label: 'Récord: $highScore',
                  color: AppColor.slateGlow,
                ),
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<bool>(
                valueListenable: game.isNewHighScore,
                builder: (context, isNew, _) {
                  if (!isNew) return const SizedBox.shrink();
                  return _Chip(
                    icon: Icons.bolt_rounded,
                    label: '¡NUEVO RÉCORD!',
                    color: AppColor.neonRose,
                    filled: true,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: game.score,
                  builder: (context, score, _) => _StatTile(
                    icon: Icons.flight_takeoff_rounded,
                    label: 'SUPERADOS',
                    value: '$score obstáculos',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ValueListenableBuilder<Duration>(
                  valueListenable: game.flightTime,
                  builder: (context, time, _) => _StatTile(
                    icon: Icons.timer_rounded,
                    label: 'TIEMPO VUELO',
                    value: _formatDuration(time),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.9) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: filled ? null : Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: filled ? AppColor.canvasBase : color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: filled ? AppColor.canvasBase : AppColor.slateWhite,
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.canvasMidnight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColor.hudGlass,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColor.electricCyan, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColor.slateGlow,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColor.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Space Grotesk',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColor.canvasBase, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: AppColor.canvasBase,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.1,
                  fontFamily: 'Space Grotesk',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
