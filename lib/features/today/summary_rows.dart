import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/durations.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/app_database.dart';
import '../habits/habit_actions.dart';
import '../habits/habit_defaults.dart';
import '../habits/habit_detail_screen.dart';
import '../habits/habit_providers.dart';
import '../habits/habit_setup_screen.dart';
import '../hobbies/hobbies_screen.dart';
import '../hobbies/hobby_detail_screen.dart';
import '../hobbies/hobby_providers.dart';
import '../screen_time/screen_time_providers.dart';
import '../screen_time/screen_time_screen.dart';
import '../sleep/sleep_log_sheet.dart';
import '../sleep/sleep_logic.dart' show sleepDateCaption;
import '../sleep/sleep_screen.dart';
import '../week/week_marks.dart';
import '../week/week_providers.dart';
import '../workouts/log_workout_screen.dart';
import '../workouts/workout_detail_screen.dart';
import '../workouts/workout_icons.dart';
import '../workouts/workout_providers.dart';

/// Hobby activity for a day as short text: `Music 20 min, Reading 15 min`.
/// Pure so it is easy to test.
String hobbyActivityText(List<HobbyLog> logs, Map<String, String> hobbyNames) {
  final minutes = <String, int>{};
  for (final l in logs) {
    minutes[l.hobbyId] = (minutes[l.hobbyId] ?? 0) + l.durationMinutes;
  }
  return [
    for (final e in minutes.entries)
      '${hobbyNames[e.key] ?? 'Hobby'} ${durationShort(e.value)}',
  ].join(', ');
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

/// The summary card shared by Today and a selected day in Week (R1, R8): the
/// day's workouts, healthy-habit activity, hobby activity, sleep and screen
/// time, all in one card language. Every row opens the same detail view as
/// elsewhere in the app.
class DaySummaryCard extends ConsumerWidget {
  const DaySummaryCard({
    super.key,
    required this.date,
    required this.isToday,
    this.title,
  });

  final String date;
  final bool isToday;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final workouts = ref.watch(workoutsOnProvider(date)).value ?? const [];
    final types = {
      for (final t
          in ref.watch(allWorkoutTypesProvider).value ?? const <WorkoutType>[])
        t.id: t,
    };
    final habits = ref.watch(activeHabitsProvider).value ?? const <Habit>[];
    final counts = ref.watch(habitCountsOnProvider(date)).value ?? const {};
    final hobbyLogs =
        ref.watch(hobbyLogsOnDateProvider(date)).value ?? const [];
    final hobbies = [
      ...(ref.watch(activeHobbiesProvider).value ?? const <Hobby>[]),
      ...(ref.watch(archivedHobbiesProvider).value ?? const <Hobby>[]),
    ];
    final sleep = ref.watch(sleepOnProvider(date)).value;
    final sleepTarget = ref.watch(sleepTargetMinutesProvider);
    final screen = ref.watch(screenOnProvider(date)).value;
    final goal = ref.watch(screenTimeGoalProvider).value;
    final granted = ref.watch(screenTimeAccessProvider).value ?? false;

    void open(Widget screen) =>
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => screen));

    final habitsWithActivity = [
      for (final h in habits)
        if ((counts[h.id] ?? 0) > 0) h,
    ];

    final hobbyIds = {for (final l in hobbyLogs) l.hobbyId};
    final singleHobby = hobbyIds.length == 1
        ? hobbies.where((h) => h.id == hobbyIds.first).firstOrNull
        : null;

    final rows = <Widget>[
      if (workouts.isEmpty)
        SummaryRow(
          icon: Icons.self_improvement_rounded,
          colors: tokens.cat(Cat.workout),
          title: 'Workout',
          subtitle: isToday ? 'Not logged yet' : 'None logged',
          onTap: () => openLogWorkout(context, forDate: isToday ? null : date),
        )
      else
        for (final w in workouts)
          SummaryRow(
            icon: workoutIcon(types[w.workoutTypeId]?.iconKey ?? 'custom'),
            colors: workoutColors(
              context,
              types[w.workoutTypeId]?.iconKey ?? 'custom',
            ),
            title: 'Workout',
            subtitle:
                '${types[w.workoutTypeId]?.name ?? 'Workout'} • ${durationShort(w.durationMinutes)}',
            done: true,
            onTap: () => openWorkoutDetail(context, w.id),
          ),
      if (habits.isEmpty)
        SummaryRow(
          icon: Icons.spa_rounded,
          colors: tokens.cat(Cat.habit),
          title: 'Healthy Habits',
          subtitle: 'Add a habit to get started',
          onTap: () => open(const HabitSetupScreen()),
        )
      else if (habitsWithActivity.isEmpty)
        SummaryRow(
          icon: Icons.spa_rounded,
          colors: tokens.cat(Cat.habit),
          title: 'Healthy Habits',
          subtitle: isToday ? 'No activity yet' : 'No activity logged',
          onTap: () => open(HabitDetailScreen(habitId: habits.first.id)),
        )
      else
        for (final h in habitsWithActivity)
          SummaryRow(
            icon: habitIcon(h.kind),
            colors: tokens.cat(habitCat(h.kind)),
            title: h.name,
            subtitle: '${counts[h.id] ?? 0} of ${h.dailyTarget}',
            done: (counts[h.id] ?? 0) >= h.dailyTarget,
            semanticLabel:
                '${h.name}, ${counts[h.id] ?? 0} of ${h.dailyTarget}',
            onTap: () => open(HabitDetailScreen(habitId: h.id)),
          ),
      SummaryRow(
        icon: Icons.interests_rounded,
        colors: tokens.cat(Cat.hobby),
        title: 'Hobbies',
        subtitle: hobbyLogs.isEmpty
            ? (isToday ? 'Nothing logged yet' : 'No hobby activity')
            : hobbyActivityText(hobbyLogs, {
                for (final h in hobbies) h.id: h.name,
              }),
        done: hobbyLogs.isEmpty ? null : true,
        onTap: () => open(
          singleHobby == null
              ? const HobbiesScreen()
              : HobbyDetailScreen(hobby: singleHobby),
        ),
      ),
      SummaryRow(
        icon: Icons.nightlight_round,
        colors: tokens.cat(Cat.sleep),
        title: 'Sleep',
        subtitle: sleep == null
            ? 'Not logged'
            : '${durationShort(sleep.durationMinutes)} (target ${durationShort(sleepTarget)})',
        done: sleep == null ? null : sleep.durationMinutes >= sleepTarget,
        onTap: () => sleep != null && !isToday
            ? showSleepLogSheet(context, existing: sleep)
            : open(const SleepScreen()),
      ),
      SummaryRow(
        icon: Icons.smartphone_rounded,
        colors: tokens.cat(Cat.screen),
        title: 'Screen time',
        subtitle: screen == null
            ? (isToday && !granted ? 'Not set up yet' : 'Not tracked')
            : goal == null
            ? durationShort(screen.totalMinutes)
            : '${durationShort(screen.totalMinutes)} (target ${durationShort(goal)})',
        done: screen == null || goal == null
            ? null
            : screenMarkMet(screen, goal),
        onTap: () => open(const ScreenTimeScreen()),
      ),
    ];

    final text = Theme.of(context).textTheme;
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? (isToday ? "Today's Summary" : 'Summary'),
            style: text.titleMedium,
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const RowDivider(indent: 62),
            rows[i],
          ],
          const SizedBox(height: 4),
          if (!isToday)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '$sleepDateCaption.',
                style: text.bodySmall?.copyWith(color: tokens.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}

