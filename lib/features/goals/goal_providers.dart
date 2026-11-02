import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../habits/habit_providers.dart';
import '../hobbies/hobby_providers.dart';
import '../screen_time/screen_time_providers.dart';
import '../week/week_marks.dart';
import 'goal_logic.dart';

const _workoutTargetKey = 'workout_weekly_target';

/// Workout sessions per week the person aims for; null means no goal. Kept
/// on this phone, like the screen-time limit.
class WorkoutGoalNotifier extends AsyncNotifier<int?> {
  @override
  Future<int?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_workoutTargetKey);
  }

  Future<void> set(int? sessions) async {
    final prefs = await SharedPreferences.getInstance();
    if (sessions == null) {
      await prefs.remove(_workoutTargetKey);
    } else {
      await prefs.setInt(_workoutTargetKey, sessions);
    }
    state = AsyncData(sessions);
  }
}

final workoutGoalProvider = AsyncNotifierProvider<WorkoutGoalNotifier, int?>(
  WorkoutGoalNotifier.new,
);

const _nutritionTargetKey = 'nutrition_daily_servings';

/// Servings of food a day the person aims for; null means no goal. Kept on
/// this phone, like the workout and screen-time goals.
class NutritionGoalNotifier extends AsyncNotifier<int?> {
  @override
  Future<int?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_nutritionTargetKey);
  }

  Future<void> set(int? servings) async {
    final prefs = await SharedPreferences.getInstance();
    if (servings == null) {
      await prefs.remove(_nutritionTargetKey);
    } else {
      await prefs.setInt(_nutritionTargetKey, servings);
    }
    state = AsyncData(servings);
  }
}

final nutritionGoalProvider =
    AsyncNotifierProvider<NutritionGoalNotifier, int?>(
      NutritionGoalNotifier.new,
    );

/// An inclusive span of local dates, `yyyy-MM-dd`.
typedef DateRange = (String from, String to);

final _rangeWorkoutsProvider = StreamProvider.family<List<Workout>, DateRange>((
  ref,
  r,
) async* {
  final user = await ref.watch(currentUserProvider.future);
  yield* ref.watch(workoutRepositoryProvider).watchBetween(user.id, r.$1, r.$2);
});

final _rangeMealsProvider = StreamProvider.family<List<MealLog>, DateRange>((
  ref,
  r,
) async* {
  final user = await ref.watch(currentUserProvider.future);
  yield* ref.watch(mealRepositoryProvider).watchBetween(user.id, r.$1, r.$2);
});

final _rangeSleepProvider = StreamProvider.family<List<SleepLog>, DateRange>((
  ref,
  r,
) async* {
  final user = await ref.watch(currentUserProvider.future);
  yield* ref.watch(sleepRepositoryProvider).watchBetween(user.id, r.$1, r.$2);
});

final _rangeScreenProvider =
    StreamProvider.family<List<ScreenTimeDailyData>, DateRange>((
      ref,
      r,
    ) async* {
      final user = await ref.watch(currentUserProvider.future);
      yield* ref
          .watch(screenTimeRepositoryProvider)
          .watchBetween(user.id, r.$1, r.$2);
    });

/// Everything goal progress needs for [range].
final goalInputsProvider = Provider.family<GoalInputs, DateRange>((ref, range) {
  return GoalInputs(
    workoutWeeklyTarget: ref.watch(workoutGoalProvider).value,
    workouts: ref.watch(_rangeWorkoutsProvider(range)).value ?? const [],
    habits: ref.watch(activeHabitsProvider).value ?? const [],
    habitLogs: ref.watch(allHabitLogsProvider).value ?? const [],
    habitThreshold: ref.watch(habitThresholdProvider),
    hobbyGoals: ref.watch(hobbyGoalsProvider),
    hobbyActivities: ref.watch(hobbyActivitiesProvider),
    sleepLogs: ref.watch(_rangeSleepProvider(range)).value ?? const [],
    sleepTargetMinutes: ref.watch(sleepTargetMinutesProvider),
    screenRows: ref.watch(_rangeScreenProvider(range)).value ?? const [],
    screenGoalMinutes: ref.watch(screenTimeGoalProvider).value,
    nutritionDailyServings: ref.watch(nutritionGoalProvider).value,
    meals: ref.watch(_rangeMealsProvider(range)).value ?? const [],
  );
});

/// Goal progress for one period.
class GoalSummary {
  const GoalSummary({
    required this.period,
    required this.dates,
    required this.categories,
  });

  final GoalPeriod period;
  final List<String> dates;
  final List<CategoryGoal> categories;

  /// Rounded share of goals met; null when no goal is set.
  int? get percent => overallPercent(categories);
}

/// Progress for the [period] containing [anchor] (a local date).
final goalSummaryProvider = Provider.family<GoalSummary, (GoalPeriod, String)>((
  ref,
  key,
) {
  final dates = periodDates(key.$1, key.$2);
  final inputs = ref.watch(goalInputsProvider((dates.first, dates.last)));
  return GoalSummary(
    period: key.$1,
    dates: dates,
    categories: categoryGoals(period: key.$1, dates: dates, inputs: inputs),
  );
});

/// Each day of the week containing [anchor], with its share of daily goals
/// met (null when no daily goal is set).
final weekBreakdownProvider = Provider.family<Map<String, double?>, String>((
  ref,
  anchor,
) {
  final dates = periodDates(GoalPeriod.week, anchor);
  final inputs = ref.watch(goalInputsProvider((dates.first, dates.last)));
  return {
    for (final d in dates)
      d: () {
        final goals = categoryGoals(
          period: GoalPeriod.day,
          dates: [d],
          inputs: inputs,
        );
        if (goals.isEmpty) return null;
        return goals.map((g) => g.fraction).reduce((a, b) => a + b) /
            goals.length;
      }(),
  };
});
