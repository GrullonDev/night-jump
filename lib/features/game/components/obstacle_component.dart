import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/game/state/game_status.dart';
import 'package:night_jump/utils/theme/app_color.dart';

/// A pair of neon bars (top/bottom) with a gap the orb must pass through.
/// Scrolls right-to-left and awards a point once the orb clears it.
class ObstacleComponent extends PositionComponent
    with HasGameReference<NightJumpGame> {
  static const double barWidth = 64;
  static const double defaultGapHeight = 190;
  static const double defaultSpeed = 180;
  static const double _edgeMargin = 90;

  final double screenHeight;
  final double gapCenterY;
  final double speed;
  final double gapHeight;
  bool scored = false;

  ObstacleComponent({
    required double startX,
    required this.screenHeight,
    required Random random,
    double? speed,
    double? gapHeight,
  }) : speed = speed ?? defaultSpeed,
       gapHeight = gapHeight ?? defaultGapHeight,
       gapCenterY =
            _edgeMargin + random.nextDouble() * (screenHeight - 2 * _edgeMargin),
       super(position: Vector2(startX, 0), size: Vector2(barWidth, 0));

  @override
  Future<void> onLoad() async {
    add(
      RectangleHitbox(
        size: Vector2(barWidth, gapCenterY - gapHeight / 2),
        position: Vector2.zero(),
      ),
    );
    add(
      RectangleHitbox(
        size: Vector2(barWidth, screenHeight - (gapCenterY + gapHeight / 2)),
        position: Vector2(0, gapCenterY + gapHeight / 2),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.status != GameStatus.playing) return;

    position.x -= speed * dt;

    if (!scored && position.x + barWidth < game.orb.position.x) {
      scored = true;
      game.addScore();
    }

    if (position.x + barWidth < 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = AppColor.electricCyan.withValues(alpha: 0.85);
    final glowPaint = Paint()
      ..color = AppColor.electricCyan.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    final topRect = Rect.fromLTWH(0, 0, barWidth, gapCenterY - gapHeight / 2);
    final bottomRect = Rect.fromLTWH(
      0,
      gapCenterY + gapHeight / 2,
      barWidth,
      screenHeight - (gapCenterY + gapHeight / 2),
    );

    canvas.drawRect(topRect, glowPaint);
    canvas.drawRect(topRect, paint);
    canvas.drawRect(bottomRect, glowPaint);
    canvas.drawRect(bottomRect, paint);
  }
}
