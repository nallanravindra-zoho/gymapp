import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../data/sync/local_reset.dart';
import '../../data/sync/remote_store.dart';
import '../../data/sync/sync_engine.dart';
import '../../data/sync/sync_state.dart';
import 'auth_service.dart';

/// Why sync could not start, when the build has settings but starting
/// Supabase or Google failed. Set in main(); null otherwise.
final syncSetupIssueProvider = Provider<String?>((_) => null);

/// Overridden with the Supabase implementation in main() when configured.
final authServiceProvider = Provider<AuthService>(
  (_) => UnavailableAuthService(),
);

/// Overridden with the Supabase implementation in main() when configured.
final remoteStoreProvider = Provider<RemoteStore>((_) => _NoRemote());

class _NoRemote implements RemoteStore {
  @override
  Future<void> upsert(String table, String keyColumn, List<Json> rows) =>
      throw StateError('Sync is not set up in this build.');
  @override
  Future<RemotePage> fetchChanges(
    String table,
    int afterSeq, {
    int limit = 500,
  }) => throw StateError('Sync is not set up in this build.');
}

final syncStateProvider = Provider<SyncStateStore>(
  (_) => PrefsSyncStateStore(),
);

final syncEngineProvider = Provider(
  (ref) => SyncEngine(
    db: ref.watch(databaseProvider),
    remote: ref.watch(remoteStoreProvider),
    state: ref.watch(syncStateProvider),
  ),
);

/// The signed-in account, or null.
final authUserProvider = StreamProvider<AccountUser?>((ref) async* {
  final auth = ref.watch(authServiceProvider);
  yield auth.currentUser;
  yield* auth.userChanges;
});

class SyncStatus {
  const SyncStatus({
    this.syncing = false,
    this.lastSyncedAt,
    this.lastFailed = false,
    this.accountConflict = false,
  });

  final bool syncing;
  final DateTime? lastSyncedAt;

  /// The most recent attempt did not finish. It is retried automatically.
  final bool lastFailed;

  /// This phone holds data from a different account than the one signed in,
  /// so nothing is synced until the person chooses what to do.
  final bool accountConflict;

  SyncStatus copyWith({
    bool? syncing,
    DateTime? lastSyncedAt,
    bool? lastFailed,
    bool? accountConflict,
  }) => SyncStatus(
    syncing: syncing ?? this.syncing,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    lastFailed: lastFailed ?? this.lastFailed,
    accountConflict: accountConflict ?? this.accountConflict,
  );
}

class SyncController extends Notifier<SyncStatus> {
  @override
  SyncStatus build() => const SyncStatus();

  /// Syncs now if someone is signed in. Safe to call at any time and as
  /// often as needed: overlapping calls are ignored.
  Future<void> syncNow() async {
    final account = ref.read(authServiceProvider).currentUser;
    if (account == null || state.syncing) return;

    final store = ref.read(syncStateProvider);
    final previous = await store.accountId();
    if (previous != null && previous != account.id) {
      // Never merge one person's data into another account unasked.
      state = state.copyWith(accountConflict: true);
      return;
    }
    // Recorded before the first push, so a sync that stops half-way still
    // remembers whose data this is.
    if (previous == null) await store.setAccountId(account.id);

    state = state.copyWith(syncing: true, accountConflict: false);
    try {
      final user = await ref.read(userRepositoryProvider).ensureUser();
      final report = await ref
          .read(syncEngineProvider)
          .run(remoteUserId: account.id, localUserId: user.id);
      state = report.ok
          ? SyncStatus(
              lastSyncedAt: ref.read(clockProvider).now(),
              lastFailed: false,
            )
          : SyncStatus(lastSyncedAt: state.lastSyncedAt, lastFailed: true);
    } catch (_) {
      state = SyncStatus(lastSyncedAt: state.lastSyncedAt, lastFailed: true);
    }
  }

  /// For a phone that held another account's data: erase it here and start
  /// from the signed-in account's data on the server.
  Future<void> replaceLocalData() async {
    final account = ref.read(authServiceProvider).currentUser;
    if (account == null) return;
    final store = ref.read(syncStateProvider);
    final user = await ref.read(userRepositoryProvider).ensureUser();
    await wipeLocalAccountData(ref.read(databaseProvider), user.id);
    await store.reset();
    await store.setAccountId(account.id);
    state = const SyncStatus();
    await syncNow();
  }
}

final syncControllerProvider = NotifierProvider<SyncController, SyncStatus>(
  SyncController.new,
);

/// Tables whose changes should reach the server.
const _syncedTables = {
  'users',
  'workout_types',
  'workouts',
  'habits',
  'habit_logs',
  'sleep_targets',
  'sleep_logs',
  'rest_days',
  'badges_awarded',
  'screen_time_daily',
};

/// Starts syncing at the right moments: after sign-in, a few seconds after
/// local changes, and every few minutes. Watch it once, from the app shell.
final syncEffectsProvider = Provider<void>((ref) {
  Timer? debounce;
  var immediatePending = false;

  /// Asks for a sync. By default it waits a few seconds, restarting the wait
  /// on each new change so a burst of edits is sent together. A request for
  /// an immediate sync (after sign-in, on a timer) is never pushed back by
  /// later change requests.
  void request({Duration delay = const Duration(seconds: 3)}) {
    final immediate = delay == Duration.zero;
    if (immediatePending && !immediate) return;
    debounce?.cancel();
    immediatePending = immediate;
    debounce = Timer(delay, () {
      immediatePending = false;
      ref.read(syncControllerProvider.notifier).syncNow();
    });
  }

  ref.listen(authUserProvider, (_, next) {
    if (next.value != null) request(delay: Duration.zero);
  }, fireImmediately: true);

  final db = ref.watch(databaseProvider);
  final sub = db
      .tableUpdates(TableUpdateQuery.onAllTables(db.allTables))
      .listen((updates) {
        // Changes made by a running sync are not new work.
        if (ref.read(syncControllerProvider).syncing) return;
        if (updates.any((u) => _syncedTables.contains(u.table))) request();
      });

  final periodic = Timer.periodic(
    const Duration(minutes: 5),
    (_) => request(delay: Duration.zero),
  );

  ref.onDispose(() {
    debounce?.cancel();
    periodic.cancel();
    sub.cancel();
  });
});
