import '../../data/builtin_workout_types.dart';

/// Why a group action failed, in terms the person can act on.
enum GroupsProblem {
  notSignedIn,
  inviteNotFound,
  groupFull,
  tooManyGroups,
  tooManyAttempts,
  notOwner,
  invalidName,
  network,
}

class GroupsException implements Exception {
  const GroupsException(this.problem);
  final GroupsProblem problem;

  String get message => switch (problem) {
    GroupsProblem.notSignedIn => 'Sign in to use groups.',
    GroupsProblem.inviteNotFound =>
      'That invite is not valid. Ask for a new one.',
    GroupsProblem.groupFull => 'This group is full.',
    GroupsProblem.tooManyGroups => 'You are in the maximum number of groups.',
    GroupsProblem.tooManyAttempts =>
      'Too many wrong codes. Wait about 15 minutes and try again.',
    GroupsProblem.notOwner => 'Only the owner can do that.',
    GroupsProblem.invalidName => 'Enter a name up to 40 characters.',
    GroupsProblem.network => 'Could not reach the server. Try again.',
  };

  @override
  String toString() => 'GroupsException($problem)';
}

class Group {
  const Group({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.inviteCode,
    this.memberCount = 0,
  });

  final String id;
  final String name;
  final String ownerId;
  final String inviteCode;
  final int memberCount;

  Group copyWith({String? name, String? inviteCode, int? memberCount}) => Group(
    id: id,
    name: name ?? this.name,
    ownerId: ownerId,
    inviteCode: inviteCode ?? this.inviteCode,
    memberCount: memberCount ?? this.memberCount,
  );
}

class InvitePreview {
  const InvitePreview({
    required this.name,
    required this.memberCount,
    required this.alreadyMember,
  });
  final String name;
  final int memberCount;
  final bool alreadyMember;
}

class GroupMember {
  const GroupMember({
    required this.userId,
    required this.displayName,
    required this.isOwner,
    required this.joinedAt,
    this.shareWorkouts = true,
    this.shareBreaks = true,
    this.shareSleep = false,
    this.shareScreenTime = false,
    this.shareHobbies = false,
  });

  final String userId;
  final String displayName;
  final bool isOwner;
  final DateTime joinedAt;
  final bool shareWorkouts;

  /// Healthy Habits. The stored name predates the new label.
  final bool shareBreaks;
  final bool shareSleep;
  final bool shareScreenTime;

  /// Reserved: nothing in a group reads hobbies yet.
  final bool shareHobbies;

  bool get shareHabits => shareBreaks;

  bool shares(GroupCategory c) => switch (c) {
    GroupCategory.workouts => shareWorkouts,
    GroupCategory.habits => shareBreaks,
    GroupCategory.sleep => shareSleep,
    GroupCategory.screenTime => shareScreenTime,
  };
}

/// What a person chooses to share with a group (spec R9). Workouts and
/// Healthy Habits start on, sleep, screen time and hobbies start off.
class GroupSharing {
  const GroupSharing({
    this.workouts = true,
    this.habits = true,
    this.sleep = false,
    this.screenTime = false,
    this.hobbies = false,
  });

  final bool workouts;
  final bool habits;
  final bool sleep;
  final bool screenTime;
  final bool hobbies;

  bool shares(GroupCategory c) => switch (c) {
    GroupCategory.workouts => workouts,
    GroupCategory.habits => habits,
    GroupCategory.sleep => sleep,
    GroupCategory.screenTime => screenTime,
  };

  GroupSharing withCategory(GroupCategory c, bool value) => GroupSharing(
    workouts: c == GroupCategory.workouts ? value : workouts,
    habits: c == GroupCategory.habits ? value : habits,
    sleep: c == GroupCategory.sleep ? value : sleep,
    screenTime: c == GroupCategory.screenTime ? value : screenTime,
    hobbies: hobbies,
  );

  /// The shape the server's create_group / join_group read.
  Map<String, bool> toJson() => {
    'workouts': workouts,
    'habits': habits,
    'sleep': sleep,
    'screen_time': screenTime,
    'hobbies': hobbies,
  };
}

/// The areas a group compares people on (R9). `habits` is the Healthy Habits
/// category; the database still calls its switch `share_breaks`.
///
/// Scoring happens only on the server (one daily 0 to 10 score per category,
/// capped, averaged over days with data; overall is the mean over the
/// categories a person shares and is never sent to the app). The rules are in
/// docs/group-scoring.md and in the group_daily_scores function of
/// supabase/migrations/20261013000000_group_categories.sql. The app only
/// receives ranks and key figures, so there is no score type here on purpose.
enum GroupCategory {
  workouts('workouts', 'Workouts'),
  habits('habits', 'Healthy Habits'),
  sleep('sleep', 'Sleep Health'),
  screenTime('screen_time', 'Screen Time');

  const GroupCategory(this.wire, this.label);

  /// The name used by the server.
  final String wire;
  final String label;

