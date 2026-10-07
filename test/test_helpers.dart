import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wellbeing/app/app.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/providers.dart';
import 'package:wellbeing/features/reminders/notification_scheduler.dart';
import 'package:wellbeing/features/reminders/reminder_providers.dart';

final testNow = DateTime.utc(2026, 5, 13, 10);

/// The notification scheduler used by the current [appTest]. It starts
/// without notification permission and grants it when asked, unless a test
/// sets `grantOnRequest` to false.
late FakeNotificationScheduler testScheduler;

/// Runs [body] against the full app on an in-memory database and a fixed
/// clock (Wed 13 May 2026, 10:00 UTC), on a phone-sized surface.
///
/// Drift schedules zero-length cleanup timers for its streams. Under fake
/// async these must be drained before the test ends, and the in-memory
/// database is left open rather than awaited, so each test is wrapped here.
void appTest(
  String name,
  Future<void> Function(WidgetTester tester, AppDatabase db) body,
) {
  testWidgets(name, (tester) async {
    SharedPreferences.setMockInitialValues({});
    drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    final db = AppDatabase(NativeDatabase.memory());
    testScheduler = FakeNotificationScheduler(permitted: false);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationSchedulerProvider.overrideWithValue(testScheduler),
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(FixedClock(testNow)),
        ],
        child: const WellbeingApp(),
      ),
    );
    await tester.pumpAndSettle();

    await body(tester, db);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
