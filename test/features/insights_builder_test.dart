import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/core/time/local_date.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/repositories/habit_repository.dart';
import 'package:wellbeing/data/repositories/screen_time_repository.dart';
import 'package:wellbeing/data/repositories/sleep_repository.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/repositories/workout_repository.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/features/insights/insight_builder.dart';
import 'package:wellbeing/features/insights/insight_rules.dart';

// Today is Wed 2026-05-13, so last week is Mon 2026-05-04 .. Sun 2026-05-10.
const today = '2026-05-13';
const lastWeek = '2026-05-04';

void main() {
  late AppDatabase db;
  late String userId;
  final clock = FixedClock(DateTime.utc(2026, 5, 13, 10));

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    userId = (await UserRepository(db, clock).ensureUser()).id;
  });
  tearDown(() => db.close());

  Future<void> workout(
    String date, {
    String type = 'builtin-yoga',
    int min = 30,
  }) {
    final d = parseLocalDate(date);
    return WorkoutRepository(db, clock)
        .add(
          userId: userId,
          dayCutoffMinutes: 0,
          workoutTypeId: type,
          startedAt: DateTime.utc(d.year, d.month, d.day, 8),
          endedAt: DateTime.utc(d.year, d.month, d.day, 8, min),
          source: WorkoutSource.manual,
        )
        .then((_) {});
  }

  Future<InsightInput> build({String week = lastWeek}) async {
    return buildInsightInput(
      weekStart: week,
      today: today,
      workouts: await WorkoutRepository(db, clock).allLive(userId),
      restDates: {
        for (final r in await db.select(db.restDays).get()) r.localDate,
      },
      habits: await (db.select(
        db.habits,
      )..where((h) => h.deletedAt.isNull())).get(),
      habitLogs: await db.select(db.habitLogs).get(),
      sleepLogs: await db.select(db.sleepLogs).get(),
      targetBedtimeMinutes: 22 * 60 + 30,
      targetWakeMinutes: 6 * 60 + 30,
      screenTime: await db.select(db.screenTimeDaily).get(),
    );
  }

  test('last week is complete; this week is not', () async {
    expect((await build()).complete, isTrue);
    final cur = await build(week: '2026-05-11');
    expect(cur.complete, isFalse);
    expect(cur.periodLabel, 'this week');
    expect(cur.lastClosedDay, '2026-05-12'); // yesterday
  });

  test('workout and rest dates come through', () async {
    await workout('2026-05-05');
    await workout('2026-05-05');
    final input = await build();
    expect(input.workoutDates, {'2026-05-05'});
  });

  test(
    'water and stretch completion are measured against each target',
    () async {
      final h = HabitRepository(db, clock);
      final water = await h.create(
        userId: userId,
        name: 'Water',
        kind: HabitKind.water,
        dailyTarget: 4,
      );
      final stretch = await h.create(
        userId: userId,
        name: 'Stretch',
        kind: HabitKind.stretch,
        dailyTarget: 2,
      );
      Future<void> log(String id, String date, int n) async {
        final d = parseLocalDate(date);
        await h.log(
          habit: (await h.byId(id))!,
          dayCutoffMinutes: 0,
          count: n,
          at: DateTime.utc(d.year, d.month, d.day, 9),
        );
      }

      await log(water, '2026-05-04', 4); // met
      await log(water, '2026-05-05', 3); // not met
      await log(stretch, '2026-05-04', 2); // 100%
      await log(stretch, '2026-05-05', 1); // 50%

      final input = await build();
      expect(input.hasWater, isTrue);
      expect(input.waterMet['2026-05-04'], isTrue);
      expect(input.waterMet['2026-05-05'], isFalse);
      expect(input.waterMet['2026-05-06'], isFalse); // nothing logged
      expect(input.hasStretch, isTrue);
      expect(input.stretchCompletion['2026-05-04'], 1.0);
      expect(input.stretchCompletion['2026-05-05'], 0.5);
      expect(input.stretchCompletion['2026-05-06'], 0.0);
    },
  );

  test('no water or stretch habit means those rules stay off', () async {
    final input = await build();
    expect(input.hasWater, isFalse);
    expect(input.hasStretch, isFalse);
  });

  test('sleep is scored for the week and the week before', () async {
    final s = SleepRepository(db, clock);
    Future<void> night(String wakeDate, int bedH, int bedM) {
      final w = parseLocalDate(wakeDate);
      return s
          .log(
            userId: userId,
            dayCutoffMinutes: 0,
            bedtimeAt: DateTime.utc(w.year, w.month, w.day - 1, bedH, bedM),
            wakeAt: DateTime.utc(w.year, w.month, w.day, 6, 30),
          )
          .then((_) {});
    }

    await night('2026-05-05', 22, 30); // on schedule, last week
    await night('2026-05-06', 22, 40); // on schedule
    await night('2026-05-07', 1, 0); // late
    await night('2026-04-29', 22, 30); // on schedule, the week before

    final input = await build();
    expect(input.sleep!.matched, 2);
    expect(input.sleep!.logged, 3);
    expect(input.sleep!.days, 7);
    expect(input.prevSleep!.matched, 1);
    expect(input.prevSleep!.logged, 1);
  });

  test(
    'evening screen time is paired with the bedtime that followed',
    () async {
      final st = ScreenTimeRepository(db, clock);
      final sl = SleepRepository(db, clock);
      // Evening of the 5th: 90 late minutes, bed at 23:30 (330 after 18:00).
      await st.upsertDay(
        userId: userId,
        localDate: '2026-05-05',
        totalMinutes: 240,
        lateEveningMinutes: 90,
      );
      await sl.log(
        userId: userId,
        dayCutoffMinutes: 0,
        bedtimeAt: DateTime.utc(2026, 5, 5, 23, 30),
        wakeAt: DateTime.utc(2026, 5, 6, 7, 0),
      );
      // A day with screen time but no sleep log pairs with nothing.
      await st.upsertDay(
        userId: userId,
        localDate: '2026-05-06',
        totalMinutes: 100,
        lateEveningMinutes: 20,
      );

      final input = await build();
      expect(input.latePairs.length, 1);
      expect(input.latePairs.single.lateMinutes, 90);
      expect(input.latePairs.single.bedtimeOffset, 330);
    },
  );

  test('a bedtime after midnight is measured from 18:00', () async {
    final st = ScreenTimeRepository(db, clock);
    await st.upsertDay(
      userId: userId,
      localDate: '2026-05-05',
      totalMinutes: 200,
      lateEveningMinutes: 60,
    );
    await SleepRepository(db, clock).log(
      userId: userId,
      dayCutoffMinutes: 0,
      bedtimeAt: DateTime.utc(2026, 5, 6, 0, 30),
      wakeAt: DateTime.utc(2026, 5, 6, 8, 0),
    );
    final input = await build();
    expect(
      input.latePairs.single.bedtimeOffset,
      390,
    ); // 00:30 = 6.5 h after 18:00
  });

  group('recap', () {
    Future<List<Workout>> all() => WorkoutRepository(db, clock).allLive(userId);

    test('counts only the chosen week', () async {
      await workout('2026-05-03'); // Sunday before
      await workout('2026-05-04', min: 45);
      await workout('2026-05-05', min: 15);
      await workout('2026-05-11'); // Monday after
      final r = computeRecap(
        weekStart: lastWeek,
        workouts: await all(),
        longestStreak: 9,
      );
      expect(r.activeDays, 2);
      expect(r.totalMinutes, 60);
      expect(r.longestStreak, 9);
      expect(r.isEmpty, isFalse);
    });

    test('the top workout is the most frequent, then the longest', () async {
      await workout('2026-05-04', type: 'builtin-run', min: 20);
      await workout('2026-05-05', type: 'builtin-run', min: 20);
      await workout('2026-05-06', type: 'builtin-yoga', min: 90);
      expect(
        computeRecap(
          weekStart: lastWeek,
          workouts: await all(),
          longestStreak: 0,
        ).topTypeId,
        'builtin-run',
      );

      await workout('2026-05-07', type: 'builtin-yoga', min: 10);
      // Two each now: yoga has more minutes.
      expect(
        computeRecap(
          weekStart: lastWeek,
          workouts: await all(),
          longestStreak: 0,
        ).topTypeId,
        'builtin-yoga',
      );
    });

    test('an empty week', () async {
      final r = computeRecap(
        weekStart: lastWeek,
        workouts: [],
        longestStreak: 0,
      );
      expect(r.isEmpty, isTrue);
      expect(r.topTypeId, isNull);
    });
  });

  test('the whole flow produces sensible insights from stored data', () async {
    // Last week: 4 active days; the week before: 3.
    for (final d in ['2026-05-04', '2026-05-05', '2026-05-06', '2026-05-10']) {
      await workout(d);
    }
    for (final d in ['2026-04-27', '2026-04-28', '2026-04-29']) {
      await workout(d);
    }
    final insights = computeInsights(await build());
    expect(insights.map((i) => insightText(i)), [
      '4 active days last week, up from 3.',
      'Longest gap: 3 days (Thu to Sat).',
    ]);
  });
}
