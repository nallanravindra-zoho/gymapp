import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/durations.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/avatar_button.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../habits/habit_actions.dart';
import '../habits/habit_defaults.dart';
import '../habits/habit_providers.dart';
import '../habits/habit_setup_screen.dart';
import '../habits/habits_screen.dart';
import '../screen_time/screen_time_providers.dart';
import '../screen_time/screen_time_screen.dart';
import '../sleep/sleep_providers.dart';
import '../hobbies/hobbies_screen.dart';
import '../sleep/sleep_screen.dart';
import '../streaks/streak_card.dart';
import '../streaks/streak_providers.dart';
import '../week/week_providers.dart';
import '../workouts/log_workout_screen.dart';
import '../workouts/timer_screen.dart';
import '../workouts/workout_icons.dart';
import '../workouts/workout_providers.dart';
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
                const StreakCard(),
                const SizedBox(height: 14),
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
                const _QuickLog(),
                const SizedBox(height: 14),
                const _TodaySummary(),
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

class _QuickLog extends StatelessWidget {
  const _QuickLog();

  @override
  Widget build(BuildContext context) {
    void open(Widget screen) =>
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => screen));

    return SoftCard(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              'Quick log',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 14),
          Row(
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
                  TintedIcon(icon: icon, cat: cat, size: 58),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: context.tokens.text,
                      fontSize: 12.5,
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

/// Today's workouts and healthy habits, then sleep and screen time.
class _TodaySummary extends ConsumerWidget {
  const _TodaySummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(todayWorkoutsProvider).value ?? const [];
    final types = {
      for (final t
          in ref.watch(workoutTypesProvider).value ?? const <WorkoutType>[])
        t.id: t,
    };
    final habits = ref.watch(activeHabitsProvider).value ?? const <Habit>[];
    final counts = ref.watch(todayHabitCountsProvider).value ?? const {};
    final lastNight = ref.watch(lastNightProvider);
    final target = ref.watch(effectiveSleepTargetProvider);
    final granted = ref.watch(screenTimeAccessProvider).value ?? false;
    final screen = ref.watch(screenTimeTodayProvider);
    final goal = ref.watch(screenTimeGoalProvider).value;

    final sleepTarget =
        (target.wakeMinutes - target.bedtimeMinutes + 1440) % 1440;

    void open(Widget screen) =>
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => screen));

    final rows = <Widget>[
      if (workouts.isEmpty)
        SummaryRow(
          icon: Icons.self_improvement_rounded,
          colors: context.tokens.cat(Cat.workout),
          title: 'Workout',
          subtitle: 'Not logged yet',
          onTap: () => openLogWorkout(context),
        )
      else
        for (final w in workouts)
          SummaryRow(
            icon: workoutIcon(types[w.workoutTypeId]?.iconKey ?? 'other'),
            colors: workoutColors(
              context,
              types[w.workoutTypeId]?.iconKey ?? 'custom',
            ),
            title: 'Workout',
            subtitle:
                '${types[w.workoutTypeId]?.name ?? 'Workout'} • ${durationShort(w.durationMinutes)}',
            done: true,
            onTap: () => openLogWorkout(context, existing: w),
          ),
      if (habits.isEmpty)
        SummaryRow(
          icon: Icons.spa_rounded,
          colors: context.tokens.cat(Cat.habit),
          title: 'Healthy Habits',
          subtitle: 'Add a habit to get started',
          onTap: () => open(const HabitSetupScreen()),
        )
      else
        for (final h in habits)
          SummaryRow(
            icon: habitIcon(h.kind),
            colors: context.tokens.cat(habitCat(h.kind)),
            title: h.name,
            subtitle: '${counts[h.id] ?? 0}/${h.dailyTarget}',
            done: (counts[h.id] ?? 0) >= h.dailyTarget,
            semanticLabel:
                'Log ${h.name}, ${counts[h.id] ?? 0} of ${h.dailyTarget} today',
            onTap: () => logHabitOnce(context, ref, h),
          ),
      SummaryRow(
        icon: Icons.nightlight_round,
        colors: context.tokens.cat(Cat.sleep),
        title: 'Sleep',
        subtitle: lastNight == null
            ? 'Not logged yet'
            : '${durationShort(lastNight.durationMinutes)} (target ${durationShort(sleepTarget)})',
        onTap: () => open(const SleepScreen()),
      ),
      SummaryRow(
        icon: Icons.smartphone_rounded,
        colors: context.tokens.cat(Cat.screen),
        title: 'Screen time',
        subtitle: !granted
            ? 'Not set up yet'
            : goal == null
            ? durationShort(screen?.totalMinutes ?? 0)
            : '${durationShort(screen?.totalMinutes ?? 0)} (goal ${durationShort(goal)})',
        onTap: () => open(const ScreenTimeScreen()),
      ),
      SummaryRow(
        icon: Icons.self_improvement_rounded,
        colors: context.tokens.cat(Cat.hobby),
        title: 'Hobbies',
        subtitle: 'Om chanting counter',
        onTap: () => open(const HobbiesScreen()),
      ),
    ];

    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's summary",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const RowDivider(indent: 62),
            rows[i],
          ],
        ],
      ),
    );
  }
}

/// A summary line: tinted icon, title, one line of detail, and a tick when
/// the day's target for it is met.
class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.icon,
    required this.colors,
    required this.title,
    required this.subtitle,
    this.done,
    this.onTap,
    this.semanticLabel,
  });

  final IconData icon;
  final CatColors colors;
  final String title;
  final String subtitle;

  /// Null shows no mark at all; true a tick; false an empty ring.
  final bool? done;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 66),
          child: Row(
            children: [
              TintedIcon(
                icon: icon,
                tint: colors.tint,
                color: colors.icon,
                size: 46,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleSmall),
                    const SizedBox(height: 2),
                    Text(subtitle, style: text.bodySmall),
                  ],
                ),
              ),
              if (done != null) DoneMark(done: done!),
            ],
          ),
        ),
      ),
    );
  }
}
