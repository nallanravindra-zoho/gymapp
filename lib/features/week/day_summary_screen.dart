import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/rest_day_repository.dart';
import '../habits/habit_providers.dart';
import '../screen_time/screen_time_providers.dart';
import '../hobbies/hobby_providers.dart';
import '../today/summary_rows.dart';
import '../workouts/log_workout_screen.dart';
import '../workouts/workout_detail_screen.dart';
import '../workouts/workout_providers.dart';
import '../workouts/workout_row.dart';
import 'day_format.dart';
import 'week_marks.dart';
import 'week_providers.dart';

/// One day in the same style as Today's summary: a friendly line about the
/// day, four tiles (workout, healthy habits, sleep, screen time), then the
/// day's workouts with the actions to add one or mark a rest day.
class DaySummaryScreen extends ConsumerWidget {
  const DaySummaryScreen({super.key, required this.localDate});

  final String localDate;

  Future<void> _toggleRest(
    BuildContext context,
    WidgetRef ref,
    bool isRest,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final user = await ref.read(currentUserProvider.future);
    final repo = ref.read(restDayRepositoryProvider);
    String message;
    if (isRest) {
      await repo.unmark(user.id, localDate);
      message = 'Rest day removed.';
    } else {
      final result = await repo.mark(
        userId: user.id,
        localDate: localDate,
        weeklyLimit: user.weeklyRestDays,
      );
      message = switch (result) {
        RestDayResult.recorded => 'Rest day recorded.',
        RestDayResult.alreadyRecorded => 'Rest day recorded.',
        RestDayResult.limitReached =>
          'Rest day limit reached for this week (${user.weeklyRestDays}).',
      };
    }
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final workouts = ref.watch(workoutsOnProvider(localDate)).value ?? const [];
    final types = {
      for (final t
          in (ref.watch(allWorkoutTypesProvider).value ??
              const <WorkoutType>[]))
        t.id: t,
    };
    final isRest =
        ref.watch(weekRestDaysProvider).value?.contains(localDate) ?? false;
    final habits = ref.watch(activeHabitsProvider).value ?? const <Habit>[];
    final counts =
        ref.watch(habitCountsOnProvider(localDate)).value ?? const {};
    final sleep = ref.watch(sleepOnProvider(localDate)).value;
    final screen = ref.watch(screenOnProvider(localDate)).value;

    final marks = buildDayMarks(
      date: localDate,
      workouts: workouts,
      isRest: isRest,
      habits: habits,
      habitCounts: counts,
      habitThreshold: ref.watch(habitThresholdProvider),
      hobbyGoalMet: ref.watch(hobbyGoalMetOnDateProvider(localDate)),
      sleepLog: sleep,
      sleepTargetMinutes: ref.watch(sleepTargetMinutesProvider),
      screenRow: screen,
      screenGoalMinutes: ref.watch(screenTimeGoalProvider).value,
    );
    final (title, line) = switch (marks.count) {
      >= 3 => (
        'A balanced day',
        'You moved, looked after yourself and made time to rest.',
      ),
      >= 1 => ('A good day', 'Here is what you logged.'),
      _ =>
        isRest
            ? ('A rest day', 'Rest is part of the plan.')
            : ('A quiet day', 'Nothing logged for this day.'),
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Summary'),
            Text(
              formatDayTitle(localDate),
              style: text.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        toolbarHeight: 64,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
            decoration: BoxDecoration(
              color: t.mint,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const SproutIcon(size: 46),
                const SizedBox(height: 10),
                Text(title, style: text.titleMedium),
                const SizedBox(height: 6),
                Text(
                  line,
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(color: t.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          DaySummaryCard(date: localDate, isToday: false),
          const SizedBox(height: 14),
          HabitCountsSection(date: localDate, isToday: false),
          const SizedBox(height: 22),
          Text('Workouts', style: text.titleMedium),
          const SizedBox(height: 10),
          if (workouts.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'No workouts logged this day.',
                style: text.bodyMedium?.copyWith(color: t.textMuted),
              ),
            ),
          for (final w in workouts) ...[
            WorkoutRow(
              workout: w,
              type: types[w.workoutTypeId],
              showDate: false,
              onTap: () => openWorkoutDetail(context, w.id),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () => openLogWorkout(context, forDate: localDate),
            child: const Text('Add workout'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => _toggleRest(context, ref, isRest),
            child: Text(isRest ? 'Remove rest day' : 'Mark rest day'),
          ),
        ],
      ),
    );
  }
}
