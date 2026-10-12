import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/features/account/auth_service.dart';
import 'package:wellbeing/features/groups/group_categories_ui.dart';
import 'package:wellbeing/features/groups/groups_models.dart';
import 'package:wellbeing/features/groups/groups_remote.dart';

import '../test_helpers.dart';

const me = 'me';

FakeAuthService signedInAuth() => FakeAuthService(
  signedIn: const AccountUser(id: me, displayName: 'Divya'),
);

/// Divya (shares workouts and Healthy Habits, the defaults), Asha, Ben.
/// Workouts and habits have data for all three. Sleep: Asha and Ben share
/// it and have data; Divya does not share sleep. Screen time: only Asha.
FakeGroupsRemote crew({bool meSleep = false}) {
  final s = FakeGroupsRemote(me: me, myName: 'Divya');
  final g = s.seedGroup('Sunday crew', id: 'g1', owner: 'asha', code: '1111');
  s.addMember(g.id, 'ben', 'Ben', shareSleep: true);
  // addMember for the owner happened inside seedGroup with the defaults.
  s.setMemberSharing('g1', 'asha', sleep: true, screenTime: true);
  const workouts = {'active_minutes': 98, 'active_days': 2, 'sessions': 3};
  s.seedScores(g.id, 'asha', GroupCategory.workouts, 9, metrics: workouts);
  s.seedScores(g.id, 'ben', GroupCategory.workouts, 7, metrics: workouts);
  s.seedScores(g.id, me, GroupCategory.workouts, 5, metrics: workouts);
  const habits = {'days_logged': 3, 'targets_met': 4, 'habits_tracked': 2};
  s.seedScores(g.id, 'asha', GroupCategory.habits, 6, metrics: habits);
  s.seedScores(g.id, 'ben', GroupCategory.habits, 8, metrics: habits);
  const sleep = {
    'nights': 5,
    'average_minutes': 450,
    'target_minutes': 480,
    'nights_near_target': 3,
  };
  s.seedScores(
    g.id,
    'asha',
    GroupCategory.sleep,
    9,
    metrics: sleep,
    daily: [
      (date: '2026-05-11', amount: 470),
      (date: '2026-05-12', amount: 430),
    ],
  );
  s.seedScores(g.id, 'ben', GroupCategory.sleep, 4, metrics: sleep);
  s.seedScores(
    g.id,
    'asha',
    GroupCategory.screenTime,
    7,
    metrics: {'days': 3, 'average_minutes': 130, 'days_within_limit': 1},
  );
  if (meSleep) s.setMemberSharing(g.id, me, sleep: true);
  return s;
}

