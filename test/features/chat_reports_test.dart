import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/features/chat/chat_reports.dart';

void main() {
  group('screenTimeChangePercent', () {
    test('is the rounded change against last week', () {
      expect(screenTimeChangePercent(780, 1000), -22);
      expect(screenTimeChangePercent(1050, 1000), 5);
      expect(screenTimeChangePercent(1000, 1000), 0);
      expect(screenTimeChangePercent(2000, 1000), 100);
    });

    test('rounds to the nearest whole percent', () {
      expect(screenTimeChangePercent(1004, 1000), 0);
      expect(screenTimeChangePercent(1006, 1000), 1);
      expect(screenTimeChangePercent(994, 1000), -1);
    });

    test('is null when either week has no data', () {
      expect(screenTimeChangePercent(0, 500), isNull);
      expect(screenTimeChangePercent(500, 0), isNull);
      expect(screenTimeChangePercent(0, 0), isNull);
    });
  });

  group('screenTimeTrendText', () {
    test('describes a drop, a rise and no change in neutral words', () {
      expect(screenTimeTrendText(-22), 'Down by 22% from last week');
      expect(screenTimeTrendText(5), 'Up by 5% from last week');
      expect(screenTimeTrendText(0), 'Same as last week');
    });

    test('says so plainly when there is not enough data', () {
      expect(screenTimeTrendText(null), 'Not enough data yet');
    });

    test('never uses exclamation marks', () {
      for (final p in [null, -50, -1, 0, 1, 50]) {
        expect(screenTimeTrendText(p), isNot(contains('!')));
      }
    });

    test('works end to end with the percentage', () {
      expect(
        screenTimeTrendText(screenTimeChangePercent(390, 500)),
        'Down by 22% from last week',
      );
    });
  });
}
