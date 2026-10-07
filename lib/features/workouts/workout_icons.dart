import 'package:flutter/material.dart';

/// One outline icon per workout type (spec 4.4). Unknown keys fall back to
/// the generic "other" glyph, so custom types always render.
IconData workoutIcon(String iconKey) => switch (iconKey) {
  'yoga' => Icons.self_improvement_rounded,
  'zumba' => Icons.music_note_rounded,
  'walk' => Icons.directions_walk_rounded,
  'run' => Icons.directions_run_rounded,
  'weights' => Icons.fitness_center_rounded,
  'legs' => Icons.directions_bike_rounded,
  'arms' => Icons.sports_gymnastics_rounded,
  'chest' => Icons.sports_martial_arts_rounded,
  'back' => Icons.accessibility_new_rounded,
  'stability' => Icons.balance_rounded,
  'flexibility' => Icons.sports_handball_rounded,
  _ => Icons.more_horiz_rounded,
};
