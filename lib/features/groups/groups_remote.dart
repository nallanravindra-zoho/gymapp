import 'groups_models.dart';

/// Everything the Groups screens need from the server. Groups are online
/// only: they are read when a screen opens and are not kept in the local
/// database. Behind an interface so tests never touch Supabase.
abstract class GroupsRemote {
  /// False when the build has no backend settings.
  bool get isAvailable;

  Future<List<Group>> listGroups();
  Future<Group> createGroup(String name, {GroupSharing? sharing});
  Future<InvitePreview> previewInvite(String code);

  /// Joins and returns the group id. Joining twice is harmless. [sharing] is
  /// what the person chose in the onboarding sheet; it is applied as the
  /// membership is created, so nothing is shared against their choice.
  Future<String> joinGroup(String code, {GroupSharing? sharing});

  Future<List<GroupMember>> roster(String groupId);
  Future<List<GroupEvent>> feed(String groupId, {int limit = 30});

  /// Weekly totals for the Mon-Sun week starting [weekStart] (`YYYY-MM-DD`).
  /// Only members who share workouts appear.
  Future<List<LeaderboardEntry>> leaderboard(String groupId, String weekStart);

  Future<void> setCheer(String eventId, {required bool cheered});

  /// Changes this member's switches for the group. [breaks] is Healthy Habits.
  Future<void> setSharing(
    String groupId, {
    bool? workouts,
    bool? breaks,
    bool? sleep,
    bool? screenTime,
    bool? hobbies,
  });

  /// The tabs this member can see for the week: Overall and the categories
  /// that at least 2 members share with data, which this member shares too.
  Future<Set<GroupTab>> availableTabs(String groupId, String weekStart);

  /// Overall ranks: a rank and the categories behind it, never a score.
  Future<List<OverallEntry>> overallBoard(String groupId, String weekStart);

  /// A category's ranking with each person's key figures.
  Future<List<CategoryEntry>> categoryBoard(
    String groupId,
    String weekStart,
    GroupCategory category,
  );

  /// One participant's shared key metrics, or null when they (or you) do not
  /// share the category.
  Future<ParticipantMetrics?> memberMetrics(
    String groupId,
    String userId,
    String weekStart,
    GroupCategory category,
  );

  Future<void> rename(String groupId, String name);

  /// Replaces the invite code; the old link stops working. Returns the new one.
  Future<String> rotateInvite(String groupId);
  Future<void> leave(String groupId);
}

/// Used when the build is not configured, and by default in tests.
class UnavailableGroupsRemote implements GroupsRemote {
  @override
  bool get isAvailable => false;

  Never _no() => throw const GroupsException(GroupsProblem.notSignedIn);

  @override
  Future<List<Group>> listGroups() async => _no();
  @override
  Future<Group> createGroup(String name, {GroupSharing? sharing}) async => _no();
  @override
  Future<InvitePreview> previewInvite(String code) async => _no();
  @override
  Future<String> joinGroup(String code, {GroupSharing? sharing}) async => _no();
  @override
  Future<List<GroupMember>> roster(String groupId) async => _no();
  @override
  Future<List<GroupEvent>> feed(String groupId, {int limit = 30}) async =>
      _no();
  @override
  Future<List<LeaderboardEntry>> leaderboard(
    String groupId,
    String weekStart,
  ) async => _no();
  @override
  Future<void> setCheer(String eventId, {required bool cheered}) async => _no();
  @override
  Future<void> setSharing(
    String groupId, {
    bool? workouts,
    bool? breaks,
    bool? sleep,
    bool? screenTime,
    bool? hobbies,
  }) async => _no();
  @override
  Future<Set<GroupTab>> availableTabs(String groupId, String weekStart) async =>
      _no();
  @override
  Future<List<OverallEntry>> overallBoard(
    String groupId,
    String weekStart,
  ) async => _no();
  @override
  Future<List<CategoryEntry>> categoryBoard(
    String groupId,
    String weekStart,
    GroupCategory category,
  ) async => _no();
  @override
  Future<ParticipantMetrics?> memberMetrics(
    String groupId,
    String userId,
    String weekStart,
    GroupCategory category,
  ) async => _no();
  @override
  Future<void> rename(String groupId, String name) async => _no();
  @override
  Future<String> rotateInvite(String groupId) async => _no();
  @override
  Future<void> leave(String groupId) async => _no();
}

