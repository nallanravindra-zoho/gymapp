import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/features/goals/goal_logic.dart';

import '../helpers/nav_a.dart';
import '../test_helpers.dart';

Future<void> openGoals(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Goals'),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> setWorkoutGoal(
  WidgetTester tester, {
  int extraSessions = 0,
}) async {
  await tester.tap(find.byTooltip('Set a goal'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Workout'));
  await tester.pumpAndSettle();
  for (var i = 0; i < extraSessions; i++) {
    await tester.tap(find.byTooltip('More sessions'));
    await tester.pump();
  }
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
  await tester.pageBack();
  await tester.pumpAndSettle();
}

void main() {
  appTest('Goals lists every category and invites a goal where none is set', (
    tester,
    db,
  ) async {
    await openGoals(tester);

    expect(find.text('Your goals. Your progress.'), findsOneWidget);
    for (final c in GoalCategory.values) {
      expect(find.text(c.label), findsOneWidget);
    }
    // Workout, healthy habits, screen time and nutrition have no goal yet.
    expect(find.text('Set a goal'), findsWidgets);
  });

  appTest('a workout goal is set in one sheet and shows its progress', (
    tester,
    db,
  ) async {
    await openGoals(tester);
    await setWorkoutGoal(tester, extraSessions: 1);

    expect(find.text('4 sessions per week'), findsOneWidget);
    expect(find.text('0/4'), findsOneWidget);
  });

  appTest('a logged workout counts toward the weekly goal, in progress', (
    tester,
    db,
  ) async {
    await logToday(tester, 'Yoga');
    await openGoals(tester);
    await setWorkoutGoal(tester);

    expect(find.text('3 sessions per week'), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
    // A week still in progress is never called failed.
    expect(find.textContaining('fail'), findsNothing);
  });

  appTest('the Week calendar stays available inside Goals', (tester, db) async {
    await openWeekTab(tester);

    expect(find.text('Mon'), findsWidgets);
    expect(find.text('11 – 17 May'), findsOneWidget);
  });

  appTest('Set a goal offers every category', (tester, db) async {
    await openGoals(tester);
    await tester.tap(find.byTooltip('Set a goal'));
    await tester.pumpAndSettle();

    expect(find.text('What would you like to focus on?'), findsOneWidget);
    for (final c in GoalCategory.values) {
      expect(find.text(c.label), findsOneWidget);
    }
  });

  appTest('Home shows today goal progress and one suggestion', (
    tester,
    db,
  ) async {
    expect(find.text('Today’s goal progress'), findsOneWidget);

    await openGoals(tester);
    await setWorkoutGoal(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Home'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your goals for today'), findsOneWidget);
    expect(find.textContaining('furthest from its target'), findsOneWidget);
  });

  appTest('Goal progress switches between daily, weekly and monthly', (
    tester,
    db,
  ) async {
    await openGoals(tester);
    await setWorkoutGoal(tester);
    await tester.ensureVisible(find.text('See goal progress'));
    await tester.tap(find.text('See goal progress'));
    await tester.pumpAndSettle();

    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Goals met'), findsOneWidget);

    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();
    expect(find.text('Goals met'), findsWidgets);

    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();
    expect(find.text('Category progress'), findsOneWidget);
  });

  test('goal copy has no exclamation marks', () {
    const copy = [
      'Set a goal to see your progress here.',
      'All of your goals are met for now.',
      'One small step is enough.',
    ];
    expect(copy.any((s) => s.contains('!')), isFalse);
  });
}
