import '../../data/builtin_workout_types.dart';

/// Why a group action failed, in terms the person can act on.
enum GroupsProblem {
  notSignedIn,
  inviteNotFound,
  groupFull,
  tooManyGroups,
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
  });

  final String userId;
  final String displayName;
  final bool isOwner;
  final DateTime joinedAt;
  final bool shareWorkouts;
  final bool shareBreaks;
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

// Invite links ------------------------------------------------------------------

const _inviteScheme = 'wellbeing';

String inviteLink(String code) => '$_inviteScheme://join/$code';

/// Accepts a pasted invite (the link, a bare code, or the whole message that
/// "Copy invite" produces) and returns the code, or null when there is none.
String? parseInviteCode(String input) {
  final text = input.trim();
  if (text.isEmpty) return null;
  final link = RegExp(
    '$_inviteScheme://join/([A-Za-z0-9]{6,32})',
    caseSensitive: false,
  ).firstMatch(text);
  if (link != null) return link.group(1)!.toLowerCase();
  final bare = text.toLowerCase();
  return RegExp(r'^[a-z0-9]{6,32}$').hasMatch(bare) ? bare : null;
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
          ? '$who met a break goal.'
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
