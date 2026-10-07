/// A row as sent to or received from the server: snake_case column names,
/// timestamps as ISO-8601 strings.
typedef Json = Map<String, Object?>;

class RemotePage {
  const RemotePage({
    required this.rows,
    required this.cursor,
    required this.hasMore,
  });

  final List<Json> rows;

  /// Highest `sync_seq` in [rows], or the cursor that was asked for when empty.
  final int cursor;
  final bool hasMore;
}

/// The server side of sync. The app talks to this interface; Supabase
/// implements it for real, and [FakeRemoteStore] stands in for tests.
abstract class RemoteStore {
  /// Inserts or updates rows keyed by [keyColumn]. The server keeps the newer
  /// row by `updated_at` and silently ignores stale or duplicate writes.
  Future<void> upsert(String table, String keyColumn, List<Json> rows);

  /// Rows whose `sync_seq` is greater than [afterSeq], oldest change first.
  Future<RemotePage> fetchChanges(
    String table,
    int afterSeq, {
    int limit = 500,
  });
}

/// Behaves like the SQL in supabase/migrations: last write wins by
/// `updated_at`, and each accepted write gets the next `sync_seq`.
class FakeRemoteStore implements RemoteStore {
  final Map<String, Map<Object?, Json>> _tables = {};
  int _seq = 0;

  /// Set to make calls fail, to simulate being offline.
  Object? failWith;

  /// With [failWith], fail only calls for this table, as when a connection
  /// drops part-way through a sync. Null means every table fails.
  String? failOnlyTable;
  int upsertCalls = 0;
  int rowsSent = 0;

  bool _fails(String table) =>
      failWith != null && (failOnlyTable == null || failOnlyTable == table);

  List<Json> rows(String table) => [
    for (final r in (_tables[table] ?? const {}).values) {...r},
  ];

  @override
  Future<void> upsert(String table, String keyColumn, List<Json> rows) async {
    if (_fails(table)) throw failWith!;
    upsertCalls++;
    final store = _tables.putIfAbsent(table, () => {});
    for (final row in rows) {
      rowsSent++;
      final key = row[keyColumn];
      final existing = store[key];
      if (existing != null) {
        final old = DateTime.parse(existing['updated_at'] as String);
        final next = DateTime.parse(row['updated_at'] as String);
        if (!next.isAfter(old)) continue; // stale or duplicate: ignored
      }
      store[key] = {...row, 'sync_seq': ++_seq};
    }
  }

  @override
  Future<RemotePage> fetchChanges(
    String table,
    int afterSeq, {
    int limit = 500,
  }) async {
    if (_fails(table)) throw failWith!;
    final all = [
      for (final r in (_tables[table] ?? const {}).values)
        if ((r['sync_seq'] as int) > afterSeq) {...r},
    ]..sort((a, b) => (a['sync_seq'] as int).compareTo(b['sync_seq'] as int));
    final page = all.take(limit).toList();
    return RemotePage(
      rows: page,
      cursor: page.isEmpty ? afterSeq : page.last['sync_seq'] as int,
      hasMore: all.length > limit,
    );
  }
}
