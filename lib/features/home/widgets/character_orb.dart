import 'package:flutter/material.dart';

import 'package:night_jump/utils/theme/app_color.dart';

/// Menu orb with a slow idle "breathing" scale. The motion owns its
/// lifecycle here (controller created + disposed in this state) and
/// renders static when the OS requests reduced motion.
class CharacterOrb extends StatefulWidget {
  const CharacterOrb({super.key, this.size = 180});

  /// Diameter of the outer ring. Inner rings/orb/glow scale proportionally.
  final double size;

  @override
  State<CharacterOrb> createState() => _CharacterOrbState();
}

class _CharacterOrbState extends State<CharacterOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _scale = Tween(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return _OrbBody(size: widget.size);
    }
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(scale: _scale.value, child: child);
      },
      child: _OrbBody(size: widget.size),
    );
  }
}

class _OrbBody extends StatelessWidget {
  const _OrbBody({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final middleSize = size * (140 / 180);
    final glowSize = size * (120 / 180);
    final orbSize = size * (100 / 180);
    final highlightSize = size * (30 / 180);
    final highlightOffset = size * (25 / 180);
    final highlightLeft = size * (35 / 180);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColor.electricCyan.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
          ),
          // Middle ring
          Container(
            width: middleSize,
            height: middleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColor.electricCyan.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          // Glow effect
          Container(
            width: glowSize,
            height: glowSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColor.intenseMagenta.withValues(alpha: 0.4),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
                BoxShadow(
                  color: AppColor.neonRose.withValues(alpha: 0.2),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
          // Main orb
          Container(
            width: orbSize,
            height: orbSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [
                  AppColor.intenseMagenta,
                  AppColor.neonRose,
                  AppColor.secondaryContainer,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.intenseMagenta.withValues(alpha: 0.6),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          // Inner highlight
          Positioned(
            top: highlightOffset,
            left: highlightLeft,
            child: Container(
              width: highlightSize,
              height: highlightSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.8),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
