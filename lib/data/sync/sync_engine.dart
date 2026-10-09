import '../app_database.dart';
import 'remote_store.dart';
import 'sync_state.dart';
import 'sync_tables.dart';

class SyncReport {
  const SyncReport({this.pushed = 0, this.pulled = 0, this.error});

  /// Rows sent to the server (including ones it ignored as already current).
  final int pushed;

  /// Server rows that changed this device.
  final int pulled;

  /// Set when the sync stopped early (offline, server error). Nothing is lost:
  /// the next run continues from where this one stopped.
  final Object? error;

  bool get ok => error == null;
}

/// Local-first sync (spec section 12, step "Auth and sync").
///
/// Writes always go to the local database first and work offline. This engine
/// copies changes to the server and brings other devices' changes back.
///
///  * Push: rows whose `updated_at` is at or after the per-table watermark,
///    in chunks. The server keeps the newer row, so re-sending is harmless.
///  * Pull: rows after the per-table `sync_seq` cursor. A server row replaces
///    a local one only if strictly newer (last write wins).
///  * Row ids are client-generated UUIDs, so retries never create duplicates.
class SyncEngine {
  SyncEngine({
    required this.db,
    required this.remote,
    required this.state,
    this.tables = syncTables,
    this.chunkSize = 200,
    this.pageSize = 500,
  });

  final AppDatabase db;
  final RemoteStore remote;
  final SyncStateStore state;
  final List<SyncTable> tables;
  final int chunkSize;
  final int pageSize;

  bool _running = false;

  /// Syncs everything. [remoteUserId] is the signed-in account's id on the
  /// server and [localUserId] is this device's user row.
  Future<SyncReport> run({
    required String remoteUserId,
    required String localUserId,
  }) async {
    if (_running) return const SyncReport(); // one sync at a time
    _running = true;
    var pushed = 0;
    var pulled = 0;
    try {
      for (final t in tables) {
        pushed += await _push(t, remoteUserId);
      }
      for (final t in tables) {
        pulled += await _pull(t, localUserId);
      }
      return SyncReport(pushed: pushed, pulled: pulled);
    } catch (e) {
      return SyncReport(pushed: pushed, pulled: pulled, error: e);
    } finally {
      _running = false;
    }
  }

  Future<int> _push(SyncTable t, String remoteUserId) async {
    final since = await state.pushedUntil(t.name);
    final rows = await t.localChanges(db, since, remoteUserId);
    if (rows.isEmpty) return 0;

    for (var i = 0; i < rows.length; i += chunkSize) {
      final end = i + chunkSize > rows.length ? rows.length : i + chunkSize;
      await remote.upsert(t.name, t.keyColumn, rows.sublist(i, end));
    }
    // Only after every chunk succeeded, so a failure resends the lot.
    final newest = rows
        .map((r) => DateTime.parse(r['updated_at'] as String))
        .reduce((a, b) => a.isAfter(b) ? a : b);
    await state.setPushedUntil(t.name, newest);
    return rows.length;
  }

  Future<int> _pull(SyncTable t, String localUserId) async {
    var cursor = await state.pullCursor(t.name);
    var changed = 0;
    while (true) {
      final page = await remote.fetchChanges(t.name, cursor, limit: pageSize);
      for (final row in page.rows) {
        if (await t.applyRemote(db, row, localUserId)) changed++;
      }
      if (page.cursor != cursor) {
        cursor = page.cursor;
        await state.setPullCursor(t.name, cursor);
      }
      if (!page.hasMore) break;
    }
    return changed;
  }
}
