import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/features/groups/groups_models.dart';
import 'package:wellbeing/features/groups/supabase_groups_remote.dart';

LeaderboardEntry entry(String name, int minutes, int days) => LeaderboardEntry(
  userId: name,
  displayName: name,
  activeMinutes: minutes,
  activeDays: days,
);

List<String> order(List<RankedEntry> r) => [
  for (final e in r) '${e.rank}:${e.entry.displayName}',
];

void main() {
  group('leaderboard ranking', () {
    test('volume ranks by active minutes, highest first', () {
      final r = rankLeaderboard([
        entry('Asha', 60, 2),
        entry('Ben', 120, 3),
        entry('Chen', 30, 1),
      ], LeaderboardMetric.volume);
      expect(order(r), ['1:Ben', '2:Asha', '3:Chen']);
    });

    test('consistency ranks by active days, not minutes', () {
      final r = rankLeaderboard([
        entry('Asha', 300, 2),
        entry('Ben', 60, 5),
      ], LeaderboardMetric.consistency);
      expect(order(r), ['1:Ben', '2:Asha']);
    });

    test('ties share a rank and the next rank is skipped', () {
      final r = rankLeaderboard([
        entry('Asha', 60, 3),
        entry('Ben', 60, 3),
        entry('Chen', 10, 1),
      ], LeaderboardMetric.volume);
      expect(order(r), ['1:Asha', '1:Ben', '3:Chen']);
    });

    test('a tie is on the chosen measure only', () {
      // Same minutes, different days: still tied on volume, and tied
      // members are ordered by the other measure only for stable display.
      final volume = rankLeaderboard([
        entry('Asha', 60, 1),
        entry('Ben', 60, 4),
      ], LeaderboardMetric.volume);
      expect(order(volume), ['1:Ben', '1:Asha']);

      // Same days, different minutes: not tied on volume.
      final days = rankLeaderboard([
        entry('Asha', 90, 3),
        entry('Ben', 60, 3),
      ], LeaderboardMetric.volume);
      expect(order(days), ['1:Asha', '2:Ben']);
    });

    test('everyone at zero shares first place', () {
      final r = rankLeaderboard([
        entry('Ben', 0, 0),
        entry('Asha', 0, 0),
      ], LeaderboardMetric.volume);
      expect(order(r), ['1:Asha', '1:Ben']);
    });

    test('an empty group has an empty leaderboard', () {
      expect(rankLeaderboard([], LeaderboardMetric.volume), isEmpty);
    });
  });

  group('invite codes', () {
    test('a pasted link and a bare code give the same code', () {
      expect(parseInviteCode('wellbeing://join/abc123def456'), 'abc123def456');
      expect(parseInviteCode('  abc123def456  '), 'abc123def456');
      expect(parseInviteCode('ABC123DEF456'), 'abc123def456');
      expect(
        parseInviteCode(
          'Join my group "Sunday crew" in Well-Being. Paste this: '
          'wellbeing://join/abc123def456',
        ),
        'abc123def456',
        reason: 'the whole copied message works',
      );
    });

    test('the link made for a code reads back as that code', () {
      expect(parseInviteCode(inviteLink('abc123def456')), 'abc123def456');
    });

    test('nonsense is rejected', () {
      expect(parseInviteCode(''), isNull);
      expect(parseInviteCode('   '), isNull);
      expect(parseInviteCode('abc'), isNull);
      expect(parseInviteCode('wellbeing://join'), isNull);
      expect(parseInviteCode('not a code!'), isNull);
    });
  });

  group('feed text', () {
    GroupEvent ev(GroupEventKind kind, Map<String, Object?> payload) =>
        GroupEvent(
          id: 'e',
          userId: 'u',
          kind: kind,
          payload: payload,
          occurredAt: DateTime.utc(2026, 5, 13),
        );

    test('workouts name the type and duration', () {
      expect(
        describeEvent(
          ev(GroupEventKind.workout, {
            'type_id': 'builtin-yoga',
            'duration_minutes': 30,
          }),
          'Asha',
        ),
        'Asha logged Yoga for 30 min.',
      );
      expect(
        describeEvent(
          ev(GroupEventKind.workout, {
            'type_id': 'builtin-run',
            'duration_minutes': 90,
          }),
          'You',
        ),
        'You logged Run for 1 h 30 min.',
      );
    });

    test('a custom workout type uses its own name', () {
      expect(
        describeEvent(
          ev(GroupEventKind.workout, {
            'type_id': 'c-1',
            'type_name': 'Climbing',
            'duration_minutes': 45,
          }),
          'Ben',
        ),
        'Ben logged Climbing for 45 min.',
      );
    });

    test('unknown or missing details still read as a sentence', () {
      expect(
        describeEvent(ev(GroupEventKind.workout, {}), 'Ben'),
        'Ben logged a workout.',
      );
      expect(
        describeEvent(ev(GroupEventKind.breakGoal, {}), 'Ben'),
        'Ben met a break goal.',
      );
      expect(
        describeEvent(ev(GroupEventKind.milestone, {}), 'Ben'),
        'Ben reached a milestone.',
      );
    });

    test('break goals and milestones', () {
      expect(
        describeEvent(
          ev(GroupEventKind.breakGoal, {'habit_name': 'Water'}),
          'Asha',
        ),
        'Asha met the Water goal.',
      );
      expect(
        describeEvent(
          ev(GroupEventKind.milestone, {'badge_key': 'streak_overall_7'}),
          'Asha',
        ),
        'Asha reached a 7-day streak.',
      );
      expect(
        describeEvent(
          ev(GroupEventKind.milestone, {'badge_key': 'streak_habit:abc_30'}),
          'Asha',
        ),
        'Asha reached a 30-day streak.',
      );
    });

    test('no exclamation marks anywhere in the wording', () {
      for (final k in GroupEventKind.values) {
        expect(describeEvent(ev(k, {}), 'Asha'), isNot(contains('!')));
      }
      for (final p in GroupsProblem.values) {
        expect(GroupsException(p).message, isNot(contains('!')));
      }
    });

    test('a member without a name is still addressable', () {
      expect(memberName(''), 'A member');
      expect(memberName('  '), 'A member');
      expect(memberName(' Asha '), 'Asha');
    });
  });

  group('server messages', () {
    test('the database function errors map to problems', () {
      expect(
        problemForServerMessage('invite_not_found'),
        GroupsProblem.inviteNotFound,
      );
      expect(problemForServerMessage('group_full'), GroupsProblem.groupFull);
      expect(
        problemForServerMessage('too_many_groups'),
        GroupsProblem.tooManyGroups,
      );
      expect(problemForServerMessage('not_owner'), GroupsProblem.notOwner);
      expect(
        problemForServerMessage('invalid_name'),
        GroupsProblem.invalidName,
      );
      expect(
        problemForServerMessage('not_signed_in'),
        GroupsProblem.notSignedIn,
      );
      expect(problemForServerMessage('something else'), GroupsProblem.network);
    });
  });
}
