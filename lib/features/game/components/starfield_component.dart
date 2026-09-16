import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/game/state/game_status.dart';

class _Star {
  _Star(this.position, this.radius, this.speed, this.alpha);

  Vector2 position;
  final double radius;
  final double speed;
  final double alpha;
}

class StarfieldComponent extends PositionComponent
    with HasGameReference<NightJumpGame> {
  static const int starCount = 60;
  final Random _random = Random();
  final List<_Star> _stars = [];

  @override
  Future<void> onLoad() async {
    priority = -1;
    final size = game.size;
    for (var i = 0; i < starCount; i++) {
      _stars.add(
        _Star(
          Vector2(_random.nextDouble() * size.x, _random.nextDouble() * size.y),
          _random.nextDouble() * 1.6 + 0.4,
          _random.nextDouble() * 20 + 10,
          _random.nextDouble() * 0.5 + 0.3,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final size = game.size;
    final scrollSpeed = game.status == GameStatus.playing ? 1.0 : 0.15;
    for (final star in _stars) {
      star.position.x -= star.speed * scrollSpeed * dt;
      if (star.position.x < 0) {
        star.position
          ..x = size.x
          ..y = _random.nextDouble() * size.y;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFFFFFFF);
    for (final star in _stars) {
      paint.color = paint.color.withValues(alpha: star.alpha);
      canvas.drawCircle(
        Offset(star.position.x, star.position.y),
        star.radius,
        paint,
      );
    }
  }
}
