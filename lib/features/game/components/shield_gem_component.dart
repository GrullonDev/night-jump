import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/game/state/game_status.dart';
import 'package:night_jump/utils/theme/app_color.dart';

class ShieldGemComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<NightJumpGame> {
  static const double gemSize = 28;
  static const double hitboxRadius = 18;

  double _pulseTime = 0;
  double _rotationAngle = 0;

  ShieldGemComponent({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(gemSize),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(radius: hitboxRadius, anchor: Anchor.center));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.status != GameStatus.playing) return;

    _pulseTime += dt * 3;
    _rotationAngle += dt * 1.5;

    // Move left with obstacles
    position.x -= game.currentObstacleSpeed * dt;

    // Remove when off-screen
    if (position.x + gemSize < 0) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other == game.orb && game.status == GameStatus.playing) {
      game.collectGem();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(gemSize / 2, gemSize / 2);
    final pulseFactor = 0.8 + 0.2 * sin(_pulseTime);
    final glowRadius = gemSize * 0.9 * pulseFactor;

    // Outer glow
    canvas.drawCircle(
      center,
      glowRadius,
      Paint()
        ..color = AppColor.gemGreen.withValues(alpha: 0.25 * pulseFactor)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Mid glow
    canvas.drawCircle(
      center,
      glowRadius * 0.7,
      Paint()
        ..color = AppColor.gemGreen.withValues(alpha: 0.4 * pulseFactor)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Octagonal gem body
    final path = Path();
    final radius = gemSize / 2 - 2;
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * pi / 8) + _rotationAngle;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Gem gradient
    final gemPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColor.gemGreen,
          AppColor.gemGreenDark,
        ],
        stops: const [0.0, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawPath(path, gemPaint);

    // Inner highlight
    final highlightPath = Path();
    final innerRadius = radius * 0.4;
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * pi / 8) + _rotationAngle + pi / 8;
      final x = center.dx + innerRadius * cos(angle);
      final y = center.dy + innerRadius * sin(angle);
      if (i == 0) {
        highlightPath.moveTo(x, y);
      } else {
        highlightPath.lineTo(x, y);
      }
    }
    highlightPath.close();

    canvas.drawPath(
      highlightPath,
      Paint()..color = AppColor.gemGreen.withValues(alpha: 0.6),
    );

    // Center spark
    canvas.drawCircle(
      center,
      3 * pulseFactor,
      Paint()..color = const Color(0xCCFFFFFF),
    );
  }
}
