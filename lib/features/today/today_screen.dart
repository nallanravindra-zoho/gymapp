import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/avatar_button.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../habits/habit_manage_screen.dart';
import '../habits/habits_screen.dart';
import '../hobbies/hobbies_screen.dart';
import '../metrics/measurements_banner.dart';
import '../screen_time/screen_time_screen.dart';
import '../sleep/sleep_screen.dart';
import '../streaks/streak_providers.dart' show userStreamProvider;
import '../streaks/today_streaks.dart';
import '../week/week_providers.dart';
import '../workouts/log_workout_screen.dart';
import '../workouts/timer_screen.dart';
import '../workouts/workout_detail_screen.dart';
import '../workouts/workout_manage_screen.dart';
import '../workouts/workout_providers.dart';
import '../workouts/workout_row.dart';
import 'summary_rows.dart';
import 'today_text.dart';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', //
];

String formatHeaderDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

/// The home screen (R1): a greeting for the time of day, a short tagline,
/// streaks first, then quick log and a summary of today.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clock = ref.watch(clockProvider);
    final instant = clock.now();
    final local = instant.add(Duration(minutes: clock.offsetAt(instant)));
    final name = ref.watch(userStreamProvider).value?.displayName.trim() ?? '';
    final today = ref.watch(todayDateProvider).value;
    final timer = ref.watch(activeTimerProvider).value;
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    final topInset = MediaQuery.paddingOf(context).top;

    final greeting = greetingForHour(local.hour);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          HillsHeader(
            height: 226 + topInset,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, topInset + 18, 8, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isEmpty ? greeting : '$greeting, $name',
                              style: text.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              today == null ? '' : taglineFor(today),
                              style: text.bodyMedium?.copyWith(
                                color: t.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const AvatarButton(size: 48),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: Text(
                      formatHeaderDate(local),
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TodayStreaks(),
                const SizedBox(height: 14),
                const MeasurementsBanner(),
                if (timer != null) ...[
                  _ResumeTimerCard(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const TimerScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                const _QuickAccess(),
                const SizedBox(height: 14),
                if (today != null) DaySummaryCard(date: today, isToday: true),
                const SizedBox(height: 14),
                const _WorkoutSection(),
                const SizedBox(height: 14),
                if (today != null)
                  HabitCountsSection(
                    date: today,
                    isToday: true,
                    trailing: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(64, 48),
                      ),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const HabitManageScreen(),
                        ),
                      ),
                      child: const Text('Manage'),
                    ),
                  ),
              ],
            ),
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
    return SoftCard(
      onTap: onTap,
      color: t.mint,
      borderColor: t.accent.withValues(alpha: 0.25),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, color: t.accentDeep),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Timer running',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: t.textMuted),
        ],
      ),
    );
  }
}

class _QuickAccess extends StatelessWidget {
  const _QuickAccess();

  @override
  Widget build(BuildContext context) {
    void open(Widget screen) =>
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => screen));

    return SoftCard(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _QuickButton(
            label: 'Workout',
            icon: Icons.self_improvement_rounded,
            cat: Cat.workout,
            onTap: () => openLogWorkout(context),
          ),
          _QuickButton(
            label: 'Healthy Habits',
            icon: Icons.spa_rounded,
            cat: Cat.habit,
            onTap: () => open(const HabitsScreen()),
          ),
          _QuickButton(
            label: 'Hobbies',
            icon: Icons.interests_rounded,
            cat: Cat.hobby,
            onTap: () => open(const HobbiesScreen()),
          ),
          _QuickButton(
            label: 'Sleep',
            icon: Icons.nightlight_round,
            cat: Cat.sleep,
            onTap: () => open(const SleepScreen()),
          ),
          _QuickButton(
            label: 'Screen Time',
            icon: Icons.smartphone_rounded,
            cat: Cat.screen,
            onTap: () => open(const ScreenTimeScreen()),
          ),
        ],
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({
    required this.label,
    required this.icon,
    required this.cat,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Cat cat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      key: ValueKey('quick-$label'),
      child: Semantics(
        button: true,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ExcludeSemantics(
              child: Column(
                children: [
                  TintedIcon(icon: icon, cat: cat, size: 50),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: context.tokens.text,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A section title with a Manage link at the top right.
class _ManageHeader extends StatelessWidget {
  const _ManageHeader({required this.title, required this.onManage});

  final String title;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
            onPressed: onManage,
            child: const Text('Manage'),
          ),
        ],
      ),
    );
  }
}

/// Today's saved workouts (tap to open the detail view) and the action to add
/// another.
class _WorkoutSection extends ConsumerWidget {
  const _WorkoutSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(todayWorkoutsProvider).value ?? const [];
    final types = {
      for (final t
          in ref.watch(allWorkoutTypesProvider).value ?? const <WorkoutType>[])
        t.id: t,
    };
    final text = Theme.of(context).textTheme;
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ManageHeader(
            title: 'Workout',
            onManage: () => openWorkoutManage(context),
          ),
          if (workouts.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'No workouts saved today.',
                style: text.bodyMedium?.copyWith(
                  color: context.tokens.textMuted,
                ),
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
          OutlinedButton.icon(
            onPressed: () => openLogWorkout(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add new workout'),
          ),
        ],
      ),
    );
  }
}
