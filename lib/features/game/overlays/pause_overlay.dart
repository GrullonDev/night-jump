import 'package:flutter/material.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/game/overlays/soft_entrance.dart';
import 'package:night_jump/utils/responsive/responsive_extension.dart';
import 'package:night_jump/utils/theme/app_color.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game});

  final NightJumpGame game;

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.responsive(mobile: double.infinity, tablet: 480.0);
    final horizontalPadding = context.responsive(mobile: 24.0, tablet: 32.0);

    return Container(
      color: AppColor.canvasBase.withValues(alpha: 0.9),
      child: SafeArea(
        child: Center(
          child: SoftEntrance(
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
                    Text(
                      'PAUSA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColor.electricCyan,
                        fontSize: 40.0,
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
                    const SizedBox(height: 40),
                    _PrimaryButton(
                      label: 'CONTINUAR',
                      icon: Icons.play_arrow_rounded,
                      color: AppColor.electricCyan,
                      onTap: game.resumeGame,
                    ),
                    const SizedBox(height: 12),
                    _PrimaryButton(
                      label: 'MENÚ PRINCIPAL',
                      icon: Icons.home_rounded,
                      color: AppColor.surfaceContainerHighest,
                      onTap: game.returnToMenu,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
