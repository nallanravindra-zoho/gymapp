// Renders the app's screens to PNG files so they can be compared with the
// reference designs. Not part of the normal test run:
//
//   flutter test tool/screens/render_test.dart
//
// Output goes to build/screens/.
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/repositories/habit_repository.dart';
import 'package:wellbeing/data/repositories/sleep_repository.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/repositories/workout_repository.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/features/screen_time/usage_source.dart';
import 'package:wellbeing/features/habits/habits_screen.dart';
import 'package:wellbeing/features/screen_time/screen_time_screen.dart';
import 'package:wellbeing/features/sleep/sleep_screen.dart';
import 'package:wellbeing/features/week/week_screen.dart';
import 'package:wellbeing/features/workouts/log_workout_screen.dart';
import 'package:wellbeing/features/workouts/timer_screen.dart';
import 'package:wellbeing/features/workouts/workout_timer.dart';

import '../../test/test_helpers.dart';

final _key = GlobalKey();

Future<void> loadFonts() async {
  final loader = FontLoader('PlusJakartaSans');
  for (final f in ['400Regular', '500Medium', '600SemiBold', '700Bold']) {
    loader.addFont(
      Future.value(
        ByteData.sublistView(
          File('assets/fonts/PlusJakartaSans_$f.ttf').readAsBytesSync(),
        ),
      ),
    );
  }
  await loader.load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(
      Future.value(
        ByteData.sublistView(
          File(
            '/opt/sdk/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
          ).readAsBytesSync(),
        ),
      ),
    );
  await icons.load();
}

Widget wrap(Widget app) => RepaintBoundary(key: _key, child: app);

