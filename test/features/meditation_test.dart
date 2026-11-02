import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/features/hobbies/chant_controller.dart';
import 'package:wellbeing/features/hobbies/chant_platform.dart';
import 'package:wellbeing/features/meditation/meditation_logic.dart';
import 'package:wellbeing/features/meditation/meditation_screen.dart';

import '../helpers/hobby_helpers.dart' show scrollTo;
import '../test_helpers.dart';
import 'chant_test.dart' show FakeChantPlatform;

void main() {
  group('logic', () {
    test('remaining time counts down and stops at zero', () {
      expect(remainingSeconds(10, Duration.zero), 600);
      expect(remainingSeconds(10, const Duration(minutes: 4, seconds: 7)), 353);
      expect(remainingSeconds(5, const Duration(minutes: 9)), 0);
    });

    test('clock text', () {
      expect(clockText(600), '10:00');
      expect(clockText(247), '4:07');
      expect(clockText(3900), '1:05:00');
    });

    test('a full session is saved and complete', () {
      final o = outcomeOf(
        plannedMinutes: 10,
        elapsed: const Duration(minutes: 12),
      );
      expect(o.saved, isTrue);
      expect(o.completed, isTrue);
      expect(o.seconds, 600);
      expect(o.message, 'Logged. 10 min meditation.');
    });

    test('an early end keeps the time spent, if it was a minute or more', () {
      final o = outcomeOf(
        plannedMinutes: 15,
        elapsed: const Duration(minutes: 4, seconds: 40),
      );
      expect(o.saved, isTrue);
      expect(o.completed, isFalse);
      expect(o.minutes, 5);
    });

    test('a false start is not saved', () {
      final o = outcomeOf(
        plannedMinutes: 10,
        elapsed: const Duration(seconds: 20),
      );
      expect(o.saved, isFalse);
      expect(o.message, 'Session ended. Nothing saved.');
    });

    test('copy has no exclamation marks', () {
      expect(
        [
          'Logged. 10 min meditation.',
          'Session ended. Nothing saved.',
          'Find your calm',
          'A few minutes each day can make a difference.',
        ].any((s) => s.contains('!')),
        isFalse,
      );
    });
  });

  group('screen', () {
    late DateTime now;
    late FakeChantPlatform chant;

    Widget Function(Widget) wrap() {
      now = DateTime.utc(2026, 5, 13, 10);
      chant = FakeChantPlatform();
      return (app) => ProviderScope(
        overrides: [
          chantPlatformProvider.overrideWithValue(chant as ChantPlatform),
          meditationNowProvider.overrideWithValue(() => now),
        ],
        child: app,
      );
    }

    Future<void> openMeditation(WidgetTester tester) async {
      final card = find.byKey(const ValueKey('meditation-card'));
      await scrollTo(tester, card);
      await tester.tap(card);
      await tester.pumpAndSettle();
    }

    appTest('starts with a quick pick and no goal set up', (tester, db) async {
      await openMeditation(tester);
      expect(find.text('Find your calm'), findsOneWidget);
      for (final label in ['5 min', '10 min', '15 min', 'Custom']) {
        expect(find.text(label), findsOneWidget);
      }
      await tester.tap(find.text('5 min'));
      await tester.pump();
      await tester.tap(find.text('Start'));
      await tester.pump();
      expect(find.text('5:00'), findsOneWidget);
      expect(chant.awake, isTrue);
      await tester.pumpWidget(const SizedBox());
    }, wrapApp: wrap());

    appTest('a full session is saved and ends with a chime', (
      tester,
      db,
    ) async {
      await openMeditation(tester);
      await tester.tap(find.text('5 min'));
      await tester.pump();
      await tester.tap(find.text('Start'));
      await tester.pump();

      now = now.add(const Duration(minutes: 5));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Session complete'), findsOneWidget);
      expect(find.text('Logged. 5 min meditation.'), findsOneWidget);
      expect(chant.awake, isFalse);
      final rows = await db.select(db.meditationSessions).get();
      expect(rows.single.plannedMinutes, 5);
      expect(rows.single.durationSeconds, 300);
      expect(rows.single.completed, isTrue);
    }, wrapApp: wrap());

    appTest('ending early keeps the time, a false start keeps nothing', (
      tester,
      db,
    ) async {
      await openMeditation(tester);
      await tester.tap(find.text('Start'));
      await tester.pump();
      now = now.add(const Duration(seconds: 20));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('End session'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('End session').last);
      await tester.pumpAndSettle();
      expect(find.text('Session ended. Nothing saved.'), findsOneWidget);
      expect(await db.select(db.meditationSessions).get(), isEmpty);

      await tester.tap(find.text('Meditate again'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start'));
      await tester.pump();
      now = now.add(const Duration(minutes: 3));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('End session'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('End session').last);
      await tester.pumpAndSettle();
      expect(find.text('Logged. 3 min meditation.'), findsOneWidget);
      final row = (await db.select(db.meditationSessions).get()).single;
      expect(row.completed, isFalse);
      expect(row.durationSeconds, 180);
    }, wrapApp: wrap());

    appTest('a custom length can be chosen', (tester, db) async {
      await openMeditation(tester);
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '25');
      await tester.tap(find.text('Use'));
      await tester.pumpAndSettle();
      expect(find.text('25 min'), findsOneWidget);
      await tester.tap(find.text('Start'));
      await tester.pump();
      expect(find.text('25:00'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    }, wrapApp: wrap());
  });
}
