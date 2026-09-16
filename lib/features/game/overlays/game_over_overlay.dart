import 'package:flutter/material.dart';
import 'package:zo_animated_border/zo_animated_border.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/utils/responsive/responsive_extension.dart';
import 'package:night_jump/utils/theme/app_color.dart';

/// Game over summary shown as the 'gameOver' overlay: final score, high
/// score badge, and neon restart / menu actions.
class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});

  final NightJumpGame game;

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.responsive(
      mobile: double.infinity,
      tablet: 480.0,
    );

    return Container(
      color: AppColor.canvasBase.withValues(alpha: 0.85),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'GAME OVER',
                    style: TextStyle(
                      color: AppColor.intenseMagenta,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Sora',
                      shadows: [
                        Shadow(
                          color: AppColor.intenseMagenta.withValues(
                            alpha: 0.5,
                          ),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ValueListenableBuilder<int>(
                    valueListenable: game.score,
                    builder: (context, score, _) => Text(
                      '$score',
                      style: TextStyle(
                        color: AppColor.onSurface,
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Sora',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PUNTAJE FINAL',
                    style: TextStyle(
                      color: AppColor.slateGlow,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.15,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ValueListenableBuilder<bool>(
                        valueListenable: game.isNewHighScore,
                        builder: (context, isNew, _) {
                          if (!isNew) return const SizedBox.shrink();
                          return _Badge(
                            icon: Icons.emoji_events,
                            label: 'NUEVO RÉCORD',
                            color: AppColor.electricCyan,
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      ValueListenableBuilder<int>(
                        valueListenable: game.highScore,
                        builder: (context, highScore, _) => _Badge(
                          icon: Icons.military_tech,
                          label: 'BEST $highScore',
                          color: AppColor.neonRose,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  ZoAnimatedGradientBorder(
                    borderRadius: 100,
                    borderThickness: 3,
                    animationDuration: const Duration(seconds: 3),
                    animationCurve: Curves.linear,
                    gradientColor: [
                      AppColor.electricCyan,
                      AppColor.intenseMagenta,
                    ],
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(100),
                        onTap: game.startGame,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          child: Text(
                            'REINTENTAR',
                            style: TextStyle(
                              color: AppColor.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                              fontFamily: 'Space Grotesk',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: game.returnToMenu,
                    child: Text(
                      'MENÚ PRINCIPAL',
                      style: TextStyle(
                        color: AppColor.slateGlow,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
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

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.hudGlass.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: AppColor.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'Space Grotesk',
            ),
          ),
        ],
      ),
    );
  }
}