  /// A short form for small indicators.
  String get shortLabel => switch (this) {
    GroupCategory.workouts => 'Workouts',
    GroupCategory.habits => 'Habits',
    GroupCategory.sleep => 'Sleep',
    GroupCategory.screenTime => 'Screen',
  };

  static GroupCategory? fromWire(String? wire) {
    for (final c in values) {
      if (c.wire == wire) return c;
    }
    return null;
  }
}

/// The tabs of the group screen. Overall plus the categories.
enum GroupTab {
  overall('Overall', null),
  workouts('Workouts', GroupCategory.workouts),
  habits('Healthy Habits', GroupCategory.habits),
  sleep('Sleep Health', GroupCategory.sleep),
  screenTime('Screen Time', GroupCategory.screenTime);

  const GroupTab(this.label, this.category);
  final String label;
  final GroupCategory? category;

  static GroupTab? fromWire(String? wire) {
    if (wire == 'overall') return GroupTab.overall;
    final c = GroupCategory.fromWire(wire);
    if (c == null) return null;
    return values.firstWhere((t) => t.category == c);
  }
}

/// A row of the Overall tab: a rank and the categories behind it. There is
/// deliberately no score here: the overall number never leaves the server.
class OverallEntry {
  const OverallEntry({
    required this.userId,
    required this.displayName,
    required this.rank,
    required this.categories,
  });
  final String userId;
  final String displayName;
  final int rank;

  /// Categories that count towards this person's rank and that you share too.
  final List<GroupCategory> categories;
}

/// A row of a category tab: rank plus the person's key figures.
class CategoryEntry {
  const CategoryEntry({
    required this.userId,
    required this.displayName,
    required this.rank,
    required this.metrics,
  });
  final String userId;
  final String displayName;
  final int rank;
  final Map<String, Object?> metrics;
}

/// One member's shared key metrics for a category and week.
class ParticipantMetrics {
  const ParticipantMetrics({required this.summary, this.days = const []});
  final Map<String, Object?> summary;

  /// One figure per day: the date (`YYYY-MM-DD`) and the day's main amount.
  final List<({String date, num amount})> days;
}

/// A label and value for display.
typedef MetricLine = ({String label, String value});

String _duration(num minutes) {
  final m = minutes.round();
  final h = m ~/ 60;
  final r = m % 60;
  if (h == 0) return '$r min';
  return r == 0 ? '$h h' : '$h h $r min';
}

String _plural(num n, String one, String many) =>
    '${n.round()} ${n.round() == 1 ? one : many}';

/// Key figures as short lines (never a score).
List<MetricLine> describeMetrics(
  GroupCategory category,
  Map<String, Object?> m,
) {
  num n(String key) => (m[key] as num?) ?? 0;
  switch (category) {
    case GroupCategory.workouts:
      return [
        (label: 'Active time', value: _duration(n('active_minutes'))),
        (label: 'Active days', value: _plural(n('active_days'), 'day', 'days')),
        (label: 'Sessions', value: '${n('sessions').round()}'),
      ];
    case GroupCategory.habits:
      return [
        (label: 'Days with activity', value: '${n('days_logged').round()}'),
        (label: 'Daily goals met', value: '${n('targets_met').round()}'),
        (label: 'Habits tracked', value: '${n('habits_tracked').round()}'),
      ];
    case GroupCategory.sleep:
      return [
        (label: 'Nights logged', value: '${n('nights').round()}'),
        (label: 'Average sleep', value: _duration(n('average_minutes'))),
        (label: 'Own target', value: _duration(n('target_minutes'))),
        (
          label: 'Nights near target',
          value: '${n('nights_near_target').round()}',
        ),
      ];
    case GroupCategory.screenTime:
      return [
        (label: 'Days logged', value: '${n('days').round()}'),
        (label: 'Average a day', value: _duration(n('average_minutes'))),
        (label: 'Average limit', value: _duration(n('average_limit_minutes'))),
        (
          label: 'Days within limit',
          value: '${n('days_within_limit').round()}',
        ),
      ];
  }
}

/// A day's main figure as text, for the per-day list.
String dayAmountText(GroupCategory category, num amount) =>
    category == GroupCategory.habits
    ? _plural(amount, 'goal met', 'goals met')
    : _duration(amount);

/// One line for a list row.
String metricsSummary(GroupCategory category, Map<String, Object?> m) {
  num n(String key) => (m[key] as num?) ?? 0;
  return switch (category) {
    GroupCategory.workouts =>
      '${_duration(n('active_minutes'))}, '
          '${_plural(n('active_days'), 'day', 'days')}',
    GroupCategory.habits =>
      '${_plural(n('targets_met'), 'goal', 'goals')} met on '
          '${_plural(n('days_logged'), 'day', 'days')}',
    GroupCategory.sleep =>
      'Average ${_duration(n('average_minutes'))}, '
          '${n('nights_near_target').round()} of ${n('nights').round()} '
          'near target',
    GroupCategory.screenTime =>
      'Average ${_duration(n('average_minutes'))}, '
          '${n('days_within_limit').round()} of ${n('days').round()} '
          'within limit',
  };
}

