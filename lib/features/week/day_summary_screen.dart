import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/durations.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/rest_day_repository.dart';
import '../habits/habit_providers.dart';
import '../screen_time/screen_time_providers.dart';
import '../workouts/log_workout_screen.dart';
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
    final workouts =
        (ref.watch(weekWorkoutsProvider).value ?? const <Workout>[])
            .where((w) => w.localDate == localDate)
            .toList()
          ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    final types = {
      for (final t
          in (ref.watch(workoutTypesProvider).value ?? const <WorkoutType>[]))
        t.id: t,
    };
    final isRest =
        ref.watch(weekRestDaysProvider).value?.contains(localDate) ?? false;
    final habits = ref.watch(activeHabitsProvider).value ?? const <Habit>[];
    final counts =
        ref.watch(habitCountsOnProvider(localDate)).value ?? const {};
    final sleep = ref.watch(sleepOnProvider(localDate)).value;
    final sleepTarget = ref.watch(sleepTargetMinutesProvider);
    final screen = ref.watch(screenOnProvider(localDate)).value;
    final goal = ref.watch(screenTimeGoalProvider).value;

    final metHabits = habits
        .where((h) => (counts[h.id] ?? 0) >= h.dailyTarget)
        .length;
    final marks = DayMarks(
      workouts: workouts,
      habits: metHabits > 0,
      sleep: sleep != null && sleep.durationMinutes >= sleepTarget,
      screen: screen != null && goal != null && screen.totalMinutes <= goal,
      rest: isRest,
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

    final totalMinutes = workouts.fold<int>(0, (a, w) => a + w.durationMinutes);
    final names = {
      for (final w in workouts) types[w.workoutTypeId]?.name ?? 'Workout',
    }.join(', ');

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Tile(
                  icon: Icons.self_improvement_rounded,
                  cat: Cat.workout,
                  label: 'Workout',
                  value: workouts.isEmpty ? '–' : durationShort(totalMinutes),
                  detail: workouts.isEmpty ? 'None logged' : names,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Tile(
                  icon: Icons.water_drop_rounded,
                  cat: Cat.water,
                  label: 'Healthy Habits',
                  value: habits.isEmpty ? '–' : '$metHabits/${habits.length}',
                  detail: habits.isEmpty ? 'None set up' : 'habits met',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Tile(
                  icon: Icons.nightlight_round,
                  cat: Cat.sleep,
                  label: 'Sleep',
                  value: sleep == null
                      ? '–'
                      : durationShort(sleep.durationMinutes),
                  detail: sleep == null
                      ? 'Not logged'
                      : 'target ${durationShort(sleepTarget)}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Tile(
                  icon: Icons.smartphone_rounded,
                  cat: Cat.screen,
                  label: 'Screen time',
                  value: screen == null
                      ? '–'
                      : durationShort(screen.totalMinutes),
                  detail: screen == null
                      ? 'Not tracked'
                      : goal == null
                      ? 'no goal set'
                      : 'goal ${durationShort(goal)}',
                ),
              ),
            ],
          ),
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
              onTap: () => openLogWorkout(context, existing: w),
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

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.cat,
    required this.label,
    required this.value,
    required this.detail,
  });

  final IconData icon;
  final Cat cat;
  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TintedIcon(icon: icon, cat: cat, size: 42),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: text.bodySmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  detail,
                  style: text.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
