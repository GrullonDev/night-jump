import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/game/state/game_status.dart';
import 'package:night_jump/utils/theme/app_color.dart';

/// A horizontal rocket that spawns at the right edge targeting the player's
/// current Y position. Moves faster than regular obstacles, forcing the
/// player to dodge vertically. (Chill mode only.)
class RocketComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<NightJumpGame> {
  static const double rocketWidth = 36;
  static const double rocketHeight = 14;
  static const double hitboxWidth = 32;
  static const double hitboxHeight = 10;

  double _pulseTime = 0;
  final double targetY;

  RocketComponent({required Vector2 position, required this.targetY})
      : super(
          position: position,
          size: Vector2(rocketWidth, rocketHeight),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    add(
      RectangleHitbox(
        size: Vector2(hitboxWidth, hitboxHeight),
        position: Vector2(
          (rocketWidth - hitboxWidth) / 2,
          (rocketHeight - hitboxHeight) / 2,
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.status != GameStatus.playing) return;

    _pulseTime += dt * 8;

    // Move left faster than regular obstacles
    position.x -= game.currentObstacleSpeed * 1.5 * dt;

    // Gently drift toward the target Y (the player's Y when spawned)
    final yDiff = targetY - position.y;
    position.y += yDiff * dt * 2.0;

    // Remove when off-screen
    if (position.x + rocketWidth < 0) {
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
        game.deactivateShield();
        game.sound.score();
        removeFromParent();
      } else {
        game.endGame();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(rocketWidth / 2, rocketHeight / 2);
    final pulseFactor = 0.8 + 0.2 * sin(_pulseTime);

    // Flame trail glow
    canvas.drawCircle(
      Offset(center.dx + rocketWidth * 0.45, center.dy),
      8 * pulseFactor,
      Paint()
        ..color = AppColor.error.withValues(alpha: 0.3 * pulseFactor)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Flame trail
    final flamePaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColor.error, Color(0xFFFF6B00), Color(0xFFFFD600)],
      ).createShader(
        Rect.fromLTWH(
          center.dx - 2,
          center.dy - 5,
          rocketWidth * 0.45,
          10,
        ),
      );
    final flamePath = Path()
      ..moveTo(center.dx - 2, center.dy - 5)
      ..lineTo(center.dx - rocketWidth * 0.4, center.dy)
      ..lineTo(center.dx - 2, center.dy + 5)
      ..close();
    canvas.drawPath(flamePath, flamePaint);

    // Rocket body (elongated diamond/arrow shape)
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD600), Color(0xFFFF6B00), AppColor.error],
      ).createShader(
        Rect.fromLTWH(
          center.dx - rocketWidth / 2,
          center.dy - rocketHeight / 2,
          rocketWidth,
          rocketHeight,
        ),
      );
    final bodyPath = Path()
      ..moveTo(center.dx + rocketWidth / 2, center.dy) // nose tip
      ..lineTo(center.dx + 4, center.dy - rocketHeight / 2) // top edge
      ..lineTo(center.dx - rocketWidth / 2 + 6, center.dy - 3) // tail top
      ..lineTo(center.dx - rocketWidth / 2, center.dy - 6) // fin top
      ..lineTo(center.dx - rocketWidth / 2, center.dy + 6) // fin bottom
      ..lineTo(center.dx - rocketWidth / 2 + 6, center.dy + 3) // tail bottom
      ..lineTo(center.dx + 4, center.dy + rocketHeight / 2) // bottom edge
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Nose cone highlight
    canvas.drawCircle(
      Offset(center.dx + rocketWidth / 2 - 4, center.dy),
      2.5,
      Paint()..color = const Color(0xCCFFFFFF),
    );

    // Side fins
    final finPaint = Paint()..color = AppColor.errorContainer;
    // Top fin
    canvas.drawLine(
      Offset(center.dx - rocketWidth / 2 + 6, center.dy - 3),
      Offset(center.dx - rocketWidth / 2 + 2, center.dy - 9),
      finPaint..strokeWidth = 2,
    );
    // Bottom fin
    canvas.drawLine(
      Offset(center.dx - rocketWidth / 2 + 6, center.dy + 3),
      Offset(center.dx - rocketWidth / 2 + 2, center.dy + 9),
      finPaint..strokeWidth = 2,
    );

    // Engine glow
    canvas.drawCircle(
      Offset(center.dx - rocketWidth / 2 + 4, center.dy),
      3 * pulseFactor,
      Paint()..color = AppColor.error.withValues(alpha: 0.9 * pulseFactor),
    );
  }
}
