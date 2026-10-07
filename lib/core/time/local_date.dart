/// Local-day derivation (spec 7.1).
///
/// A row's `local_date` is computed once at write time from the instant (UTC),
/// the user's UTC offset at that moment, and the day cutoff. It is stored, so
/// history does not shift if the user later changes timezone.
///
/// `cutoffMinutes` moves the start of the day later: with a cutoff of 120,
/// 01:30 local still belongs to the previous day.
String localDateOf(
  DateTime instant, {
  required int offsetMinutes,
  int cutoffMinutes = 0,
}) {
  final shifted = instant.toUtc().add(
    Duration(minutes: offsetMinutes - cutoffMinutes),
  );
  return formatLocalDate(shifted.year, shifted.month, shifted.day);
}

String formatLocalDate(int year, int month, int day) =>
    '${year.toString().padLeft(4, '0')}-'
    '${month.toString().padLeft(2, '0')}-'
    '${day.toString().padLeft(2, '0')}';

/// Parses a stored `YYYY-MM-DD` string into a calendar date (UTC midnight, so
/// day arithmetic is never affected by DST).
DateTime parseLocalDate(String s) {
  final p = s.split('-');
  return DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

String shiftLocalDate(String s, int days) {
  final d = parseLocalDate(s).add(Duration(days: days));
  return formatLocalDate(d.year, d.month, d.day);
}

/// Monday of the Mon-Sun week containing [localDate].
String weekStartOf(String localDate) {
  final d = parseLocalDate(localDate);
  return shiftLocalDate(localDate, -(d.weekday - DateTime.monday));
}
