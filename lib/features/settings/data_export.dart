import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/app_database.dart';

/// A file ready to hand to the person: its name, type and text.
class DataExport {
  const DataExport({
    required this.fileName,
    required this.mimeType,
    required this.content,
  });

  final String fileName;
  final String mimeType;
  final String content;
}

/// Writes every timestamp as ISO 8601 in UTC, so the file means the same
/// thing whatever time zone the phone was in.
class _UtcSerializer extends ValueSerializer {
  const _UtcSerializer();

  @override
  dynamic toJson<T>(T value) =>
      value is DateTime ? value.toUtc().toIso8601String() : value;

  @override
  T fromJson<T>(dynamic json) => throw UnsupportedError('Export only');
}

const _dates = _UtcSerializer();

String _stamp(DateTime now) {
  final d = now.toUtc();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

/// Everything stored for the person on this phone, as JSON. Deleted entries
/// and values derived from other data (streak cache, insights) are left out;
/// timestamps are ISO 8601 in UTC.
Future<DataExport> buildJsonExport(AppDatabase db, DateTime now) async {
  List<Map<String, dynamic>> rows<T extends DataClass>(List<T> items) => [
    for (final i in items) i.toJson(serializer: _dates),
  ];

  final user = await db.select(db.users).getSingleOrNull();
  final data = <String, Object?>{
    'app': 'Well-Being Companion',
    'exportVersion': 1,
    'exportedAt': now.toUtc().toIso8601String(),
    'profile': user?.toJson(serializer: _dates),
    'customWorkoutTypes': rows(
      await (db.select(
        db.workoutTypes,
      )..where((t) => t.isBuiltin.equals(false) & t.deletedAt.isNull())).get(),
    ),
    'workouts': rows(
      await (db.select(db.workouts)..where((t) => t.deletedAt.isNull())).get(),
    ),
    'habits': rows(
      await (db.select(db.habits)..where((t) => t.deletedAt.isNull())).get(),
    ),
    'habitLogs': rows(
      await (db.select(db.habitLogs)..where((t) => t.deletedAt.isNull())).get(),
    ),
    'sleepTargets': rows(await db.select(db.sleepTargets).get()),
    'sleepLogs': rows(
      await (db.select(db.sleepLogs)..where((t) => t.deletedAt.isNull())).get(),
    ),
    'restDays': rows(
      await (db.select(db.restDays)..where((t) => t.deletedAt.isNull())).get(),
    ),
    'badges': rows(
      await (db.select(
        db.badgesAwarded,
      )..where((t) => t.deletedAt.isNull())).get(),
    ),
    'screenTime': rows(
      await (db.select(
        db.screenTimeDaily,
      )..where((t) => t.deletedAt.isNull())).get(),
    ),
  };
  return DataExport(
    fileName: 'wellbeing-data-${_stamp(now)}.json',
    mimeType: 'application/json',
    content: const JsonEncoder.withIndent('  ').convert(data),
  );
}

/// One CSV cell. Quotes cells that need it, and defuses a leading `=`, `+`,
/// `-` or `@` so a spreadsheet never treats a note as a formula.
String csvCell(Object? value) {
  var text = value?.toString() ?? '';
  if (text.isNotEmpty &&
      '=+-@'.contains(text[0]) &&
      num.tryParse(text) == null) {
    text = "'$text";
  }
  final needsQuotes = text.contains(RegExp('[",\r\n]'));
  return needsQuotes ? '"${text.replaceAll('"', '""')}"' : text;
}

String toCsv(List<List<Object?>> rows) =>
    '${rows.map((r) => r.map(csvCell).join(',')).join('\r\n')}\r\n';

/// Workouts as a spreadsheet: one row each, oldest first.
Future<DataExport> buildWorkoutsCsv(AppDatabase db, DateTime now) async {
  final types = {
    for (final t in await db.select(db.workoutTypes).get()) t.id: t.name,
  };
  final workouts =
      await (db.select(db.workouts)
            ..where((w) => w.deletedAt.isNull())
            ..orderBy([(w) => OrderingTerm.asc(w.startedAt)]))
          .get();
  return DataExport(
    fileName: 'wellbeing-workouts-${_stamp(now)}.csv',
    mimeType: 'text/csv',
    content: toCsv([
      [
        'date',
        'type',
        'started_at',
        'ended_at',
        'minutes',
        'intensity',
        'note',
      ],
      for (final w in workouts)
        [
          w.localDate,
          types[w.workoutTypeId] ?? w.workoutTypeId,
          w.startedAt.toUtc().toIso8601String(),
          w.endedAt.toUtc().toIso8601String(),
          w.durationMinutes,
          w.intensity?.name ?? '',
          w.note ?? '',
        ],
    ]),
  );
}

/// Hands an export to the person (the phone's share sheet).
abstract class ExportSink {
  Future<void> deliver(DataExport export);
}

class ShareSheetExportSink implements ExportSink {
  @override
  Future<void> deliver(DataExport export) async {
    final dir = await Directory.systemTemp.createTemp('wellbeing-export');
    final file = File('${dir.path}/${export.fileName}');
    await file.writeAsString(export.content);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: export.mimeType)],
        subject: export.fileName,
      ),
    );
  }
}

class FakeExportSink implements ExportSink {
  final delivered = <DataExport>[];
  bool fail = false;

  @override
  Future<void> deliver(DataExport export) async {
    if (fail) throw const FileSystemException('cannot write');
    delivered.add(export);
  }
}

final exportSinkProvider = Provider<ExportSink>((_) => ShareSheetExportSink());