/// An in-memory server for tests. It applies the same visibility rules the
/// real one does: feed items and leaderboard rows follow each member's
/// current sharing switches.
class FakeGroupsRemote implements GroupsRemote {
  FakeGroupsRemote({
    this.me = 'me',
    this.myName = 'Divya',
    this.signedIn = true,
  });

  /// The signed-in user's id and name.
  final String me;
  final String myName;
  bool signedIn;

  final _groups = <String, Group>{};
  final _members = <String, List<_Member>>{};
  final _events = <String, List<_Event>>{}; // by group id
  final _totals =
      <String, Map<String, (int, int)>>{}; // group -> user -> (min, days)
  // group -> user -> category -> that week's data
  final _scores =
      <
        String,
        Map<
          String,
          Map<
            GroupCategory,
            ({
              double score,
              int days,
              Map<String, Object?> metrics,
              List<({String date, num amount})> daily,
            })
          >
        >
      >{};
  var _next = 0;

  /// Makes the next call fail with this, once.
  GroupsProblem? failNext;

  final calls = <String>[];

  String _id(String prefix) => '$prefix-${++_next}';

  var _codes = 0;

  /// A 4-digit code, different each time.
  String _newCode() => (4000 + ++_codes * 37).toString();

  var _wrongCodes = 0;

  /// Like the server: 5 wrong codes lock out further tries.
  void _checkGuessing() {
    if (_wrongCodes >= 5) {
      throw const GroupsException(GroupsProblem.tooManyAttempts);
    }
  }

  /// Lets the guessing limit lapse, as it does after 15 minutes.
  void forgetWrongCodes() => _wrongCodes = 0;

  void _check(String call) {
    calls.add(call);
    final f = failNext;
    if (f != null) {
      failNext = null;
      throw GroupsException(f);
    }
    if (!signedIn) throw const GroupsException(GroupsProblem.notSignedIn);
  }

  // Test set-up -----------------------------------------------------------

  /// A group that already exists, with [me] optionally in it.
  Group seedGroup(
    String name, {
    String id = '',
    String owner = 'someone',
    bool includeMe = true,
    String? code,
  }) {
    final gid = id.isEmpty ? _id('g') : id;
    final g = Group(
      id: gid,
      name: name,
      ownerId: owner,
      inviteCode:
          code ?? 'code${gid.replaceAll(RegExp('[^a-z0-9]'), '')}000000',
    );
    _groups[gid] = g;
    _members[gid] = [];
    _events[gid] = [];
    if (owner != me) addMember(gid, owner, 'Owner of $name', owner: true);
    if (includeMe) {
      _members[gid]!.add(
        _Member(me, myName, owner == me, DateTime.utc(2026, 1, 1)),
      );
    }
    return g;
  }

  void addMember(
    String groupId,
    String userId,
    String name, {
    bool owner = false,
    bool shareWorkouts = true,
    bool shareBreaks = true,
    bool shareSleep = false,
    bool shareScreenTime = false,
  }) {
    _members[groupId]!.add(
      _Member(
        userId,
        name,
        owner,
        DateTime.utc(2026, 1, 2).add(Duration(days: _members[groupId]!.length)),
        shareWorkouts: shareWorkouts,
        shareBreaks: shareBreaks,
        shareSleep: shareSleep,
        shareScreenTime: shareScreenTime,
      ),
    );
  }

  /// Gives a member weekly data in a category: [score] (0 to 10) is what the
  /// real server would compute and is used only to rank, never shown;
  /// [metrics] are the key figures; [daily] one figure per day.
  void seedScores(
    String groupId,
    String userId,
    GroupCategory category,
    double score, {
    int days = 1,
    Map<String, Object?> metrics = const {},
    List<({String date, num amount})> daily = const [],
  }) {
    ((_scores[groupId] ??= {})[userId] ??= {})[category] = (
      score: score,
      days: days,
      metrics: metrics,
      daily: daily,
    );
  }

  GroupEvent addEvent(
    String groupId,
    String userId,
    GroupEventKind kind,
    Map<String, Object?> payload,
    DateTime at,
  ) {
    final e = _Event(_id('e'), userId, kind, payload, at);
    _events[groupId]!.add(e);
    return e.toModel();
  }

  void setTotals(String groupId, String userId, int minutes, int days) {
    (_totals[groupId] ??= {})[userId] = (minutes, days);
  }

  bool isMember(String groupId) =>
      _members[groupId]?.any((m) => m.userId == me) ?? false;

