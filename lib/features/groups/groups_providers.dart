import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/time/local_date.dart';
import '../../data/providers.dart';
import '../account/sync_providers.dart';

import 'package:drift/drift.dart' show Value;

import '../../data/app_database.dart' show UsersCompanion;
import '../week/week_providers.dart';
import 'groups_models.dart';
import 'groups_remote.dart';

/// Failed loads are shown (with Try again) rather than retried silently behind
/// a spinner, which Riverpod would otherwise do.
Duration? _noRetry(int retryCount, Object error) => null;

/// Overridden with the Supabase implementation in main() when configured.
final groupsRemoteProvider = Provider<GroupsRemote>(
  (_) => UnavailableGroupsRemote(),
);

/// The signed-in account's id, or null.
final _accountIdProvider = Provider<String?>(
  (ref) => ref.watch(authUserProvider).value?.id,
);

/// The groups the signed-in person belongs to. Empty when signed out.
final groupsListProvider = FutureProvider<List<Group>>((ref) async {
  final account = ref.watch(_accountIdProvider);
  if (account == null) return const [];
  return ref.watch(groupsRemoteProvider).listGroups();
}, retry: _noRetry);

/// A group from the list, so settings can show the latest name and code.
final groupProvider = Provider.family<Group?, String>((ref, id) {
  final groups = ref.watch(groupsListProvider).value;
  if (groups == null) return null;
  for (final g in groups) {
    if (g.id == id) return g;
  }
  return null;
});

final groupRosterProvider = FutureProvider.family<List<GroupMember>, String>(
  (ref, groupId) => ref.watch(groupsRemoteProvider).roster(groupId),
  retry: _noRetry,
);

final groupFeedProvider = FutureProvider.family<List<GroupEvent>, String>(
  (ref, groupId) => ref.watch(groupsRemoteProvider).feed(groupId),
  retry: _noRetry,
);

/// Monday of the current week in this phone's local time.
final groupWeekStartProvider = Provider<String?>((ref) {
  final today = ref.watch(todayDateProvider).value;
  return today == null ? null : weekStartOf(today);
});

final groupLeaderboardProvider =
    FutureProvider.family<List<LeaderboardEntry>, String>((ref, groupId) async {
      final week = ref.watch(groupWeekStartProvider);
      if (week == null) return const [];
      return ref.watch(groupsRemoteProvider).leaderboard(groupId, week);
    }, retry: _noRetry);

class LeaderboardMetricNotifier extends Notifier<LeaderboardMetric> {
  @override
  LeaderboardMetric build() => LeaderboardMetric.volume;
  void set(LeaderboardMetric m) => state = m;
}

final leaderboardMetricProvider =
    NotifierProvider<LeaderboardMetricNotifier, LeaderboardMetric>(
      LeaderboardMetricNotifier.new,
    );

/// Changes made from the Groups screens. Each call refreshes what it
/// affected and lets [GroupsException] reach the caller to show.
class GroupsActions {
  GroupsActions(this._ref);
  final Ref _ref;

  GroupsRemote get _remote => _ref.read(groupsRemoteProvider);

  void _refreshGroup(String groupId) {
    _ref.invalidate(groupRosterProvider(groupId));
    _ref.invalidate(groupFeedProvider(groupId));
    _ref.invalidate(groupLeaderboardProvider(groupId));
  }

  /// Members see each other by name. If none is set yet, use the account's.
  Future<void> _ensureName() async {
    final account = _ref.read(authUserProvider).value;
    final accountName = account?.displayName?.trim() ?? '';
    if (accountName.isEmpty) return;
    final repo = _ref.read(userRepositoryProvider);
    final user = await repo.ensureUser();
    if (user.displayName.trim().isEmpty) {
      await repo.update(
        user.id,
        UsersCompanion(displayName: Value(accountName)),
      );
    }
  }

  Future<Group> create(String name) async {
    await _ensureName();
    final g = await _remote.createGroup(name);
    _ref.invalidate(groupsListProvider);
    return g;
  }

  Future<String> join(String code) async {
    await _ensureName();
    final id = await _remote.joinGroup(code);
    _ref.invalidate(groupsListProvider);
    return id;
  }

  Future<void> cheer(String groupId, String eventId, bool cheered) async {
    await _remote.setCheer(eventId, cheered: cheered);
    _ref.invalidate(groupFeedProvider(groupId));
  }

  Future<void> setSharing(
    String groupId, {
    bool? workouts,
    bool? breaks,
  }) async {
    await _remote.setSharing(groupId, workouts: workouts, breaks: breaks);
    _refreshGroup(groupId);
  }

  Future<void> rename(String groupId, String name) async {
    await _remote.rename(groupId, name);
    _ref.invalidate(groupsListProvider);
  }

  Future<void> rotateInvite(String groupId) async {
    await _remote.rotateInvite(groupId);
    _ref.invalidate(groupsListProvider);
  }

  Future<void> leave(String groupId) async {
    await _remote.leave(groupId);
    _ref.invalidate(groupsListProvider);
  }

  void refresh(String groupId) {
    _refreshGroup(groupId);
    _ref.invalidate(groupsListProvider);
  }
}

final groupsActionsProvider = Provider((ref) => GroupsActions(ref));
