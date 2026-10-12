import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/local_date.dart';
import 'package:wellbeing/features/today/today_text.dart';

void main() {
  group('greetingForHour', () {
    test('changes at noon and at five in the afternoon', () {
      expect(greetingForHour(0), 'Good morning');
      expect(greetingForHour(11), 'Good morning');
      expect(greetingForHour(12), 'Good afternoon');
      expect(greetingForHour(16), 'Good afternoon');
      expect(greetingForHour(17), 'Good evening');
      expect(greetingForHour(23), 'Good evening');
    });

    test('every hour of the day has a greeting', () {
      for (var h = 0; h < 24; h++) {
        expect(greetingForHour(h), startsWith('Good '));
      }
    });
  });

  group('taglineFor', () {
    test('is stable within a day and always one of the taglines', () {
      expect(taglineFor('2026-05-13'), taglineFor('2026-05-13'));
      expect(taglines, contains(taglineFor('2026-05-13')));
    });

    test('changes from one day to the next', () {
      var d = '2026-01-01';
      for (var i = 0; i < 400; i++) {
        final next = shiftLocalDate(d, 1);
        expect(taglineFor(next), isNot(taglineFor(d)), reason: '$d -> $next');
        d = next;
      }
    });

    test('cycles through every tagline over ten days', () {
      final seen = {
        for (var i = 0; i < taglines.length; i++)
          taglineFor(shiftLocalDate('2026-05-13', i)),
      };
      expect(seen.length, taglines.length);
    });

    test('handles the leap day and year end', () {
      expect(taglines, contains(taglineFor('2028-02-29')));
      expect(taglines, contains(taglineFor('2026-12-31')));
    });
  });

  test('taglines are calm: no exclamation marks, no duplicates, no blanks', () {
    expect(taglines.any((t) => t.contains('!')), isFalse);
    expect(taglines.toSet().length, taglines.length);
    expect(taglines.every((t) => t.trim().isNotEmpty), isTrue);
  });
}
