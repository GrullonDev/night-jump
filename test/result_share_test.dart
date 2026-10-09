import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:night_jump/features/game/state/game_difficulty.dart';
import 'package:night_jump/features/game/state/result_share_service.dart';

void main() {
  testWidgets(
    'exports a complete portrait PNG and shares it without an invented URL',
    (tester) async {
      await tester.runAsync(() async {
        final loader = FontLoader('Sora')
          ..addFont(rootBundle.load('assets/fonts/Sora.ttf'));
        await loader.load();
        ShareParams? captured;
        final service = ResultShareService(
          shareSheet: (params) async {
            captured = params;
          },
        );
        await service.share(
          score: 42,
          difficulty: GameDifficulty.classic,
          best: 71,
          origin: const ui.Rect.fromLTWH(24, 100, 200, 48),
        );
        expect(captured!.files, hasLength(1));
        expect(captured!.text, isNull);
        expect(captured!.fileNameOverrides, ['night-jump-42.png']);
        expect(captured!.sharePositionOrigin!.width, 200);
        final png = await captured!.files!.single.readAsBytes();
        final codec = await ui.instantiateImageCodec(png);
        final frame = await codec.getNextFrame();
        expect(frame.image.width, 1080);
        expect(frame.image.height, 1350);
        frame.image.dispose();
        codec.dispose();
        await Directory('build/qa').create(recursive: true);
        await File('build/qa/result-card.png').writeAsBytes(png);
      });
    },
  );
}