Future<void> shot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary =
        _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1.5);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory('build/screens')..createSync(recursive: true);
    File('${dir.path}/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

/// A person with a few days of history, like the reference screens.
Future<void> seedDemo(AppDatabase db) async {
  final clock = FixedClock(testNow);
  final users = UserRepository(db, clock);
  final user = await users.ensureUser();
  await users.update(
    user.id,
    const UsersCompanion(displayName: Value('Divya')),
  );

  final workouts = WorkoutRepository(db, clock);
  Future<void> workout(String type, int daysAgo, int minutes) => workouts.add(
    userId: user.id,
    dayCutoffMinutes: 0,
    workoutTypeId: type,
    startedAt: testNow.subtract(Duration(days: daysAgo)),
    endedAt: testNow
        .subtract(Duration(days: daysAgo))
        .add(Duration(minutes: minutes)),
    source: WorkoutSource.manual,
  );
  await workout('builtin-yoga', 0, 32);
  await workout('builtin-yoga', 1, 30);
  await workout('builtin-walk', 2, 45);
  await workout('builtin-weights', 3, 40);
  await workout('builtin-zumba', 4, 35);
  await workout('builtin-yoga', 5, 30);

  final habits = HabitRepository(db, clock);
  Future<void> habit(String name, HabitKind kind, int target, int done) async {
    final id = await habits.create(
      userId: user.id,
      name: name,
      kind: kind,
      dailyTarget: target,
    );
    if (done > 0) {
      final h = await (db.select(
        db.habits,
      )..where((x) => x.id.equals(id))).getSingle();
      await habits.log(habit: h, dayCutoffMinutes: 0, count: done);
    }
  }

  await habit('Stand from desk', HabitKind.stand, 8, 8);
  await habit('Water break', HabitKind.water, 8, 6);
  await habit('Stretch break', HabitKind.stretch, 6, 4);
  await habit('Other healthy break', HabitKind.custom, 2, 1);

  await SleepRepository(db, clock).log(
    userId: user.id,
    dayCutoffMinutes: 0,
    bedtimeAt: DateTime.utc(2026, 5, 12, 23, 15),
    wakeAt: DateTime.utc(2026, 5, 13, 6, 35),
  );
}

FakeUsageSource demoUsage() => FakeUsageSource(
  access: true,
  byDate: {
    '2026-05-13': const DayUsage(
      totalMinutes: 252,
      categories: {
        'social': 92,
        'video': 70,
        'browser': 56,
        'productivity': 34,
        'other': 20,
      },
    ),
  },
);

const demoPrefs = <String, Object>{'screen_time_goal_minutes': 300};

void main() {
  setUpAll(loadFonts);

  appTest(
    'today',
    (tester, db) async {
      await seedDemo(db);
      await tester.pump(const Duration(seconds: 1));
      await shot(tester, 'today');
    },
    wrapApp: wrap,
    usage: demoUsage(),
    prefs: demoPrefs,
  );

  appTest(
    'log',
    (tester, db) async {
      tester.view.padding = const FakeViewPadding(top: 80, bottom: 60);
      tester.view.viewPadding = const FakeViewPadding(top: 80, bottom: 60);
      await seedDemo(db);
      await tester.pump(const Duration(seconds: 1));
      unawaited(openLogWorkout(tester.element(find.byType(Scaffold).first)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yoga').last);
      await tester.pumpAndSettle();
      await shot(tester, 'log');
    },
    wrapApp: wrap,
    usage: demoUsage(),
    prefs: demoPrefs,
  );

  appTest(
    'timer',
    (tester, db) async {
      tester.view.padding = const FakeViewPadding(top: 80, bottom: 60);
      tester.view.viewPadding = const FakeViewPadding(top: 80, bottom: 60);
      await seedDemo(db);
      await tester.pump(const Duration(seconds: 1));
      unawaited(
        Navigator.of(tester.element(find.byType(Scaffold).first))
            .push(MaterialPageRoute<void>(builder: (_) => const TimerScreen())),
      );
      await tester.pumpAndSettle();
      await shot(tester, 'timer');
    },
    wrapApp: wrap,
    usage: demoUsage(),
    prefs: {
      ...demoPrefs,
      'active_workout_timer': TimerState(
        workoutTypeId: 'builtin-yoga',
        startedAt: testNow.subtract(const Duration(minutes: 32, seconds: 18)),
      ).toJson(),
    },
  );

  appTest(
    'week',
    (tester, db) async {
      tester.view.padding = const FakeViewPadding(top: 80, bottom: 0);
      tester.view.viewPadding = const FakeViewPadding(top: 80, bottom: 0);
      await seedDemo(db);
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Week').last);
      await tester.pumpAndSettle();
      await shot(tester, 'week');
    },
    wrapApp: wrap,
    usage: demoUsage(),
    prefs: demoPrefs,
  );

  appTest(
    'summary',
    (tester, db) async {
      tester.view.padding = const FakeViewPadding(top: 80, bottom: 0);
      tester.view.viewPadding = const FakeViewPadding(top: 80, bottom: 0);
      await seedDemo(db);
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Week').last);
      await tester.pumpAndSettle();
      openDaySummary(tester.element(find.byType(Scaffold).first), '2026-05-13');
      await tester.pumpAndSettle();
      await shot(tester, 'summary');
    },
    wrapApp: wrap,
    usage: demoUsage(),
    prefs: demoPrefs,
  );

  appTest(
    'habits',
    (tester, db) async {
      tester.view.padding = const FakeViewPadding(top: 80, bottom: 0);
      tester.view.viewPadding = const FakeViewPadding(top: 80, bottom: 0);
      await seedDemo(db);
      await tester.pump(const Duration(seconds: 1));
      unawaited(
        Navigator.of(
          tester.element(find.byType(Scaffold).first),
        ).push(MaterialPageRoute<void>(builder: (_) => const HabitsScreen())),
      );
      await tester.pumpAndSettle();
      await shot(tester, 'habits');
    },
    wrapApp: wrap,
    usage: demoUsage(),
    prefs: demoPrefs,
  );

  appTest(
    'sleep',
    (tester, db) async {
      tester.view.padding = const FakeViewPadding(top: 80, bottom: 0);
      tester.view.viewPadding = const FakeViewPadding(top: 80, bottom: 0);
      await seedDemo(db);
      await tester.pump(const Duration(seconds: 1));
      unawaited(
        Navigator.of(tester.element(find.byType(Scaffold).first))
            .push(MaterialPageRoute<void>(builder: (_) => const SleepScreen())),
      );
      await tester.pumpAndSettle();
      await shot(tester, 'sleep');
    },
    wrapApp: wrap,
    usage: demoUsage(),
    prefs: demoPrefs,
  );

  appTest(
    'screentime',
    (tester, db) async {
      tester.view.padding = const FakeViewPadding(top: 80, bottom: 0);
      tester.view.viewPadding = const FakeViewPadding(top: 80, bottom: 0);
      await seedDemo(db);
      await tester.pump(const Duration(seconds: 1));
      unawaited(
        Navigator.of(tester.element(find.byType(Scaffold).first)).push(
          MaterialPageRoute<void>(builder: (_) => const ScreenTimeScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await shot(tester, 'screentime');
    },
    wrapApp: wrap,
    usage: demoUsage(),
    prefs: demoPrefs,
  );
}
