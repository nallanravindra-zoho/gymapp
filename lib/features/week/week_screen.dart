import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/durations.dart';
import '../../core/theme/tokens.dart';
import '../../core/time/local_date.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/app_database.dart';
import '../hobbies/hobby_providers.dart';
import '../streaks/streak_card.dart';
import '../workouts/workout_detail_screen.dart';
import '../workouts/workout_history_screen.dart';
import '../workouts/workout_providers.dart';
import '../workouts/workout_row.dart';
import 'day_format.dart';
import 'day_summary_screen.dart';
import 'week_marks.dart';
import 'week_providers.dart';
import 'week_summary.dart';

const _short = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String formatWeekRange(String weekStart) {
  final a = parseLocalDate(weekStart);
  final b = parseLocalDate(shiftLocalDate(weekStart, 6));
  final am = monthNames[a.month - 1];
  final bm = monthNames[b.month - 1];
  return a.month == b.month
      ? '${a.day} – ${b.day} $bm'
      : '${a.day} $am – ${b.day} $bm';
}

void openDaySummary(BuildContext context, String localDate) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => DaySummaryScreen(localDate: localDate),
    ),
  );
}

class WeekScreen extends ConsumerWidget {
  const WeekScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekStart = ref.watch(weekStartProvider);
    final today = ref.watch(todayDateProvider).value;
    final workouts = ref.watch(weekWorkoutsProvider).value ?? const <Workout>[];
    final restDays = ref.watch(weekRestDaysProvider).value ?? const <String>{};
    final marks = ref.watch(weekMarksProvider);
    final types = {
      for (final t
          in ref.watch(workoutTypesProvider).value ?? const <WorkoutType>[])
        t.id: t,
    };
    final text = Theme.of(context).textTheme;
    final sorted = [...workouts]
      ..sort((a, b) => a.startedAt.compareTo(b.startedAt));

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text('Week'),
        ),
      ),
      body: weekStart == null
          ? const SizedBox.shrink()
          : ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              children: [
                _WeekHeader(weekStart: weekStart, today: today),
                const SizedBox(height: 14),
                _DayStrip(
                  dates: weekDates(weekStart),
                  marks: marks,
                  today: today,
                ),
                const SizedBox(height: 22),
                SectionTitle(
                  'Workouts',
                  trailing: 'View all',
                  onTrailing: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const WorkoutHistoryScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                if (sorted.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No workouts logged this week.',
                      style: text.bodyMedium?.copyWith(
                        color: context.tokens.textMuted,
                      ),
                    ),
                  )
                else
                  for (final w in sorted) ...[
                    WorkoutRow(
                      workout: w,
                      type: types[w.workoutTypeId],
                      onTap: () => openWorkoutDetail(context, w.id),
                    ),
                    const SizedBox(height: 10),
                  ],
                const SizedBox(height: 14),
                _WeeklyHobbyGoals(weekStart: weekStart),
                Text('Streaks', style: text.titleMedium),
                const SizedBox(height: 12),
                const WeekStreaks(),
                if (sorted.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _Totals(
                    summary: summarizeWeek(workouts),
                    restCount: restDays.length,
                  ),
                ],
              ],
            ),
    );
  }
}

class _WeekHeader extends ConsumerWidget {
  const _WeekHeader({required this.weekStart, required this.today});

  final String weekStart;
  final String? today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final notifier = ref.read(selectedWeekProvider.notifier);
    final current = today == null ? weekStart : weekStartOf(today!);
    final isCurrent = weekStart == current;
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous week',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: Icon(Icons.chevron_left_rounded, color: t.accentDeep, size: 30),
          onPressed: () => notifier.shift(weekStart, -1),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                formatWeekRange(weekStart),
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              if (!isCurrent)
                GestureDetector(
                  onTap: notifier.reset,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'This week',
                      style: TextStyle(
                        color: t.accentDeep,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Next week',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: Icon(
            Icons.chevron_right_rounded,
            color: t.accentDeep,
            size: 30,
          ),
          onPressed: () => notifier.shift(weekStart, 1),
        ),
      ],
    );
  }
}

class _DayStrip extends StatelessWidget {
  const _DayStrip({
    required this.dates,
    required this.marks,
    required this.today,
  });

