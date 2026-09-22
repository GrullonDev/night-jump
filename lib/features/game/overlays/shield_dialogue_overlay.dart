import 'dart:async';

import 'package:flutter/material.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/game/overlays/soft_entrance.dart';
import 'package:night_jump/utils/responsive/responsive_extension.dart';
import 'package:night_jump/utils/theme/app_color.dart';

class ShieldDialogueOverlay extends StatefulWidget {
  const ShieldDialogueOverlay({super.key, required this.game});

  final NightJumpGame game;

  @override
  State<ShieldDialogueOverlay> createState() => _ShieldDialogueOverlayState();
}

class _ShieldDialogueOverlayState extends State<ShieldDialogueOverlay> {
  int _countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _countdown--;
        });
        if (_countdown <= 0) {
          timer.cancel();
          widget.game.rejectShield();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.responsive(mobile: 340.0, tablet: 400.0);

    return Container(
      color: AppColor.canvasBase.withValues(alpha: 0.85),
      child: Center(
        child: SoftEntrance(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColor.hudGlass.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColor.shieldCyan.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.shieldCyan.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Shield icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.shieldCyan.withValues(alpha: 0.15),
                      border: Border.all(
                        color: AppColor.shieldCyan.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Icon(
                      Icons.shield_rounded,
                      color: AppColor.shieldCyan,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    '¡ESCUDO DISPONIBLE!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColor.shieldCyan,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Sora',
                      shadows: [
                        Shadow(
                          color: AppColor.shieldCyan.withValues(alpha: 0.5),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Description
                  Text(
                    'TUVISTE UN CHOQUE.\n¿DESEAS USAR UN ESCUDO\nPARA CONTINUAR?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColor.slateWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Space Grotesk',
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Countdown timer
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.canvasBase.withValues(alpha: 0.6),
                      border: Border.all(
                        color: _countdown <= 2
                            ? AppColor.error
                            : AppColor.shieldCyan,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${_countdown}s',
                        style: TextStyle(
                          color: _countdown <= 2
                              ? AppColor.error
                              : AppColor.shieldCyan,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Sora',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _Action(
                          label: 'SÍ, USAR ESCUDO',
                          icon: Icons.shield_rounded,
                          color: AppColor.gemGreen,
                          onTap: () {
                            _timer?.cancel();
                            widget.game.useShield();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Action(
                          label: 'NO, FINALIZAR',
                          icon: Icons.close_rounded,
                          color: AppColor.error,
                          onTap: () {
                            _timer?.cancel();
                            widget.game.rejectShield();
                          },
                        ),
                      ),
                    ],
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

class _Action extends StatelessWidget {
  const _Action({
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColor.canvasBase, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColor.canvasBase,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Space Grotesk',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
