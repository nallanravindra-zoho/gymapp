import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/theme/app_theme.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/repositories/body_measurement_repository.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/features/account/profile_services.dart';
import 'package:wellbeing/features/metrics/measurements_banner.dart';
import 'package:wellbeing/features/metrics/metrics_logic.dart';
import 'package:wellbeing/features/metrics/metrics_providers.dart';

import '../helpers/metrics_helpers.dart';
import '../helpers/nav_b.dart';
import '../test_helpers.dart';

Future<User> user(AppDatabase db) =>
    UserRepository(db, FixedClock(testNow)).ensureUser();

Future<void> setUser(AppDatabase db, UsersCompanion c) async {
  final u = await user(db);
  await UserRepository(db, FixedClock(testNow)).update(u.id, c);
}

Future<void> addRecord(
  AppDatabase db,
  DateTime at, {
  double? weight,
  double? height,
  double? waist,
}) async {
  final u = await user(db);
  await BodyMeasurementRepository(db, FixedClock(testNow)).add(
    userId: u.id,
    dayCutoffMinutes: 0,
    measuredAt: at,
    weightKg: weight,
    heightCm: height,
    waistIn: waist,
  );
}

/// The scrollable of the screen on top (tabs stay in the tree underneath).
Finder topScroller() => find
    .descendant(
      of: find.byType(Scaffold).last,
      matching: find.byType(Scrollable),
    )
    .first;

