import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'groups_models.dart';
import 'groups_remote.dart';

/// [GroupsRemote] over Supabase. Row-level security and the database
/// functions decide what each member may see (see migrations/…_groups.sql).
class SupabaseGroupsRemote implements GroupsRemote {
  SupabaseGroupsRemote(this._client);

  final SupabaseClient _client;

  @override
  bool get isAvailable => true;

  String get _me {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const GroupsException(GroupsProblem.notSignedIn);
    return id;
  }

  /// Runs [call], turning server and network failures into [GroupsException].
  Future<T> _run<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on PostgrestException catch (e) {
      throw GroupsException(_problemFor(e));
    } on SocketException {
      throw const GroupsException(GroupsProblem.network);
    } on AuthException {
      throw const GroupsException(GroupsProblem.notSignedIn);
    } on HttpException {
      throw const GroupsException(GroupsProblem.network);
    }
  }

  @override
  Future<List<Group>> listGroups() => _run(() async {
    _me;
    final rows = await _client
        .from('groups')
        .select('id, name, owner_id, invite_code, group_members(count)')
        .order('created_at');
    return [for (final r in rows) _group(Map<String, Object?>.from(r))];
  });

  @override
  Future<Group> createGroup(String name) => _run(() async {
    final row = await _client.rpc('create_group', params: {'p_name': name});
    return _group(Map<String, Object?>.from(row as Map))
        .copyWith(memberCount: 1);
  });

  @override
  Future<InvitePreview> previewInvite(String code) => _run(() async {
    final rows = await _client.rpc('group_preview', params: {'p_code': code});
    final list = rows as List;
    if (list.isEmpty) {
      throw const GroupsException(GroupsProblem.inviteNotFound);
    }
    final r = Map<String, Object?>.from(list.first as Map);
    return InvitePreview(
      name: r['name'] as String,
      memberCount: (r['member_count'] as num).toInt(),
      alreadyMember: r['is_member'] as bool,
    );
  });

  @override
  Future<String> joinGroup(String code) => _run(() async {
    final id = await _client.rpc('join_group', params: {'p_code': code});
    return id as String;
  });

  @override
  Future<List<GroupMember>> roster(String groupId) => _run(() async {
    final rows = await _client.rpc(
      'group_roster',
      params: {'p_group_id': groupId},
    );
    return [
      for (final r in rows as List)
        _member(Map<String, Object?>.from(r as Map)),
    ];
  });

  @override
  Future<List<GroupEvent>> feed(String groupId, {int limit = 30}) => _run(
    () async {
      final rows = await _client
          .from('group_events')
          .select('id, user_id, kind, payload, occurred_at, reactions(user_id)')
          .eq('group_id', groupId)
          .order('occurred_at', ascending: false)
          .limit(limit);
      return [for (final r in rows) _event(Map<String, Object?>.from(r))];
    },
  );

  @override
  Future<List<LeaderboardEntry>> leaderboard(
    String groupId,
    String weekStart,
  ) => _run(() async {
    final rows = await _client.rpc(
      'group_leaderboard',
      params: {'p_group_id': groupId, 'p_week_start': weekStart},
    );
    return [
      for (final r in rows as List)
        LeaderboardEntry(
          userId: (r as Map)['user_id'] as String,
          displayName: r['display_name'] as String? ?? '',
          activeMinutes: (r['active_minutes'] as num).toInt(),
          activeDays: (r['active_days'] as num).toInt(),
        ),
    ];
  });

  @override
  Future<void> setCheer(String eventId, {required bool cheered}) =>
      _run(() async {
        final me = _me;
        if (cheered) {
          await _client
              .from('reactions')
              .upsert(
                {'event_id': eventId, 'user_id': me, 'kind': 'cheer'},
                onConflict: 'event_id,user_id,kind',
                ignoreDuplicates: true,
              );
        } else {
          await _client
              .from('reactions')
              .delete()
              .eq('event_id', eventId)
              .eq('user_id', me)
              .eq('kind', 'cheer');
        }
      });

  @override
  Future<void> setSharing(String groupId, {bool? workouts, bool? breaks}) =>
      _run(() async {
        final changes = <String, Object?>{
          'share_workouts': ?workouts,
          'share_breaks': ?breaks,
        };
        if (changes.isEmpty) return;
        await _client
            .from('group_members')
            .update(changes)
            .eq('group_id', groupId)
            .eq('user_id', _me);
      });

  @override
  Future<void> rename(String groupId, String name) => _run(() async {
    final n = name.trim();
    if (n.isEmpty || n.length > 40) {
      throw const GroupsException(GroupsProblem.invalidName);
    }
    final updated = await _client
        .from('groups')
        .update({'name': n})
        .eq('id', groupId)
        .select('id');
    if (updated.isEmpty) throw const GroupsException(GroupsProblem.notOwner);
  });

  @override
  Future<String> rotateInvite(String groupId) => _run(() async {
    final code = await _client.rpc(
      'rotate_invite_code',
      params: {'p_group_id': groupId},
    );
    return code as String;
  });

  @override
  Future<void> leave(String groupId) => _run(() async {
    await _client
        .from('group_members')
        .delete()
        .eq('group_id', groupId)
        .eq('user_id', _me);
  });
}

Group _group(Map<String, Object?> r) {
  var count = 0;
  final embedded = r['group_members'];
  if (embedded is List && embedded.isNotEmpty) {
    count = ((embedded.first as Map)['count'] as num).toInt();
  }
  return Group(
    id: r['id'] as String,
    name: r['name'] as String,
    ownerId: r['owner_id'] as String,
    inviteCode: r['invite_code'] as String,
    memberCount: count,
  );
}

GroupMember _member(Map<String, Object?> r) => GroupMember(
  userId: r['user_id'] as String,
  displayName: r['display_name'] as String? ?? '',
  isOwner: r['role'] == 'owner',
  joinedAt: DateTime.parse(r['joined_at'] as String),
  shareWorkouts: r['share_workouts'] as bool,
  shareBreaks: r['share_breaks'] as bool,
);

GroupEvent _event(Map<String, Object?> r) {
  final reactions = (r['reactions'] as List?) ?? const [];
  return GroupEvent(
    id: r['id'] as String,
    userId: r['user_id'] as String,
    kind: switch (r['kind']) {
      'break_goal' => GroupEventKind.breakGoal,
      'milestone' => GroupEventKind.milestone,
      _ => GroupEventKind.workout,
    },
    payload: Map<String, Object?>.from((r['payload'] as Map?) ?? const {}),
    occurredAt: DateTime.parse(r['occurred_at'] as String),
    cheeredBy: {for (final x in reactions) (x as Map)['user_id'] as String},
  );
}

GroupsProblem _problemFor(PostgrestException e) {
  final text = '${e.message} ${e.details ?? ''}';
  if (text.contains('invite_not_found')) return GroupsProblem.inviteNotFound;
  if (text.contains('group_full')) return GroupsProblem.groupFull;
  if (text.contains('too_many_groups')) return GroupsProblem.tooManyGroups;
  if (text.contains('not_owner')) return GroupsProblem.notOwner;
  if (text.contains('invalid_name')) return GroupsProblem.invalidName;
  if (text.contains('not_signed_in')) return GroupsProblem.notSignedIn;
  return GroupsProblem.network;
}

/// Visible for tests.
GroupsProblem problemForServerMessage(String message) =>
    _problemFor(PostgrestException(message: message));
