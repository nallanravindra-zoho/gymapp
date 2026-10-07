import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/section_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/avatar_button.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../habits/breaks_card.dart';
import '../streaks/streak_card.dart';
import '../workouts/log_workout_sheet.dart';
import '../workouts/timer_screen.dart';
import '../workouts/workout_icons.dart';
import '../workouts/workout_providers.dart';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', //
];

String formatHeaderDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider).now().toLocal();
    final timer = ref.watch(activeTimerProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: const [AvatarButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 4),
            child: Text(
              formatHeaderDate(now),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const StreakCard(),
          const SizedBox(height: 12),
          if (timer != null) ...[
            _ResumeTimerCard(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const TimerScreen()),
              ),
            ),
            const SizedBox(height: 12),
          ],
          const _WorkoutCard(),
          const SizedBox(height: 12),
          const BreaksCard(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, kMinTapTarget),
                  ),
                  onPressed: () => showLogWorkoutSheet(context),
                  icon: const Icon(Icons.timer_outlined),
                  label: const Text('Start timer'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, kMinTapTarget),
                  ),
                  onPressed: () =>
                      showLogWorkoutSheet(context, startManual: true),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Add manual entry'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResumeTimerCard extends StatelessWidget {
  const _ResumeTimerCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Card(
      color: t.accent.withValues(alpha: 0.12),
      child: ListTile(
        minTileHeight: kMinTapTarget,
        leading: Icon(Icons.timer_outlined, color: t.accent),
        title: const Text('Timer running'),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _WorkoutCard extends ConsumerWidget {
  const _WorkoutCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(todayWorkoutsProvider).value ?? const [];
    final types = {
      for (final t
          in ref.watch(workoutTypesProvider).value ?? const <WorkoutType>[])
        t.id: t,
    };
    final tokens = context.tokens;

    return SectionTheme(
      section: AppSection.workout,
      child: Builder(
        builder: (context) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Workout', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (workouts.isEmpty)
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, kMinTapTarget),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: () => showLogWorkoutSheet(context),
                    child: const Text('Log workout'),
                  )
                else
                  for (final w in workouts)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      minTileHeight: kMinTapTarget,
                      leading: Icon(
                        workoutIcon(types[w.workoutTypeId]?.iconKey ?? 'other'),
                        color: tokens.accent,
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
      ),
    );
  }
}
