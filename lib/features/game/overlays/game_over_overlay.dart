import 'package:flutter/material.dart';
import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/features/game/state/game_difficulty.dart';
import 'package:night_jump/features/game/state/result_share_service.dart';
import 'package:night_jump/features/themes/page/theme_gallery_page.dart';
import 'package:night_jump/utils/theme/app_color.dart';

class GameOverOverlay extends StatefulWidget {
  const GameOverOverlay({super.key, required this.game});
  final NightJumpGame game;
  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  bool _sharing = false;
  bool _retryingSave = false;
  final _shareKey = GlobalKey();
  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    final game = widget.game;
    try {
      final box = _shareKey.currentContext!.findRenderObject()! as RenderBox;
      await ResultShareService().share(
        score: game.score.value,
        difficulty: game.difficulty.value,
        best: game.highScore.value,
        origin: MatrixUtils.transformRect(
          box.getTransformTo(null),
          Offset.zero & box.size,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo compartir. Inténtalo de nuevo.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final missions = game.resultMissions;
    return ColoredBox(
      color: AppColor.canvasBase.withValues(alpha: 0.95),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'TU VUELO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColor.electricCyan,
                      fontFamily: 'Sora',
                      fontSize: 28,
                    ),
                  ),
                  Text(
                    '${game.difficulty.value.label} • ${game.lossCause}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColor.slateGlow),
                  ),
                  Text(
                    '${game.score.value}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColor.slateWhite,
                      fontFamily: 'Sora',
                      fontSize: 72,
                    ),
                  ),
                  Text(
                    'Récord personal: ${game.highScore.value}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColor.electricCyan,
                      fontSize: 18,
                    ),
                  ),
                  if (game.isNewHighScore.value)
                    const Text(
                      '✦ ¡Nuevo récord!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColor.neonRose),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    '+${game.dustEarnedThisRun.value} Stardust • ${game.flightTime.value.inSeconds} s de vuelo',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColor.slateWhite),
                  ),
                  if (game.persistenceError != null)
                    Text(
                      game.persistenceError!,
                      style: const TextStyle(color: AppColor.error),
                    ),
                  if (game.persistenceError != null)
                    TextButton(
                      onPressed: _retryingSave || _sharing
                          ? null
                          : () async {
                              setState(() => _retryingSave = true);
                              await game.retrySaveResult();
                              if (mounted) {
                                setState(() => _retryingSave = false);
                              }
                            },
                      child: Text(
                        _retryingSave ? 'GUARDANDO…' : 'REINTENTAR GUARDADO',
                      ),
                    ),
                  if (missions != null) ...[
                    const SizedBox(height: 12),
                    for (final m in [
                      ...missions.dailyMissions,
                      ...missions.weeklyMissions,
                    ])
                      Text(
                        '${m.isCompleted ? '✓' : '○'} ${m.title}: ${m.progress}/${m.target}${m.claimed ? ' • recompensa cobrada' : ''}',
                        style: const TextStyle(
                          color: AppColor.slateGlow,
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                  ],
                  if (game.affordableThemes.isNotEmpty)
                    TextButton(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ThemeGalleryPage(
                              themeRepository: game.themeRepository,
                              missionsRepository: game.missionsRepository,
                              settingsRepository: game.settingsRepository,
                            ),
                          ),
                        );
                        await game.refreshTheme();
                        final unlocked = await game.themeRepository
                            .getUnlockedPaletteIds();
                        game.affordableThemes = game.affordableThemes
                            .where((p) => !unlocked.contains(p.id))
                            .toList();
                        if (mounted) setState(() {});
                      },
                      child: Text(
                        'Puedes desbloquear: ${game.affordableThemes.map((p) => p.name).join(', ')}',
                      ),
                    ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _sharing || _retryingSave
                        ? null
                        : game.playAgain,
                    child: const Text('JUGAR OTRA VEZ'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    key: _shareKey,
                    onPressed: _sharing || _retryingSave ? null : _share,
                    child: Text(
                      _sharing ? 'PREPARANDO…' : 'COMPARTIR RESULTADO',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _sharing || _retryingSave
                        ? null
                        : game.returnToMenu,
                    child: const Text('INICIO'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
