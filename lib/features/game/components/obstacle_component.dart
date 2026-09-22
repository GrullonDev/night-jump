import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/game/state/game_status.dart';

/// A pair of neon bars (top/bottom) with a gap the orb must pass through.
/// Scrolls right-to-left and awards a point once the orb clears it.
/// When [lowerOnly] is true, only the bottom bar spawns (Tranquilo mode),
/// leaving the upper screen completely open.
class ObstacleComponent extends PositionComponent
    with HasGameReference<NightJumpGame> {
  static const double barWidth = 64;
  static const double defaultGapHeight = 190;
  static const double _edgeMargin = 90;

  final double screenHeight;
  final double gapCenterY;
  final double gapHeight;
  final bool lowerOnly;
  bool scored = false;

  ObstacleComponent({
    required double startX,
    required this.screenHeight,
    required Random random,
    double? gapHeight,
    this.lowerOnly = false,
  }) : gapHeight = gapHeight ?? defaultGapHeight,
       gapCenterY = lowerOnly
           ? screenHeight * 0.55 + random.nextDouble() * (screenHeight * 0.3)
           : _edgeMargin +
               random.nextDouble() * (screenHeight - 2 * _edgeMargin),
       super(position: Vector2(startX, 0), size: Vector2(barWidth, 0));

  @override
  Future<void> onLoad() async {
    if (lowerOnly) {
      // Bottom bar only: from below the gap to the screen bottom.
      add(
        RectangleHitbox(
          size: Vector2(
            barWidth,
            screenHeight - (gapCenterY + gapHeight / 2),
          ),
          position: Vector2(0, gapCenterY + gapHeight / 2),
        ),
      );
    } else {
      // Top bar
      add(
        RectangleHitbox(
          size: Vector2(barWidth, gapCenterY - gapHeight / 2),
          position: Vector2.zero(),
        ),
      );
      // Bottom bar
      add(
        RectangleHitbox(
          size: Vector2(
            barWidth,
            screenHeight - (gapCenterY + gapHeight / 2),
          ),
          position: Vector2(0, gapCenterY + gapHeight / 2),
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.status != GameStatus.playing) return;

    // Live speed: all on-screen bars accelerate together as the run ramps.
    position.x -= game.currentObstacleSpeed * dt;

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
    // Bars follow the selected palette's primary; comfort mode
    // softens the halo so long sessions stay easy on the eyes.
    final barColor = game.palette.value.primary;
    final glowAlpha = game.comfortDim.value ? 0.18 : 0.35;
    final paint = Paint()..color = barColor.withValues(alpha: 0.85);
    final glowPaint = Paint()
      ..color = barColor.withValues(alpha: glowAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    final bottomRect = Rect.fromLTWH(
      0,
      gapCenterY + gapHeight / 2,
      barWidth,
      screenHeight - (gapCenterY + gapHeight / 2),
    );

    if (lowerOnly) {
      // Bottom bar only
      canvas.drawRect(bottomRect, glowPaint);
      canvas.drawRect(bottomRect, paint);
    } else {
      // Top and bottom bars
      final topRect = Rect.fromLTWH(0, 0, barWidth, gapCenterY - gapHeight / 2);
      canvas.drawRect(topRect, glowPaint);
      canvas.drawRect(topRect, paint);
      canvas.drawRect(bottomRect, glowPaint);
      canvas.drawRect(bottomRect, paint);
    }
  }
}
