import 'package:flutter/material.dart';

import 'package:night_jump/features/missions/state/missions_repository.dart';
import 'package:night_jump/features/themes/state/neon_palette.dart';
import 'package:night_jump/features/themes/state/theme_repository.dart';
import 'package:night_jump/features/themes/widgets/palette_card.dart';
import 'package:night_jump/features/themes/widgets/palette_preview_orb.dart';
import 'package:night_jump/utils/responsive/responsive_extension.dart';
import 'package:night_jump/utils/theme/app_color.dart';

class ThemeGalleryPage extends StatefulWidget {
  const ThemeGalleryPage({
    super.key,
    required this.themeRepository,
    required this.missionsRepository,
  });

  final ThemeRepository themeRepository;
  final MissionsRepository missionsRepository;

  @override
  State<ThemeGalleryPage> createState() => _ThemeGalleryPageState();
}

class _ThemeGalleryPageState extends State<ThemeGalleryPage> {
  String? _confirmedPaletteId;
  late String _previewPaletteId;
  Set<String> _unlockedIds = {};
  int _stardust = 0;
  bool _comfortMode = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final selected = await widget.themeRepository.getSelectedPaletteId();
    final unlocked = await widget.themeRepository.getUnlockedPaletteIds();
    final stardust = await widget.missionsRepository.getStardust();
    setState(() {
      _confirmedPaletteId = selected;
      _previewPaletteId = selected;
      _unlockedIds = unlocked;
      _stardust = stardust;
      _loading = false;
    });
  }

  Future<void> _onPaletteTap(NeonPalette palette) async {
    if (_unlockedIds.contains(palette.id)) {
      setState(() => _previewPaletteId = palette.id);
      return;
    }

    final unlocked = await _tryUnlock(palette);
    if (unlocked) {
      setState(() {
        _unlockedIds = {..._unlockedIds, palette.id};
        _previewPaletteId = palette.id;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Necesitas ${palette.cost} de polvo astral')),
      );
    }
  }

  Future<bool> _tryUnlock(NeonPalette palette) async {
    final success = await widget.missionsRepository.spendStardust(palette.cost);
    if (!success) return false;
    await widget.themeRepository.unlockPalette(palette.id);
    setState(() => _stardust -= palette.cost);
    return true;
  }

  Future<void> _confirm() async {
    await widget.themeRepository.selectPalette(_previewPaletteId);
    setState(() => _confirmedPaletteId = _previewPaletteId);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColor.canvasBase,
        body: Center(
          child: CircularProgressIndicator(color: AppColor.electricCyan),
        ),
      );
    }

    final previewPalette = NeonPalette.byId(_previewPaletteId);
    final hasChanges = _previewPaletteId != _confirmedPaletteId;
    final maxWidth = context.responsive(mobile: double.infinity, tablet: 480.0);
    final horizontalPadding = context.responsive(mobile: 20.0, tablet: 28.0);
    final previewOrbSize = context.responsive(mobile: 200.0, tablet: 240.0);

    return Scaffold(
      backgroundColor: AppColor.canvasBase,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.canvasBase,
              AppColor.canvasMidnight,
              AppColor.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(stardust: _stardust),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: AppColor.hudGlass.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          PalettePreviewOrb(
                            primary: previewPalette.primary,
                            secondary: previewPalette.secondary,
                            dimmed: _comfortMode,
                            size: previewOrbSize,
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${previewPalette.name.toUpperCase()} NEÓN',
                                style: TextStyle(
                                  color: AppColor.slateGlow,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.1,
                                  fontFamily: 'Space Grotesk',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ComfortToggle(
                      value: _comfortMode,
                      onChanged: (value) =>
                          setState(() => _comfortMode = value),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'COLECCIÓN DE ESPECTROS',
                          style: TextStyle(
                            color: AppColor.slateGlow,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                            fontFamily: 'Space Grotesk',
                          ),
                        ),
                        Text(
                          '${NeonPalette.catalog.length} Temas',
                          style: TextStyle(
                            color: AppColor.electricCyan,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Space Grotesk',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final palette in NeonPalette.catalog) ...[
                      PaletteCard(
                        palette: palette,
                        isActive: palette.id == _previewPaletteId,
                        isUnlocked: _unlockedIds.contains(palette.id),
                        onTap: () => _onPaletteTap(palette),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 8),
                    _ConfirmButton(enabled: hasChanges, onTap: _confirm),
                    const SizedBox(height: 12),
                    Text(
                      'LOS TEMAS AJUSTAN ARMÓNICAMENTE PLATAFORMAS, '
                      'HUD Y DESTELLOS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColor.slateGlow,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.stardust});

  final int stardust;

  @override
  Widget build(BuildContext context) {
    final titleFontSize = context.responsive(mobile: 22.0, tablet: 26.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back_rounded, color: AppColor.slateWhite),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TEMAS & PALETAS',
                  style: TextStyle(
                    color: AppColor.onSurface,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Sora',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Personaliza tu atmósfera visual sin fatiga',
                  style: TextStyle(
                    color: AppColor.slateGlow,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColor.hudGlass,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: AppColor.electricCyan,
                ),
                const SizedBox(width: 6),
                Text(
                  '$stardust POLVO',
                  style: TextStyle(
                    color: AppColor.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ComfortToggle extends StatelessWidget {
  const _ComfortToggle({required this.value, required this.onChanged});

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
          Icon(Icons.nightlight_round, color: AppColor.slateWhite, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Brillo Nocturno',
                  style: TextStyle(
                    color: AppColor.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
                Text(
                  'Modo confort (suave)',
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

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? AppColor.electricCyan
        : AppColor.electricCyan.withValues(alpha: 0.3);

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColor.electricCyan.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.palette_rounded, color: AppColor.canvasBase, size: 20),
              const SizedBox(width: 10),
              Text(
                'CONFIRMAR PALETA',
                style: TextStyle(
                  color: AppColor.canvasBase,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.1,
                  fontFamily: 'Space Grotesk',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