  _Member? _memberRow(String groupId, String userId) {
    for (final m in _members[groupId] ?? const <_Member>[]) {
      if (m.userId == userId) return m;
    }
    return null;
  }

  /// What a member currently shares, for assertions.
  ({bool workouts, bool breaks, bool sleep, bool screenTime, bool hobbies})?
  sharing(String groupId, String userId) {
    final m = _memberRow(groupId, userId);
    return m == null
        ? null
        : (
            workouts: m.shareWorkouts,
            breaks: m.shareBreaks,
            sleep: m.shareSleep,
            screenTime: m.shareScreenTime,
            hobbies: m.shareHobbies,
          );
  }

  // GroupsRemote -------------------------------------------------------------

  @override
  bool get isAvailable => true;

  @override
  Future<List<Group>> listGroups() async {
    _check('listGroups');
    return [
      for (final g in _groups.values)
        if (isMember(g.id)) g.copyWith(memberCount: _members[g.id]!.length),
    ];
  }

  @override
  Future<Group> createGroup(String name, {GroupSharing? sharing}) async {
    _check('createGroup');
    lastSharing = sharing;
    final n = name.trim();
    if (n.isEmpty || n.length > 40) {
      throw const GroupsException(GroupsProblem.invalidName);
    }
    if (_groups.values.where((g) => isMember(g.id)).length >= 10) {
      throw const GroupsException(GroupsProblem.tooManyGroups);
    }
    final g = seedGroup(n, owner: me);
    _applySharing(g.id, sharing);
    return g.copyWith(memberCount: 1);
  }

  /// The choices passed with the last create or join, for assertions.
  GroupSharing? lastSharing;

  void _applySharing(String groupId, GroupSharing? s) {
    final m = _memberRow(groupId, me);
    if (m == null || s == null) return;
    m.shareWorkouts = s.workouts;
    m.shareBreaks = s.habits;
    m.shareSleep = s.sleep;
    m.shareScreenTime = s.screenTime;
    m.shareHobbies = s.hobbies;
  }

  Group? _byCode(String code) {
    for (final g in _groups.values) {
      if (g.inviteCode == code.trim().toLowerCase()) return g;
    }
    return null;
  }

  @override
  Future<InvitePreview> previewInvite(String code) async {
    _check('previewInvite');
    _checkGuessing();
    final g = _byCode(code);
    if (g == null) {
      _wrongCodes++;
      throw const GroupsException(GroupsProblem.inviteNotFound);
    }
    return InvitePreview(
      name: g.name,
      memberCount: _members[g.id]!.length,
      alreadyMember: isMember(g.id),
    );
  }

  @override
  Future<String> joinGroup(String code, {GroupSharing? sharing}) async {
    _check('joinGroup');
    lastSharing = sharing;
    _checkGuessing();
    final g = _byCode(code);
    if (g == null) {
      _wrongCodes++;
      throw const GroupsException(GroupsProblem.inviteNotFound);
    }
    if (isMember(g.id)) return g.id;
    if (_members[g.id]!.length >= 20) {
      throw const GroupsException(GroupsProblem.groupFull);
    }
    _members[g.id]!.add(_Member(me, myName, false, DateTime.utc(2026, 5, 13)));
    _applySharing(g.id, sharing);
    return g.id;
  }

  @override
  Future<List<GroupMember>> roster(String groupId) async {
    _check('roster');
    if (!isMember(groupId)) return [];
    return [for (final m in _members[groupId]!) m.toModel()];
  }

  @override
  Future<List<GroupEvent>> feed(String groupId, {int limit = 30}) async {
    _check('feed');
    if (!isMember(groupId)) return [];
    final shown = [
      for (final e in _events[groupId]!)
        if (_shares(groupId, e)) e,
    ]..sort((a, b) => b.at.compareTo(a.at));
    return [for (final e in shown.take(limit)) e.toModel()];
  }

  bool _shares(String groupId, _Event e) {
    final m = _memberRow(groupId, e.userId);
    if (m == null) return false;
    return e.kind == GroupEventKind.breakGoal ? m.shareBreaks : m.shareWorkouts;
  }

