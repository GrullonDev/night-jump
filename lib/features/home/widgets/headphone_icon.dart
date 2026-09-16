import 'package:flutter/material.dart';

import 'package:night_jump/utils/theme/app_color.dart';

class HeadphoneIcon extends StatelessWidget {
  const HeadphoneIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColor.hudGlass.withValues(alpha: 0.6),
        shape: BoxShape.circle,
        border: Border.all(color: AppColor.electricCyan.withValues(alpha: 0.3)),
      ),
      child: Icon(
        Icons.headset_mic_rounded,
        color: AppColor.electricCyan,
        size: 24,
      ),
    );
  }
}
