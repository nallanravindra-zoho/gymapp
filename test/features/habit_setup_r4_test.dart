import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/time/app_clock.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/data/repositories/habit_repository.dart';
import 'package:wellbeing/data/repositories/user_repository.dart';
import 'package:wellbeing/data/seed_tips.dart';
import 'package:wellbeing/data/tables/tables.dart';
import 'package:wellbeing/features/habits/reminder_config.dart';
import 'package:wellbeing/features/insights/tips.dart';

import '../helpers/nav_b.dart';
import '../test_helpers.dart';
import 'habits_ui_test.dart' show openDetailFromManage, startNewHabit;

Future<String> addHabit(
  AppDatabase db, {
  String name = 'Water',
  HabitKind kind = HabitKind.water,
  int target = 4,
  bool reminders = false,
  ReminderConfig config = const ReminderConfig(),
}) async {
  final clock = FixedClock(testNow);
  final user = await UserRepository(db, clock).ensureUser();
  return HabitRepository(db, clock).create(
    userId: user.id,
    name: name,
    kind: kind,
    dailyTarget: target,
    remindersEnabled: reminders,
    reminderConfig: config.toJson(),
  );
}

Future<void> save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
  // Turning reminders on explains and asks for notification access first.
  if (find.text('Allow notifications').evaluate().isNotEmpty) {
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }
}

FilledButton saveButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Save'));

/// Sets the open time picker to [hour] (1-12) : 00 and AM or PM, by typing.
Future<void> pickTime(
  WidgetTester tester, {
  required int hour,
  required bool pm,
}) async {
  await tester.tap(find.byTooltip('Switch to text input mode'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(pm ? 'PM' : 'AM'));
  await tester.pumpAndSettle();
  final fields = find.descendant(
    of: find.byType(Dialog),
    matching: find.byType(TextField),
  );
  await tester.enterText(fields.at(0), hour.toString().padLeft(2, '0'));
  await tester.enterText(fields.at(1), '00');
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

/// A tall phone, so the whole setup form is built and on screen.
void tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 5200);
}