  @override
  Future<List<LeaderboardEntry>> leaderboard(
    String groupId,
    String weekStart,
  ) async {
    _check('leaderboard');
    if (!isMember(groupId)) return [];
    return [
      for (final m in _members[groupId]!)
        if (m.shareWorkouts)
          LeaderboardEntry(
            userId: m.userId,
            displayName: m.name,
            activeMinutes: _totals[groupId]?[m.userId]?.$1 ?? 0,
            activeDays: _totals[groupId]?[m.userId]?.$2 ?? 0,
          ),
    ];
  }

  @override
  Future<void> setCheer(String eventId, {required bool cheered}) async {
    _check('setCheer');
    for (final list in _events.values) {
      for (final e in list) {
        if (e.id != eventId) continue;
        if (e.userId == me) {
          throw const GroupsException(GroupsProblem.notOwner);
        }
        cheered ? e.cheers.add(me) : e.cheers.remove(me);
      }
    }
  }

  @override
  Future<void> setSharing(
    String groupId, {
    bool? workouts,
    bool? breaks,
    bool? sleep,
    bool? screenTime,
    bool? hobbies,
  }) async {
    _check('setSharing');
    final m = _memberRow(groupId, me);
    if (m == null) return;
    if (workouts != null) m.shareWorkouts = workouts;
    if (breaks != null) m.shareBreaks = breaks;
    if (sleep != null) m.shareSleep = sleep;
    if (screenTime != null) m.shareScreenTime = screenTime;
    if (hobbies != null) m.shareHobbies = hobbies;
  }

  // Scoring views. They follow the same rules as the server functions in
  // supabase/migrations/20261013000000_group_categories.sql: a category is
  // read only for members who share it and only shown to a viewer who shares
  // it; a tab needs at least 2 sharing members with data.

  /// Members who share [c] and have data this week.
  List<_Member> _sharersWithData(String groupId, GroupCategory c) => [
    for (final m in _members[groupId] ?? const <_Member>[])
      if (m.shares(c) && _scores[groupId]?[m.userId]?[c] != null) m,
  ];

  /// userId -> (overall mean, categories behind it) for members with at
  /// least one shared category with data.
  Map<String, ({double mean, List<GroupCategory> cats})> _overall(
    String groupId,
  ) {
    final out = <String, ({double mean, List<GroupCategory> cats})>{};
    for (final m in _members[groupId] ?? const <_Member>[]) {
      final cats = [
        for (final c in GroupCategory.values)
          if (m.shares(c) && _scores[groupId]?[m.userId]?[c] != null) c,
      ];
      if (cats.isEmpty) continue;
      final sum = cats.fold<double>(
        0,
        (a, c) => a + _scores[groupId]![m.userId]![c]!.score,
      );
      out[m.userId] = (mean: sum / cats.length, cats: cats);
    }
    return out;
  }

  @override
  Future<Set<GroupTab>> availableTabs(String groupId, String weekStart) async {
    _check('availableTabs');
    final mine = _memberRow(groupId, me);
    if (mine == null) return {};
    final tabs = <GroupTab>{};
    for (final c in GroupCategory.values) {
      if (mine.shares(c) && _sharersWithData(groupId, c).length >= 2) {
        tabs.add(GroupTab.fromWire(c.wire)!);
      }
    }
    final sharesAny = GroupCategory.values.any(mine.shares);
    if (sharesAny && _overall(groupId).length >= 2) tabs.add(GroupTab.overall);
    return tabs;
  }

  @override
  Future<List<OverallEntry>> overallBoard(
    String groupId,
    String weekStart,
  ) async {
    _check('overallBoard');
    if (!(await availableTabs(groupId, weekStart)).contains(GroupTab.overall)) {
      return [];
    }
    final mine = _memberRow(groupId, me)!;
    final rows = _overall(groupId).entries.toList()
      ..sort((a, b) {
        final byScore = b.value.mean.compareTo(a.value.mean);
        return byScore != 0
            ? byScore
            : _memberRow(groupId, a.key)!.name.toLowerCase().compareTo(
                _memberRow(groupId, b.key)!.name.toLowerCase(),
              );
      });
    final ranks = competitionRanks([for (final r in rows) r.value.mean]);
    return [
      for (var i = 0; i < rows.length; i++)
        OverallEntry(
          userId: rows[i].key,
          displayName: _memberRow(groupId, rows[i].key)!.name,
          rank: ranks[i],
          categories: [
            for (final c in rows[i].value.cats)
              if (mine.shares(c)) c,
          ],
        ),
    ];
  }

