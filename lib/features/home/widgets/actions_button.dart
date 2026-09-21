import 'package:flutter/material.dart';

import 'package:night_jump/features/home/widgets/home_button.dart';

/// Home keeps a single action: changing the orb color.
/// Retos and Ranking were retired to keep the start screen calm.
class ButtonActions extends StatelessWidget {
  const ButtonActions({super.key, this.onTapPalette});

  final VoidCallback? onTapPalette;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HomeButton(
          icon: Icons.palette_rounded,
          label: 'COLOR',
          onTap: onTapPalette,
        ),
      ],
    );
  }
}