/// Ranks 1, 1, 3 style (ties share a rank) for values already sorted best
/// first. Equal values are the ones that tie.
List<int> competitionRanks(List<num> sortedBestFirst) {
  final ranks = <int>[];
  for (var i = 0; i < sortedBestFirst.length; i++) {
    final tied = i > 0 && sortedBestFirst[i] == sortedBestFirst[i - 1];
    ranks.add(tied ? ranks[i - 1] : i + 1);
  }
  return ranks;
}

enum GroupEventKind { workout, breakGoal, milestone }

class GroupEvent {
  const GroupEvent({
    required this.id,
    required this.userId,
    required this.kind,
    required this.payload,
    required this.occurredAt,
    this.cheeredBy = const {},
  });

  final String id;
  final String userId;
  final GroupEventKind kind;
  final Map<String, Object?> payload;
  final DateTime occurredAt;

  /// Ids of the members who cheered this item.
  final Set<String> cheeredBy;
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.activeMinutes,
    required this.activeDays,
  });

  final String userId;
  final String displayName;
  final int activeMinutes;
  final int activeDays;
}

enum LeaderboardMetric { volume, consistency }

class RankedEntry {
  const RankedEntry(this.rank, this.entry);
  final int rank;
  final LeaderboardEntry entry;
}

/// Ranks members for the chosen metric (spec 7.6). Ties share a rank and the
/// next rank is skipped (1, 1, 3). Within a tie the other measure and then
/// the name decide the order, only so the list does not jump around.
List<RankedEntry> rankLeaderboard(
  List<LeaderboardEntry> entries,
  LeaderboardMetric metric,
) {
  int main(LeaderboardEntry e) =>
      metric == LeaderboardMetric.volume ? e.activeMinutes : e.activeDays;
  int other(LeaderboardEntry e) =>
      metric == LeaderboardMetric.volume ? e.activeDays : e.activeMinutes;

  final sorted = [...entries]
    ..sort((a, b) {
      final byMain = main(b).compareTo(main(a));
      if (byMain != 0) return byMain;
      final byOther = other(b).compareTo(other(a));
      if (byOther != 0) return byOther;
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });

  final ranked = <RankedEntry>[];
  for (var i = 0; i < sorted.length; i++) {
    final tied = i > 0 && main(sorted[i]) == main(sorted[i - 1]);
    ranked.add(RankedEntry(tied ? ranked[i - 1].rank : i + 1, sorted[i]));
  }
  return ranked;
}

// Invite codes -------------------------------------------------------------------

/// Shows a code in groups of four for reading out: 4821 stays "4821" and
/// a longer older code such as 12345678 becomes "1234 5678".
String formatInviteCode(String code) {
  final buffer = StringBuffer();
  for (var i = 0; i < code.length; i++) {
    if (i > 0 && i % 4 == 0) buffer.write(' ');
    buffer.write(code[i]);
  }
  return buffer.toString();
}

/// Reads a typed or pasted invite code. Spaces and dashes are ignored, so
/// "1234 5678" and "1234-5678" both work. Returns null when the text could
/// not be a code.
String? parseInviteCode(String input) {
  final code = input.replaceAll(RegExp(r'[\s-]'), '').toLowerCase();
  return RegExp(r'^[a-z0-9]{4,32}$').hasMatch(code) ? code : null;
}

// Feed text -------------------------------------------------------------------------

String _minutesText(int m) {
  final h = m ~/ 60;
  final r = m % 60;
  if (h == 0) return '$r min';
  return r == 0 ? '$h h' : '$h h $r min';
}

String memberName(String displayName) =>
    displayName.trim().isEmpty ? 'A member' : displayName.trim();

/// One neutral sentence for a feed item. [who] is the name, or "You".
String describeEvent(GroupEvent e, String who) {
  switch (e.kind) {
    case GroupEventKind.workout:
      final minutes = (e.payload['duration_minutes'] as num?)?.toInt();
      final name = _workoutName(e.payload);
      final tail = minutes == null ? '' : ' for ${_minutesText(minutes)}';
      return '$who logged $name$tail.';
    case GroupEventKind.breakGoal:
      final habit = (e.payload['habit_name'] as String?)?.trim();
      return habit == null || habit.isEmpty
          ? '$who met a Healthy Habits goal.'
          : '$who met the $habit goal.';
    case GroupEventKind.milestone:
      final days = _streakDays(e.payload['badge_key'] as String?);
      return days == null
          ? '$who reached a milestone.'
          : '$who reached a $days-day streak.';
  }
}

String _workoutName(Map<String, Object?> payload) {
  final custom = (payload['type_name'] as String?)?.trim();
  if (custom != null && custom.isNotEmpty) return custom;
  final id = payload['type_id'] as String?;
  for (final t in builtinWorkoutTypes) {
    if (t.id == id) return t.name;
  }
  return 'a workout';
}

int? _streakDays(String? badgeKey) {
  if (badgeKey == null) return null;
  return int.tryParse(badgeKey.split('_').last);
}
