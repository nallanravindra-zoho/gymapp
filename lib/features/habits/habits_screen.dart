import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_database.dart';
import '../reminders/reminders_screen.dart';
import 'habit_defaults.dart';
import 'habit_detail_screen.dart';
import 'habit_providers.dart';
import 'habit_setup_screen.dart';
import 'reminder_config.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(activeHabitsProvider).value ?? const <Habit>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits and breaks'),
        actions: [
          IconButton(
            tooltip: 'Reminders',
            constraints: const BoxConstraints(
              minWidth: kMinTapTarget,
              minHeight: kMinTapTarget,
            ),
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const RemindersScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: ListTile(
              minTileHeight: kMinTapTarget + 16,
              leading: const Icon(Icons.notifications_none_rounded),
              title: const Text('Reminders'),
              subtitle: const Text('See what is scheduled and send a test'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RemindersScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          if (habits.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No habits yet.'),
            ),
          for (final h in habits)
            Card(
              child: ListTile(
                minTileHeight: kMinTapTarget + 16,
                leading: Icon(habitIcon(h.kind)),
                title: Text(h.name),
                subtitle: Text(_subtitle(h)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => HabitDetailScreen(habitId: h.id),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
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

  String _subtitle(Habit h) {
    final target = '${h.dailyTarget} per day';
    if (!h.remindersEnabled) return '$target, reminders off';
    final c = ReminderConfig.fromJson(h.reminderConfig);
    return c.mode == ReminderMode.interval
        ? '$target, ${describeInterval(c.everyMinutes).toLowerCase()}'
        : '$target, ${c.times.length} reminder${c.times.length == 1 ? '' : 's'}';
  }
}
