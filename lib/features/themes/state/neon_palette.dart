import 'package:flutter/material.dart';

import 'package:night_jump/utils/theme/app_color.dart';

/// A selectable color scheme for the orb / HUD glow. [cost] is in
/// stardust; a palette with cost 0 is available from the start.
class NeonPalette {
  const NeonPalette({
    required this.id,
    required this.name,
    required this.description,
    required this.primary,
    required this.secondary,
    this.cost = 0,
  });

  final String id;
  final String name;
  final String description;
  final Color primary;
  final Color secondary;
  final int cost;

  bool get isFree => cost == 0;

  static const catalog = [
    NeonPalette(
      id: 'default',
      name: 'Default',
      description: 'Cian Eléctrico & Magenta Neón',
      primary: AppColor.electricCyan,
      secondary: AppColor.intenseMagenta,
    ),
    NeonPalette(
      id: 'cyberpunk',
      name: 'Cyberpunk',
      description: 'Amarillo Eléctrico & Violeta Neón',
      primary: Color(0xFFF5D90A),
      secondary: Color(0xFF9D4EDD),
    ),
    NeonPalette(
      id: 'aurora',
      name: 'Aurora Boreal',
      description: 'Verde Esmeralda & Turquesa',
      primary: Color(0xFF2DE1A5),
      secondary: Color(0xFF00DBE9),
      cost: 800,
    ),
    NeonPalette(
      id: 'eclipse',
      name: 'Eclipse Total',
      description: 'Rojo Carmesí & Naranja Ígneo',
      primary: Color(0xFFFF3B3B),
      secondary: Color(0xFFFF7A1A),
      cost: 1200,
    ),
  ];

  static NeonPalette byId(String id) =>
      catalog.firstWhere((p) => p.id == id, orElse: () => catalog.first);
}
