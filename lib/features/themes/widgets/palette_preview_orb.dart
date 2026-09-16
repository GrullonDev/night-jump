import 'package:flutter/material.dart';

import 'package:night_jump/utils/theme/app_color.dart';

/// Live preview of the orb glow for a given palette, used by the theme
/// gallery so the player can see a color scheme before confirming it.
class PalettePreviewOrb extends StatelessWidget {
  const PalettePreviewOrb({
    super.key,
    required this.primary,
    required this.secondary,
    this.size = 200,
    this.dimmed = false,
  });

  final Color primary;
  final Color secondary;
  final double size;

  /// "Brillo Nocturno" comfort mode: softens the glow intensity.
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final glowAlpha = dimmed ? 0.2 : 0.4;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: secondary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
          ),
          Container(
            width: size * 0.7,
            height: size * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primary.withValues(alpha: 0.15)),
            ),
          ),
          Container(
            width: size * 0.5,
            height: size * 0.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  primary.withValues(alpha: dimmed ? 0.7 : 1),
                  secondary.withValues(alpha: dimmed ? 0.5 : 0.85),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: glowAlpha),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          Positioned(
            top: size * 0.32,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.canvasBase.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'SIMULACIÓN\nEN VIVO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                  fontFamily: 'Space Grotesk',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
