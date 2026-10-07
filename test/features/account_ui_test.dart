import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/repositories/workout_repository.dart';
import 'package:wellbeing/data/sync/remote_store.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/features/account/auth_service.dart';

import '../test_helpers.dart';

const signedIn = AccountUser(
  id: 'account-1',
  email: 'divya@example.com',
  displayName: 'Divya',
);

FakeAuthService fake() => testAuth as FakeAuthService;

/// A remote store that shows each account only its own rows, like the real
/// server, and follows whoever the fake sign-in says is signed in.
FakeRemoteStore serverFor(FakeAuthService auth) =>
    FakeRemoteStore(accountId: () => auth.currentUser?.id);

Future<void> openAccount(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Profile and settings').first);
  await tester.pumpAndSettle();
}

Future<void> addWorkout(
  AppDatabase db, {
  String note = 'logged on the phone',
}) async {
  final clock = FixedClock(testNow);
  final user = await UserRepository(db, clock).ensureUser();
  await WorkoutRepository(db, clock).add(
    userId: user.id,
    dayCutoffMinutes: 0,
    workoutTypeId: 'builtin-yoga',
    startedAt: testNow,
    endedAt: testNow.add(const Duration(minutes: 30)),
    source: WorkoutSource.manual,
    note: note,
  );
}

