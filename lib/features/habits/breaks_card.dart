import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/app_database.dart';
import 'habit_actions.dart';
import 'habit_defaults.dart';
import 'habit_detail_screen.dart';
import 'habit_providers.dart';
import 'habit_setup_screen.dart';
import 'habits_screen.dart';

/// Today's breaks: a progress ring per habit. Tap to log one; tap the arrow
/// for the habit's detail.
class BreaksCard extends ConsumerWidget {
  const BreaksCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(activeHabitsProvider).value ?? const <Habit>[];
    final counts = ref.watch(todayHabitCountsProvider).value ?? const {};
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Breaks', style: text.titleLarge)),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const HabitsScreen(),
                    ),
                  ),
                  child: const Text('Manage'),
                ),
              ],
            ),
            if (habits.isEmpty) ...[
              const SizedBox(height: 4),
              Text('No habits yet.', style: text.bodySmall),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, kMinTapTarget),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HabitSetupScreen(),
                  ),
                ),
                child: const Text('Add habit'),
              ),
            ] else
              for (final h in habits)
                _HabitRow(habit: h, count: counts[h.id] ?? 0),
          ],
        ),
      ),
    );
  }
}

class _HabitRow extends ConsumerWidget {
  const _HabitRow({required this.habit, required this.count});

  final Habit habit;
  final int count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final met = count >= habit.dailyTarget;
    final progress = (count / habit.dailyTarget).clamp(0.0, 1.0);

    return Semantics(
      button: true,
      label: 'Log ${habit.name}, $count of ${habit.dailyTarget} today',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => logHabitOnce(context, ref, habit),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: kMinTapTarget + 8),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                      backgroundColor: t.textMuted.withValues(alpha: 0.2),
                      color: t.accent,
                    ),
                    Icon(
                      habitIcon(habit.kind),
                      size: 18,
                      color: met ? t.accent : t.text,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(habit.name)),
              Text(
                '$count/${habit.dailyTarget}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              IconButton(
                tooltip: '${habit.name} details',
                constraints: const BoxConstraints(
                  minWidth: kMinTapTarget,
                  minHeight: kMinTapTarget,
                ),
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => HabitDetailScreen(habitId: habit.id),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
