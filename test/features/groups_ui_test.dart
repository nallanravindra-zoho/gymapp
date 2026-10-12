import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/core/theme/app_theme.dart';
import 'package:wellbeing/features/account/auth_service.dart';
import 'package:wellbeing/features/groups/groups_models.dart';
import 'package:wellbeing/features/groups/groups_providers.dart';
import 'package:wellbeing/features/groups/groups_remote.dart';
import 'package:wellbeing/features/groups/groups_screen.dart';

import '../helpers/nav_c.dart';
import '../test_helpers.dart';

const me = 'me';

FakeAuthService signedInAuth() => FakeAuthService(
  signedIn: const AccountUser(id: me, displayName: 'Divya'),
);

FakeGroupsRemote server() => FakeGroupsRemote(me: me, myName: 'Divya');

/// A group of three with some activity, as the signed-in person sees it.
FakeGroupsRemote withCrew() {
  final s = server();
  final g = s.seedGroup('Sunday crew', id: 'g1', owner: 'asha', code: '1111');
  s.addMember(g.id, 'ben', 'Ben');
  s.setTotals(g.id, 'asha', 120, 4);
  s.setTotals(g.id, 'ben', 45, 5);
  s.setTotals(g.id, me, 45, 2);
  s.addEvent(g.id, 'asha', GroupEventKind.workout, {
    'type_id': 'builtin-yoga',
    'duration_minutes': 30,
  }, DateTime.utc(2026, 5, 13, 8));
  s.addEvent(g.id, 'ben', GroupEventKind.breakGoal, {
    'habit_name': 'Water',
  }, DateTime.utc(2026, 5, 12, 17, 30));
  s.addEvent(g.id, me, GroupEventKind.workout, {
    'type_id': 'builtin-walk',
    'duration_minutes': 20,
  }, DateTime.utc(2026, 5, 11, 7));
  // This week's scores (only used to rank; never shown).
  for (final (u, score) in [('asha', 8.0), ('ben', 6.0), (me, 5.0)]) {
    s.seedScores(
      g.id,
      u,
      GroupCategory.workouts,
      score,
      metrics: {'active_minutes': 120, 'active_days': 4, 'sessions': 4},
    );
  }
  return s;
}

Future<void> openGroupsTab(WidgetTester tester) async {
  await tester.tap(find.text('Groups'));
  await tester.pumpAndSettle();
}

Future<void> openGroup(WidgetTester tester, String name) async {
  await openGroupsTab(tester);
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
}

/// Switches the group screen to its Workouts tab.
Future<void> openWorkoutsTab(WidgetTester tester) async {
  await tester.tap(find.text('Workouts').first);
  await tester.pumpAndSettle();
}

/// Confirms the sharing sheet that opens before creating or joining.
Future<void> confirmSheet(WidgetTester tester, String action) async {
  await tester.tap(
    find.descendant(of: find.byType(BottomSheet), matching: find.text(action)),
  );
  await tester.pumpAndSettle();
}

final verticalScrollable = find
    .byWidgetPredicate((w) => w is Scrollable && w.axis == Axis.vertical)
    .first;

/// Scrolls the settings screen until a sharing switch is on screen.
Future<void> showSwitch(WidgetTester tester, String title) async {
  await tester.scrollUntilVisible(
    find.widgetWithText(SwitchListTile, title),
    200,
    scrollable: verticalScrollable,
  );
  await tester.pumpAndSettle();
}

Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Group settings'));
  await tester.pumpAndSettle();
}

Future<void> typeInto(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
}

/// Names shown in the leaderboard card, top to bottom.
List<String> leaderboardRows(WidgetTester tester) => leaderboardRowsOf(tester);

