import 'package:flutter/material.dart';

import 'package:night_jump/features/home/page/home_page.dart';
import 'package:night_jump/utils/theme/app_color.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Night Jump (Demo)',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: AppColor.inversePrimary),
      ),
      home: const HomePage(),
    );
  }
}
