import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/format/durations.dart';

void main() {
  group('durationShort', () {
    test('under an hour is minutes', () {
      expect(durationShort(0), '0 min');
      expect(durationShort(5), '5 min');
      expect(durationShort(32), '32 min');
      expect(durationShort(59), '59 min');
    });

    test('whole hours drop the minutes', () {
      expect(durationShort(60), '1h');
      expect(durationShort(240), '4h');
    });

    test('hours with minutes', () {
      expect(durationShort(61), '1h 1m');
      expect(durationShort(440), '7h 20m');
      expect(durationShort(1500), '25h');
    });
  });

  group('durationCompact', () {
    test('under an hour is just minutes', () {
      expect(durationCompact(0), '0m');
      expect(durationCompact(56), '56m');
    });

    test('hours and minutes', () {
      expect(durationCompact(92), '1h 32m');
      expect(durationCompact(120), '2h');
      expect(durationCompact(245), '4h 5m');
    });
  });

  test('both formats agree on the hours and minutes', () {
    for (final m in [0, 1, 59, 60, 61, 119, 120, 600, 1439]) {
      final short = durationShort(m).replaceAll(' min', 'm');
      expect(short, durationCompact(m), reason: '$m minutes');
    }
  });
}