Future<void> openGroup(WidgetTester tester) async {
  await tester.tap(find.text('Groups'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Sunday crew'));
  await tester.pumpAndSettle();
}

Future<void> tapTab(WidgetTester tester, String label) async {
  final tab = find.descendant(
    of: find.byType(GroupTabBar),
    matching: find.text(label),
  );
  await tester.ensureVisible(tab);
  await tester.pumpAndSettle();
  await tester.tap(tab);
  await tester.pumpAndSettle();
}

List<String> tabLabels(WidgetTester tester) => [
  for (final t in GroupTab.values)
    if (find
        .descendant(of: find.byType(GroupTabBar), matching: find.text(t.label))
        .evaluate()
        .isNotEmpty)
      t.label,
];

/// Every string the group screen shows or announces, to look for numbers.
List<String> everyText(WidgetTester tester) => [
  for (final e in find.byType(Text).evaluate())
    if ((e.widget as Text).data != null) (e.widget as Text).data!,
  for (final e in find.byType(Semantics).evaluate())
    if ((e.widget as Semantics).properties.label != null)
      (e.widget as Semantics).properties.label!,
];

final vertical = find
    .byWidgetPredicate((w) => w is Scrollable && w.axis == Axis.vertical)
    .first;

/// Scrolls to a widget and taps it.
Future<void> scrollTap(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(f, 200, scrollable: vertical);
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  group('tabs', () {
    appTest(
      'show only the categories you share that have enough data',
      (tester, db) async {
        await openGroup(tester);
        // Divya shares workouts and habits: Overall, Workouts, Healthy
        // Habits. Sleep has data from two members but she does not share it,
        // and screen time has only one member.
        expect(tabLabels(tester), ['Overall', 'Workouts', 'Healthy Habits']);
      },
      auth: signedInAuth(),
      groups: crew(),
    );

    appTest(
      'sleep appears once you opt in',
      (tester, db) async {
        await openGroup(tester);
        expect(tabLabels(tester), isNot(contains('Sleep Health')));
        await tester.tap(find.byTooltip('Group settings'));
        await tester.pumpAndSettle();
        await scrollTap(
          tester,
          find.widgetWithText(SwitchListTile, 'Sleep Health'),
        );
        expect(testGroups.sharing('g1', me)!.sleep, isTrue);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(tabLabels(tester), contains('Sleep Health'));
        expect(tabLabels(tester), isNot(contains('Screen Time')));
      },
      auth: signedInAuth(),
      groups: crew(),
    );

    appTest(
      'with nothing shared yet the screen explains when tabs appear',
      (tester, db) async {
        await openGroup(tester);
        expect(tabLabels(tester), isEmpty);
        expect(find.textContaining('at least 2 members'), findsOneWidget);
      },
      auth: signedInAuth(),
      groups: FakeGroupsRemote(me: me)
        ..seedGroup('Sunday crew', id: 'g1', owner: me, code: '1111'),
    );

    appTest(
      'the category tabs say what the ranking is based on',
      (tester, db) async {
        await openGroup(tester);
        expect(
          find.text('Ranked on the categories each person shares.'),
          findsOneWidget,
        );
        await tapTab(tester, 'Healthy Habits');
        expect(find.textContaining('own targets'), findsOneWidget);
        // Ben 8, Asha 6; Divya has no habit data and is not listed.
        final board = find.byType(CategoryBoardCard);
        expect(
          find.descendant(of: board, matching: find.text('Ben')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: board,
            matching: find.text('Owner of Sunday crew'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: board, matching: find.text('You')),
          findsNothing,
        );
      },
      auth: signedInAuth(),
      groups: crew(),
    );

    appTest(
      'Workouts keeps the volume and consistency totals',
      (tester, db) async {
        await openGroup(tester);
        await tapTab(tester, 'Workouts');
        expect(find.text('Weekly totals'), findsOneWidget);
        expect(find.text('Volume'), findsOneWidget);
        await scrollTap(tester, find.text('Consistency'));
        await tester.dragUntilVisible(
          find.text('5 days'),
          find.byType(RefreshIndicator),
          const Offset(0, -200),
        );
        expect(find.text('5 days'), findsOneWidget);
      },
      auth: signedInAuth(),
      groups: crew()
        ..setTotals('g1', 'asha', 120, 4)
        ..setTotals('g1', 'ben', 45, 5)
        ..setTotals('g1', me, 45, 2),
    );
  });

  group('Overall', () {
    appTest(
      'shows rank and contribution chips, and never a number',
      (tester, db) async {
        await openGroup(tester);
        // Asha shares four categories, Ben three, Divya one (workouts): they
        // are compared on what each shares. Ranks are 1, 2, 3.
        final board = find.byType(OverallBoardCard);
        expect(board, findsOneWidget);
        expect(
          find.descendant(of: board, matching: find.text('Workouts')),
          findsNWidgets(3),
        );
        expect(
          find.descendant(of: board, matching: find.text('Habits')),
          findsNWidgets(2),
          reason: 'Divya has no habit data, so it does not count for her',
        );
        // Ranks: 1, 1 and 3.
        final labels = [
          for (final e
              in find
                  .descendant(of: board, matching: find.byType(Semantics))
                  .evaluate())
            if ((e.widget as Semantics).properties.label != null)
              (e.widget as Semantics).properties.label!,
        ];
        expect(labels.where((l) => l.startsWith('1, ')).length, 1);
        expect(labels.where((l) => l.startsWith('2, ')).length, 1);
        expect(labels.where((l) => l.startsWith('3, ')).length, 1);
        expect(labels.join(' '), contains('based on Workouts, Healthy Habits'));

        // No overall (or any) score: the only digits on this screen are the
        // week's dates, member count style words and the ranks.
        final numbers = everyText(tester).where(
          (t) => RegExp(
            r'\d+\.\d|/ ?10|out of 10|score',
            caseSensitive: false,
          ).hasMatch(t),
        );
        expect(numbers, isEmpty, reason: 'no score is shown or announced');
      },
      auth: signedInAuth(),
      groups: crew(),
    );

    appTest(
      'a person who shares more is not ranked on what you do not share',
      (tester, db) async {
        await openGroup(tester);
        // Asha shares sleep and screen time too, but Divya shares neither,
        // so only Workouts and Habits show next to Asha.
        final asha = find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label ?? '').contains('Owner of Sunday crew'),
        );
        expect(asha, findsOneWidget);
        final label = (tester.widget<Semantics>(asha)).properties.label!;
        expect(label, isNot(contains('Sleep')));
        expect(label, isNot(contains('Screen')));
      },
      auth: signedInAuth(),
      groups: crew(),
    );
  });

  group('opening a participant', () {
    appTest(
      'shows their shared figures for the category',
      (tester, db) async {
        await openGroup(tester);
        await tapTab(tester, 'Workouts');
        await tester.tap(find.text('Owner of Sunday crew').first);
        await tester.pumpAndSettle();
        expect(find.text('Shared with this group this week'), findsOneWidget);
        expect(find.text('Active time'), findsOneWidget);
        expect(find.text('1 h 38 min'), findsOneWidget);
        expect(find.text('Sessions'), findsOneWidget);
        // Only the category that was opened.
        expect(find.text('Sleep Health'), findsNothing);
      },
      auth: signedInAuth(),
      groups: crew(),
    );

    appTest(
      'sleep figures and the days open for members who both share it',
      (tester, db) async {
        await openGroup(tester);
        await tapTab(tester, 'Sleep Health');
        await tester.tap(find.text('Owner of Sunday crew').first);
        await tester.pumpAndSettle();
        expect(find.text('Average sleep'), findsOneWidget);
        expect(find.text('7 h 30 min'), findsOneWidget);
        expect(find.text('Own target'), findsOneWidget);
        expect(find.text('Mon 11 May'), findsOneWidget);
        expect(find.text('7 h 50 min'), findsOneWidget);
      },
      auth: signedInAuth(),
      groups: crew(meSleep: true),
    );

    appTest(
      'a member list tap shows only categories shared with you',
      (tester, db) async {
        await openGroup(tester);
        await tester.scrollUntilVisible(
          find.text('Members'),
          300,
          scrollable: vertical,
        );
        // Ben, the member row (the board rows are above).
        await tester.tap(find.text('Ben').last);
        await tester.pumpAndSettle();
        // Divya shares workouts and habits; Ben shares those with data too.
        expect(find.text('Workouts'), findsWidgets);
        expect(find.text('Healthy Habits'), findsWidgets);
        expect(find.text('Sleep Health'), findsNothing);
      },
      auth: signedInAuth(),
      groups: crew(),
    );

    appTest(
      'when nothing is shared with you it says so',
      (tester, db) async {
        await openGroup(tester);
        await tester.scrollUntilVisible(
          find.text('Members'),
          300,
          scrollable: vertical,
        );
        await tester.tap(find.text('Ben').last);
        await tester.pumpAndSettle();
        expect(
          find.textContaining('Nothing from Ben is shared with you'),
          findsOneWidget,
        );
        expect(find.text('Active time'), findsNothing);
      },
      auth: signedInAuth(),
      groups: crew()
        ..setMemberSharing(
          'g1',
          'ben',
          workouts: false,
          habits: false,
          sleep: false,
        ),
    );
  });

  group('choosing what to share', () {
    Future<void> startCreate(WidgetTester tester) async {
      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create group'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Walkers');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
    }

    Finder inSheet(Finder f) =>
        find.descendant(of: find.byType(BottomSheet), matching: f);

    appTest(
      'creating asks first, with sleep and screen time off',
      (tester, db) async {
        await startCreate(tester);
        expect(testGroups.calls, isNot(contains('createGroup')));
        expect(find.text('What would you like to share?'), findsOneWidget);
        expect(find.textContaining('never shared'), findsOneWidget);
        expect(find.textContaining('start off'), findsOneWidget);
        bool on(String title) => tester
            .widget<SwitchListTile>(find.widgetWithText(SwitchListTile, title))
            .value;
        expect(on('Workouts'), isTrue);
        expect(on('Healthy Habits'), isTrue);
        expect(on('Sleep Health'), isFalse);
        expect(on('Screen Time'), isFalse);

        await tester.tap(find.widgetWithText(SwitchListTile, 'Sleep Health'));
        await tester.tap(find.widgetWithText(SwitchListTile, 'Workouts'));
        await tester.pumpAndSettle();
        await tester.tap(inSheet(find.text('Create group')));
        await tester.pumpAndSettle();

        final sharing = testGroups.lastSharing!;
        expect(sharing.sleep, isTrue);
        expect(sharing.workouts, isFalse);
        expect(sharing.screenTime, isFalse);
        final mine =
            testGroups.sharing('g-1', me) ?? testGroups.sharing('g-2', me);
        expect(mine, isNotNull);
        expect(mine!.sleep, isTrue);
      },
      auth: signedInAuth(),
      groups: FakeGroupsRemote(me: me, myName: 'Divya'),
    );

    appTest(
      'cancelling the sheet creates nothing',
      (tester, db) async {
        await startCreate(tester);
        await tester.tap(inSheet(find.text('Cancel')));
        await tester.pumpAndSettle();
        expect(testGroups.calls, isNot(contains('createGroup')));
      },
      auth: signedInAuth(),
      groups: FakeGroupsRemote(me: me, myName: 'Divya'),
    );

    appTest(
      'joining shows the same choices and joins with them',
      (tester, db) async {
        await tester.tap(find.text('Groups'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Join with a code'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), '2222');
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.text('Join Walkers?'), findsOneWidget);
        expect(find.textContaining('choose to share'), findsOneWidget);
        await tester.tap(find.widgetWithText(SwitchListTile, 'Screen Time'));
        await tester.pumpAndSettle();
        await tester.tap(inSheet(find.text('Join')));
        await tester.pumpAndSettle();
        final s = testGroups.sharing('w1', me)!;
        expect(s.screenTime, isTrue);
        expect(s.sleep, isFalse);
        expect(s.workouts, isTrue);
      },
      auth: signedInAuth(),
      groups: FakeGroupsRemote(me: me, myName: 'Divya')
        ..seedGroup(
          'Walkers',
          id: 'w1',
          owner: 'asha',
          includeMe: false,
          code: '2222',
        ),
    );

    appTest(
      'settings shows all four switches and uses Healthy Habits wording',
      (tester, db) async {
        await openGroup(tester);
        await tester.tap(find.byTooltip('Group settings'));
        await tester.pumpAndSettle();
        final scroll = find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axis == Axis.vertical,
            )
            .first;
        for (final title in [
          'Workouts',
          'Healthy Habits',
          'Sleep Health',
          'Screen Time',
        ]) {
          await tester.scrollUntilVisible(
            find.widgetWithText(SwitchListTile, title),
            200,
            scrollable: scroll,
          );
        }
        expect(find.textContaining('Break'), findsNothing);
        expect(find.textContaining('break'), findsNothing);
        await scrollTap(
          tester,
          find.widgetWithText(SwitchListTile, 'Screen Time'),
        );
        expect(testGroups.sharing('g1', me)!.screenTime, isTrue);
        expect(testGroups.sharing('g1', me)!.sleep, isFalse);
        expect(
          find.textContaining('No overall number is shown'),
          findsOneWidget,
        );
      },
      auth: signedInAuth(),
      groups: crew(),
    );
  });
}
