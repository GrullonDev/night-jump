import 'package:flutter/material.dart';

import 'package:night_jump/utils/theme/app_color.dart';

class SeasonText extends StatelessWidget {
  const SeasonText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'SIN CONEXIÓN • TU PROPIO RITMO',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColor.slateGlow,
        letterSpacing: 0.15,
        fontFamily: 'Space Grotesk',
      ),
    );
  }
}
