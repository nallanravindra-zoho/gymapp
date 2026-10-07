import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/local_date.dart';

void main() {
  test('applies the UTC offset', () {
    // 23:30 UTC is already the next day in UTC+2.
    final t = DateTime.utc(2026, 5, 12, 23, 30);
    expect(localDateOf(t, offsetMinutes: 0), '2026-05-12');
    expect(localDateOf(t, offsetMinutes: 120), '2026-05-13');
    expect(localDateOf(t, offsetMinutes: -300), '2026-05-12');
  });

  test('day cutoff keeps early-morning activity on the previous day', () {
    final t = DateTime.utc(2026, 5, 13, 1, 30);
    expect(localDateOf(t, offsetMinutes: 0), '2026-05-13');
    expect(localDateOf(t, offsetMinutes: 0, cutoffMinutes: 120), '2026-05-12');
    expect(localDateOf(t, offsetMinutes: 0, cutoffMinutes: 60), '2026-05-13');
  });

  test('crosses month and year boundaries', () {
    final t = DateTime.utc(2026, 12, 31, 23, 0);
    expect(localDateOf(t, offsetMinutes: 60), '2027-01-01');
  });

  test('week starts on Monday', () {
    expect(weekStartOf('2026-05-13'), '2026-05-11'); // Wednesday
    expect(weekStartOf('2026-05-11'), '2026-05-11'); // Monday
    expect(weekStartOf('2026-05-17'), '2026-05-11'); // Sunday
  });

  test('shiftLocalDate handles month ends', () {
    expect(shiftLocalDate('2026-02-28', 1), '2026-03-01');
    expect(shiftLocalDate('2026-03-01', -1), '2026-02-28');
  });
}
