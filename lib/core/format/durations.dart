/// Compact durations as in the reference screens: `32 min`, `7h 20m`, `4h`.
String durationShort(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '$m min';
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}

/// Even tighter for table columns: `1h 32m`, `56m`, `4h`.
String durationCompact(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '${m}m';
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}