void main() {
  group('before there is a group', () {
    appTest('signed out: explains that groups need an account', (
      tester,
      db,
    ) async {
      await openGroupsTab(tester);
      expect(find.text('Groups need an account'), findsOneWidget);
      expect(find.textContaining('stay private'), findsOneWidget);
      expect(find.text('Create group'), findsNothing);
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      // Sign in opens the profile hub; sign-in itself is under Account & sync.
      await tester.tap(find.text('App Management'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Account & sync'));
      await tester.pumpAndSettle();
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('a build without a backend says groups are not available', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            groupsRemoteProvider.overrideWithValue(UnavailableGroupsRemote()),
          ],
          child: MaterialApp(
            theme: buildTheme(Brightness.light),
            home: const GroupsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Groups are not available in this build'),
        findsOneWidget,
      );
      expect(find.text('Create group'), findsNothing);
    });

    appTest(
      'signed in with no groups: invites you to create or join',
      (tester, db) async {
        await openGroupsTab(tester);
        expect(find.textContaining('No groups yet'), findsOneWidget);
        expect(find.text('Create group'), findsOneWidget);
        expect(find.text('Join with a code'), findsOneWidget);
      },
      auth: signedInAuth(),
      groups: server(),
    );

    appTest(
      'a list that cannot load offers to try again',
      (tester, db) async {
        await openGroupsTab(tester);
        expect(find.text('Could not load your groups.'), findsOneWidget);
        await tester.tap(find.text('Try again'));
        await tester.pumpAndSettle();
        expect(find.textContaining('No groups yet'), findsOneWidget);
      },
      auth: signedInAuth(),
      groups: server()..failNext = GroupsProblem.network,
    );
  });

  group('creating a group', () {
    appTest(
      'opens the new group with you as its owner',
      (tester, db) async {
        await openGroupsTab(tester);
        await tester.tap(find.text('Create group'));
        await tester.pumpAndSettle();
        await typeInto(tester, '  Sunday crew ');
        await tester.tap(find.text('Create'));
        await tester.pumpAndSettle();
        await confirmSheet(tester, 'Create group');

        expect(find.text('Sunday crew'), findsWidgets);
        expect(find.text('This week'), findsOneWidget);
        expect(find.text('Owner'), findsOneWidget);
        expect(find.text('You'), findsWidgets);

        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.textContaining('1 member'), findsOneWidget);
      },
      auth: signedInAuth(),
      groups: server(),
    );

    appTest(
      'an empty name does nothing',
      (tester, db) async {
        await openGroupsTab(tester);
        await tester.tap(find.text('Create group'));
        await tester.pumpAndSettle();
        await typeInto(tester, '   ');
        await tester.tap(find.text('Create'));
        await tester.pumpAndSettle();
        expect(find.text('New group'), findsOneWidget, reason: 'dialog stays');
        expect(testGroups.calls, isNot(contains('createGroup')));
      },
      auth: signedInAuth(),
      groups: server(),
    );

    appTest(
      'a server refusal is shown in plain words',
      (tester, db) async {
        await openGroupsTab(tester);
        testGroups.failNext = GroupsProblem.tooManyGroups;
        await tester.tap(find.text('Create group'));
        await tester.pumpAndSettle();
        await typeInto(tester, 'One more');
        await tester.tap(find.text('Create'));
        await tester.pumpAndSettle();
        await confirmSheet(tester, 'Create group');
        expect(
          find.text('You are in the maximum number of groups.'),
          findsOneWidget,
        );
      },
      auth: signedInAuth(),
      groups: server(),
    );
  });

  group('joining by invite', () {
    FakeGroupsRemote other() {
      final s = server();
      s.seedGroup(
        'Walkers',
        id: 'w1',
        owner: 'asha',
        includeMe: false,
        code: '2222',
      );
      return s;
    }

    appTest(
      'a pasted link asks for confirmation, then joins',
      (tester, db) async {
        await openGroupsTab(tester);
        await tester.tap(find.text('Join with a code'));
        await tester.pumpAndSettle();
        await typeInto(tester, '2222');
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        expect(find.text('Join Walkers?'), findsOneWidget);
        expect(find.textContaining('1 member'), findsOneWidget);
        expect(find.textContaining('choose to share'), findsOneWidget);
        expect(testGroups.isMember('w1'), isFalse, reason: 'not joined yet');

        await tester.tap(find.text('Join'));
        await tester.pumpAndSettle();
        expect(testGroups.isMember('w1'), isTrue);
        expect(find.text('This week'), findsOneWidget, reason: 'group opened');
      },
      auth: signedInAuth(),
      groups: other(),
    );

    appTest(
      'cancelling the confirmation joins nothing',
      (tester, db) async {
        await openGroupsTab(tester);
        await tester.tap(find.text('Join with a code'));
        await tester.pumpAndSettle();
        await typeInto(tester, '2222');
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(testGroups.isMember('w1'), isFalse);
      },
      auth: signedInAuth(),
      groups: other(),
    );

    appTest(
      'an unknown code is explained',
      (tester, db) async {
        await openGroupsTab(tester);
        await tester.tap(find.text('Join with a code'));
        await tester.pumpAndSettle();
        await typeInto(tester, 'zzzzzzzzzzzz');
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(
          find.text('That invite is not valid. Ask for a new one.'),
          findsOneWidget,
        );
      },
      auth: signedInAuth(),
      groups: other(),
    );

    appTest(
      'text that cannot be a code never reaches the server',
      (tester, db) async {
        await openGroupsTab(tester);
        await tester.tap(find.text('Join with a code'));
        await tester.pumpAndSettle();
        await typeInto(tester, 'hi');
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(
          find.text('That invite is not valid. Ask for a new one.'),
          findsOneWidget,
        );
        expect(testGroups.calls, isNot(contains('previewInvite')));
      },
      auth: signedInAuth(),
      groups: other(),
    );

    appTest(
      'after five wrong codes further tries are refused, then allowed again',
      (tester, db) async {
        await openGroupsTab(tester);
        Future<void> tryCode(String code) async {
          await tester.tap(find.text('Join with a code'));
          await tester.pumpAndSettle();
          await typeInto(tester, code);
          await tester.tap(find.text('Continue'));
          await tester.pumpAndSettle();
        }

        for (var i = 0; i < 5; i++) {
          await tryCode('900$i');
          expect(
            find.text('That invite is not valid. Ask for a new one.'),
            findsOneWidget,
          );
        }
        // Even the right code is refused now.
        await tryCode('2222');
        expect(
          find.text(
            'Too many wrong codes. Wait about 15 minutes and try again.',
          ),
          findsOneWidget,
        );
        expect(testGroups.isMember('w1'), isFalse);

        testGroups.forgetWrongCodes();
        await tryCode('2222');
        expect(find.text('Join Walkers?'), findsOneWidget);
      },
      auth: signedInAuth(),
      groups: other(),
    );

    appTest(
      'a full group says so',
      (tester, db) async {
        await openGroupsTab(tester);
        await tester.tap(find.text('Join with a code'));
        await tester.pumpAndSettle();
        await typeInto(tester, '2222');
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        testGroups.failNext = GroupsProblem.groupFull;
        await tester.tap(find.text('Join'));
        await tester.pumpAndSettle();
        expect(find.text('This group is full.'), findsOneWidget);
        expect(testGroups.isMember('w1'), isFalse);
      },
      auth: signedInAuth(),
      groups: other(),
    );

    appTest(
      'a group you are already in just opens',
      (tester, db) async {
        await openGroupsTab(tester);
        // Already in a group, so the join option lives behind the + action.
        expect(find.text('Join with a code'), findsNothing);
        await addGroupAction(tester, 'Join with a code');
        await typeInto(tester, '1111');
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.textContaining('Join Sunday crew?'), findsNothing);
        expect(find.text('This week'), findsOneWidget);
      },
      auth: signedInAuth(),
      groups: withCrew(),
    );
  });

  group('the group screen', () {
    appTest(
      'lists the groups you are in with member counts',
      (tester, db) async {
        await openGroupsTab(tester);
        expect(find.text('Sunday crew'), findsOneWidget);
        expect(find.textContaining('3 members'), findsOneWidget);
        // The first group's leaderboard preview is on the same screen.
        expect(find.text('Leaderboards'), findsOneWidget);
      },
      auth: signedInAuth(),
      groups: withCrew(),
    );

    appTest(
      'shows this week and ranks by volume by default',
      (tester, db) async {
        await openGroup(tester, 'Sunday crew');
        await openWorkoutsTab(tester);
        expect(find.text('11 – 17 May'), findsOneWidget);
        // Volume: Asha 120, then Ben and Divya tied on 45 minutes.
        final rows = leaderboardRows(tester);
        expect(rows.first, '1 Owner of Sunday crew');
        expect(rows.sublist(1).toSet(), {'2 Ben', '2 You'});
        expect(find.text('2 h'), findsOneWidget);
      },
      auth: signedInAuth(),
      groups: withCrew(),
    );

    appTest(
      'Consistency re-ranks by active days',
      (tester, db) async {
        await openGroup(tester, 'Sunday crew');
        await openWorkoutsTab(tester);
        await tester.tap(find.text('Consistency'));
        await tester.pumpAndSettle();
        // Ben 5 days, Asha 4, Divya 2.
        expect(leaderboardRows(tester), [
          '1 Ben',
          '2 Owner of Sunday crew',
          '3 You',
        ]);
        expect(find.text('5 days'), findsOneWidget);
        await tester.tap(find.text('Volume'));
        await tester.pumpAndSettle();
        expect(leaderboardRows(tester).first, '1 Owner of Sunday crew');
      },
      auth: signedInAuth(),
      groups: withCrew(),
    );

    appTest(
      'members who do not share workouts are not listed',
      (tester, db) async {
        await openGroup(tester, 'Sunday crew');
        await openWorkoutsTab(tester);
        expect(leaderboardRows(tester).join(), isNot(contains('Dev')));
        await tester.scrollUntilVisible(
          find.text('Dev'),
          300,
          scrollable: verticalScrollable,
        );
        expect(find.text('Dev'), findsOneWidget, reason: 'still a member');
      },
      auth: signedInAuth(),
      groups: withCrew()
        ..addMember('g1', 'dev', 'Dev', shareWorkouts: false)
        ..setTotals('g1', 'dev', 999, 7),
    );

    appTest(
      'the feed describes activity, newest first, in neutral words',
      (tester, db) async {
        await openGroup(tester, 'Sunday crew');
        final lines = [
          'Owner of Sunday crew logged Yoga for 30 min.',
          'Ben met the Water goal.',
          'You logged Walk for 20 min.',
        ];
        for (final l in lines) {
          expect(find.text(l), findsOneWidget);
        }
        expect(
          tester.getTopLeft(find.text(lines[0])).dy,
          lessThan(tester.getTopLeft(find.text(lines[1])).dy),
        );
        expect(
          tester.getTopLeft(find.text(lines[1])).dy,
          lessThan(tester.getTopLeft(find.text(lines[2])).dy),
        );
        expect(find.text('Today, 8:00 AM'), findsOneWidget);
        expect(find.text('Yesterday, 5:30 PM'), findsOneWidget);
        expect(find.text('11 May, 7:00 AM'), findsOneWidget);
      },
      auth: signedInAuth(),
      groups: withCrew(),
    );

    appTest(
      'you can cheer other people\'s items, and take it back',
      (tester, db) async {
        await openGroup(tester, 'Sunday crew');
        // Two items by others have a Cheer button; your own does not.
        expect(find.text('Cheer'), findsNWidgets(2));

        await tester.tap(find.text('Cheer').first);
        await tester.pumpAndSettle();
        expect(find.widgetWithText(TextButton, '1'), findsOneWidget);
        expect(find.text('Cheer'), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsOneWidget);

        await tester.tap(find.widgetWithText(TextButton, '1'));
        await tester.pumpAndSettle();
        expect(find.text('Cheer'), findsNWidgets(2));
        expect(find.byIcon(Icons.favorite), findsNothing);
      },
      auth: signedInAuth(),
      groups: withCrew(),
    );

    appTest(
      'you see how many cheered your own item',
      (tester, db) async {
        testGroups.addEvent('g1', me, GroupEventKind.workout, {
          'type_id': 'builtin-run',
          'duration_minutes': 10,
        }, DateTime.utc(2026, 5, 13, 9));
        await openGroup(tester, 'Sunday crew');
        expect(find.text('Cheer'), findsNWidgets(2));
      },
      auth: signedInAuth(),
      groups: withCrew(),
    );

    appTest(
      'a failed refresh keeps the screen and says what happened',
      (tester, db) async {
        await openGroup(tester, 'Sunday crew');
        testGroups.failNext = GroupsProblem.network;
        await tester.tap(find.text('Cheer').first);
        await tester.pumpAndSettle();
        expect(
          find.text('Could not reach the server. Try again.'),
          findsOneWidget,
        );
        expect(find.text('This week'), findsOneWidget);
      },
      auth: signedInAuth(),
      groups: withCrew(),
    );
  });

  group('group settings', () {
    appTest(
      'your switches reach the server and hide you again at once',
      (tester, db) async {
        await openGroup(tester, 'Sunday crew');
        await openWorkoutsTab(tester);
        expect(leaderboardRows(tester).join(), contains('You'));
        await openSettings(tester);

        expect(find.textContaining('never shared'), findsOneWidget);
        await showSwitch(tester, 'Workouts');
        await tester.tap(find.widgetWithText(SwitchListTile, 'Workouts'));
        await tester.pumpAndSettle();
        expect(testGroups.sharing('g1', me)!.workouts, isFalse);
        expect(testGroups.sharing('g1', me)!.breaks, isTrue);

        await tester.pageBack();
        await tester.pumpAndSettle();
        // Not sharing workouts: no Workouts tab, and the feed hides you.
        expect(find.text('Workouts'), findsNothing);
        expect(find.text('You logged Walk for 20 min.'), findsNothing);

        await openSettings(tester);
        await showSwitch(tester, 'Workouts');
        await tester.tap(find.widgetWithText(SwitchListTile, 'Workouts'));
        await showSwitch(tester, 'Healthy Habits');
        await tester.tap(find.widgetWithText(SwitchListTile, 'Healthy Habits'));
        await tester.pumpAndSettle();
        expect(testGroups.sharing('g1', me)!.workouts, isTrue);
        expect(testGroups.sharing('g1', me)!.breaks, isFalse);
      },
      auth: signedInAuth(),
      groups: withCrew(),
    );

    appTest(
      'the code is shown in groups of four and can be shared',
      (tester, db) async {
        await openGroup(tester, 'Sunday crew');
        await openSettings(tester);
        expect(
          tester
              .widget<SelectableText>(find.byKey(const Key('invite-code')))
              .data,
          '1111',
        );

        await tester.tap(find.text('Share invite'));
        await tester.pumpAndSettle();
        final message = testShare.shared.single;
        expect(message, contains('Sunday crew'));
        expect(message, contains('Join with a code'));
        expect(message, contains('1111'));
        expect(message, isNot(contains('!')));
        expect(parseInviteCode('1111'), '1111');
      },
      auth: signedInAuth(),
      groups: withCrew(),
    );

    appTest(
      'if there is no share sheet the invite is copied instead',
      (tester, db) async {
        String? copied;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = (call.arguments as Map)['text'] as String;
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        testShare.fail = true;
        await openGroup(tester, 'Sunday crew');
        await openSettings(tester);
        await tester.tap(find.text('Share invite'));
        await tester.pumpAndSettle();
        expect(copied, contains('1111'));
        expect(find.text('Invite copied.'), findsOneWidget);
      },
      auth: signedInAuth(),
      groups: withCrew(),
    );

    appTest(
      'copy code puts just the code on the clipboard',
      (tester, db) async {
        String? copied;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData') {
              copied = (call.arguments as Map)['text'] as String;
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        await openGroup(tester, 'Sunday crew');
        await openSettings(tester);
        await tester.tap(find.text('Copy code'));
        await tester.pumpAndSettle();
        expect(copied, '1111');
        expect(find.text('Code copied.'), findsOneWidget);
      },
      auth: signedInAuth(),
      groups: withCrew(),
    );

    appTest(
      'the code shown is read again, so a change made elsewhere is not missed',
      (tester, db) async {
        await openGroupsTab(tester);
        // The code is replaced behind the app's back (another phone).
        final fresh = await testGroups.rotateInvite('m1');
        expect(fresh, isNot('3333'));
        await tester.tap(find.text('Mine'));
        await tester.pumpAndSettle();
        await openSettings(tester);
        expect(
          tester
              .widget<SelectableText>(find.byKey(const Key('invite-code')))
              .data,
          formatInviteCode(fresh),
        );
      },
      auth: signedInAuth(),
      groups: server()..seedGroup('Mine', id: 'm1', owner: me, code: '3333'),
    );

    appTest(
      'a member cannot rename or replace the invite',
      (tester, db) async {
        await openGroup(tester, 'Sunday crew');
        await openSettings(tester);
        expect(find.byIcon(Icons.edit_outlined), findsNothing);
        expect(find.text('Make a new code'), findsNothing);
      },
      auth: signedInAuth(),
      groups: withCrew(),
    );

    appTest(
      'the owner can rename and make a new code',
      (tester, db) async {
        await openGroup(tester, 'Mine');
        await openSettings(tester);

        await tester.tap(find.text('Name'));
        await tester.pumpAndSettle();
        await typeInto(tester, 'Better name');
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(find.text('Better name'), findsOneWidget);

        expect(find.text('3333'), findsOneWidget);
        await tester.tap(find.text('Make a new code'));
        await tester.pumpAndSettle();
        expect(find.textContaining('will stop working'), findsOneWidget);
        await tester.tap(find.text('Make new code'));
        await tester.pumpAndSettle();
        expect(find.text('3333'), findsNothing);
      },
      auth: signedInAuth(),
      groups: server()..seedGroup('Mine', id: 'm1', owner: me, code: '3333'),
    );

    appTest(
      'leaving asks first, then returns to the list without the group',
      (tester, db) async {
        await openGroup(tester, 'Sunday crew');
        await openSettings(tester);
        await tester.scrollUntilVisible(
          find.text('Leave group'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Leave group'));
        await tester.pumpAndSettle();
        expect(find.textContaining('stay on your phone'), findsOneWidget);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(
          testGroups.isMember('g1'),
          isTrue,
          reason: 'cancel keeps you in',
        );

        await tester.scrollUntilVisible(
          find.text('Leave group'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Leave group'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Leave'));
        await tester.pumpAndSettle();
        expect(testGroups.isMember('g1'), isFalse);
        expect(find.textContaining('No groups yet'), findsOneWidget);
      },
      auth: signedInAuth(),
      groups: withCrew(),
    );
  });
}
