import '../../core/time/local_date.dart';

/// `Good morning`, `Good afternoon` or `Good evening` for a local hour (0-23).
String greetingForHour(int hour) {
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

/// Short, calm taglines for the Today header. No exclamation marks, no
/// pressure (spec 4.5).
const taglines = [
  'Small steps. Big difference.',
  'Move a little. Rest well.',
  'Progress, not perfection.',
  'Start where you are.',
  'Healthy habits power your day.',
  'Be kind to your body today.',
  'Little things add up.',
  'Breathe. Stretch. Sip some water.',
  'One tap to log, one glance to understand.',
  'A calm day is a good day.',
];

/// One tagline per local day: it changes each day and stays put within one.
String taglineFor(String localDate) {
  final d = parseLocalDate(localDate);
  final dayOfYear = d.difference(DateTime.utc(d.year)).inDays;
  return taglines[(dayOfYear + d.year) % taglines.length];
}
