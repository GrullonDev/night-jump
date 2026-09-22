import 'package:flutter/material.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/game/state/game_difficulty.dart';
import 'package:night_jump/utils/responsive/responsive_extension.dart';
import 'package:night_jump/utils/theme/app_color.dart';

/// Minimalist score counter shown during gameplay ('hud' overlay).
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  final NightJumpGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          top: context.responsive(mobile: 20.0, tablet: 32.0),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: _SpeedUpCue(game: game),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ValueListenableBuilder<int>(
                valueListenable: game.score,
                builder: (context, score, _) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.hudGlass.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColor.electricCyan.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '$score',
                      style: TextStyle(
                        color: AppColor.electricCyan,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Sora',
                      ),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: game.isPaused,
                      builder: (context, paused, _) {
                        return IconButton(
                          icon: Icon(
                            paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                            color: AppColor.electricCyan,
                            size: 32,
                          ),
                          onPressed: game.togglePause,
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    ValueListenableBuilder<int>(
                      valueListenable: game.shieldCount,
                      builder: (context, shieldCount, _) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: game.shieldActive,
                          builder: (context, shieldActive, _) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.hudGlass.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: shieldActive
                                      ? AppColor.shieldCyan.withValues(alpha: 0.6)
                                      : AppColor.electricCyan.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.shield_rounded,
                                    color: shieldActive
                                        ? AppColor.shieldCyan
                                        : AppColor.slateGlow,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$shieldCount',
                                    style: TextStyle(
                                      color: shieldActive
                                          ? AppColor.shieldCyan
                                          : AppColor.slateWhite,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Space Grotesk',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Brief "speed up" flash shown in Chill mode whenever [NightJumpGame.speedLevel]
/// ticks up, giving players a subtle cue that the pace just increased even
/// though obstacles stay confined to the bottom of the screen.
class _SpeedUpCue extends StatefulWidget {
  const _SpeedUpCue({required this.game});

  final NightJumpGame game;

  @override
  State<_SpeedUpCue> createState() => _SpeedUpCueState();
}

class _SpeedUpCueState extends State<_SpeedUpCue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _opacity = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 25),
    TweenSequenceItem(tween: ConstantTween(1), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 45),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  int _lastLevel = 0;

  @override
  void initState() {
    super.initState();
    _lastLevel = widget.game.speedLevel.value;
    widget.game.speedLevel.addListener(_onSpeedLevelChanged);
  }

  void _onSpeedLevelChanged() {
    final level = widget.game.speedLevel.value;
    if (level > _lastLevel &&
        widget.game.difficulty.value == GameDifficulty.chill) {
      _controller.forward(from: 0);
    }
    _lastLevel = level;
  }

  @override
  void dispose() {
    widget.game.speedLevel.removeListener(_onSpeedLevelChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: FadeTransition(
        opacity: _opacity,
        child: Padding(
          padding: const EdgeInsets.only(top: 64),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColor.shieldCyan.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColor.shieldCyan.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.speed_rounded, color: AppColor.shieldCyan, size: 14),
                const SizedBox(width: 6),
                Text(
                  'RITMO EN AUMENTO',
                  style: TextStyle(
                    color: AppColor.shieldCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
