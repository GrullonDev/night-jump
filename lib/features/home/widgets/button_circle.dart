import 'package:flutter/material.dart';

import 'package:night_jump/utils/theme/app_color.dart';

class ButtonCircle extends StatelessWidget {
  const ButtonCircle({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColor.hudGlass.withValues(alpha: 0.7),
        shape: BoxShape.circle,
        border: Border.all(color: AppColor.electricCyan.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColor.electricCyan.withValues(alpha: 0.1),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(icon, color: AppColor.electricCyan, size: 22),
    );
  }
}