void main() {
  group('setup order', () {
    appTest('Reminder, then Repeating or Set times, then target', (
      tester,
      db,
    ) async {
      tall(tester);
      await startNewHabit(tester);
      // Reminders are off by default and nothing else is shown yet.
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      expect(find.text('Repeating'), findsNothing);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      final reminder = tester.getTopLeft(find.text('Reminder')).dy;
      final mode = tester.getTopLeft(find.text('Repeating')).dy;
      final target = tester.getTopLeft(find.text('Daily target')).dy;
      expect(reminder, lessThan(mode));
      expect(mode, lessThan(target));
    });

    appTest('repeat options are 30 minutes and 1 to 4 hours', (
      tester,
      db,
    ) async {
      tall(tester);
      await startNewHabit(tester);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      for (final label in [
        'Every 30 minutes',
        'Every hour',
        'Every 2 hours',
        'Every 3 hours',
        'Every 4 hours',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(find.text('From'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);
    });

    appTest('custom habits offer Meditation and Chanting quick picks', (
      tester,
      db,
    ) async {
      tall(tester);
      await startNewHabit(tester);
      expect(find.text('Meditation'), findsNothing);
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();
      expect(find.text('Meditation'), findsOneWidget);
      expect(find.text('Chanting'), findsOneWidget);
      await tester.tap(find.text('Chanting'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Chanting',
      );
      await save(tester);
      final h = (await db.select(db.habits).get()).single;
      expect(h.name, 'Chanting');
      expect(h.kind, HabitKind.custom);
    });

    appTest('built-in kinds include Moisturize and Skin care', (
      tester,
      db,
    ) async {
      tall(tester);
      await startNewHabit(tester);
      for (final k in [
        'Water',
        'Stand and move',
        'Stretch',
        'Moisturize',
        'Skin care',
      ]) {
        expect(find.widgetWithText(ChoiceChip, k), findsOneWidget, reason: k);
      }
    });
  });

  group('daily target follows the reminders', () {
    appTest('hourly 9 to 5 sets the target to nine, counting both ends', (
      tester,
      db,
    ) async {
      tall(tester);
      await startNewHabit(tester);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Every hour'));
      await tester.pumpAndSettle();
      expect(find.text('9 reminders a day'), findsOneWidget);
      expect(find.textContaining('9 hours'), findsNothing);
      expect(find.textContaining('hours a day'), findsNothing);
      await save(tester);
      expect((await db.select(db.habits).get()).single.dailyTarget, 9);
    });

    appTest('changing the interval recalculates the target', (
      tester,
      db,
    ) async {
      tall(tester);
      await startNewHabit(tester);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Every 30 minutes'));
      await tester.pumpAndSettle();
      expect(find.text('17 reminders a day'), findsOneWidget);
      await tester.tap(find.text('Every 4 hours'));
      await tester.pumpAndSettle();
      expect(find.text('3 reminders a day'), findsOneWidget);
      await save(tester);
      expect((await db.select(db.habits).get()).single.dailyTarget, 3);
    });

    appTest('a target the person edits is kept', (tester, db) async {
      tall(tester);
      await startNewHabit(tester);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Increase target'));
      await tester.tap(find.byTooltip('Increase target')); // 5 -> 6
      await tester.pumpAndSettle();
      await tester.tap(find.text('Every hour'));
      await tester.pumpAndSettle();
      await save(tester);
      expect((await db.select(db.habits).get()).single.dailyTarget, 6);
    });

    appTest('editing a habit with its own target keeps it', (tester, db) async {
      await addHabit(
        db,
        target: 3,
        reminders: true,
        config: const ReminderConfig(everyMinutes: 60), // nine a day
      );
      await tester.pumpAndSettle();
      tall(tester);
      await openHabits(tester);
      await openDetailFromManage(tester, 'Water');
      await tester.tap(find.byTooltip('Edit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Every 2 hours'));
      await tester.pumpAndSettle();
      await save(tester);
      expect((await db.select(db.habits).get()).single.dailyTarget, 3);
    });

    appTest('set times count as occurrences too', (tester, db) async {
      tall(tester);
      await startNewHabit(tester);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Set times'));
      await tester.pumpAndSettle();
      expect(find.text('Add at least one reminder time.'), findsOneWidget);
    });
  });

  group('validation', () {
    appTest('an end before the start shows red text and disables Save', (
      tester,
      db,
    ) async {
      // 11 PM to 6 AM, stored from an earlier version.
      await addHabit(
        db,
        reminders: true,
        config: const ReminderConfig(
          windowStart: 23 * 60,
          windowEnd: 6 * 60,
          everyMinutes: 60,
        ),
      );
      await tester.pumpAndSettle();
      tall(tester);
      await openHabits(tester);
      await openDetailFromManage(tester, 'Water');
      await tester.tap(find.byTooltip('Edit'));
      await tester.pumpAndSettle();

      final msg = find.text(windowOrderMessage);
      expect(msg, findsOneWidget);
      final color = tester.widget<Text>(msg).style!.color;
      final ctx = tester.element(msg);
      expect(color, Theme.of(ctx).colorScheme.error);
      expect(saveButton(tester).onPressed, isNull);
      // Nothing is silently wrapped overnight.
      expect(find.textContaining('reminders a day'), findsNothing);
    });

    appTest('picking a To time before From triggers it; fixing it clears it', (
      tester,
      db,
    ) async {
      tall(tester);
      await startNewHabit(tester);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(saveButton(tester).onPressed, isNotNull);

      await tester.tap(find.text('5:00 PM')); // the To value
      await tester.pumpAndSettle();
      await pickTime(tester, hour: 8, pm: false);
      expect(find.text(windowOrderMessage), findsOneWidget);
      expect(saveButton(tester).onPressed, isNull);
      expect(await db.select(db.habits).get(), isEmpty);

      await tester.tap(find.text('8:00 AM'));
      await tester.pumpAndSettle();
      await pickTime(tester, hour: 6, pm: true);
      expect(find.text(windowOrderMessage), findsNothing);
      expect(saveButton(tester).onPressed, isNotNull);
      expect(find.text('5 reminders a day'), findsOneWidget);
    });

    appTest('the same From and To is allowed (one reminder)', (
      tester,
      db,
    ) async {
      tall(tester);
      await startNewHabit(tester);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5:00 PM'));
      await tester.pumpAndSettle();
      await pickTime(tester, hour: 9, pm: false);
      expect(find.text(windowOrderMessage), findsNothing);
      expect(find.text('1 reminder a day'), findsOneWidget);
    });

    appTest('Set times with none added disables Save', (tester, db) async {
      tall(tester);
      await startNewHabit(tester);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Set times'));
      await tester.pumpAndSettle();
      expect(saveButton(tester).onPressed, isNull);
      expect(await db.select(db.habits).get(), isEmpty);
    });

    appTest('no active days disables Save', (tester, db) async {
      tall(tester);
      await startNewHabit(tester);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      for (final d in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']) {
        await tester.ensureVisible(find.text(d));
        await tester.tap(find.text(d));
        await tester.pumpAndSettle();
      }
      expect(find.text('Choose at least one day.'), findsOneWidget);
      expect(saveButton(tester).onPressed, isNull);
    });

    appTest('a bad window does not matter while reminders are off', (
      tester,
      db,
    ) async {
      await addHabit(
        db,
        reminders: false,
        config: const ReminderConfig(windowStart: 23 * 60, windowEnd: 6 * 60),
      );
      await tester.pumpAndSettle();
      tall(tester);
      await openHabits(tester);
      await openDetailFromManage(tester, 'Water');
      await tester.tap(find.byTooltip('Edit'));
      await tester.pumpAndSettle();
      expect(find.text(windowOrderMessage), findsNothing);
      expect(saveButton(tester).onPressed, isNotNull);
    });
  });

  group('Manage', () {
    appTest('Manage lists, edits and archives; archived can be restored', (
      tester,
      db,
    ) async {
      await addHabit(db, name: 'Water');
      await addHabit(db, name: 'Stretch', kind: HabitKind.stretch);
      await tester.pumpAndSettle();
      await openHabits(tester);
      expect(find.text('Stretch'), findsOneWidget);

      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();
      expect(find.text('Manage habits'), findsOneWidget);
      expect(find.byTooltip('Edit Water'), findsOneWidget);

      await tester.tap(find.byTooltip('Archive Stretch'));
      await tester.pumpAndSettle();
      expect(
        find.text('Stretch archived. Its history is kept.'),
        findsOneWidget,
      );
      expect(find.text('Archived'), findsOneWidget);
      final stretch = (await db.select(db.habits).get()).firstWhere(
        (h) => h.name == 'Stretch',
      );
      expect(stretch.isActive, isFalse);
      expect(stretch.deletedAt, isNull);

      await goBack(tester);
      expect(find.text('Stretch'), findsNothing); // gone from Healthy Habits

      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Restore Stretch'));
      await tester.pumpAndSettle();
      expect(
        (await db.select(db.habits).get())
            .firstWhere((h) => h.name == 'Stretch')
            .isActive,
        isTrue,
      );
    });

    appTest('an archived habit stops its reminders', (tester, db) async {
      testScheduler.permitted = true;
      await addHabit(
        db,
        reminders: true,
        config: const ReminderConfig(
          mode: ReminderMode.times,
          times: [12 * 60],
        ),
      );
      await tester.pumpAndSettle();
      expect(testScheduler.planned, isNotEmpty);
      await openHabits(tester);
      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Archive Water'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 4; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(testScheduler.planned, isEmpty);
    });

    appTest('editing from Manage saves changes', (tester, db) async {
      await addHabit(db, name: 'Water');
      await tester.pumpAndSettle();
      await openHabits(tester);
      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit Water'));
      await tester.pumpAndSettle();
      expect(find.text('Edit habit'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Water bottle');
      await save(tester);
      expect((await db.select(db.habits).get()).single.name, 'Water bottle');
    });
  });

  group('permission warning', () {
    appTest('shows a non-blocking warning with a settings shortcut', (
      tester,
      db,
    ) async {
      testScheduler.permitted = false;
      await addHabit(
        db,
        reminders: true,
        config: const ReminderConfig(
          mode: ReminderMode.times,
          times: [12 * 60],
        ),
      );
      await tester.pumpAndSettle();
      await openHabits(tester);
      expect(find.byKey(const Key('notification-warning')), findsOneWidget);
      expect(find.textContaining('you can still log habits'), findsOneWidget);

      await tester.tap(find.text('Open notification settings'));
      await tester.pumpAndSettle();
      expect(testSystem.notificationsOpened, 1);

      // Logging in the app still works, and the settings are kept.
      await tester.tap(find.text('Water'));
      await tester.pumpAndSettle();
      expect(find.textContaining('1/4'), findsOneWidget);
      expect(
        (await db.select(db.habits).get()).single.remindersEnabled,
        isTrue,
      );
    });

    appTest('is hidden when notifications are allowed', (tester, db) async {
      testScheduler.permitted = true;
      await addHabit(db, reminders: true);
      await tester.pumpAndSettle();
      await openHabits(tester);
      expect(find.byKey(const Key('notification-warning')), findsNothing);
    });

    appTest('is hidden when no habit has reminders on', (tester, db) async {
      testScheduler.permitted = false;
      await addHabit(db, reminders: false);
      await tester.pumpAndSettle();
      await openHabits(tester);
      expect(find.byKey(const Key('notification-warning')), findsNothing);
    });

    appTest('also appears on the Reminders screen', (tester, db) async {
      testScheduler.permitted = false;
      await addHabit(db, reminders: true);
      await tester.pumpAndSettle();
      await openHabits(tester);
      await tester.tap(find.byTooltip('Reminders'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('notification-warning')), findsOneWidget);
    });
  });

  group('recommendation cards', () {
    appTest('are shown with the disclaimer and the source', (tester, db) async {
      await addHabit(db);
      await tester.pumpAndSettle();
      await openHabits(tester);
      final card = find.byKey(const Key('recommendation-rec-water-1'));
      await tester.scrollUntilVisible(card, 200);
      expect(card, findsOneWidget);
      expect(find.textContaining(recommendationDisclaimer), findsWidgets);
      expect(find.textContaining('Source: NHS'), findsOneWidget);
    });

    appTest('movement cards show for a stretch habit', (tester, db) async {
      await addHabit(db, name: 'Stretch', kind: HabitKind.stretch);
      await tester.pumpAndSettle();
      await openHabits(tester);
      final card = find.byKey(const Key('recommendation-rec-stretch-1'));
      await tester.scrollUntilVisible(card, 200);
      expect(card, findsOneWidget);
      expect(find.textContaining('Source: Mayo Clinic'), findsOneWidget);
    });

    appTest('starter cards show before any habit exists', (tester, db) async {
      await openHabits(tester);
      expect(
        find.byKey(const Key('recommendation-rec-water-1')),
        findsOneWidget,
      );
    });
  });

  group('recommendation library', () {
    test('every card ends exactly with the disclaimer', () {
      expect(
        recommendationDisclaimer,
        'General wellness information only; not medical advice.',
      );
      for (final r in habitRecommendations) {
        expect(r.text.endsWith(recommendationDisclaimer), isTrue, reason: r.id);
      }
    });

    test('sources are kept with their links', () {
      final water = habitRecommendations.firstWhere(
        (r) => r.habitKind == 'water',
      );
      expect(
        water.sourceUrl,
        'https://www.nhs.uk/live-well/eat-well/food-guidelines-and-food-labels/water-drinks-nutrition/',
      );
      final move = habitRecommendations.firstWhere(
        (r) => r.habitKind == 'stand',
      );
      expect(
        move.sourceUrl,
        'https://www.mayoclinic.org/healthy-lifestyle/adult-health/in-depth/sitting/art-20043914',
      );
      for (final r in habitRecommendations) {
        expect(r.sourceLabel, isNotEmpty);
        expect(r.sourceUrl.startsWith('https://'), isTrue);
      }
    });

    test('calm, general and non-prescriptive', () {
      for (final r in habitRecommendations) {
        expect(r.text.contains('!'), isFalse, reason: r.id);
        expect(r.title.contains('!'), isFalse, reason: r.id);
        // No fixed amounts: no digits, litres, glasses a day, or targets.
        expect(
          RegExp(
            r'\d|\b(litre|liter|ml|cups? a day|glasses a day|you should|you must|cure|treat|diagnos|disease|medication)\b',
            caseSensitive: false,
          ).hasMatch(r.text),
          isFalse,
          reason: r.id,
        );
      }
    });

    test('recommendationsFor matches the habits tracked', () {
      expect(recommendationsFor(['water']).map((r) => r.id), ['rec-water-1']);
      expect(recommendationsFor(['stretch', 'stand']).map((r) => r.id), [
        'rec-stand-1',
        'rec-stretch-1',
      ]);
      // Nothing matching: starter cards, not the stretch one.
      expect(recommendationsFor(['skinCare']).map((r) => r.id), [
        'rec-water-1',
        'rec-stand-1',
      ]);
      expect(recommendationsFor(const []).map((r) => r.id), [
        'rec-water-1',
        'rec-stand-1',
      ]);
    });
  });
}
