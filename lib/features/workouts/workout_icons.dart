import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';

/// One icon per workout type (spec 4.4). Unknown keys fall back to the generic
/// "other" glyph, so custom types always render.
IconData workoutIcon(String iconKey) => switch (iconKey) {
  'yoga' => Icons.self_improvement_rounded,
  'zumba' => Icons.sports_handball_rounded,
  'walk' => Icons.directions_walk_rounded,
  'run' => Icons.directions_run_rounded,
  'weights' => Icons.fitness_center_rounded,
  'legs' => Icons.sports_kabaddi_rounded,
  'arms' => Icons.sports_gymnastics_rounded,
  'chest' => Icons.sports_martial_arts_rounded,
  'back' => Icons.accessibility_new_rounded,
  'stability' => Icons.balance_rounded,
  'flexibility' => Icons.spa_rounded,
  'custom' => Icons.add_rounded,
  _ => Icons.more_horiz_rounded,
};

const _light = {
  'yoga': CatColors(Color(0xFFC3EBD0), Color(0xFF1B7A4B)),
  'zumba': CatColors(Color(0xFFFBE0D8), Color(0xFFE4572E)),
  'walk': CatColors(Color(0xFFE4EEF1), Color(0xFF2E78B8)),
  'run': CatColors(Color(0xFFDDEFF0), Color(0xFF2B6CB5)),
  'weights': CatColors(Color(0xFFE5EBF0), Color(0xFF1F3F7A)),
  'legs': CatColors(Color(0xFFECE4F4), Color(0xFF3A3E9E)),
  'arms': CatColors(Color(0xFFF2E3F0), Color(0xFF4A3A99)),
  'chest': CatColors(Color(0xFFF9E1E1), Color(0xFF5C3C8F)),
  'back': CatColors(Color(0xFFEAE3F2), Color(0xFF4D4A9A)),
  'stability': CatColors(Color(0xFFDCEBF3), Color(0xFF1E5E8E)),
  'flexibility': CatColors(Color(0xFFD4E6F6), Color(0xFF2A5C99)),
  'custom': CatColors(Color(0xFFF0EFEA), Color(0xFF3C4F66)),
};

const _dark = {
  'yoga': CatColors(Color(0xFF244A38), Color(0xFF86DDA9)),
  'zumba': CatColors(Color(0xFF4A2B25), Color(0xFFFF8A68)),
  'walk': CatColors(Color(0xFF22363F), Color(0xFF7FB9EA)),
  'run': CatColors(Color(0xFF203A3E), Color(0xFF7DB4EC)),
  'weights': CatColors(Color(0xFF26323F), Color(0xFF8FB0EA)),
  'legs': CatColors(Color(0xFF302A45), Color(0xFFA9ACF2)),
  'arms': CatColors(Color(0xFF3A2B42), Color(0xFFB7A8F0)),
  'chest': CatColors(Color(0xFF442A33), Color(0xFFC9A6EC)),
  'back': CatColors(Color(0xFF332D45), Color(0xFFB5B2F0)),
  'stability': CatColors(Color(0xFF223847), Color(0xFF7DBFEA)),
  'flexibility': CatColors(Color(0xFF223548), Color(0xFF8DB9EE)),
  'custom': CatColors(Color(0xFF2A302E), Color(0xFFB9C6D6)),
};

/// The tint and icon colour for a workout type, so each type looks the same
/// on Today, Week and in the log grid. Custom and unknown types share one.
CatColors workoutColors(BuildContext context, String iconKey) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  final table = dark ? _dark : _light;
  return table[iconKey] ?? table['custom']!;
}
