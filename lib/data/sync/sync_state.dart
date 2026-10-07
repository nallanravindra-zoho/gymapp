import 'package:shared_preferences/shared_preferences.dart';

/// Remembers how far each table has been pushed and pulled, so a sync only
/// moves what changed.
abstract class SyncStateStore {
  /// Latest local `updated_at` already pushed for [table].
  Future<DateTime?> pushedUntil(String table);
  Future<void> setPushedUntil(String table, DateTime value);

  /// Highest server `sync_seq` already pulled for [table].
  Future<int> pullCursor(String table);
  Future<void> setPullCursor(String table, int value);

  /// The account this phone's data was last synced with, if any. Used to stop
  /// one person's data from being merged into another account.
  Future<String?> accountId();
  Future<void> setAccountId(String? id);

  /// Forget the sync positions (not the account id), e.g. before starting
  /// afresh with another account.
  Future<void> reset();
}

class MemorySyncStateStore implements SyncStateStore {
  final Map<String, DateTime> _pushed = {};
  final Map<String, int> _cursor = {};
  String? _account;

  @override
  Future<DateTime?> pushedUntil(String table) async => _pushed[table];
  @override
  Future<void> setPushedUntil(String table, DateTime value) async =>
      _pushed[table] = value;
  @override
  Future<int> pullCursor(String table) async => _cursor[table] ?? 0;
  @override
  Future<void> setPullCursor(String table, int value) async =>
      _cursor[table] = value;
  @override
  Future<String?> accountId() async => _account;
  @override
  Future<void> setAccountId(String? id) async => _account = id;
  @override
  Future<void> reset() async {
    _pushed.clear();
    _cursor.clear();
  }
}

class PrefsSyncStateStore implements SyncStateStore {
  static const _prefix = 'sync_';

  @override
  Future<DateTime?> pushedUntil(String table) async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt('${_prefix}push_$table');
    return ms == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  @override
  Future<void> setPushedUntil(String table, DateTime value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_prefix}push_$table', value.millisecondsSinceEpoch);
  }

  @override
  Future<int> pullCursor(String table) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('${_prefix}pull_$table') ?? 0;
  }

  @override
  Future<void> setPullCursor(String table, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_prefix}pull_$table', value);
  }

  static const _accountKey = 'sync_account_id';

  @override
  Future<String?> accountId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accountKey);
  }

  @override
  Future<void> setAccountId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_accountKey);
    } else {
      await prefs.setString(_accountKey, id);
    }
  }

  @override
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    final positions = prefs
        .getKeys()
        .where(
          (k) =>
              k.startsWith('${_prefix}push_') ||
              k.startsWith('${_prefix}pull_'),
        )
        .toList();
    for (final k in positions) {
      await prefs.remove(k);
    }
  }
}
