import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/dialogs.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../streaks/streak_providers.dart';
import 'log_workout_screen.dart';
import 'workout_detail_screen.dart';
import 'workout_icons.dart';
import 'workout_providers.dart';
import 'workout_row.dart';

/// Opens the Manage screen: saved workouts, custom workout types and a way
/// to add a new workout.
Future<void> openWorkoutManage(BuildContext context) {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const WorkoutManageScreen()));
}

class WorkoutManageScreen extends ConsumerWidget {
  const WorkoutManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(allWorkoutsProvider).value ?? const <Workout>[];
    final allTypes =
        ref.watch(allWorkoutTypesProvider).value ?? const <WorkoutType>[];
    final byId = {for (final x in allTypes) x.id: x};
    final custom = [
      for (final x in ref.watch(workoutTypesProvider).value ?? const [])
        if (!x.isBuiltin) x,
    ];
    final sorted = [...all]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage workouts'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          4,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          FilledButton.icon(
            onPressed: () => openLogWorkout(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add new workout'),
          ),
          const SizedBox(height: 22),
          const SectionTitle('Saved workouts'),
          const SizedBox(height: 10),
          if (sorted.isEmpty)
            Text(
              'No workouts logged yet.',
              style: text.bodyMedium?.copyWith(color: t.textMuted),
            )
          else
            for (final w in sorted) ...[
              WorkoutRow(
                workout: w,
                type: byId[w.workoutTypeId],
                onTap: () => openWorkoutDetail(context, w.id),
              ),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 14),
          const SectionTitle('Your workout types'),
          const SizedBox(height: 10),
          if (custom.isEmpty)
            Text(
              'Types you add with Custom appear here, where you can rename '
              'or delete them.',
              style: text.bodyMedium?.copyWith(color: t.textMuted),
            )
          else
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Column(
                children: [
                  for (var i = 0; i < custom.length; i++) ...[
                    if (i > 0) const RowDivider(),
                    _CustomTypeRow(type: custom[i]),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CustomTypeRow extends ConsumerWidget {
  const _CustomTypeRow({required this.type});
  final WorkoutType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = workoutColors(context, type.iconKey);
    final repo = ref.read(workoutRepositoryProvider);
    return Row(
      children: [
        TintedIcon(
          icon: workoutIcon(type.iconKey),
          tint: colors.tint,
          color: colors.icon,
          size: 44,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(type.name, style: Theme.of(context).textTheme.titleSmall),
        ),
        IconButton(
          tooltip: 'Rename ${type.name}',
          constraints: const BoxConstraints(
            minWidth: kMinTapTarget,
            minHeight: kMinTapTarget,
          ),
          icon: const Icon(Icons.edit_outlined),
          onPressed: () async {
            final name = await showDialog<String>(
              context: context,
              builder: (_) => TextPromptDialog(
                title: 'Rename workout type',
                label: 'Name',
                action: 'Save',
                initial: type.name,
                maxLength: 30,
              ),
            );
            final trimmed = name?.trim() ?? '';
            if (trimmed.isEmpty) return;
            await repo.renameCustomType(type.id, trimmed);
          },
        ),
        IconButton(
          tooltip: 'Delete ${type.name}',
          constraints: const BoxConstraints(
            minWidth: kMinTapTarget,
            minHeight: kMinTapTarget,
          ),
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: () async {
            final ok = await confirm(
              context,
              title: 'Delete ${type.name}',
              body:
                  'It will no longer be offered when you log a workout. '
                  'Workouts already saved with it stay in your history.',
              action: 'Delete',
            );
            if (ok) await repo.deleteCustomType(type.id);
          },
        ),
      ],
    );
  }
}
