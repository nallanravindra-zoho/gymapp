import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/time/local_date.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../habits/habit_providers.dart';
import '../sleep/sleep_providers.dart';
import '../streaks/streak_providers.dart';
import '../week/week_providers.dart';
import 'insight_builder.dart';
import 'insight_rules.dart';
import 'tips.dart';

enum InsightWeek { last, current }

class InsightWeekNotifier extends Notifier<InsightWeek> {
  @override
  InsightWeek build() => InsightWeek.last;

  void set(InsightWeek w) => state = w;
}

final insightWeekProvider = NotifierProvider<InsightWeekNotifier, InsightWeek>(
  InsightWeekNotifier.new,
);

final tipsLibraryProvider = StreamProvider<List<TipsLibraryData>>(
  (ref) => ref
      .watch(databaseProvider)
      .select(ref.watch(databaseProvider).tipsLibrary)
      .watch(),
);

/// Four weeks of sleep and screen time, enough for a week and the one before.
final sleepMonthProvider = StreamProvider<List<SleepLog>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  final today = await ref.watch(todayDateProvider.future);
  yield* ref
      .watch(sleepRepositoryProvider)
      .watchBetween(
        user.id,
        shiftLocalDate(today, -34),
        shiftLocalDate(today, 1),
      );
});

final screenTimeMonthProvider = StreamProvider<List<ScreenTimeDailyData>>((
  ref,
) async* {
  final user = await ref.watch(currentUserProvider.future);
  final today = await ref.watch(todayDateProvider.future);
  yield* ref
      .watch(screenTimeRepositoryProvider)
      .watchBetween(user.id, shiftLocalDate(today, -34), today);
});

class InsightsView {
  const InsightsView({
    required this.weekStart,
    required this.complete,
    required this.recap,
    required this.insights,
    required this.tips,
  });

  final String weekStart;
  final bool complete;
  final WeekRecap recap;
  final List<Insight> insights;
  final List<WeeklyTip> tips;
}

/// The Insights screen's content, recomputed whenever the underlying records
/// change. Null until everything has loaded.
final insightsViewProvider = Provider<InsightsView?>((ref) {
  final today = ref.watch(todayDateProvider).value;
  final workouts = ref.watch(allWorkoutsProvider).value;
  final rest = ref.watch(allRestDaysProvider).value;
  final habits = ref.watch(activeHabitsProvider).value;
  final habitLogs = ref.watch(allHabitLogsProvider).value;
  final sleepLogs = ref.watch(sleepMonthProvider).value;
  final screen = ref.watch(screenTimeMonthProvider).value;
  final library = ref.watch(tipsLibraryProvider).value;
  if (today == null ||
      workouts == null ||
      rest == null ||
      habits == null ||
      habitLogs == null ||
      sleepLogs == null ||
      screen == null ||
      library == null) {
    return null;
  }

  final mode = ref.watch(insightWeekProvider);
  final thisWeek = weekStartOf(today);
  final weekStart = mode == InsightWeek.current
      ? thisWeek
      : shiftLocalDate(thisWeek, -7);

  final target = ref.watch(effectiveSleepTargetProvider);
  final input = buildInsightInput(
    weekStart: weekStart,
    today: today,
    workouts: workouts,
    restDates: rest,
    habits: habits,
    habitLogs: habitLogs,
    sleepLogs: sleepLogs,
    targetBedtimeMinutes: target.bedtimeMinutes,
    targetWakeMinutes: target.wakeMinutes,
    screenTime: screen,
  );
  final insights = computeInsights(input);

  return InsightsView(
    weekStart: weekStart,
    complete: input.complete,
    recap: computeRecap(
      weekStart: weekStart,
      workouts: workouts,
      longestStreak: ref.watch(streakSnapshotProvider)?.overall.longest ?? 0,
    ),
    insights: insights,
    tips: selectTips(
      insights: insights,
      library: library,
      weekStart: weekStart,
    ),
  );
});