void main() {
  group('signed out', () {
    appTest('offers Google sign-in and says everything works without it', (
      tester,
      db,
    ) async {
      await openAccount(tester);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Back up and sync'), findsOneWidget);
      expect(find.textContaining('works without an account'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    appTest('signing in shows the account and syncs the phone\'s data', (
      tester,
      db,
    ) async {
      await addWorkout(db);
      await openAccount(tester);
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();

      expect(fake().signInCalls, 1);
      expect(find.text('Divya'), findsOneWidget);
      expect(find.text('divya@example.com'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);

      // The sync starts by itself and uploads what was already on the phone.
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(testRemote.rows('workouts').single['note'], 'logged on the phone');
      expect(testRemote.rows('workouts').single['user_id'], 'account-1');
      expect(find.textContaining('Last synced'), findsOneWidget);
    });

    appTest('cancelling sign-in changes nothing and shows no error', (
      tester,
      db,
    ) async {
      fake().nextResult = SignInResult.cancelled;
      await openAccount(tester);
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Could not sign in. Try again.'), findsNothing);
    });

    appTest('a failed sign-in says so plainly and can be retried', (
      tester,
      db,
    ) async {
      fake().nextResult = SignInResult.failed;
      await openAccount(tester);
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();
      expect(find.text('Could not sign in. Try again.'), findsOneWidget);

      fake().nextResult = SignInResult.signedIn;
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();
      expect(find.text('Divya'), findsOneWidget);
    });
  });

  appTest('a build without backend settings explains and offers no sign-in', (
    tester,
    db,
  ) async {
    await openAccount(tester);
    expect(find.text('Sync is not set up in this build'), findsOneWidget);
    expect(find.text('Continue with Google'), findsNothing);
  }, auth: UnavailableAuthService());

  appTest('a build without settings names what is missing, never values', (
    tester,
    db,
  ) async {
    await openAccount(tester);
    expect(find.textContaining('This build is missing:'), findsOneWidget);
    expect(find.textContaining('SUPABASE_URL'), findsOneWidget);
    expect(find.textContaining('SUPABASE_PUBLISHABLE_KEY'), findsOneWidget);
    expect(find.textContaining('GOOGLE_WEB_CLIENT_ID'), findsOneWidget);
    expect(
      find.textContaining('--dart-define-from-file=env.json'),
      findsOneWidget,
    );
  }, auth: UnavailableAuthService());

  appTest(
    'a startup failure is shown instead of the missing-settings hint',
    (tester, db) async {
      await openAccount(tester);
      expect(
        find.textContaining('Sync could not start: network unreachable'),
        findsOneWidget,
      );
      expect(find.textContaining('This build is missing'), findsNothing);
    },
    auth: UnavailableAuthService(),
    setupIssue: 'network unreachable',
  );

  group('signed in', () {
    appTest('starts syncing as soon as the app opens', (tester, db) async {
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      // It already asked the server what it has, with no tap needed.
      expect(testRemote.fetchCalls, greaterThan(0));
    }, auth: FakeAuthService(signedIn: signedIn));

    appTest(
      'a change made on the phone reaches the server a few seconds later',
      (tester, db) async {
        await tester.pumpAndSettle();
        expect(testRemote.rows('workouts'), isEmpty);

        await addWorkout(db, note: 'new entry');
        await tester.pump(const Duration(seconds: 1));
        expect(testRemote.rows('workouts'), isEmpty); // waits, to batch changes

        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
        expect(testRemote.rows('workouts').single['note'], 'new entry');
      },
      auth: FakeAuthService(signedIn: signedIn),
    );

    appTest('several quick changes are sent together', (tester, db) async {
      await tester.pumpAndSettle();
      testRemote.upsertsByTable.clear();
      for (var i = 0; i < 4; i++) {
        await addWorkout(db, note: 'entry $i');
        await tester.pump(const Duration(milliseconds: 500));
      }
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(testRemote.rows('workouts').length, 4);
      // One batched sync, not four: the workouts table was sent once.
      expect(testRemote.upsertsByTable['workouts'], 1);
    }, auth: FakeAuthService(signedIn: signedIn));

    appTest('Sync now works and reports a failure without losing data', (
      tester,
      db,
    ) async {
      await addWorkout(db);
      await tester.pumpAndSettle();
      await openAccount(tester);

      testRemote.failWith = Exception('no network');
      await tester.tap(find.text('Sync now'));
      await tester.pumpAndSettle();
      expect(find.text('Could not sync. It will retry.'), findsOneWidget);
      expect((await db.select(db.workouts).get()).length, 1);

      testRemote.failWith = null;
      await tester.tap(find.text('Sync now'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Last synced'), findsOneWidget);
      expect(find.text('Could not sync. It will retry.'), findsNothing);
    }, auth: FakeAuthService(signedIn: signedIn));

    appTest('signing out keeps the data on the phone', (tester, db) async {
      await addWorkout(db);
      await tester.pumpAndSettle();
      await openAccount(tester);

      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      expect(find.text('Your data stays on this phone.'), findsOneWidget);
      await tester.tap(find.text('Sign out').last);
      await tester.pumpAndSettle();

      expect(fake().signOutCalls, 1);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect((await db.select(db.workouts).get()).length, 1);
    }, auth: FakeAuthService(signedIn: signedIn));

    appTest('declining the sign-out dialog keeps the account', (
      tester,
      db,
    ) async {
      await tester.pumpAndSettle();
      await openAccount(tester);
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(fake().signOutCalls, 0);
      expect(find.text('Divya'), findsOneWidget);
    }, auth: FakeAuthService(signedIn: signedIn));
  });

  group('a different account on the same phone', () {
    final auth = FakeAuthService(signedIn: signedIn);
    appTest(
      'asks before replacing, then switches cleanly',
      (tester, db) async {
        await addWorkout(db, note: 'belongs to the first account');
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();
        expect(testRemote.rows('workouts').length, 1);

        // A second person signs in on this phone.
        await openAccount(tester);
        await fake().signOut();
        fake().signInAs = const AccountUser(
          id: 'account-2',
          email: 'asha@example.com',
          displayName: 'Asha',
        );
        await fake().signInWithGoogle();
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        expect(find.text('Different account'), findsOneWidget);
        expect(find.text('Sync now'), findsNothing);
        // Nothing moved in either direction.
        expect(testRemote.rows('workouts').length, 1);
        expect((await db.select(db.workouts).get()).length, 1);

        await tester.tap(find.text('Replace data on this phone'));
        await tester.pumpAndSettle();

        expect(find.text('Different account'), findsNothing);
        expect(await db.select(db.workouts).get(), isEmpty);
        // The first account's data on the server is untouched.
        expect(testRemote.rows('workouts').single['user_id'], 'account-1');
      },
      auth: auth,
      remote: serverFor(auth),
    );
  });

  test('screen copy has no exclamation marks', () {
    const copy = [
      'Back up and sync',
      'Could not sign in. Try again.',
      'Could not sync. It will retry.',
      'Your data stays on this phone.',
      'Sync is not set up in this build',
      'Different account',
    ];
    expect(copy.any((c) => c.contains('!')), isFalse);
  });
}
