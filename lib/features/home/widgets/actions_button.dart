import 'package:flutter/material.dart';

import 'package:night_jump/features/home/widgets/button_circle.dart';
import 'package:night_jump/features/home/widgets/home_button.dart';

class ButtonActions extends StatelessWidget {
  const ButtonActions({super.key, this.onTapRetos, this.onTapPalette});

  final VoidCallback? onTapRetos;
  final VoidCallback? onTapPalette;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HomeButton(
          icon: Icons.local_fire_department_rounded,
          label: 'RETOS',
          onTap: onTapRetos,
        ),
        const SizedBox(width: 16),
        HomeButton(icon: Icons.emoji_events_rounded, label: 'RANKING'),
        const SizedBox(width: 16),
        ButtonCircle(icon: Icons.palette_rounded, onTap: onTapPalette),
      ],
    );
  }
}
