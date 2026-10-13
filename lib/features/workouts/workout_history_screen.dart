import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../data/app_database.dart';
import '../streaks/streak_providers.dart';
import 'workout_detail_screen.dart';
import 'workout_providers.dart';
import 'workout_row.dart';

/// Every saved workout, newest first ("View all" on Week).
class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(allWorkoutsProvider).value ?? const <Workout>[];
    final types = {
      for (final t
          in ref.watch(allWorkoutTypesProvider).value ?? const <WorkoutType>[])
        t.id: t,
    };
    final sorted = [...all]..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: sorted.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No workouts logged yet.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: context.tokens.textMuted),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(
                16,
                4,
                16,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              itemCount: sorted.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => WorkoutRow(
                workout: sorted[i],
                type: types[sorted[i].workoutTypeId],
                onTap: () => openWorkoutDetail(context, sorted[i].id),
              ),
            ),
    );
  }
}
