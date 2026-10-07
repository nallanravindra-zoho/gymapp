import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/time/local_date.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../week/week_providers.dart';
import 'sleep_logic.dart';

final sleepTargetProvider = StreamProvider<SleepTarget?>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  yield* ref.watch(sleepRepositoryProvider).watchTarget(user.id);
});

/// Targets in effect: the saved ones, or the defaults until set.
final effectiveSleepTargetProvider =
    Provider<({int bedtimeMinutes, int wakeMinutes, bool isSet})>((ref) {
      final t = ref.watch(sleepTargetProvider).value;
      return (
        bedtimeMinutes: t?.bedtimeMinutes ?? defaultBedtimeMinutes,
        wakeMinutes: t?.wakeMinutes ?? defaultWakeMinutes,
        isSet: t != null,
      );
    });

/// Sleep logs for the 7 days ending today (by wake date).
final recentSleepLogsProvider = StreamProvider<List<SleepLog>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  final today = await ref.watch(todayDateProvider.future);
  yield* ref
      .watch(sleepRepositoryProvider)
      .watchBetween(user.id, shiftLocalDate(today, -6), today);
});

/// The log for today's wake date, if any ("last night").
final lastNightProvider = Provider<SleepLog?>((ref) {
  final today = ref.watch(todayDateProvider).value;
  final logs = ref.watch(recentSleepLogsProvider).value;
  if (today == null || logs == null) return null;
  return logs.where((l) => l.localDate == today).firstOrNull;
});

final sleepConsistencyProvider = Provider<SleepConsistency?>((ref) {
  final today = ref.watch(todayDateProvider).value;
  final logs = ref.watch(recentSleepLogsProvider).value;
  if (today == null || logs == null) return null;
  final t = ref.watch(effectiveSleepTargetProvider);
  return sleepConsistency(
    logs: logs,
    targetBedtimeMinutes: t.bedtimeMinutes,
    targetWakeMinutes: t.wakeMinutes,
    today: today,
  );
});
