import 'dart:math';

/// Conservatively limits movement between corridors using actual jump physics.
/// Space includes time to clear the bar and settle after a tap.
class GatePlanner {
  static const gravity = 900.0;
  static const jumpVelocity = -320.0;
  static const hitboxRadius = 16.0;
  static const recoverySeconds = 1.5;
  static const maxRise = jumpVelocity * jumpVelocity / (2 * gravity);
  static const jumpCycle = -2 * jumpVelocity / gravity;

  static double effectiveGap(double desired, double height) =>
      min(desired, height - 120).clamp(100.0, desired);

  static double nextCenter({
    required double previous,
    required double height,
    required double gap,
    required double interval,
    required double maxSpeed,
    required Random random,
    double barWidth = 64,
  }) {
    final travelTime = max(
      0.0,
      interval - (barWidth + 2 * hitboxRadius) / maxSpeed,
    );
    // At most half a jump's rise; adjacent safe corridors overlap.
    final delta = min(maxRise * 0.5, travelTime * jumpVelocity.abs() * 0.2);
    final margin = gap / 2 + 36;
    // A repeating jump follows a parabola spanning maxRise. Every corridor
    // contains that same reference path plus hitbox and 12px safety clearance.
    final sharedRange = max(0.0, gap / 2 - hitboxRadius - maxRise / 2 - 12);
    final low = max(margin, height / 2 - sharedRange);
    final high = min(height - margin, height / 2 + sharedRange);
    return (previous + (random.nextDouble() * 2 - 1) * delta).clamp(low, high);
  }
}
