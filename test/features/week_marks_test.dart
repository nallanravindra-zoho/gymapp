import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/features/week/week_marks.dart';

final _t = DateTime.utc(2026, 5, 1);

// Mon 11 May to Sun 17 May 2026.
const dates = [
  '2026-05-11',
  '2026-05-12',
  '2026-05-13',
  '2026-05-14',
  '2026-05-15',
  '2026-05-16',
  '2026-05-17',
];

Workout workout(String id, String date, int hour) => Workout(
  id: id,
  createdAt: _t,
  updatedAt: _t,
  deletedAt: null,
  userId: 'u',
  workoutTypeId: 'builtin-yoga',
  startedAt: DateTime.utc(2026, 5, 11, hour),
  endedAt: DateTime.utc(2026, 5, 11, hour, 30),
  durationMinutes: 30,
  intensity: null,
  note: null,
  source: WorkoutSource.manual,
  tzOffsetMinutes: 0,
  localDate: date,
  pausedSeconds: 0,
);

Habit habit(String id, {int target = 1}) => Habit(
  id: id,
  createdAt: _t,
  updatedAt: _t,
  deletedAt: null,
  userId: 'u',
  name: id,
  kind: HabitKind.custom,
  dailyTarget: target,
  remindersEnabled: false,
  reminderConfig: '{}',
  isActive: true,
);

HabitLog habitLog(String habitId, String date, {int count = 1}) => HabitLog(
  id: '$habitId-$date-$count-${_n++}',
  createdAt: _t,
  updatedAt: _t,
  deletedAt: null,
  habitId: habitId,
  userId: 'u',
  loggedAt: _t,
  count: count,
  tzOffsetMinutes: 0,
  localDate: date,
);

int _n = 0;

SleepLog sleep(String date, int minutes) => SleepLog(
  id: 'sleep-$date',
  createdAt: _t,
  updatedAt: _t,
  deletedAt: null,
  userId: 'u',
  bedtimeAt: _t,
  wakeAt: _t.add(Duration(minutes: minutes)),
  durationMinutes: minutes,
  tzOffsetMinutes: 0,
  localDate: date,
);

ScreenTimeDailyData screen(String date, int minutes) => ScreenTimeDailyData(
  id: 'screen-$date',
  createdAt: _t,
  updatedAt: _t,
  deletedAt: null,
  userId: 'u',
  localDate: date,
  totalMinutes: minutes,
  categoryMinutes: '{}',
  lateEveningMinutes: 0,
  shareInGroups: false,
  source: ScreenTimeSource.automatic,
);

Map<String, DayMarks> build({
  List<Workout> workouts = const [],
  Set<String> restDays = const {},
  List<Habit> habits = const [],
  List<HabitLog> habitLogs = const [],
  int habitThreshold = 1,
  Set<String> hobbyDates = const {},
  List<SleepLog> sleepLogs = const [],
  int sleepTarget = 480,
  List<ScreenTimeDailyData> screenRows = const [],
  int? screenGoal = 180,
}) => buildWeekMarks(
  dates: dates,
  workouts: workouts,
  restDays: restDays,
  habits: habits,
  habitLogs: habitLogs,
  habitThreshold: habitThreshold,
  hobbyDates: hobbyDates,
  sleepLogs: sleepLogs,
  sleepTargetMinutes: sleepTarget,
  screenRows: screenRows,
  screenGoalMinutes: screenGoal,
);

