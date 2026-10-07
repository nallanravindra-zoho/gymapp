import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../streaks/streak_engine.dart';
import '../week/week_providers.dart';

final activeHabitsProvider = StreamProvider<List<Habit>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  yield* ref.watch(habitRepositoryProvider).watchActive(user.id);
});

/// Completions today per habit id.
final todayHabitCountsProvider = StreamProvider<Map<String, int>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  final today = await ref.watch(todayDateProvider.future);
  yield* ref.watch(habitRepositoryProvider).watchCountsForDate(user.id, today);
});

final allHabitLogsProvider = StreamProvider<List<HabitLog>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  yield* ref.watch(habitRepositoryProvider).watchAllLogs(user.id);
});

/// Completions per local date for one habit, from all logs.
Map<String, int> dailyTotals(List<HabitLog> logs, String habitId) {
  final totals = <String, int>{};
  for (final l in logs) {
    if (l.habitId != habitId) continue;
    totals[l.localDate] = (totals[l.localDate] ?? 0) + l.count;
  }
  return totals;
}

/// Habit streak: consecutive days the daily target was met (spec 7.2). No
/// rest days and no freeze apply.
StreakResult habitStreak({
  required Habit habit,
  required List<HabitLog> logs,
  required String today,
}) {
  final totals = dailyTotals(logs, habit.id);
  final met = {
    for (final e in totals.entries)
      if (e.value >= habit.dailyTarget) e.key,
  };
  return computeStreak(counted: met, today: today);
}

final habitStreaksProvider = Provider<Map<String, StreakResult>>((ref) {
  final habits = ref.watch(activeHabitsProvider).value;
  final logs = ref.watch(allHabitLogsProvider).value;
  final today = ref.watch(todayDateProvider).value;
  if (habits == null || logs == null || today == null) return const {};
  return {
    for (final h in habits)
      h.id: habitStreak(habit: h, logs: logs, today: today),
  };
});
