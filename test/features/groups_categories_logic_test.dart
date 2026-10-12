import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/features/groups/groups_models.dart';
import 'package:wellbeing/features/groups/groups_remote.dart';
import 'package:wellbeing/features/groups/supabase_groups_remote.dart';

const week = '2026-05-11';

/// A group where [me] shares everything, plus asha and ben who share what
/// the test gives them.
FakeGroupsRemote crew() {
  final s = FakeGroupsRemote(me: 'me', myName: 'Divya');
  final g = s.seedGroup('Crew', id: 'g', owner: 'asha', code: '1111');
  s.addMember(g.id, 'ben', 'Ben');
  return s;
}

void score(
  FakeGroupsRemote s,
  String user,
  GroupCategory c,
  double v, {
  int days = 1,
}) => s.seedScores('g', user, c, v, days: days, metrics: {'days': days});

void main() {
  group('categories and tabs', () {
    test('the server names and the labels', () {
      expect(GroupCategory.habits.wire, 'habits');
      expect(GroupCategory.screenTime.wire, 'screen_time');
      expect(GroupCategory.habits.label, 'Healthy Habits');
      expect(GroupCategory.sleep.label, 'Sleep Health');
      expect(GroupCategory.fromWire('screen_time'), GroupCategory.screenTime);
      expect(GroupCategory.fromWire('breaks'), isNull);
      expect(GroupTab.fromWire('overall'), GroupTab.overall);
      expect(GroupTab.fromWire('habits'), GroupTab.habits);
      expect(GroupTab.fromWire('nonsense'), isNull);
      expect(
        [for (final t in GroupTab.values) t.label],
        [
          'Overall',
          'Workouts',
          'Healthy Habits',
          'Sleep Health',
          'Screen Time',
        ],
      );
      for (final label in [
        for (final c in GroupCategory.values) c.label,
        for (final t in GroupTab.values) t.label,
      ]) {
        expect(label.toLowerCase(), isNot(contains('break')));
      }
    });

    test('sharing starts with sleep and screen time off', () {
      const s = GroupSharing();
      expect(s.workouts, isTrue);
      expect(s.habits, isTrue);
      expect(s.sleep, isFalse);
      expect(s.screenTime, isFalse);
      expect(s.hobbies, isFalse);
      expect(s.toJson(), {
        'workouts': true,
        'habits': true,
        'sleep': false,
        'screen_time': false,
        'hobbies': false,
      });
      final on = s.withCategory(GroupCategory.sleep, true);
      expect(on.sleep, isTrue);
      expect(on.workouts, isTrue);
      expect(s.sleep, isFalse, reason: 'the original is unchanged');
    });

    test('a member row without the new switches means they are off', () {
      final m = GroupMember(
        userId: 'u',
        displayName: 'U',
        isOwner: false,
        joinedAt: DateTime.utc(2026),
      );
      expect(m.shares(GroupCategory.sleep), isFalse);
      expect(m.shares(GroupCategory.screenTime), isFalse);
      expect(m.shares(GroupCategory.habits), isTrue);
      expect(m.shareHabits, isTrue);
    });
  });

  group('ranking helpers', () {
    test('ties share a rank and the next is skipped', () {
      expect(competitionRanks([9, 9, 7, 7, 7, 2]), [1, 1, 3, 3, 3, 6]);
      expect(competitionRanks([]), isEmpty);
    });

    test('key figures read as plain lines, never scores', () {
      expect(
        metricsSummary(GroupCategory.workouts, {
          'active_minutes': 98,
          'active_days': 2,
          'sessions': 3,
        }),
        '1 h 38 min, 2 days',
      );
      expect(
        metricsSummary(GroupCategory.sleep, {
          'nights': 5,
          'average_minutes': 450,
          'nights_near_target': 3,
        }),
        'Average 7 h 30 min, 3 of 5 near target',
      );
      expect(
        metricsSummary(GroupCategory.screenTime, {
          'days': 4,
          'average_minutes': 130,
          'days_within_limit': 1,
        }),
        'Average 2 h 10 min, 1 of 4 within limit',
      );
      expect(
        metricsSummary(GroupCategory.habits, {
          'targets_met': 1,
          'days_logged': 1,
        }),
        '1 goal met on 1 day',
      );
      final lines = describeMetrics(GroupCategory.sleep, {
        'nights': 5,
        'average_minutes': 450,
        'target_minutes': 480,
        'nights_near_target': 3,
      });
      expect(lines.map((l) => l.label), contains('Own target'));
      expect(
        [for (final c in GroupCategory.values) ...describeMetrics(c, {})]
            .map((l) => l.label.toLowerCase())
            .join(' '),
        isNot(contains('score')),
      );
      expect(dayAmountText(GroupCategory.habits, 2), '2 goals met');
      expect(dayAmountText(GroupCategory.sleep, 480), '8 h');
    });

    test('the server result for a participant is read, and nulls are kept', () {
      expect(parseMemberMetrics(null), isNull);
      final m = parseMemberMetrics({
        'summary': {'nights': 1},
        'days': [
          {'date': '2026-05-12', 'amount': 480},
        ],
      })!;
      expect(m.summary['nights'], 1);
      expect(m.days.single.date, '2026-05-12');
      expect(m.days.single.amount, 480);
    });
  });

  group('the group server applies the privacy rules', () {
    test('a tab needs 2 members sharing with data', () async {
      final s = crew();
      score(s, 'me', GroupCategory.workouts, 8);
      expect(await s.availableTabs('g', week), isEmpty);
      score(s, 'ben', GroupCategory.workouts, 6);
      expect(await s.availableTabs('g', week), {
        GroupTab.workouts,
        GroupTab.overall,
      });
    });

    test('a member with no data does not count', () async {
      final s = crew();
      score(s, 'me', GroupCategory.workouts, 8);
      // asha and ben share workouts but logged nothing.
      expect((await s.availableTabs('g', week)), isEmpty);
    });

    test('you must share a category to see it', () async {
      final s = crew();
      s.addMember('g', 'cy', 'Cy', shareSleep: true);
      score(s, 'ben', GroupCategory.sleep, 8);
      score(s, 'cy', GroupCategory.sleep, 6);
      // ben does not share sleep (the default), cy does; and so does nobody
      // else, and I do not.
      expect(await s.availableTabs('g', week), isEmpty);
      expect(await s.categoryBoard('g', week, GroupCategory.sleep), isEmpty);
      await s.setSharing('g', sleep: true);
      s.addMember('g', 'di', 'Di', shareSleep: true);
      score(s, 'di', GroupCategory.sleep, 7);
      expect(await s.availableTabs('g', week), contains(GroupTab.sleep));
    });

    test('someone who does not share a category is not ranked in it', () async {
      final s = crew();
      await s.setSharing('g', sleep: true);
      s.addMember('g', 'cy', 'Cy', shareSleep: true);
      s.addMember('g', 'di', 'Di', shareSleep: true);
      score(s, 'cy', GroupCategory.sleep, 5);
      score(s, 'di', GroupCategory.sleep, 6);
      score(s, 'ben', GroupCategory.sleep, 10); // ben shares nothing of sleep
      final board = await s.categoryBoard('g', week, GroupCategory.sleep);
      expect(board.map((e) => e.userId), ['di', 'cy']);
      expect(board.map((e) => e.rank), [1, 2]);
    });

    test('turning a category off removes you at once', () async {
      final s = crew();
      score(s, 'me', GroupCategory.workouts, 8);
      score(s, 'ben', GroupCategory.workouts, 6);
      expect(
        (await s.categoryBoard('g', week, GroupCategory.workouts)).length,
        2,
      );
      await s.setSharing('g', workouts: false);
      expect(await s.categoryBoard('g', week, GroupCategory.workouts), isEmpty);
      expect(await s.availableTabs('g', week), isEmpty);
    });

    test('overall compares on the categories each person shares', () async {
      final s = crew();
      await s.setSharing('g', sleep: true);
      s.addMember('g', 'cy', 'Cy', shareSleep: true);
      // Ben: workouts only, 9. Cy: workouts 8 and sleep 2, mean 5. Me: 6.
      score(s, 'ben', GroupCategory.workouts, 9);
      score(s, 'cy', GroupCategory.workouts, 8);
      score(s, 'cy', GroupCategory.sleep, 2);
      score(s, 'me', GroupCategory.workouts, 6);
      final board = await s.overallBoard('g', week);
      expect(
        [for (final e in board) '${e.rank}:${e.userId}'],
        ['1:ben', '2:me', '3:cy'],
      );
      expect(board.last.categories, [
        GroupCategory.workouts,
        GroupCategory.sleep,
      ]);
      expect(board.first.categories, [GroupCategory.workouts]);
    });

    test('overall lists only categories you share too', () async {
      final s = crew();
      s.addMember('g', 'cy', 'Cy', shareSleep: true, shareScreenTime: true);
      score(s, 'cy', GroupCategory.workouts, 5);
      score(s, 'cy', GroupCategory.sleep, 5);
      score(s, 'cy', GroupCategory.screenTime, 5);
      score(s, 'ben', GroupCategory.workouts, 4);
      final cy = (await s.overallBoard(
        'g',
        week,
      )).firstWhere((e) => e.userId == 'cy');
      // I share workouts and habits only, so Cy's sleep and screen time do
      // not show.
      expect(cy.categories, [GroupCategory.workouts]);
    });

    test('ties in overall share a rank', () async {
      final s = crew();
      score(s, 'ben', GroupCategory.workouts, 7);
      score(s, 'me', GroupCategory.workouts, 7);
      score(s, 'asha', GroupCategory.workouts, 3);
      final ranks = (await s.overallBoard('g', week)).map((e) => e.rank);
      expect(ranks, [1, 1, 3]);
    });

    test('participant figures only where both share the category', () async {
      final s = crew();
      s.addMember('g', 'cy', 'Cy', shareSleep: true);
      s.seedScores(
        'g',
        'cy',
        GroupCategory.sleep,
        7,
        metrics: {'nights': 3},
        daily: [(date: '2026-05-12', amount: 480)],
      );
      s.seedScores(
        'g',
        'ben',
        GroupCategory.workouts,
        7,
        metrics: {'sessions': 2},
      );
      // I do not share sleep: nothing from Cy.
      expect(
        await s.memberMetrics('g', 'cy', week, GroupCategory.sleep),
        isNull,
      );
      // Ben shares workouts and so do I.
      expect(
        (await s.memberMetrics(
          'g',
          'ben',
          week,
          GroupCategory.workouts,
        ))!.summary['sessions'],
        2,
      );
      // Ben does not share sleep even if he had data.
      s.seedScores('g', 'ben', GroupCategory.sleep, 7);
      expect(
        await s.memberMetrics('g', 'ben', week, GroupCategory.sleep),
        isNull,
      );
      await s.setSharing('g', sleep: true);
      final cy = (await s.memberMetrics('g', 'cy', week, GroupCategory.sleep))!;
      expect(cy.days.single.amount, 480);
    });

    test('create and join apply the onboarding choices', () async {
      final s = FakeGroupsRemote(me: 'me');
      final g = await s.createGroup(
        'New',
        sharing: const GroupSharing(sleep: true, workouts: false),
      );
      final sharing = s.sharing(g.id, 'me')!;
      expect(sharing.sleep, isTrue);
      expect(sharing.workouts, isFalse);
      expect(sharing.screenTime, isFalse);

      final t = FakeGroupsRemote(me: 'me');
      t.seedGroup('Other', id: 'o', includeMe: false, code: '2222');
      await t.joinGroup('2222');
      final defaults = t.sharing('o', 'me')!;
      expect(defaults.sleep, isFalse);
      expect(defaults.screenTime, isFalse);
      expect(defaults.workouts, isTrue);
    });
  });

  test('server messages for the new calls map to the same problems', () {
    expect(
      problemForServerMessage('too_many_attempts'),
      GroupsProblem.tooManyAttempts,
    );
  });
}
