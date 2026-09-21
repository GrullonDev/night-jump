import 'package:flutter/material.dart';

import 'package:night_jump/utils/responsive/responsive_extension.dart';
import 'package:night_jump/utils/theme/app_color.dart';

/// Calm onboarding dialog shown once on first launch (and on demand via
/// the help icon). Explains the one-tap control, the goal and the
/// danger cues without pressure.
Future<bool?> showHowToPlayDialog(
  BuildContext context, {
  required VoidCallback onPlay,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => _HowToPlayDialog(onPlay: onPlay),
  );
}

class _HowToPlayDialog extends StatelessWidget {
  const _HowToPlayDialog({required this.onPlay});

  final VoidCallback onPlay;

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColor.electricCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.touch_app_rounded,
                        color: AppColor.electricCyan,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CÓMO JUGAR',
                            style: TextStyle(
                              color: AppColor.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Sora',
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tranquilo, es solo un toque',
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
                  ],
                ),
                const SizedBox(height: 20),
                const _TipRow(
                  icon: Icons.touch_app_rounded,
                  text: 'Toca en cualquier lugar para saltar. Sin prisa.',
                ),
                const SizedBox(height: 12),
                const _TipRow(
                  icon: Icons.filter_center_focus_rounded,
                  text: 'Pasa por el hueco entre las barras para sumar 1 punto.',
                ),
                const SizedBox(height: 12),
                const _TipRow(
                  icon: Icons.warning_amber_rounded,
                  text: 'Si el orbe brilla en rojo, estás muy cerca del borde.',
                ),
                const SizedBox(height: 12),
                const _TipRow(
                  icon: Icons.pause_rounded,
                  text: 'Puedes pausar arriba a la derecha cuando quieras.',
                ),
                const SizedBox(height: 20),

                // ── Shields Section ──
                _SectionDivider(label: 'ESCUDOS'),
                const SizedBox(height: 12),
                const _TipRow(
                  icon: Icons.shield_rounded,
                  text: 'Recoge gemas verdes para ganar escudos que protegen contra choques.',
                ),
                const SizedBox(height: 12),
                const _TipRow(
                  icon: Icons.health_and_safety_rounded,
                  text: 'Al chocar, si tienes escudo disponible, puedes usarlo para continuar.',
                ),
                const SizedBox(height: 12),
                const _TipRow(
                  icon: Icons.timer_off_rounded,
                  text: 'Si no respondes a tiempo, la partida termina automáticamente.',
                ),
                const SizedBox(height: 20),

                // ── Polvos Section ──
                _SectionDivider(label: 'POLVOS ESTELARES'),
                const SizedBox(height: 12),
                const _TipRow(
                  icon: Icons.auto_awesome_rounded,
                  text: 'Ganas 1 Polvo por cada obstáculo que superas durante la partida.',
                ),
                const SizedBox(height: 12),
                const _TipRow(
                  icon: Icons.palette_rounded,
                  text: 'Los Polvos se usan para desbloquear y cambiar los temas visuales del juego.',
                ),
                const SizedBox(height: 12),
                const _TipRow(
                  icon: Icons.store_rounded,
                  text: 'Visita la galería de temas para canjear tus Polvos por nuevos estilos.',
                ),
                const SizedBox(height: 24),

                Material(
                  color: AppColor.electricCyan,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).pop(true);
                      onPlay();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'JUGAR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColor.canvasBase,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.1,
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Explorar primero',
                    style: TextStyle(
                      color: AppColor.slateGlow,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColor.electricCyan.withValues(alpha: 0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: TextStyle(
              color: AppColor.electricCyan.withValues(alpha: 0.7),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.15,
              fontFamily: 'Space Grotesk',
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColor.electricCyan.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              text,
              style: const TextStyle(
                color: AppColor.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Space Grotesk',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
