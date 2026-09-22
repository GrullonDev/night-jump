import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:night_jump/features/game/components/obstacle_component.dart';
import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/game/state/game_status.dart';
import 'package:night_jump/utils/theme/app_color.dart';

class OrbComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<NightJumpGame> {
  static const double visualRadius = 22;
  static const double hitboxRadius = 16;
  static const double gravity = 900;
  static const double jumpVelocity = -320;
  static const double edgeDangerMargin = 80;

  double velocityY = 0;
  double _dangerRatio = 0;
  double _pulseTime = 0;
  double _shieldPulseTime = 0;
  bool _shieldFlashActive = false;
  double _shieldFlashTimer = 0;

  OrbComponent()
    : super(size: Vector2.all(visualRadius * 2), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(radius: hitboxRadius, anchor: Anchor.center));
  }

  void reset() {
    position = Vector2(game.size.x * 0.3, game.size.y / 2);
    velocityY = 0;
    _dangerRatio = 0;
    _pulseTime = 0;
    _shieldPulseTime = 0;
    _shieldFlashActive = false;
    _shieldFlashTimer = 0;
  }

  void jump() {
    velocityY = jumpVelocity;
    game.sound.jump();
    if (game.hapticsEnabled.value) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.status != GameStatus.playing) return;

    velocityY += gravity * dt;
    position.y += velocityY * dt;

    // Update shield pulse
    if (game.shieldActive.value) {
      _shieldPulseTime += dt * 4;
    }

    // Update shield flash effect
    if (_shieldFlashActive) {
      _shieldFlashTimer -= dt;
      if (_shieldFlashTimer <= 0) {
        _shieldFlashActive = false;
      }
    }

    if (position.y - visualRadius <= 0 ||
        position.y + visualRadius >= game.size.y) {
      position.y = position.y.clamp(visualRadius, game.size.y - visualRadius);
      if (game.shieldActive.value) {
        game.deactivateShield();
        _shieldFlashActive = true;
        _shieldFlashTimer = 0.3;
      } else {
        game.endGame();
      }
    } else {
      // Danger ratio (0.0 to 1.0) from proximity
      // to the top/bottom edges.
      final topDist = position.y - visualRadius;
      final bottomDist = game.size.y - (position.y + visualRadius);
      final minDist = topDist < bottomDist ? topDist : bottomDist;

      if (minDist < edgeDangerMargin) {
        _dangerRatio = 1.0 - (minDist / edgeDangerMargin).clamp(0.0, 1.0);
        _pulseTime += dt * 10; // Speed of pulsing
      } else {
        _dangerRatio = 0.0;
        _pulseTime = 0.0;
      }
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is ObstacleComponent && game.status == GameStatus.playing) {
      if (game.shieldActive.value) {
        // Shield absorbs the hit
        game.deactivateShield();
        _shieldFlashActive = true;
        _shieldFlashTimer = 0.3;
        game.sound.score();
      } else {
        // No shield - offer shield dialogue or end game
        game.showShieldOffer();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(visualRadius, visualRadius);
    final palette = game.palette.value;
    final dimmed = game.comfortDim.value;
    final glowScale = dimmed ? 0.55 : 1.0;

    // Shield halo effect
    if (game.shieldActive.value) {
      final shieldPulse = 0.7 + 0.3 * sin(_shieldPulseTime);
      final shieldRadius = visualRadius * 2.0 * shieldPulse;
      
      // Outer shield glow
      canvas.drawCircle(
        center,
        shieldRadius,
        Paint()
          ..color = AppColor.shieldCyan.withValues(alpha: 0.2 * shieldPulse)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, dimmed ? 15 : 22),
      );

      // Inner shield ring
      final shieldRingPaint = Paint()
        ..color = AppColor.shieldCyan.withValues(alpha: 0.6 * shieldPulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(center, visualRadius * 1.5, shieldRingPaint);

      // Shield energy particles
      for (int i = 0; i < 6; i++) {
        final angle = (i * 2 * pi / 6) + _shieldPulseTime * 0.5;
        final particleDist = visualRadius * 1.7;
        final particleX = center.dx + particleDist * cos(angle);
        final particleY = center.dy + particleDist * sin(angle);
        canvas.drawCircle(
          Offset(particleX, particleY),
          2 * shieldPulse,
          Paint()..color = AppColor.shieldCyan.withValues(alpha: 0.8 * shieldPulse),
        );
      }
    }

    // Shield flash effect
    if (_shieldFlashActive) {
      final flashAlpha = _shieldFlashTimer / 0.3;
      canvas.drawCircle(
        center,
        visualRadius * 2.5,
        Paint()
          ..color = AppColor.shieldCyan.withValues(alpha: 0.5 * flashAlpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20),
      );
    }

    // Orb body follows the selected palette: secondary core
    // blending out to primary.
    Color baseGlow = palette.secondary.withValues(alpha: 0.35 * glowScale);
    Color centerGradient = palette.secondary;
    Color midGradient = Color.lerp(palette.secondary, palette.primary, 0.55)!;
    Color outerGradient = palette.primary;

    if (_dangerRatio > 0) {
      final pulseFactor = 0.5 + 0.5 * sin(_pulseTime);

      final dangerColor = Color.lerp(
        palette.secondary,
        AppColor.error, // Red
        _dangerRatio,
      )!;

      baseGlow = dangerColor.withValues(
        alpha: (0.35 + (0.2 * _dangerRatio * pulseFactor)) * glowScale,
      );
      centerGradient = dangerColor;
      midGradient = Color.lerp(
        midGradient,
        AppColor.errorContainer,
        _dangerRatio,
      )!;
      outerGradient = Color.lerp(outerGradient, AppColor.error, _dangerRatio)!;
    }

    canvas.drawCircle(
      center,
      visualRadius * 1.6,
      Paint()
        ..color = baseGlow
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, dimmed ? 12 : 18),
    );

    final gradient = RadialGradient(
      colors: [centerGradient, midGradient, outerGradient],
      stops: const [0.0, 0.5, 1.0],
    );
    canvas.drawCircle(
      center,
      visualRadius,
      Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: visualRadius),
        ),
    );

    canvas.drawCircle(
      Offset(
        visualRadius - visualRadius * 0.35,
        visualRadius - visualRadius * 0.35,
      ),
      visualRadius * 0.3,
      Paint()..color = const Color(0xCCFFFFFF),
    );
  }
}
