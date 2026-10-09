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
import 'package:wellbeing/data/sync/remote_store.dart';
import 'package:wellbeing/data/sync/sync_state.dart';
import 'package:wellbeing/features/account/auth_service.dart';
import 'package:wellbeing/features/account/sync_providers.dart';
import 'package:wellbeing/features/groups/groups_providers.dart';
import 'package:wellbeing/features/groups/groups_remote.dart';
import 'package:wellbeing/features/groups/invite_links.dart';
import 'package:wellbeing/features/reminders/notification_scheduler.dart';
import 'package:wellbeing/features/settings/data_export.dart';
import 'package:wellbeing/features/reminders/reminder_providers.dart';
import 'package:wellbeing/features/reminders/system_settings.dart';
import 'package:wellbeing/features/screen_time/screen_time_providers.dart';
import 'package:wellbeing/features/screen_time/usage_source.dart';

final testNow = DateTime.utc(2026, 5, 13, 10);

/// The notification scheduler used by the current [appTest]. It starts
/// without notification permission and grants it when asked, unless a test
/// sets `grantOnRequest` to false.
late FakeNotificationScheduler testScheduler;

/// The usage source for the current [appTest]: no usage access unless the
/// test passes its own.
late FakeUsageSource testUsage;

/// The phone-settings stand-in for the current [appTest].
late FakeSystemSettings testSystem;

/// Sign-in and server stand-ins for the current [appTest]: nobody signed in
/// and an empty server, unless the test passes its own.
late AuthService testAuth;
late FakeRemoteStore testRemote;
late MemorySyncStateStore testSyncState;

/// The groups server for the current [appTest]: signed in as `me`, no groups.
late FakeGroupsRemote testGroups;

/// Where exports go in the current [appTest].
late FakeExportSink testExport;

/// Invite links reaching the current [appTest]; `startLink` is the link the
/// app was started with, if any.
late FakeInviteLinkSource testLinks;

/// Runs [body] against the full app on an in-memory database and a fixed
/// clock (Wed 13 May 2026, 10:00 UTC), on a phone-sized surface.
///
/// Drift schedules zero-length cleanup timers for its streams. Under fake
/// async these must be drained before the test ends, and the in-memory
/// database is left open rather than awaited, so each test is wrapped here.
void appTest(
  String name,
  Future<void> Function(WidgetTester tester, AppDatabase db) body, {
  FakeUsageSource? usage,
  AuthService? auth,
  String? setupIssue,
  FakeRemoteStore? remote,
  FakeGroupsRemote? groups,
  String? startLink,
}) {
  testWidgets(name, (tester) async {
    SharedPreferences.setMockInitialValues({});
    drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    final db = AppDatabase(NativeDatabase.memory());
    testScheduler = FakeNotificationScheduler(permitted: false);
    testUsage = usage ?? FakeUsageSource(access: false);
    testSystem = FakeSystemSettings();
    testAuth = auth ?? FakeAuthService();
    testRemote = remote ?? FakeRemoteStore();
    testSyncState = MemorySyncStateStore();
    testGroups = groups ?? FakeGroupsRemote();
    testExport = FakeExportSink();
    testLinks = FakeInviteLinkSource(initial: startLink);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationSchedulerProvider.overrideWithValue(testScheduler),
          usageSourceProvider.overrideWithValue(testUsage),
          systemSettingsProvider.overrideWithValue(testSystem),
          authServiceProvider.overrideWithValue(testAuth),
          syncSetupIssueProvider.overrideWithValue(setupIssue),
          remoteStoreProvider.overrideWithValue(testRemote),
          syncStateProvider.overrideWithValue(testSyncState),
          groupsRemoteProvider.overrideWithValue(testGroups),
          exportSinkProvider.overrideWithValue(testExport),
          inviteLinkSourceProvider.overrideWithValue(testLinks),
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(FixedClock(testNow)),
        ],
        child: const WellbeingApp(),
      ),
    );
    await tester.pumpAndSettle();

    await body(tester, db);

    // Startup asks for the user from several places at once; there must still
    // be exactly one, or data written under a stray user would go missing.
    expect(
      (await db.select(db.users).get()).length,
      lessThanOrEqualTo(1),
      reason: 'concurrent startup created more than one user',
    );

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
