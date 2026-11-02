import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/features/chat/coach_logic.dart';
import 'package:wellbeing/features/goals/goal_logic.dart';

import '../test_helpers.dart';

CategoryGoal goal(GoalCategory c, double f, int met, int total, String unit) =>
    CategoryGoal(category: c, fraction: f, met: met, total: total, unit: unit);

void main() {
  const week = '11 – 17 May';

  group('answers', () {
    test('with no goals every goal question says so and invents nothing', () {
      const d = CoachData(weekLabel: week, goals: []);
      for (final q in [
        CoachQuestion.weekProgress,
        CoachQuestion.needAttention,
        CoachQuestion.nextStep,
      ]) {
        final a = answerFor(q, d);
        expect(a.text, contains('not set any goals'));
        expect(a.basis, 'No goals are set.');
      }
    });

    test('week progress gives the overall share and each category', () {
      final d = CoachData(
        weekLabel: week,
        goals: [
          goal(GoalCategory.workout, 2 / 3, 2, 3, 'sessions'),
          goal(GoalCategory.sleep, 1, 7, 7, 'days'),
        ],
      );
      final a = answerFor(CoachQuestion.weekProgress, d);
      expect(a.text, contains('83% of your goals are met so far this week.'));
      expect(a.text, contains('Workout: 2 of 3 sessions'));
      expect(a.text, contains('Sleep: 7 of 7 days'));
      expect(a.basis, contains(week));
      expect(a.basis, contains('still in progress'));
    });

    test('goals needing attention are the furthest from target first', () {
      final d = CoachData(
        weekLabel: week,
        goals: [
          goal(GoalCategory.sleep, 0.9, 6, 7, 'days'),
          goal(GoalCategory.screen, 0.2, 1, 7, 'days'),
          goal(GoalCategory.workout, 1, 3, 3, 'sessions'),
        ],
      );
      final a = answerFor(CoachQuestion.needAttention, d);
      expect(a.text.indexOf('Screen time'), lessThan(a.text.indexOf('Sleep')));
      expect(a.text, isNot(contains('Workout')));
    });

    test('met goals are reported as met', () {
      final d = CoachData(
        weekLabel: week,
        goals: [goal(GoalCategory.workout, 1, 3, 3, 'sessions')],
      );
      expect(
        answerFor(CoachQuestion.needAttention, d).text,
        'All of your goals are met so far this week.',
      );
      expect(
        answerFor(CoachQuestion.nextStep, d).text,
        contains('Nothing more'),
      );
    });

    test('the next step names one goal and one small action', () {
      final d = CoachData(
        weekLabel: week,
        goals: [
          goal(GoalCategory.habits, 0.5, 3, 7, 'days'),
          goal(GoalCategory.hobbies, 0.1, 0, 1, 'goals'),
        ],
      );
      final a = answerFor(CoachQuestion.nextStep, d);
      expect(a.text, startsWith('Hobbies is furthest from its target.'));
      expect(a.text, contains('Ten minutes'));
    });

    test('sleep consistency uses the last 7 logs, or says there is none', () {
      expect(
        answerFor(
          CoachQuestion.sleep,
          const CoachData(weekLabel: week, goals: []),
        ).text,
        contains('nothing to report yet'),
      );
      final a = answerFor(
        CoachQuestion.sleep,
        const CoachData(
          weekLabel: week,
          goals: [],
          sleepOnSchedule: 5,
          sleepDays: 7,
        ),
      );
      expect(a.text, '5 of 7 days on schedule.');
      expect(a.basis, contains('30 minutes'));
    });

    test('no answer contains an exclamation mark or medical claim', () {
      final d = CoachData(
        weekLabel: week,
        goals: [
          for (final c in GoalCategory.values) goal(c, 0.3, 1, 7, 'days'),
        ],
        sleepOnSchedule: 3,
        sleepDays: 7,
      );
      for (final q in CoachQuestion.values) {
        final a = answerFor(q, d);
        expect('${a.text}${a.basis}${q.label}'.contains('!'), isFalse);
      }
      expect(coachDisclaimer, contains('not medical advice'));
    });
  });

  group('screen', () {
    appTest('questions are answered from the person’s own data', (
      tester,
      db,
    ) async {
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();

      expect(find.text('Ask the coach'), findsOneWidget);
      await tester.tap(find.text('How am I doing this week?'));
      await tester.pumpAndSettle();
      // Sleep always has a default target, so it is the one goal here.
      expect(find.textContaining('0% of your goals are met'), findsOneWidget);
      expect(find.textContaining('Sleep: 0 of 7 days'), findsOneWidget);
      expect(find.textContaining('11 – 17 May'), findsOneWidget);
      expect(find.text(coachDisclaimer), findsOneWidget);

      await tester.tap(find.text('How consistent was my sleep?'));
      await tester.pumpAndSettle();
      expect(find.textContaining('nothing to report yet'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });
  });
}
