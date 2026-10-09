import 'package:drift/drift.dart';

/// Columns every synced row carries (spec section 6): client-generated UUID,
/// timestamps for last-write-wins sync, and a soft-delete marker.
mixin SyncColumns on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
