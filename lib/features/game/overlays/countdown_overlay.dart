import 'package:flutter/material.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/utils/theme/app_color.dart';

/// Animated 3 → 2 → 1 → ¡GO! countdown displayed over the HUD before
/// [NightJumpGame.beginPlaying] is called.
class CountdownOverlay extends StatefulWidget {
  const CountdownOverlay({super.key, required this.game});

  final NightJumpGame game;

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  // Steps: 3, 2, 1, GO (index 3)
  static const _steps = ['3', '2', '1', '¡GO!'];
  // Duration per step
  static const _stepDuration = Duration(milliseconds: 850);

  int _stepIndex = 0;
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery (and any inherited widget) must not be read in
    // initState; this runs after initState and before the first build.
    if (_ready) return;
    _ready = true;

    // Calm entrance: small fade + settle, no overshoot. With reduced
    // motion the steps complete instantly so the wait disappears too.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    _controller = AnimationController(
      vsync: this,
      duration: reduceMotion ? Duration.zero : _stepDuration,
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.85,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 60,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40),
    ]).animate(_controller);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 45),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ]).animate(_controller);

    _controller.addStatusListener(_onStepComplete);
    _controller.forward();
  }

  void _onStepComplete(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;

    if (_stepIndex < _steps.length - 1) {
      setState(() => _stepIndex++);
      _controller.forward(from: 0);
    } else {
      // Last step (GO!) finished — start the real game.
      widget.game.beginPlaying();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStepComplete);
    _controller.dispose();
    super.dispose();
  }

  bool get _isGo => _stepIndex == _steps.length - 1;

  @override
  Widget build(BuildContext context) {
    final color = _isGo ? AppColor.electricCyan : AppColor.slateWhite;
    final glowColor = _isGo ? AppColor.electricCyan : AppColor.intenseMagenta;
    final fontSize = _isGo ? 72.0 : 96.0;

    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Text(
                  _steps[_stepIndex],
                  style: TextStyle(
                    color: color,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Sora',
                    shadows: [
                      Shadow(
                        color: glowColor.withValues(alpha: 0.5),
                        blurRadius: 24,
                      ),
                      Shadow(
                        color: glowColor.withValues(alpha: 0.25),
                        blurRadius: 48,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
