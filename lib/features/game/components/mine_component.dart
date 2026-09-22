import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/game/state/game_status.dart';
import 'package:night_jump/utils/theme/app_color.dart';

/// A floating hazard that drifts in the upper screen area (Tranquilo mode).
/// Touching it ends the run or consumes a shield, adding risk to the
/// otherwise safe upper flight zone.
class MineComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<NightJumpGame> {
  static const double mineRadius = 12;
  static const double hitboxRadius = 14;

  double _pulseTime = 0;
  double _rotationAngle = 0;

  MineComponent({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(mineRadius * 2),
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

    _pulseTime += dt * 5;
    _rotationAngle += dt * 3;

    // Drift left with obstacles
    position.x -= game.currentObstacleSpeed * dt;

    // Remove when off-screen
    if (position.x + mineRadius < 0) {
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
      if (game.shieldActive.value) {
        // Shield absorbs the mine
        game.deactivateShield();
        game.sound.score();
        removeFromParent();
      } else {
        // No shield - game over
        game.endGame();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(mineRadius, mineRadius);
    final pulseFactor = 0.7 + 0.3 * sin(_pulseTime);

    // Outer danger glow
    canvas.drawCircle(
      center,
      mineRadius * 2.0 * pulseFactor,
      Paint()
        ..color = AppColor.error.withValues(alpha: 0.15 * pulseFactor)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // Mid glow
    canvas.drawCircle(
      center,
      mineRadius * 1.4,
      Paint()
        ..color = AppColor.error.withValues(alpha: 0.25 * pulseFactor)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Mine body (dark core with red rim)
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColor.canvasBase,
          AppColor.errorContainer,
        ],
        stops: const [0.0, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: mineRadius),
      );
    canvas.drawCircle(center, mineRadius, bodyPaint);

    // Red ring
    canvas.drawCircle(
      center,
      mineRadius,
      Paint()
        ..color = AppColor.error.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Spinning spikes (4 directions)
    for (int i = 0; i < 4; i++) {
      final angle = (i * pi / 2) + _rotationAngle;
      final spikeLength = mineRadius + 5 * pulseFactor;
      final innerX = center.dx + (mineRadius - 2) * cos(angle);
      final innerY = center.dy + (mineRadius - 2) * sin(angle);
      final outerX = center.dx + spikeLength * cos(angle);
      final outerY = center.dy + spikeLength * sin(angle);

      canvas.drawLine(
        Offset(innerX, innerY),
        Offset(outerX, outerY),
        Paint()
          ..color = AppColor.error.withValues(alpha: 0.8)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    // Center spark
    canvas.drawCircle(
      center,
      3 * pulseFactor,
      Paint()..color = AppColor.error.withValues(alpha: 0.9),
    );
  }
}
