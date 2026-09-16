import 'package:flutter/material.dart';

import 'package:night_jump/features/game/night_jump_game.dart';
import 'package:night_jump/utils/responsive/responsive_extension.dart';
import 'package:night_jump/utils/theme/app_color.dart';

/// Opens the "Ajustes" screen as a modal bottom sheet.
Future<void> showSettingsSheet(BuildContext context, NightJumpGame game) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SettingsSheet(game: game),
  );
}

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key, required this.game});

  final NightJumpGame game;

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.responsive(mobile: double.infinity, tablet: 480.0);
    final horizontalPadding = context.responsive(mobile: 20.0, tablet: 28.0);

    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.canvasMidnight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: AppColor.electricCyan.withValues(alpha: 0.15),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColor.slateGlow.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColor.electricCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.settings_rounded,
                          color: AppColor.electricCyan,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'AJUSTES',
                          style: TextStyle(
                            color: AppColor.onSurface,
                            fontSize: context.responsive(
                              mobile: 16.0,
                              tablet: 18.0,
                            ),
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Sora',
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColor.slateWhite,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<bool>(
                    valueListenable: game.soundEnabled,
                    builder: (context, enabled, _) => _SettingToggle(
                      icon: enabled
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      title: 'Sonido',
                      subtitle: 'Música y efectos del juego',
                      value: enabled,
                      onChanged: (_) => game.toggleSound(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<bool>(
                    valueListenable: game.hapticsEnabled,
                    builder: (context, enabled, _) => _SettingToggle(
                      icon: Icons.vibration_rounded,
                      title: 'Vibración',
                      subtitle: 'Feedback táctil al saltar',
                      value: enabled,
                      onChanged: (_) => game.toggleHaptics(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _ResetProgressTile(game: game),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingToggle extends StatelessWidget {
  const _SettingToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.hudGlass.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColor.slateWhite, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColor.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColor.slateGlow,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColor.electricCyan,
          ),
        ],
      ),
    );
  }
}

class _ResetProgressTile extends StatelessWidget {
  const _ResetProgressTile({required this.game});

  final NightJumpGame game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _confirmReset(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColor.neonRose.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColor.neonRose.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, color: AppColor.neonRose, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restablecer progreso',
                      style: TextStyle(
                        color: AppColor.neonRose,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                    Text(
                      'Borra récord, retos, polvo astral y temas',
                      style: TextStyle(
                        color: AppColor.slateGlow,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.canvasMidnight,
        title: Text(
          '¿Restablecer progreso?',
          style: TextStyle(color: AppColor.onSurface, fontFamily: 'Sora'),
        ),
        content: Text(
          'Esta acción borrará tu récord, retos, polvo astral y temas desbloqueados. No se puede deshacer.',
          style: TextStyle(color: AppColor.slateGlow, fontFamily: 'Space Grotesk'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar', style: TextStyle(color: AppColor.slateGlow)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Restablecer',
              style: TextStyle(color: AppColor.neonRose, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await game.resetProgress();
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}
