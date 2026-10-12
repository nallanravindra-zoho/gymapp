/// Approximate energy cost of each built-in workout type (R3).
///
/// Values are metabolic equivalents (MET): multiples of resting energy use.
/// They are rounded and adapted from the Compendium of Physical Activities
/// (Ainsworth BE et al., 2011 Compendium of Physical Activities, and the
/// 2024 update; https://pacompendium.com). The Compendium lists many specific
/// activities and speeds; each type here maps to the closest general entries,
/// with the low, mid and high columns standing for easy, moderate and hard
/// effort. The numbers are for estimating only and are not exact for any
/// one person.
class MetRange {
  const MetRange(this.low, this.mid, this.high);
  final double low;
  final double mid;
  final double high;

  /// Mid is used when no intensity was chosen.
  double forIntensity(String? intensity) => switch (intensity) {
    'low' => low,
    'high' => high,
    _ => mid,
  };
}

/// Keyed by the built-in type's `iconKey`.
const metByTypeKey = <String, MetRange>{
  // Hatha yoga 2.5; power / vinyasa yoga about 4.0.
  'yoga': MetRange(2.0, 2.5, 4.0),
  // Aerobic dance, low to high impact.
  'zumba': MetRange(4.5, 5.5, 7.3),
  // Walking from about 2.8 km/h (2.8 MET) to 5.6 km/h (4.3 to 5.0 MET).
  'walk': MetRange(2.8, 3.5, 4.8),
  // Running from about 8 km/h (8.3 MET) to 11 km/h (11.0 MET).
  'run': MetRange(8.3, 9.8, 11.0),
  // Resistance training: light or moderate effort 3.5, vigorous 6.0.
  'weights': MetRange(3.0, 3.5, 6.0),
  'legs': MetRange(3.0, 3.5, 6.0),
  'arms': MetRange(3.0, 3.5, 6.0),
  'chest': MetRange(3.0, 3.5, 6.0),
  'back': MetRange(3.0, 3.5, 6.0),
  // Pilates / core and balance work.
  'stability': MetRange(2.5, 3.0, 4.0),
  // Stretching, mild: 2.3.
  'flexibility': MetRange(2.0, 2.3, 2.8),
};

/// The MET for a type key and intensity name (`low`, `mid`, `high`), or null
/// when the type has no entry (custom workouts and the retired "Other").
double? metFor(String? iconKey, String? intensity) =>
    metByTypeKey[iconKey]?.forIntensity(intensity);
