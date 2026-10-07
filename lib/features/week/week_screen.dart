import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/time/local_date.dart';
import '../../core/widgets/avatar_button.dart';
import '../../data/app_database.dart';
import '../workouts/workout_icons.dart';
import '../workouts/workout_providers.dart';
import '../streaks/streak_card.dart';
import 'day_sheet.dart';
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

class WeekScreen extends ConsumerWidget {
  const WeekScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekStart = ref.watch(weekStartProvider);
    final today = ref.watch(todayDateProvider).value;
    final workouts = ref.watch(weekWorkoutsProvider).value ?? const <Workout>[];
    final restDays = ref.watch(weekRestDaysProvider).value ?? const <String>{};
    final types = {
      for (final t
          in ref.watch(workoutTypesProvider).value ?? const <WorkoutType>[])
        t.id: t,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Week'),
        actions: const [AvatarButton()],
      ),
      body: weekStart == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                _WeekHeader(weekStart: weekStart, today: today),
                const SizedBox(height: 12),
                _DayStrip(
                  dates: weekDates(weekStart),
                  byDate: groupByDate(workouts),
                  restDays: restDays,
                  types: types,
                  today: today,
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 12),
                const WeekStreaks(),
                const SizedBox(height: 12),
                _Totals(
                  summary: summarizeWeek(workouts),
                  types: types,
                  restCount: restDays.length,
                ),
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
    final notifier = ref.read(selectedWeekProvider.notifier);
    final current = today == null ? weekStart : weekStartOf(today!);
    final isCurrent = weekStart == current;
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous week',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => notifier.shift(weekStart, -1),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                formatWeekRange(weekStart),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (!isCurrent)
                TextButton(
                  onPressed: notifier.reset,
                  child: const Text('This week'),
                ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Next week',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: () => notifier.shift(weekStart, 1),
        ),
      ],
    );
  }
}

class _DayStrip extends StatelessWidget {
  const _DayStrip({
    required this.dates,
    required this.byDate,
    required this.restDays,
    required this.types,
    required this.today,
  });

  final List<String> dates;
  final Map<String, List<Workout>> byDate;
  final Set<String> restDays;
  final Map<String, WorkoutType> types;
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
              workouts: byDate[dates[i]] ?? const [],
              isRest: restDays.contains(dates[i]),
              isToday: dates[i] == today,
              types: types,
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.label,
    required this.date,
    required this.workouts,
    required this.isRest,
    required this.isToday,
    required this.types,
  });

  final String label;
  final String date;
  final List<Workout> workouts;
  final bool isRest;
  final bool isToday;
  final Map<String, WorkoutType> types;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final day = parseLocalDate(date).day;
    final first = workouts.isEmpty ? null : workouts.first;

    Widget marker;
    if (first != null) {
      final icon = workoutIcon(types[first.workoutTypeId]?.iconKey ?? 'other');
      marker = Badge(
        isLabelVisible: workouts.length > 1,
        label: Text('${workouts.length}'),
        backgroundColor: t.accent,
        child: Icon(icon, color: t.accent),
      );
    } else if (isRest) {
      // Quiet marker, not a gap (spec section 5).
      marker = Icon(Icons.bedtime_outlined, size: 20, color: t.textMuted);
    } else {
      marker = Icon(
        Icons.circle,
        size: 6,
        color: t.textMuted.withValues(alpha: 0.35),
      );
    }

    final spoken = workouts.isEmpty
        ? (isRest ? 'rest day' : 'no workouts')
        : '${workouts.length} workout${workouts.length > 1 ? 's' : ''}';

    return Semantics(
      button: true,
      label: '${formatDayTitle(date)}, $spoken',
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => showDaySheet(context, date),
        child: Container(
          constraints: const BoxConstraints(minHeight: 88),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isToday ? t.accent.withValues(alpha: 0.14) : t.surface,
            borderRadius: BorderRadius.circular(14),
            border: isToday ? Border.all(color: t.accent, width: 1.5) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text('$day', style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: 28, child: Center(child: marker)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({
    required this.summary,
    required this.types,
    required this.restCount,
  });

  final WeekSummary summary;
  final Map<String, WorkoutType> types;
  final int restCount;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    if (summary.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(4),
        child: Text('No workouts logged this week.', style: text.bodySmall),
      );
    }

    final byType = summary.countByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    value: '${summary.activeMinutes}',
                    label: 'Active minutes',
                  ),
                ),
                Expanded(
                  child: _Stat(
                    value: '${summary.activeDays}',
                    label: 'Active days',
                  ),
                ),
                if (restCount > 0)
                  Expanded(
                    child: _Stat(value: '$restCount', label: 'Rest days'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Workouts', style: text.bodySmall),
            const SizedBox(height: 8),
            for (final e in byType)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      workoutIcon(types[e.key]?.iconKey ?? 'other'),
                      size: 20,
                      color: context.tokens.accent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(types[e.key]?.name ?? 'Workout')),
                    Text('${e.value}'),
                  ],
                ),
              ),
          ],
        ),
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
