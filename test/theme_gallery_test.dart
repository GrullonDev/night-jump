import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:night_jump/features/missions/state/missions_repository.dart';
import 'package:night_jump/features/themes/page/theme_gallery_page.dart';
import 'package:night_jump/features/themes/state/theme_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('gallery fits a 320px screen without overflow', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ThemeGalleryPage(
          themeRepository: ThemeRepository(),
          missionsRepository: MissionsRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('COLECCIÓN DE ESPECTROS'), findsOneWidget);

    // Preview a free palette: switches the preview without errors.
    await tester.ensureVisible(find.text('PROBAR').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('PROBAR').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