Future<void> field(WidgetTester tester, String label, String value) async {
  final f = find.widgetWithText(TextField, label);
  await tester.ensureVisible(f);
  await tester.enterText(f, value);
}

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    200,
    scrollable: topScroller(),
  );
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  group('hub', () {
    appTest('has Profile Management and App Management', (tester, db) async {
      await openAccountHub(tester);
      expect(find.text('Profile Management'), findsOneWidget);
      expect(find.text('App Management'), findsOneWidget);
      await tester.tap(find.text('Profile Management'));
      await tester.pumpAndSettle();
      expect(find.text('My profile'), findsOneWidget);
      expect(find.text('Personal metrics'), findsOneWidget);
      expect(find.text('Body measurements'), findsOneWidget);
      await goBack(tester);
      await tester.tap(find.text('App Management'));
      await tester.pumpAndSettle();
      for (final r in [
        'Appearance',
        'Reminders',
        'Goals & preferences',
        'Privacy & data',
        'Account & sync',
      ]) {
        expect(find.text(r), findsOneWidget, reason: r);
      }
    });
  });

  group('my profile', () {
    appTest('date of birth sets the age, which is never typed', (
      tester,
      db,
    ) async {
      await openSettingsSection(tester, 'My profile');
      expect(find.text('Age'), findsOneWidget);
      await tester.tap(find.text('Date of birth'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      final u = await user(db);
      expect(u.dateOfBirth, '1996-05-13');
      expect(find.text('30'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });

    appTest('gender is optional and can be cleared', (tester, db) async {
      await openSettingsSection(tester, 'My profile');
      await tester.tap(find.text('Gender (optional)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Non-binary'));
      await tester.pumpAndSettle();
      expect((await user(db)).gender, 'non_binary');
      await tester.tap(find.text('Gender (optional)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Not set').last);
      await tester.pumpAndSettle();
      expect((await user(db)).gender, isNull);
    });

    appTest(
      'the picture comes from the gallery and is kept as a local path',
      (tester, db) async {
        await openSettingsSection(tester, 'My profile');
        await tester.tap(find.text('Profile picture'));
        await tester.pumpAndSettle();
        expect((await user(db)).avatarUrl, '/docs/profile_1.jpg');
        await tester.tap(find.byTooltip('Remove profile picture'));
        await tester.pumpAndSettle();
        expect((await user(db)).avatarUrl, isNull);
      },
      wrapApp: withPickers(
        photo: FakeProfilePhotoStore(next: '/docs/profile_1.jpg'),
      ),
    );

    appTest('cancelling the gallery changes nothing', (tester, db) async {
      await openSettingsSection(tester, 'My profile');
      await tester.tap(find.text('Profile picture'));
      await tester.pumpAndSettle();
      expect((await user(db)).avatarUrl, isNull);
    }, wrapApp: withPickers(photo: FakeProfilePhotoStore()));
  });

  group('personal metrics and BMI', () {
    appTest('height and weight are saved and BMI explained', (
      tester,
      db,
    ) async {
      await openSettingsSection(tester, 'Personal metrics');
      await tester.tap(find.text('Height'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '170');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Weight'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '72.5');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final u = await user(db);
      expect(u.heightCm, 170);
      expect(u.weightKg, 72.5);
      expect(find.text('25.1'), findsOneWidget);
      expect(find.textContaining('date of birth enables'), findsOneWidget);
      expect(find.textContaining('not a diagnosis'), findsOneWidget);
      expect(find.textContaining('South Asian'), findsOneWidget);
      expect(find.textContaining('nhs.uk'), findsOneWidget);
    });

    appTest('an adult sees the general reference wording', (tester, db) async {
      await setUser(
        db,
        const UsersCompanion(
          heightCm: Value(170),
          weightKg: Value(60),
          dateOfBirth: Value('1990-01-01'),
        ),
      );
      await openSettingsSection(tester, 'Personal metrics');
      expect(find.textContaining('general reference'), findsWidgets);
      expect(find.textContaining('Within the general reference'), findsOne);
    });

    appTest('under 18 gets no adult category', (tester, db) async {
      await setUser(
        db,
        const UsersCompanion(
          heightCm: Value(160),
          weightKg: Value(50),
          dateOfBirth: Value('2012-01-01'),
        ),
      );
      await openSettingsSection(tester, 'Personal metrics');
      expect(find.textContaining('do not apply under 18'), findsOneWidget);
      expect(find.textContaining('health professional'), findsOneWidget);
      expect(find.textContaining('Within the general'), findsNothing);
    });

    appTest('an invalid number is refused', (tester, db) async {
      await openSettingsSection(tester, 'Personal metrics');
      await tester.tap(find.text('Weight'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '0');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect((await user(db)).weightKg, isNull);
      expect(find.textContaining('Enter a number from'), findsOneWidget);
    });
  });

  group('body measurements', () {
    appTest('add a partial record, edit it, then delete it', (
      tester,
      db,
    ) async {
      await openSettingsSection(tester, 'Body measurements');
      expect(find.textContaining('never shared with groups'), findsWidgets);
      await tapText(tester, 'Add measurements');
      await field(tester, 'Weight (kg)', '70');
      await field(tester, 'Height (cm)', '175');
      await field(tester, 'Waist (inches)', '32.5');
      await tapText(tester, 'Save');
      final repo = BodyMeasurementRepository(db, FixedClock(testNow));
      final u = await user(db);
      var rows = await repo.allRecords(u.id);
      expect(rows, hasLength(1));
      expect(rows.single.waistIn, 32.5);
      expect(rows.single.hipsIn, isNull);
      expect(rows.single.bmi, closeTo(22.86, 0.01));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('Waist 32.5 in'),
        200,
        scrollable: topScroller(),
      );
      expect(find.textContaining('Waist 32.5 in'), findsOneWidget);
      // Next measurements are due a month after the record (default cadence).
      expect(u.nextMeasurementDue, '2026-06-13');

      await tester.drag(topScroller(), const Offset(0, -200));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Waist 32.5 in'));
      await tester.pumpAndSettle();
      await field(tester, 'Waist (inches)', '31');
      await field(tester, 'Hips (inches)', '38');
      await tapText(tester, 'Save');
      rows = await repo.allRecords(u.id);
      expect(rows.single.waistIn, 31);
      expect(rows.single.hipsIn, 38);

      await tester.scrollUntilVisible(
        find.byTooltip('Delete entry from 13 May 2026'),
        200,
        scrollable: topScroller(),
      );
      await tester.tap(find.byTooltip('Delete entry from 13 May 2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(await repo.allRecords(u.id), hasLength(1));
      await tester.tap(find.byTooltip('Delete entry from 13 May 2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(await repo.allRecords(u.id), isEmpty);
      await tester.scrollUntilVisible(
        find.text('No measurements yet.'),
        200,
        scrollable: topScroller(),
      );
      expect(find.text('No measurements yet.'), findsOneWidget);
    });

    appTest('an empty or out-of-range form is refused', (tester, db) async {
      await openSettingsSection(tester, 'Body measurements');
      await tapText(tester, 'Add measurements');
      await tapText(tester, 'Save');
      expect(find.text('Enter at least one measurement.'), findsOneWidget);
      await field(tester, 'Waist (inches)', '900');
      await tapText(tester, 'Save');
      expect(find.textContaining('Check Waist'), findsOneWidget);
      final u = await user(db);
      expect(
        await BodyMeasurementRepository(
          db,
          FixedClock(testNow),
        ).allRecords(u.id),
        isEmpty,
      );
    });

    appTest('cadence and the reminder switch are saved', (tester, db) async {
      await addRecord(db, DateTime.utc(2026, 5, 6), weight: 70);
      await openSettingsSection(tester, 'Body measurements');
      await tapText(tester, 'Every week');
      var u = await user(db);
      expect(u.measurementCadence, 'weekly');
      expect(u.nextMeasurementDue, '2026-05-13');
      await tapText(tester, 'Every two months');
      u = await user(db);
      expect(u.measurementCadence, 'bimonthly');
      expect(u.nextMeasurementDue, '2026-07-06');
      await tapText(tester, 'Remind me about measurement day');
      expect((await user(db)).measurementReminderEnabled, isFalse);
    });

    appTest('guidance is available', (tester, db) async {
      await openSettingsSection(tester, 'Body measurements');
      await tapText(tester, 'How to measure');
      expect(find.textContaining('flexible tape'), findsOneWidget);
      expect(find.textContaining('Waist.'), findsOneWidget);
      expect(find.textContaining('Thighs.'), findsOneWidget);
    });
  });

  group('charts', () {
    appTest('weight, BMI and body measurements get separate charts', (
      tester,
      db,
    ) async {
      await addRecord(
        db,
        DateTime.utc(2026, 4, 1),
        weight: 72,
        height: 170,
        waist: 33,
      );
      await addRecord(
        db,
        DateTime.utc(2026, 5, 1),
        weight: 70.5,
        height: 170,
        waist: 32,
      );
      await tester.tap(find.byIcon(Icons.lightbulb_outline_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Metrics'));
      await tester.pumpAndSettle();
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('BMI'), findsOneWidget);
      expect(find.text('Body measurements'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Weight chart, 2 entries')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('BMI chart, 2 entries')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('Waist chart, 2 entries')),
        findsOneWidget,
      );
      // The latest point is shown with its date and value.
      expect(find.text('70.5 kg'), findsOneWidget);
      expect(find.text('1 May 2026'), findsWidgets);
      // Tapping the left end shows the first entry.
      final chart = find.byKey(const ValueKey('weight'));
      final box = tester.getRect(chart);
      await tester.tapAt(Offset(box.left + 45, box.center.dy + 40));
      await tester.pumpAndSettle();
      expect(find.text('72.0 kg'), findsOneWidget);
      expect(find.text('1 Apr 2026'), findsWidgets);
      // Another body series can be selected; it has no data yet.
      await tester.tap(find.text('Hips'));
      await tester.pumpAndSettle();
      expect(find.textContaining('No hips entries yet'), findsOneWidget);
      expect(find.textContaining('never shared with groups'), findsOneWidget);
    });

    appTest('empty charts explain themselves', (tester, db) async {
      await tester.tap(find.byIcon(Icons.lightbulb_outline_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Metrics'));
      await tester.pumpAndSettle();
      expect(find.textContaining('No weight entries yet'), findsOneWidget);
      expect(find.textContaining('No BMI entries yet'), findsOneWidget);
    });
  });

  group('reminder sound and notification permission', () {
    appTest(
      'default is the phone sound; a chosen sound is saved and can be reset',
      (tester, db) async {
        await openSettingsSection(tester, 'Reminders');
        expect(find.text('Phone default'), findsOneWidget);
        await tester.tap(find.text('Reminder sound'));
        await tester.pumpAndSettle();
        expect((await user(db)).reminderSound, 'content://media/chime');
        expect(find.text('Chime'), findsOneWidget);
        await tester.tap(find.byTooltip('Use phone default sound'));
        await tester.pumpAndSettle();
        expect((await user(db)).reminderSound, isNull);
      },
      wrapApp: withPickers(
        ringtone: FakeRingtonePicker(
          next: const RingtoneChoice(
            uri: 'content://media/chime',
            title: 'Chime',
          ),
          titles: {'content://media/chime': 'Chime'},
        ),
      ),
    );

    appTest('cancelling the picker keeps the sound', (tester, db) async {
      await openSettingsSection(tester, 'Reminders');
      await tester.tap(find.text('Reminder sound'));
      await tester.pumpAndSettle();
      expect((await user(db)).reminderSound, isNull);
    }, wrapApp: withPickers(ringtone: FakeRingtonePicker()));

    appTest(
      'a revoked permission warns, keeps settings and links to settings',
      (tester, db) async {
        await setUser(
          db,
          const UsersCompanion(quietHoursStart: Value(23 * 60)),
        );
        testScheduler.permitted = false;
        await openSettingsSection(tester, 'Reminders');
        expect(find.textContaining('turned off for this app'), findsOneWidget);
        expect(find.text('11:00 PM'), findsOneWidget, reason: 'kept');
        await tester.tap(find.text('Open phone settings'));
        await tester.pumpAndSettle();
        expect(testSystem.notificationsOpened, 1);
      },
    );

    appTest('no warning while notifications are allowed', (tester, db) async {
      testScheduler.permitted = true;
      await openSettingsSection(tester, 'Reminders');
      expect(find.textContaining('turned off for this app'), findsNothing);
    });
  });

  group('measurement-day banner', () {
    Future<void> pumpBanner(WidgetTester tester, MeasurementNotice n) =>
        tester.pumpWidget(
          ProviderScope(
            overrides: [measurementNoticeProvider.overrideWithValue(n)],
            child: MaterialApp(
              theme: buildTheme(Brightness.light),
              home: const Scaffold(body: MeasurementsBanner()),
            ),
          ),
        );

    testWidgets('shows the heads-up two days before', (tester) async {
      await pumpBanner(
        tester,
        const MeasurementNotice(MeasurementNoticeKind.upcoming, 2),
      );
      expect(find.text('Measurements day in 2 days'), findsOneWidget);
    });

    testWidgets('shows nothing when there is no notice', (tester) async {
      await pumpBanner(tester, MeasurementNotice.none);
      expect(find.byType(Text), findsNothing);
    });

    appTest('the provider follows the due date and the switch', (
      tester,
      db,
    ) async {
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      await setUser(
        db,
        const UsersCompanion(nextMeasurementDue: Value('2026-05-15')),
      );
      await tester.pumpAndSettle();
      expect(container.read(measurementNoticeProvider).days, 2);
      await setUser(
        db,
        const UsersCompanion(measurementReminderEnabled: Value(false)),
      );
      await tester.pumpAndSettle();
      expect(container.read(measurementNoticeProvider).visible, isFalse);
    });

    appTest('on the day the banner opens Metrics', (tester, db) async {
      await setUser(
        db,
        const UsersCompanion(nextMeasurementDue: Value('2026-05-13')),
      );
      await tester.pumpAndSettle();
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      nav.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: MeasurementsBanner()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Measurements day is today'), findsOneWidget);
      await tester.tap(find.text('Measurements day is today'));
      await tester.pumpAndSettle();
      expect(find.text('Add measurements'), findsOneWidget);
    });
  });
}
