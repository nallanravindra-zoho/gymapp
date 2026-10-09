import 'package:supabase_flutter/supabase_flutter.dart';

import 'remote_store.dart';

/// [RemoteStore] over Supabase's REST API. Row-level security on the server
/// limits every call to the signed-in user's own rows.
class SupabaseRemoteStore implements RemoteStore {
  SupabaseRemoteStore(this._client);

  final SupabaseClient _client;

  @override
  Future<void> upsert(String table, String keyColumn, List<Json> rows) async {
    if (rows.isEmpty) return;
    // The server's guard trigger keeps the newer row and ignores stale or
    // duplicate writes, so this is safe to repeat.
    await _client.from(table).upsert(rows, onConflict: keyColumn);
  }

  @override
  Future<RemotePage> fetchChanges(
    String table,
    int afterSeq, {
    int limit = 500,
  }) async {
    final data = await _client
        .from(table)
        .select()
        .gt('sync_seq', afterSeq)
        .order('sync_seq', ascending: true)
        .limit(limit);
    final rows = [for (final r in data) Map<String, Object?>.from(r as Map)];
    return RemotePage(
      rows: rows,
      cursor: rows.isEmpty ? afterSeq : (rows.last['sync_seq'] as num).toInt(),
      hasMore: rows.length >= limit,
    );
  }
}
