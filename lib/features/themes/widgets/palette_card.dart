import 'package:flutter/material.dart';

import 'package:night_jump/features/themes/state/neon_palette.dart';
import 'package:night_jump/utils/theme/app_color.dart';

class PaletteCard extends StatelessWidget {
  const PaletteCard({
    super.key,
    required this.palette,
    required this.isActive,
    required this.isUnlocked,
    required this.onTap,
  });

  final NeonPalette palette;
  final bool isActive;
  final bool isUnlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.hudGlass.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? AppColor.electricCyan.withValues(alpha: 0.5)
                  : AppColor.electricCyan.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [palette.primary, palette.secondary],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          palette.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColor.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Sora',
                          ),
                        ),
                        if (isActive)
                          _StatusBadge(
                            label: 'ACTIVO',
                            color: AppColor.electricCyan,
                          )
                        else if (isUnlocked)
                          _StatusBadge(
                            label: 'DISPONIBLE',
                            color: AppColor.slateGlow,
                          )
                        else
                          Icon(
                            Icons.lock_rounded,
                            size: 14,
                            color: AppColor.slateGlow,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      palette.description,
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
              const SizedBox(width: 8),
              _TrailingAction(
                palette: palette,
                isActive: isActive,
                isUnlocked: isUnlocked,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrailingAction extends StatelessWidget {
  const _TrailingAction({
    required this.palette,
    required this.isActive,
    required this.isUnlocked,
    required this.onTap,
  });

  final NeonPalette palette;
  final bool isActive;
  final bool isUnlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return Icon(Icons.check_circle_rounded, color: AppColor.electricCyan);
    }
    if (isUnlocked) {
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColor.electricCyan.withValues(alpha: 0.4)),
          foregroundColor: AppColor.electricCyan,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: const Text(
          'PROBAR',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.canvasMidnight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 12, color: AppColor.electricCyan),
          const SizedBox(width: 4),
          Text(
            '${palette.cost}',
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          fontFamily: 'Space Grotesk',
        ),
      ),
    );
  }
}
