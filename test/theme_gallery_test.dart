import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:night_jump/features/missions/state/missions_repository.dart';
import 'package:night_jump/features/themes/page/theme_gallery_page.dart';
import 'package:night_jump/features/themes/state/theme_repository.dart';

class InterruptedThemeRepository extends ThemeRepository {
  bool failLoad = true;
  String selected = 'default';
  Completer<void>? pendingSelection;
  int selectionCalls = 0;

  @override
  Future<String> getSelectedPaletteId() async {
    if (failLoad) {
      failLoad = false;
      throw StateError('Simulated read failure');
    }
    return selected;
  }

  @override
  Future<Set<String>> getUnlockedPaletteIds() async => {'default', 'cyberpunk'};

  @override
  Future<void> selectPalette(String paletteId) async {
    selectionCalls++;
    await pendingSelection?.future;
    selected = paletteId;
  }
}

class GalleryMissionsRepository extends MissionsRepository {
  @override
  Future<int> getStardust() async => 321;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('theme confirmation handles failure and ignores repeated taps', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final themes = InterruptedThemeRepository()..failLoad = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ThemeGalleryPage(
          themeRepository: themes,
          missionsRepository: GalleryMissionsRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Cyberpunk'));
    await tester.tap(find.text('Cyberpunk'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('CONFIRMAR PALETA'));
    await tester.pumpAndSettle();
    themes.pendingSelection = Completer<void>();
    await tester.tap(find.text('CONFIRMAR PALETA'));
    await tester.pump();
    await tester.tap(find.text('CONFIRMAR PALETA'));
    expect(themes.selectionCalls, 1);
    themes.pendingSelection!.completeError(
      StateError('Simulated write failure'),
    );
    await tester.pumpAndSettle();
    expect(themes.selected, 'default');
    expect(
      find.text('No se pudo guardar el tema. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    themes.pendingSelection = Completer<void>();
    await tester.tap(find.text('CONFIRMAR PALETA'));
    await tester.pump();
    themes.pendingSelection!.complete();
    await tester.pumpAndSettle();
    expect(themes.selectionCalls, 2);
    expect(themes.selected, 'cyberpunk');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('gallery can recover from a read error without clearing data', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'missions.stardust': 321});
    final themes = InterruptedThemeRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: ThemeGalleryPage(
          themeRepository: themes,
          missionsRepository: GalleryMissionsRepository(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('REINTENTAR'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('REINTENTAR'));
    await tester.pumpAndSettle();
    expect(find.text('COLECCIÓN DE ESPECTROS'), findsOneWidget);
    expect(find.text('321 STARDUST'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

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
