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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isSmallScreen = screenHeight < 700;

    final maxWidth = context.responsive(
      mobile: screenWidth * 0.88,
      tablet: 380.0,
    );

    final horizontalPad = isSmallScreen ? 16.0 : 20.0;
    final verticalPad = isSmallScreen ? 16.0 : 20.0;
    final sectionSpacing = isSmallScreen ? 12.0 : 16.0;
    final tipSpacing = isSmallScreen ? 8.0 : 10.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: screenHeight * 0.1,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: screenHeight * 0.75,
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            horizontalPad,
            verticalPad,
            horizontalPad,
            verticalPad - 4,
          ),
          decoration: BoxDecoration(
            color: AppColor.canvasMidnight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColor.electricCyan.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Header ──
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColor.electricCyan.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.touch_app_rounded,
                              color: AppColor.electricCyan,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CÓMO JUGAR',
                                  style: TextStyle(
                                    color: AppColor.onSurface,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Sora',
                                  ),
                                ),
                                SizedBox(height: 1),
                                Text(
                                  'Tranquilo, es solo un toque',
                                  style: TextStyle(
                                    color: AppColor.slateGlow,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Space Grotesk',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sectionSpacing),

                      // ── Basic Tips ──
                      _TipRow(
                        icon: Icons.touch_app_rounded,
                        text: 'Toca para saltar. Sin prisa.',
                        small: isSmallScreen,
                      ),
                      SizedBox(height: tipSpacing),
                      _TipRow(
                        icon: Icons.filter_center_focus_rounded,
                        text: 'Pasa por el hueco para sumar 1 punto.',
                        small: isSmallScreen,
                      ),
                      SizedBox(height: tipSpacing),
                      _TipRow(
                        icon: Icons.warning_amber_rounded,
                        text: 'Orbe rojo = borde peligroso.',
                        small: isSmallScreen,
                      ),
                      SizedBox(height: tipSpacing),
                      _TipRow(
                        icon: Icons.pause_rounded,
                        text: 'Pausa arriba a la derecha.',
                        small: isSmallScreen,
                      ),
                      SizedBox(height: sectionSpacing),

                      // ── Shields Section ──
                      _SectionDivider(label: 'ESCUDOS'),
                      SizedBox(height: tipSpacing),
                      _TipRow(
                        icon: Icons.shield_rounded,
                        text: 'Gemas verdes = escudos para continuar.',
                        small: isSmallScreen,
                      ),
                      SizedBox(height: tipSpacing),
                      _TipRow(
                        icon: Icons.health_and_safety_rounded,
                        text: 'Al chocar, usa el escudo para seguir.',
                        small: isSmallScreen,
                      ),
                      SizedBox(height: tipSpacing),
                      _TipRow(
                        icon: Icons.timer_off_rounded,
                        text: 'Si no respondes, la partida termina.',
                        small: isSmallScreen,
                      ),
                      SizedBox(height: sectionSpacing),

                      // ── Stardust Section ──
                      _SectionDivider(label: 'POLVOS ESTELARES'),
                      SizedBox(height: tipSpacing),
                      _TipRow(
                        icon: Icons.auto_awesome_rounded,
                        text: '1 Polvo por obstáculo superado.',
                        small: isSmallScreen,
                      ),
                      SizedBox(height: tipSpacing),
                      _TipRow(
                        icon: Icons.palette_rounded,
                        text: 'Canjea Polvos por temas visuales.',
                        small: isSmallScreen,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: sectionSpacing),

              // ── Action Buttons ──
              Material(
                color: AppColor.electricCyan,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.of(context).pop(true);
                    onPlay();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 11 : 13,
                    ),
                    child: const Text(
                      'JUGAR',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColor.canvasBase,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.1,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Explorar primero',
                  style: TextStyle(
                    color: AppColor.slateGlow,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ),
            ],
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
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            label,
            style: TextStyle(
              color: AppColor.electricCyan.withValues(alpha: 0.7),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.12,
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
  const _TipRow({required this.icon, required this.text, this.small = false});

  final IconData icon;
  final String text;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final iconSize = small ? 26.0 : 28.0;
    final iconInner = small ? 13.0 : 14.0;
    final gap = small ? 8.0 : 10.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: const BoxDecoration(
            color: AppColor.hudGlass,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColor.electricCyan, size: iconInner),
        ),
        SizedBox(width: gap),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: TextStyle(
                color: AppColor.onSurface,
                fontSize: small ? 12 : 12.5,
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
