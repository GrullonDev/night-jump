import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:night_jump/features/game/state/game_difficulty.dart';
import 'package:night_jump/utils/theme/app_color.dart';

class ResultShareService {
  ResultShareService({this.shareSheet});
  final Future<void> Function(ShareParams)? shareSheet;
  // Set only after a public store/test URL has been verified. Image-only today.
  static const String verifiedDownloadUrl = '';
  static const cardSize = Size(1080, 1350);

  Future<Uint8List> render({
    required int score,
    required GameDifficulty difficulty,
    required int best,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final rect = Offset.zero & cardSize;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColor.canvasBase, AppColor.deepNavy],
        ).createShader(rect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(54, 54, 972, 1242),
        const Radius.circular(40),
      ),
      Paint()
        ..color = AppColor.electricCyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    void text(String value, double y, double fontSize, Color color) {
      final painter = TextPainter(
        text: TextSpan(
          text: value,
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: 'Sora',
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 900);
      painter.paint(canvas, Offset((1080 - painter.width) / 2, y));
      painter.dispose();
    }

    text('NIGHT JUMP', 140, 88, AppColor.electricCyan);
    text(difficulty.label, 280, 50, AppColor.slateWhite);
    text('PUNTUACIÓN', 415, 36, AppColor.slateGlow);
    // Large records shrink predictably; no ellipsis on the exported score.
    text(
      '$score',
      480,
      score.toString().length > 7 ? 96 : 160,
      AppColor.slateWhite,
    );
    text('Récord personal: $best', 740, 44, AppColor.electricCyan);
    text('Can you beat me?', 950, 64, AppColor.neonRose);
    text('Por GrullonDev • récord local', 1180, 30, AppColor.slateGlow);
    final picture = recorder.endRecording();
    final image = await picture.toImage(1080, 1350);
    picture.dispose();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return bytes!.buffer.asUint8List();
  }

  Future<void> share({
    required int score,
    required GameDifficulty difficulty,
    required int best,
    required Rect origin,
  }) async {
    final bytes = await render(
      score: score,
      difficulty: difficulty,
      best: best,
    );
    final params = ShareParams(
      files: [XFile.fromData(bytes, mimeType: 'image/png')],
      fileNameOverrides: ['night-jump-$score.png'],
      text: verifiedDownloadUrl.isEmpty ? null : verifiedDownloadUrl,
      subject: 'Night Jump • ${difficulty.label} • $score',
      sharePositionOrigin: origin,
    );
    if (shareSheet != null) {
      await shareSheet!(params);
    } else {
      await SharePlus.instance.share(params);
    }
  }
}