  final List<String> dates;
  final Map<String, DayMarks> marks;
  final String? today;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: _DayCell(
              label: _short[i],
              date: dates[i],
              marks: marks[dates[i]] ?? const DayMarks(),
              isToday: dates[i] == today,
            ),
          ),
      ],
    );
  }
}

/// Icon and label for each calendar category.
(IconData, Cat, String) markStyle(MarkCategory c) => switch (c) {
  MarkCategory.workout => (
    Icons.self_improvement_rounded,
    Cat.workout,
    'workout',
  ),
  MarkCategory.habits => (Icons.spa_rounded, Cat.habit, 'healthy habits met'),
  MarkCategory.hobbies => (
    Icons.interests_rounded,
    Cat.hobby,
    'hobby goal met',
  ),
  MarkCategory.sleep => (Icons.nightlight_round, Cat.sleep, 'sleep target met'),
  MarkCategory.screen => (
    Icons.smartphone_rounded,
    Cat.screen,
    'screen time target met',
  ),
};

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.label,
    required this.date,
    required this.marks,
    required this.isToday,
  });

  final String label;
  final String date;
  final DayMarks marks;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final day = parseLocalDate(date).day;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final visible = limitMarks(marks.categories);

    final fg = isToday ? Colors.white : t.text;
    final bg = isToday
        ? (dark ? t.accent : const Color(0xFF3D8670))
        : (dark ? t.track : const Color(0xFFE8F3EC));

    final spoken = [
      if (marks.workouts.isNotEmpty)
        '${marks.workouts.length} workout${marks.workouts.length > 1 ? 's' : ''}',
      for (final c in marks.categories)
        if (c != MarkCategory.workout) markStyle(c).$3,
      if (marks.rest) 'rest day',
    ];

    return Semantics(
      button: true,
      label:
          '${formatDayTitle(date)}, ${spoken.isEmpty ? 'nothing logged' : spoken.join(', ')}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => openDaySummary(context, date),
        child: ExcludeSemantics(
          child: Container(
            constraints: const BoxConstraints(minHeight: 108),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.fromLTRB(2, 8, 2, 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isToday ? Colors.white70 : t.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
                const SizedBox(height: 6),
                if (visible.shown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: marks.rest
                        ? Icon(
                            Icons.bedtime_outlined,
                            size: 16,
                            color: isToday ? Colors.white : t.textMuted,
                          )
                        : Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (isToday ? Colors.white : t.textMuted)
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                  )
                else
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 3,
                    runSpacing: 3,
                    children: [
                      for (final c in visible.shown)
                        Container(
                          key: ValueKey('mark-${c.name}'),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: isToday
                                ? Colors.white.withValues(alpha: 0.22)
                                : t.cat(markStyle(c).$2).tint,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            markStyle(c).$1,
                            size: 12,
                            color: isToday
                                ? Colors.white
                                : t.cat(markStyle(c).$2).icon,
                          ),
                        ),
                      if (visible.overflow > 0)
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: Center(
                            child: Text(
                              '+${visible.overflow}',
                              key: const ValueKey('mark-overflow'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: fg,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Weekly hobby goals met this week. Weekly goals belong to the week, so they
/// are listed here and never put on a single day of the calendar.
class _WeeklyHobbyGoals extends ConsumerWidget {
  const _WeeklyHobbyGoals({required this.weekStart});

  final String weekStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final met = ref.watch(weeklyHobbyGoalsMetProvider(weekStart));
    final hobbies = ref.watch(activeHobbiesProvider).value ?? const <Hobby>[];
    final names = [
      for (final h in hobbies)
        if (met.contains(h.id)) h.name,
    ];
    if (names.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const TintedIcon(
              icon: Icons.interests_rounded,
              cat: Cat.hobby,
              size: 42,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly hobby goals met',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    names.join(', '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.summary, required this.restCount});

  final WeekSummary summary;
  final int restCount;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              value: durationShort(summary.activeMinutes),
              label: 'Active minutes',
            ),
          ),
          Expanded(
            child: _Stat(value: '${summary.activeDays}', label: 'Active days'),
          ),
          if (restCount > 0)
            Expanded(
              child: _Stat(value: '$restCount', label: 'Rest days'),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: text.titleLarge),
        Text(label, style: text.bodySmall),
      ],
    );
  }
}
