import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/game/state/game_status.dart';
import 'package:night_jump/utils/theme/app_color.dart';

/// A mine that bounces vertically while drifting left, creating a moving
/// hazard that's harder to predict than static mines. (Chill mode only.)
class FloatingMineComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<NightJumpGame> {
  static const double mineRadius = 14;
  static const double hitboxRadius = 16;

  double _pulseTime = 0;
  double _rotationAngle = 0;
  double _verticalVelocity;
  final double _bounceSpeed;
  final double _minY;
  double _maxY;

  FloatingMineComponent({
    required Vector2 position,
    double bounceSpeed = 80,
  })  : _bounceSpeed = bounceSpeed,
        _verticalVelocity = bounceSpeed * (Random().nextBool() ? 1 : -1),
        _minY = mineRadius + 10,
        _maxY = 0, // Will be set in onLoad
        super(
          position: position,
          size: Vector2.all(mineRadius * 2),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    _maxY = game.size.y - mineRadius - 10;
    add(CircleHitbox(radius: hitboxRadius, anchor: Anchor.center));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.status != GameStatus.playing) return;

    _pulseTime += dt * 6;
    _rotationAngle += dt * 4;

    // Move left with obstacles
    position.x -= game.currentObstacleSpeed * dt;

    // Bounce vertically
    position.y += _verticalVelocity * dt;
    if (position.y <= _minY) {
      position.y = _minY;
      _verticalVelocity = _bounceSpeed.abs();
    } else if (position.y >= _maxY) {
      position.y = _maxY;
      _verticalVelocity = -_bounceSpeed.abs();
    }

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
    final center = Offset(mineRadius, mineRadius);
    final pulseFactor = 0.7 + 0.3 * sin(_pulseTime);

    // Outer amber danger glow
    canvas.drawCircle(
      center,
      mineRadius * 2.2 * pulseFactor,
      Paint()
        ..color = const Color(0xFFFF9800).withValues(alpha: 0.15 * pulseFactor)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // Mid glow
    canvas.drawCircle(
      center,
      mineRadius * 1.5,
      Paint()
        ..color = const Color(0xFFFF9800).withValues(alpha: 0.3 * pulseFactor)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Mine body (dark core with amber rim)
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColor.canvasBase,
          const Color(0xFFCC6600),
        ],
        stops: const [0.0, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: mineRadius),
      );
    canvas.drawCircle(center, mineRadius, bodyPaint);

    // Amber ring
    canvas.drawCircle(
      center,
      mineRadius,
      Paint()
        ..color = const Color(0xFFFF9800).withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Spinning spikes (6 directions - more than regular mine)
    for (int i = 0; i < 6; i++) {
      final angle = (i * pi / 3) + _rotationAngle;
      final spikeLength = mineRadius + 6 * pulseFactor;
      final innerX = center.dx + (mineRadius - 2) * cos(angle);
      final innerY = center.dy + (mineRadius - 2) * sin(angle);
      final outerX = center.dx + spikeLength * cos(angle);
      final outerY = center.dy + spikeLength * sin(angle);

      canvas.drawLine(
        Offset(innerX, innerY),
        Offset(outerX, outerY),
        Paint()
          ..color = const Color(0xFFFF9800).withValues(alpha: 0.85)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }

    // Center spark
    canvas.drawCircle(
      center,
      3.5 * pulseFactor,
      Paint()..color = const Color(0xFFFFCC00).withValues(alpha: 0.9),
    );

    // Warning exclamation mark
    final exPaint = Paint()
      ..color = const Color(0xFFFFF3E0).withValues(alpha: 0.7 * pulseFactor)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx, center.dy - 5),
      Offset(center.dx, center.dy + 1),
      exPaint,
    );
    canvas.drawCircle(Offset(center.dx, center.dy + 3.5), 1, exPaint);
  }
}
