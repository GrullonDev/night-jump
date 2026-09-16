import 'package:flutter/material.dart';

import 'package:night_jump/features/home/page/home_page.dart';
import 'package:night_jump/utils/theme/app_color.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: AppColor.inversePrimary),
      ),
      home: const HomePage() /* MyHomePage(title: 'Flutter Demo Home Page') */,
    );
  }
}
