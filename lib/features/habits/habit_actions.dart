import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../data/providers.dart';
import 'habit_providers.dart';

/// Records one completion and offers Undo. Copy: `Logged. Water 3 of 8.`
Future<void> logHabitOnce(
  BuildContext context,
  WidgetRef ref,
  Habit habit,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final user = await ref.read(currentUserProvider.future);
  final repo = ref.read(habitRepositoryProvider);
  final before = ref.read(todayHabitCountsProvider).value?[habit.id] ?? 0;
  final logId = await repo.log(
    habit: habit,
    dayCutoffMinutes: user.dayCutoffMinutes,
  );
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(
          'Logged. ${habit.name} ${before + 1} of ${habit.dailyTarget}.',
        ),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => repo.deleteLog(logId),
        ),
      ),
    );
}