void main() {
  test('an empty week has seven days and no marks', () {
    final m = build();
    expect(m.keys.toList(), dates);
    for (final d in m.values) {
      expect(d.hasAny, isFalse);
      expect(d.count, 0);
      expect(d.rest, isFalse);
    }
  });

  group('workouts', () {
    test('are grouped by day, oldest first', () {
      final m = build(
        workouts: [
          workout('late', '2026-05-13', 18),
          workout('early', '2026-05-13', 7),
          workout('other', '2026-05-15', 9),
          workout('outside', '2026-05-25', 9),
        ],
      );
      expect(m['2026-05-13']!.workouts.map((w) => w.id), ['early', 'late']);
      expect(m['2026-05-15']!.workouts.map((w) => w.id), ['other']);
      expect(m['2026-05-12']!.workouts, isEmpty);
      expect(m.containsKey('2026-05-25'), isFalse);
    });

    test('two workouts in a day still count as one category', () {
      final m = build(
        workouts: [
          workout('a', '2026-05-13', 7),
          workout('b', '2026-05-13', 18),
        ],
      );
      expect(m['2026-05-13']!.count, 1);
      expect(m['2026-05-13']!.hasAny, isTrue);
    });
  });

  group('habits', () {
    test('are marked once any active habit reaches its target', () {
      final m = build(
        habits: [habit('water', target: 3), habit('stretch')],
        habitLogs: [
          habitLog('water', '2026-05-11', count: 2),
          habitLog('stretch', '2026-05-12'),
        ],
      );
      expect(m['2026-05-11']!.habits, isFalse, reason: '2 of 3 glasses');
      expect(m['2026-05-12']!.habits, isTrue);
      expect(m['2026-05-13']!.habits, isFalse);
    });

    test('several logs on a day add up towards the target', () {
      final m = build(
        habits: [habit('water', target: 3)],
        habitLogs: [
          habitLog('water', '2026-05-11'),
          habitLog('water', '2026-05-11'),
          habitLog('water', '2026-05-11'),
        ],
      );
      expect(m['2026-05-11']!.habits, isTrue);
    });

    test('logs for a habit that is not active are ignored', () {
      final m = build(
        habits: [habit('water')],
        habitLogs: [habitLog('gone', '2026-05-11')],
      );
      expect(m['2026-05-11']!.habits, isFalse);
    });

    test('no habits means no mark', () {
      final m = build(habitLogs: [habitLog('water', '2026-05-11')]);
      expect(m['2026-05-11']!.habits, isFalse);
    });
  });

  group('sleep', () {
    test('is marked only when the target is met', () {
      final m = build(
        sleepLogs: [
          sleep('2026-05-12', 479),
          sleep('2026-05-13', 480),
          sleep('2026-05-14', 600),
        ],
      );
      expect(m['2026-05-12']!.sleep, isFalse);
      expect(m['2026-05-13']!.sleep, isTrue);
      expect(m['2026-05-14']!.sleep, isTrue);
      expect(m['2026-05-15']!.sleep, isFalse);
    });
  });

  group('screen time', () {
    test('is marked at or under the goal, not over', () {
      final m = build(
        screenRows: [
          screen('2026-05-11', 120),
          screen('2026-05-12', 180),
          screen('2026-05-13', 181),
        ],
      );
      expect(m['2026-05-11']!.screen, isTrue);
      expect(m['2026-05-12']!.screen, isTrue);
      expect(m['2026-05-13']!.screen, isFalse);
      expect(m['2026-05-14']!.screen, isFalse, reason: 'no data is not a win');
    });

    test('without a goal nothing is marked', () {
      final m = build(screenRows: [screen('2026-05-11', 10)], screenGoal: null);
      expect(m['2026-05-11']!.screen, isFalse);
    });
  });

  test('rest days are flagged but are not an achievement', () {
    final m = build(restDays: {'2026-05-16'});
    expect(m['2026-05-16']!.rest, isTrue);
    expect(m['2026-05-16']!.hasAny, isFalse);
    expect(m['2026-05-16']!.count, 0);
    expect(m['2026-05-15']!.rest, isFalse);
  });

  test('a day with everything done counts five categories', () {
    final m = build(
      workouts: [workout('a', '2026-05-13', 7)],
      habits: [habit('water')],
      habitLogs: [habitLog('water', '2026-05-13')],
      hobbyDates: {'2026-05-13'},
      sleepLogs: [sleep('2026-05-13', 500)],
      screenRows: [screen('2026-05-13', 90)],
    );
    expect(m['2026-05-13']!.count, 5);
    expect(m['2026-05-13']!.categories, MarkCategory.values);
    expect(m['2026-05-12']!.count, 0);
  });

  group('habit threshold', () {
    final habits = [habit('water'), habit('stretch'), habit('walk')];
    test('default of one habit', () {
      final m = build(
        habits: habits,
        habitLogs: [habitLog('water', '2026-05-11')],
      );
      expect(m['2026-05-11']!.habits, isTrue);
    });

    test('two needed: one is not enough, two is', () {
      final m = build(
        habits: habits,
        habitThreshold: 2,
        habitLogs: [
          habitLog('water', '2026-05-11'),
          habitLog('water', '2026-05-12'),
          habitLog('stretch', '2026-05-12'),
        ],
      );
      expect(m['2026-05-11']!.habits, isFalse);
      expect(m['2026-05-12']!.habits, isTrue);
    });

    test('a threshold above the number of habits asks for all of them', () {
      final two = [habit('water'), habit('stretch')];
      final m = build(
        habits: two,
        habitThreshold: 5,
        habitLogs: [
          habitLog('water', '2026-05-11'),
          habitLog('water', '2026-05-12'),
          habitLog('stretch', '2026-05-12'),
        ],
      );
      expect(m['2026-05-11']!.habits, isFalse);
      expect(m['2026-05-12']!.habits, isTrue);
    });

    test('a zero or negative threshold still needs one habit', () {
      expect(habitsMarkMet(habits: habits, counts: {}, threshold: 0), isFalse);
      expect(
        habitsMarkMet(habits: habits, counts: {'water': 1}, threshold: -3),
        isTrue,
      );
    });
  });

  group('hobbies', () {
    test('show only on days with a daily goal met', () {
      final m = build(hobbyDates: {'2026-05-12'});
      expect(m['2026-05-12']!.hobbies, isTrue);
      expect(m['2026-05-11']!.hobbies, isFalse);
      expect(m['2026-05-12']!.categories, [MarkCategory.hobbies]);
    });

    test('no hobby days means no hobby marks anywhere', () {
      expect(build().values.any((d) => d.hobbies), isFalse);
    });
  });

  group('screen time target', () {
    test('uses only the current target; a recorded one does not override', () {
      final row = screen('2026-05-11', 200);
      expect(screenMarkMet(row, 240), isTrue);
      expect(screenMarkMet(row, 120), isFalse);
      expect(screenMarkMet(row, null), isFalse);
      expect(screenMarkMet(null, 240), isFalse);
    });
  });

  group('sleep date', () {
    test('counts on the wake date only', () {
      final m = build(sleepLogs: [sleep('2026-05-13', 500)]);
      expect(m['2026-05-12']!.sleep, isFalse);
      expect(m['2026-05-13']!.sleep, isTrue);
    });
  });

  group('limitMarks', () {
    const all = MarkCategory.values;
    test('shows everything up to the maximum', () {
      final v = limitMarks(all.take(3).toList());
      expect(v.shown, all.take(3));
      expect(v.overflow, 0);
    });
    test('adds +N past the maximum', () {
      final v = limitMarks(all);
      expect(v.shown, all.take(maxVisibleMarks));
      expect(v.overflow, all.length - maxVisibleMarks);
    });
    test('nothing is nothing', () {
      final v = limitMarks(const []);
      expect(v.shown, isEmpty);
      expect(v.overflow, 0);
    });
    test('respects a custom maximum', () {
      final v = limitMarks(all, max: 1);
      expect(v.shown, [MarkCategory.workout]);
      expect(v.overflow, 4);
    });
  });
}
