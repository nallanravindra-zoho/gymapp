import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/time/local_date.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/rest_day_repository.dart';
import '../workouts/log_workout_sheet.dart';
import '../workouts/workout_icons.dart';
import '../workouts/workout_providers.dart';
import 'week_providers.dart';

const weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday', //
];
const monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', //
];

String formatDayTitle(String localDate) {
  final d = parseLocalDate(localDate);
  return '${weekdayNames[d.weekday - 1]}, ${d.day} ${monthNames[d.month - 1]}';
}

Future<void> showDaySheet(BuildContext context, String localDate) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => DaySheet(localDate: localDate),
  );
}

/// View and edit one day: its workouts, plus rest day marking.
class DaySheet extends ConsumerWidget {
  const DaySheet({super.key, required this.localDate});

  final String localDate;

  Future<void> _toggleRest(
    BuildContext context,
    WidgetRef ref,
    bool isRest,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
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
    navigator.pop();
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(formatDayTitle(localDate), style: text.titleLarge),
          if (isRest)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Rest day', style: text.bodySmall),
            ),
          const SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (workouts.isEmpty)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('No workouts logged this day.'),
                      ),
                    ),
                  for (final w in workouts)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      minTileHeight: kMinTapTarget,
                      leading: Icon(
                        workoutIcon(types[w.workoutTypeId]?.iconKey ?? 'other'),
                      ),
                      title: Text(types[w.workoutTypeId]?.name ?? 'Workout'),
                      subtitle: Text('${w.durationMinutes} min'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => showLogWorkoutSheet(context, existing: w),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, kMinTapTarget),
                  ),
                  onPressed: () => _toggleRest(context, ref, isRest),
                  child: Text(isRest ? 'Remove rest day' : 'Mark rest day'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, kMinTapTarget),
                  ),
                  onPressed: () =>
                      showLogWorkoutSheet(context, forDate: localDate),
                  child: const Text('Add workout'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