/// Healthy habits for one date with per-habit counts. On today, tapping a
/// habit logs one; on another day it opens the habit's detail.
class HabitCountsSection extends ConsumerWidget {
  const HabitCountsSection({
    super.key,
    required this.date,
    required this.isToday,
    this.trailing,
  });

  final String date;
  final bool isToday;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(activeHabitsProvider).value ?? const <Habit>[];
    final counts = ref.watch(habitCountsOnProvider(date)).value ?? const {};
    final text = Theme.of(context).textTheme;
    final tokens = context.tokens;

    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 48,
            child: Row(
              children: [
                Expanded(
                  child: Text('Healthy Habits', style: text.titleMedium),
                ),
                ?trailing,
              ],
            ),
          ),
          if (habits.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'No habits yet. Use Manage to add one.',
                style: text.bodyMedium?.copyWith(color: tokens.textMuted),
              ),
            ),
          for (var i = 0; i < habits.length; i++) ...[
            if (i > 0) const RowDivider(indent: 62),
            SummaryRow(
              icon: habitIcon(habits[i].kind),
              colors: tokens.cat(habitCat(habits[i].kind)),
              title: habits[i].name,
              subtitle:
                  '${counts[habits[i].id] ?? 0}/${habits[i].dailyTarget}',
              done: (counts[habits[i].id] ?? 0) >= habits[i].dailyTarget,
              semanticLabel: isToday
                  ? 'Log ${habits[i].name}, ${counts[habits[i].id] ?? 0} of ${habits[i].dailyTarget} today'
                  : '${habits[i].name}, ${counts[habits[i].id] ?? 0} of ${habits[i].dailyTarget}',
              onTap: isToday
                  ? () => logHabitOnce(context, ref, habits[i])
                  : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            HabitDetailScreen(habitId: habits[i].id),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
