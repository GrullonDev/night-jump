import 'package:flutter/material.dart';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:night_jump/features/game/components/obstacle_component.dart';
import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/game/state/game_status.dart';
import 'package:night_jump/utils/theme/app_color.dart';

class OrbComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<NightJumpGame> {
  static const double radius = 22;
  static const double gravity = 900;
  static const double jumpVelocity = -320;

  double velocityY = 0;

  OrbComponent() : super(size: Vector2.all(radius * 2), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(radius: radius, anchor: Anchor.center));
  }

  void reset() {
    position = Vector2(game.size.x * 0.3, game.size.y / 2);
    velocityY = 0;
  }

  void jump() {
    velocityY = jumpVelocity;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.status != GameStatus.playing) return;

    velocityY += gravity * dt;
    position.y += velocityY * dt;

    if (position.y - radius <= 0 || position.y + radius >= game.size.y) {
      position.y = position.y.clamp(radius, game.size.y - radius);
      game.endGame();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is ObstacleComponent && game.status == GameStatus.playing) {
      game.endGame();
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(radius, radius);

    canvas.drawCircle(
      center,
      radius * 1.6,
      Paint()
        ..color = AppColor.intenseMagenta.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    final gradient = RadialGradient(
      colors: [
        AppColor.intenseMagenta,
        AppColor.neonRose,
        AppColor.secondaryContainer,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: radius),
        ),
    );

    canvas.drawCircle(
      Offset(radius - radius * 0.35, radius - radius * 0.35),
      radius * 0.3,
      Paint()..color = const Color(0xCCFFFFFF),
    );
  }
}
