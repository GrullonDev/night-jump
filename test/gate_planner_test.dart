import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:night_jump/features/game/state/game_difficulty.dart';
import 'package:night_jump/features/game/state/gate_planner.dart';

void main() {
  for (final mode in GameDifficulty.values) {
    test(
      '${mode.name}: 1000 gates contain a physically traversable tap trajectory',
      () {
        final random = Random(71);
        var center = 360.0;
        final gap = mode.gapHeight;
        final speed = mode.obstacleSpeed + mode.rampSpeedDelta;
        expect(
          mode.minSpawnInterval - 96 / speed,
          greaterThan(GatePlanner.jumpCycle),
        );
        for (var gate = 0; gate < 1000; gate++) {
          final previous = center;
          center = GatePlanner.nextCenter(
            previous: previous,
            height: 720,
            gap: gap,
            interval: mode.minSpawnInterval,
            maxSpeed: speed,
            random: random,
          );
          expect(
            (center - previous).abs(),
            lessThanOrEqualTo(GatePlanner.maxRise / 2 + 0.001),
          );
          // Periodic taps every 2*v/g return to the same baseline. Sample
          // the entire parabola, including bar transit, with real hitbox size.
          for (var step = 0; step <= 100; step++) {
            final t = GatePlanner.jumpCycle * step / 100;
            final y =
                360 +
                GatePlanner.maxRise / 2 +
                GatePlanner.jumpVelocity * t +
                GatePlanner.gravity * t * t / 2;
            expect(y - GatePlanner.hitboxRadius, greaterThan(center - gap / 2));
            expect(y + GatePlanner.hitboxRadius, lessThan(center + gap / 2));
          }
        }
      },
    );
  }
}
