import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import 'habit_defaults.dart';
import 'habit_detail_screen.dart';
import 'habit_providers.dart';
import 'habit_setup_screen.dart';
import 'reminder_config.dart';

/// Manage habits: every habit with Edit and Archive, plus Add. Archiving
/// hides a habit from Healthy Habits and stops its reminders; its history is
/// kept and Restore brings it back.
class HabitManageScreen extends ConsumerWidget {
  const HabitManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(manageableHabitsProvider).value ?? const <Habit>[];
    final text = Theme.of(context).textTheme;
    final t = context.tokens;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage habits')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          if (habits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
              child: Text(
                'No habits yet. Add one to get started.',
                style: text.bodyMedium?.copyWith(color: t.textMuted),
              ),
            ),
          for (final h in habits) ...[
            _ManageRow(habit: h),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(kMinTapTarget),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const HabitSetupScreen()),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add habit'),
          ),
        ],
      ),
    );
  }
}

String _summary(Habit h) {
  final base = '${h.dailyTarget} per day';
  if (!h.remindersEnabled) return '$base, reminders off';
  final c = ReminderConfig.fromJson(h.reminderConfig);
  final when = c.mode == ReminderMode.interval
      ? describeInterval(c.everyMinutes).toLowerCase()
      : describeOccurrences(c.occurrences);
  return '$base, $when';
}

class _ManageRow extends ConsumerWidget {
  const _ManageRow({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final archived = !habit.isActive;
    return SoftCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HabitDetailScreen(habitId: habit.id),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      child: Row(
        children: [
          TintedIcon(
            icon: habitIcon(habit.kind),
            cat: habitCat(habit.kind),
            size: 46,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.name, style: text.titleMedium),
                const SizedBox(height: 2),
                Text(
                  archived ? 'Archived' : _summary(habit),
                  style: text.bodySmall?.copyWith(color: t.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit ${habit.name}',
            constraints: const BoxConstraints(
              minWidth: kMinTapTarget,
              minHeight: kMinTapTarget,
            ),
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => HabitSetupScreen(existing: habit),
              ),
            ),
          ),
          IconButton(
            tooltip: archived
                ? 'Restore ${habit.name}'
                : 'Archive ${habit.name}',
            constraints: const BoxConstraints(
              minWidth: kMinTapTarget,
              minHeight: kMinTapTarget,
            ),
            icon: Icon(
              archived ? Icons.unarchive_outlined : Icons.archive_outlined,
            ),
            onPressed: () async {
              await ref
                  .read(habitRepositoryProvider)
                  .update(habit.id, HabitsCompanion(isActive: Value(archived)));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      archived
                          ? '${habit.name} restored.'
                          : '${habit.name} archived. Its history is kept.',
                    ),
                  ),
                );
            },
          ),
        ],
      ),
    );
  }
}
