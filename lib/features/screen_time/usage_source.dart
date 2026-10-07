import 'package:flutter/services.dart';

import '../../core/time/local_date.dart';

/// One day of phone use: totals only, never per-app detail (spec 8.1).
class DayUsage {
  const DayUsage({
    required this.totalMinutes,
    this.categories = const {},
    this.hours = const [],
  });

  final int totalMinutes;

  /// Category key -> minutes. Keys: social, video, browser, productivity,
  /// games, other.
  final Map<String, int> categories;

  /// Minutes in each local hour of the day (24 values), when known.
  final List<int> hours;

  /// Use from 21:00 to the end of the day, for the sleep insight.
  int get lateEveningMinutes => hours.length < 24
      ? 0
      : hours.sublist(lateEveningStartHour).fold(0, (a, b) => a + b);

  static const lateEveningStartHour = 21;

  factory DayUsage.fromMap(Map<Object?, Object?> m) => DayUsage(
    totalMinutes: (m['totalMinutes'] as num?)?.toInt() ?? 0,
    categories: {
      for (final e in (m['categories'] as Map? ?? const {}).entries)
        e.key as String: (e.value as num).toInt(),
    },
    hours: [
      for (final h in (m['hours'] as List? ?? const [])) (h as num).toInt(),
    ],
  );
}

/// Where usage data comes from. Android reads it from the system; tests and
/// unsupported platforms use the stand-ins below.
abstract class UsageSource {
  /// Whether the user has granted Usage access.
  Future<bool> hasAccess();

  /// Opens the system Usage access settings page.
  Future<void> openSettings();

  /// Foreground time between [start] and [end].
  Future<DayUsage> readDay(DateTime start, DateTime end);
}

class AndroidUsageSource implements UsageSource {
  AndroidUsageSource([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('wellbeing/usage');

  final MethodChannel _channel;

  @override
  Future<bool> hasAccess() async {
    try {
      return await _channel.invokeMethod<bool>('hasAccess') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> openSettings() => _channel.invokeMethod<void>('openSettings');

  @override
  Future<DayUsage> readDay(DateTime start, DateTime end) async {
    final raw = await _channel.invokeMapMethod<Object?, Object?>('queryDay', {
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
    });
    return DayUsage.fromMap(raw ?? const {});
  }
}

/// No usage data (platforms other than Android, and the default in tests).
class NoopUsageSource implements UsageSource {
  @override
  Future<bool> hasAccess() async => false;
  @override
  Future<void> openSettings() async {}
  @override
  Future<DayUsage> readDay(DateTime start, DateTime end) async =>
      const DayUsage(totalMinutes: 0);
}

/// Scripted usage for tests.
class FakeUsageSource implements UsageSource {
  FakeUsageSource({this.access = true, Map<String, DayUsage>? byDate})
    : byDate = byDate ?? {};

  bool access;

  /// Local date (`YYYY-MM-DD`, from the window's start) -> usage.
  final Map<String, DayUsage> byDate;

  int openSettingsCalls = 0;
  final List<String> reads = [];

  @override
  Future<bool> hasAccess() async => access;

  @override
  Future<void> openSettings() async => openSettingsCalls++;

  @override
  Future<DayUsage> readDay(DateTime start, DateTime end) async {
    final date = formatLocalDate(start.year, start.month, start.day);
    reads.add(date);
    return byDate[date] ?? const DayUsage(totalMinutes: 0);
  }
}