  @override
  Future<List<CategoryEntry>> categoryBoard(
    String groupId,
    String weekStart,
    GroupCategory category,
  ) async {
    _check('categoryBoard');
    final tabs = await availableTabs(groupId, weekStart);
    if (!tabs.contains(GroupTab.fromWire(category.wire))) return [];
    final rows = _sharersWithData(groupId, category)
      ..sort((a, b) {
        final x = _scores[groupId]![a.userId]![category]!;
        final y = _scores[groupId]![b.userId]![category]!;
        final byScore = y.score.compareTo(x.score);
        return byScore != 0 ? byScore : y.days.compareTo(x.days);
      });
    final ranks = competitionRanks([
      for (final m in rows) _scores[groupId]![m.userId]![category]!.score,
    ]);
    return [
      for (var i = 0; i < rows.length; i++)
        CategoryEntry(
          userId: rows[i].userId,
          displayName: rows[i].name,
          rank: ranks[i],
          metrics: _scores[groupId]![rows[i].userId]![category]!.metrics,
        ),
    ];
  }

  @override
  Future<ParticipantMetrics?> memberMetrics(
    String groupId,
    String userId,
    String weekStart,
    GroupCategory category,
  ) async {
    _check('memberMetrics');
    final mine = _memberRow(groupId, me);
    final theirs = _memberRow(groupId, userId);
    if (mine == null || theirs == null || !theirs.shares(category)) return null;
    if (userId != me && !mine.shares(category)) return null;
    final data = _scores[groupId]?[userId]?[category];
    if (data == null) return null;
    return ParticipantMetrics(summary: data.metrics, days: data.daily);
  }

  @override
  Future<void> rename(String groupId, String name) async {
    _check('rename');
    final g = _groups[groupId]!;
    if (g.ownerId != me) throw const GroupsException(GroupsProblem.notOwner);
    final n = name.trim();
    if (n.isEmpty || n.length > 40) {
      throw const GroupsException(GroupsProblem.invalidName);
    }
    _groups[groupId] = g.copyWith(name: n);
  }

  @override
  Future<String> rotateInvite(String groupId) async {
    _check('rotateInvite');
    final g = _groups[groupId]!;
    if (g.ownerId != me) throw const GroupsException(GroupsProblem.notOwner);
    final code = _newCode();
    _groups[groupId] = g.copyWith(inviteCode: code);
    return code;
  }

  @override
  Future<void> leave(String groupId) async {
    _check('leave');
    _members[groupId]?.removeWhere((m) => m.userId == me);
    if (_members[groupId]?.isEmpty ?? false) {
      _groups.remove(groupId);
    } else if (_groups[groupId]?.ownerId == me) {
      final next = _members[groupId]!.first;
      next.isOwner = true;
      _groups[groupId] = Group(
        id: groupId,
        name: _groups[groupId]!.name,
        ownerId: next.userId,
        inviteCode: _groups[groupId]!.inviteCode,
      );
    }
  }
}

class _Member {
  _Member(
    this.userId,
    this.name,
    this.isOwner,
    this.joinedAt, {
    this.shareWorkouts = true,
    this.shareBreaks = true,
    this.shareSleep = false,
    this.shareScreenTime = false,
  });
  final String userId;
  final String name;
  bool isOwner;
  final DateTime joinedAt;
  bool shareWorkouts;
  bool shareBreaks;
  bool shareSleep;
  bool shareScreenTime;
  bool shareHobbies = false;

  bool shares(GroupCategory c) => switch (c) {
    GroupCategory.workouts => shareWorkouts,
    GroupCategory.habits => shareBreaks,
    GroupCategory.sleep => shareSleep,
    GroupCategory.screenTime => shareScreenTime,
  };

  GroupMember toModel() => GroupMember(
    userId: userId,
    displayName: name,
    isOwner: isOwner,
    joinedAt: joinedAt,
    shareWorkouts: shareWorkouts,
    shareBreaks: shareBreaks,
    shareSleep: shareSleep,
    shareScreenTime: shareScreenTime,
    shareHobbies: shareHobbies,
  );
}

class _Event {
  _Event(this.id, this.userId, this.kind, this.payload, this.at);
  final String id;
  final String userId;
  final GroupEventKind kind;
  final Map<String, Object?> payload;
  final DateTime at;
  final cheers = <String>{};

  GroupEvent toModel() => GroupEvent(
    id: id,
    userId: userId,
    kind: kind,
    payload: payload,
    occurredAt: at,
    cheeredBy: {...cheers},
  );
}
