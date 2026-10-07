import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/time/local_date.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../week/week_providers.dart';
import 'habit_providers.dart';
import 'habit_setup_screen.dart';

/// Today's count, streak and four weeks of history for one habit.
class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this habit?'),
        content: const Text('It will no longer appear in your breaks.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(habitRepositoryProvider).delete(habitId);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(activeHabitsProvider).value ?? const <Habit>[];
    final habit = habits.where((h) => h.id == habitId).firstOrNull;
    final today = ref.watch(todayDateProvider).value;
    final counts = ref.watch(todayHabitCountsProvider).value ?? const {};
    final logs = ref.watch(allHabitLogsProvider).value ?? const <HabitLog>[];
    final streak = ref.watch(habitStreaksProvider)[habitId];
    final text = Theme.of(context).textTheme;
    final t = context.tokens;

    if (habit == null || today == null) {
      return Scaffold(appBar: AppBar());
    }
    final count = counts[habit.id] ?? 0;
    final repo = ref.read(habitRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => HabitSetupScreen(existing: habit),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('Today', style: text.bodySmall),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.outlined(
                        tooltip: 'Remove one',
                        iconSize: 28,
                        constraints: const BoxConstraints(
                          minWidth: kMinTapTarget,
                          minHeight: kMinTapTarget,
                        ),
                        onPressed: count > 0
                            ? () => repo.removeLatestLog(habit.id, today)
                            : null,
                        icon: const Icon(Icons.remove_rounded),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '$count of ${habit.dailyTarget}',
                              style: text.displaySmall,
                            ),
                          ),
                        ),
                      ),
                      IconButton.filled(
                        tooltip: 'Log one',
                        iconSize: 28,
                        constraints: const BoxConstraints(
                          minWidth: kMinTapTarget,
                          minHeight: kMinTapTarget,
                        ),
                        onPressed: () async {
                          final user = await ref.read(
                            currentUserProvider.future,
                          );
                          await repo.log(
                            habit: habit,
                            dayCutoffMinutes: user.dayCutoffMinutes,
                          );
                        },
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _Stat(
                      value: '${streak?.current ?? 0}',
                      label: 'Current streak',
                    ),
                  ),
                  Expanded(
                    child: _Stat(
                      value: '${streak?.longest ?? 0}',
                      label: 'Longest streak',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Last 4 weeks', style: text.bodySmall),
          const SizedBox(height: 8),
          _History(
            habit: habit,
            totals: dailyTotals(logs, habit.id),
            today: today,
            accent: t.accent,
            muted: t.textMuted,
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

/// Four Mon-Sun rows ending with the current week.
class _History extends StatelessWidget {
  const _History({
    required this.habit,
    required this.totals,
    required this.today,
    required this.accent,
    required this.muted,
  });

  final Habit habit;
  final Map<String, int> totals;
  final String today;
  final Color accent;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final thisWeek = weekStartOf(today);
    final first = shiftLocalDate(thisWeek, -21);

    Widget cell(String date) {
      final total = totals[date] ?? 0;
      final future = date.compareTo(today) > 0;
      final met = total >= habit.dailyTarget;
      final color = future
          ? Colors.transparent
          : met
          ? accent
          : total > 0
          ? accent.withValues(alpha: 0.35)
          : muted.withValues(alpha: 0.15);
      final d = parseLocalDate(date);
      return Expanded(
        child: Semantics(
          label: '${d.day}/${d.month}: $total of ${habit.dailyTarget}',
          child: Container(
            height: 36,
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: future
                  ? Border.all(color: muted.withValues(alpha: 0.2))
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '${d.day}',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: met ? Colors.white : null, fontSize: 11),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var w = 0; w < 4; w++)
          Row(
            children: [
              for (var d = 0; d < 7; d++)
                cell(shiftLocalDate(first, w * 7 + d)),
            ],
          ),
      ],
    );
  }
}
