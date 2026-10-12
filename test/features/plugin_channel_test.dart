import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/features/reminders/notification_scheduler.dart';
import 'package:wellbeing/features/reminders/plugin_scheduler.dart';
import 'package:wellbeing/features/reminders/reminder_actions.dart';

void main() {
  group('reminder channel per sound', () {
    test('no chosen sound uses the plain channel (phone default)', () {
      expect(channelIdFor(null), 'habit_reminders');
      expect(channelIdFor(''), 'habit_reminders');
    });

    test('a chosen sound gets its own stable channel', () {
      final a = channelIdFor('content://media/internal/audio/media/12');
      final b = channelIdFor('content://media/internal/audio/media/13');
      expect(a, startsWith('habit_reminders_'));
      expect(a, isNot('habit_reminders'));
      expect(a, isNot(b));
      expect(channelIdFor('content://media/internal/audio/media/12'), a);
    });
  });

  test('action ids are Log and Skip only', () {
    expect(logActionId, 'log');
    expect(skipActionId, 'skip');
  });

  test('payload without a snooze count still decodes', () {
    final p = ReminderPayload.decode(
      '{"h":["a"],"n":["A"],"k":["water"],"p":0}',
    );
    expect(p!.habitIds, ['a']);
  });
}
