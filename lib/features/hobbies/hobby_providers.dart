/// Hobby state for the UI and for other features (streaks, badges, Week).
///
/// Public API other features can rely on:
///
/// * [hobbyStreakProvider]: the aggregated Hobbies streak ([HobbyStreakInfo]:
///   `current`, `longest`, `unit` day or week, `label` such as
///   "4-week goal streak"). Counted in goal-periods, never in "days" for
///   weekly goals.
/// * [hobbyStreaksByHobbyProvider]: the same per hobby id.
/// * [hobbyGoalMetOnDateProvider]: for a local date `YYYY-MM-DD`, whether any
///   active hobby's DAILY goal is met that day (use for a Week day icon).
/// * [weeklyHobbyGoalsMetProvider]: for a week start (Monday `YYYY-MM-DD`),
///   the ids of active hobbies whose WEEKLY goal is met that week (show in
///   the weekly summary, not on single days).
/// * [hobbyLogsOnDateProvider]: the logs on a date (for a day summary).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../week/week_providers.dart';
import 'hobby_logic.dart';

/// Active hobbies, oldest first. Adds the built-in hobbies on first read.
final activeHobbiesProvider = StreamProvider<List<Hobby>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  final repo = ref.watch(hobbyRepositoryProvider);
  await repo.ensureDefaults(user.id);
  yield* repo.watchActive(user.id);
});

final archivedHobbiesProvider = StreamProvider<List<Hobby>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  yield* ref.watch(hobbyRepositoryProvider).watchArchived(user.id);
});

final allHobbyLogsProvider = StreamProvider<List<HobbyLog>>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  yield* ref.watch(hobbyRepositoryProvider).watchAllLogs(user.id);
});

/// Logs reduced to what goals read.
final hobbyActivitiesProvider = Provider<List<HobbyActivity>>((ref) {
  final logs = ref.watch(allHobbyLogsProvider).value ?? const <HobbyLog>[];
  return [for (final l in logs) HobbyActivity.fromLog(l)];
});

/// Goals of active hobbies that have one, by hobby id.
final hobbyGoalsProvider = Provider<Map<String, HobbyGoal>>((ref) {
  final hobbies = ref.watch(activeHobbiesProvider).value ?? const <Hobby>[];
  return {
    for (final h in hobbies)
      if (HobbyGoal.of(h) != null) h.id: HobbyGoal.of(h)!,
  };
});

/// The aggregated Hobbies streak. See `hobby_logic.dart` for the definition.
final hobbyStreakProvider = Provider<HobbyStreakInfo>((ref) {
  final today = ref.watch(todayDateProvider).value;
  if (today == null) return HobbyStreakInfo.none;
  return aggregateHobbyStreak(
    goals: ref.watch(hobbyGoalsProvider),
    activities: ref.watch(hobbyActivitiesProvider),
    today: today,
  );
});

/// Each goal hobby's own streak, by hobby id.
final hobbyStreaksByHobbyProvider = Provider<Map<String, HobbyStreakInfo>>((
  ref,
) {
  final today = ref.watch(todayDateProvider).value;
  if (today == null) return const {};
  final acts = ref.watch(hobbyActivitiesProvider);
  return {
    for (final e in ref.watch(hobbyGoalsProvider).entries)
      e.key: hobbyGoalStreak(
        goal: e.value,
        activities: acts,
        hobbyId: e.key,
        today: today,
      ),
  };
});

/// Whether any active hobby's daily goal is met on [date].
final hobbyGoalMetOnDateProvider = Provider.family<bool, String>((ref, date) {
  final met = dailyGoalsMetOn(
    goals: ref.watch(hobbyGoalsProvider),
    activities: ref.watch(hobbyActivitiesProvider),
    date: date,
  );
  return met.isNotEmpty;
});

/// Ids of active hobbies whose weekly goal is met in the week starting
/// [weekStart] (a Monday).
final weeklyHobbyGoalsMetProvider = Provider.family<Set<String>, String>((
  ref,
  weekStart,
) {
  return weeklyGoalsMetIn(
    goals: ref.watch(hobbyGoalsProvider),
    activities: ref.watch(hobbyActivitiesProvider),
    weekStart: weekStart,
  );
});

/// Live logs on one local date.
final hobbyLogsOnDateProvider = StreamProvider.family<List<HobbyLog>, String>((
  ref,
  date,
) async* {
  final user = await ref.watch(currentUserProvider.future);
  yield* ref.watch(hobbyRepositoryProvider).watchLogsForDate(user.id, date);
});
