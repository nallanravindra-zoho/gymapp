import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/durations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/dialogs.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../../data/tables/tables.dart';
import 'log_workout_screen.dart';
import 'met_table.dart';
import 'workout_calc.dart';
import 'workout_icons.dart';
import 'workout_providers.dart';

/// Opens the one shared workout detail screen (all metrics, Edit, Delete).
/// Every list of workouts in the app opens this.
Future<void> openWorkoutDetail(BuildContext context, String workoutId) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => WorkoutDetailScreen(workoutId: workoutId),
    ),
  );
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', //
];
const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({super.key, required this.workoutId});

  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(workoutByIdProvider(workoutId)).value;
    final types = ref.watch(allWorkoutTypesProvider).value ?? const [];
    final user = ref.watch(liveUserProvider).value;
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    final appBar = AppBar(
      title: const Text('Workout'),
      leading: IconButton(
        tooltip: 'Back',
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.maybePop(context),
      ),
    );
    if (workout == null) {
      return Scaffold(appBar: appBar, body: const SizedBox.shrink());
    }

    final type = types.where((x) => x.id == workout.workoutTypeId).firstOrNull;
    final key = type?.iconKey ?? 'custom';
    final colors = workoutColors(context, key);
    final name = type?.name ?? 'Workout';
    final start = workout.startedAt.toLocal();
    final end = workout.endedAt.toLocal();
    final bottom = MediaQuery.paddingOf(context).bottom;
    final date =
        '${_days[start.weekday - 1]}, ${start.day} ${_months[start.month - 1]}';
    final span =
        '${TimeOfDay.fromDateTime(start).format(context)} – ${TimeOfDay.fromDateTime(end).format(context)}';

    final rows = <_Metric>[
      _Metric(
        'Duration',
        durationShort(workout.durationMinutes),
        caption: workout.pausedSeconds > 0
            ? 'Paused ${durationShort((workout.pausedSeconds / 60).ceil())} not counted'
            : null,
      ),
      if (workout.intensity != null)
        _Metric('Intensity', _intensityLabel(workout.intensity!)),
      _caloriesMetric(workout, type, user),
      if (tracksDistance(key)) ..._walkRunMetrics(workout),
      if ((workout.note ?? '').isNotEmpty) _Metric('Note', workout.note!),
    ];

    return Scaffold(
      appBar: appBar,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, bottom + 28),
        children: [
          Row(
            children: [
              TintedIcon(
                icon: workoutIcon(key),
                tint: colors.tint,
                color: colors.icon,
                size: 64,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: text.headlineSmall),
                    const SizedBox(height: 2),
                    Text(
                      '$date  $span',
                      style: text.bodyMedium?.copyWith(color: t.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SoftCard(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) const RowDivider(),
                  _MetricRow(rows[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: () => openLogWorkout(context, existing: workout),
            child: const Text('Edit'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(kMinTapTarget),
              foregroundColor: t.textMuted,
            ),
            onPressed: () => _delete(context, ref),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await confirm(
      context,
      title: 'Delete this workout',
      body: 'It will be removed from your history.',
      action: 'Delete',
    );
    if (!ok || !context.mounted) return;
    await ref.read(workoutRepositoryProvider).delete(workoutId);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Entry removed.')));
  }
}

_Metric _caloriesMetric(Workout w, WorkoutType? type, User? user) {
  final kcal = w.caloriesEstimate;
  if (kcal != null) {
    return _Metric('Calories', '$kcal kcal', caption: caloriesLabel);
  }
  final hasMet = metByTypeKey.containsKey(type?.iconKey);
  final needsWeight = hasMet && (user?.weightKg == null);
  return _Metric(
    'Calories',
    caloriesUnavailable,
    caption: needsWeight ? caloriesNeedWeightHint : caloriesNoTypeHint,
    muted: true,
  );
}

List<_Metric> _walkRunMetrics(Workout w) {
  final steps = w.steps;
  final distance = w.distanceKm;
  final speed = w.avgSpeedKmh;
  return [
    if (steps != null)
      _Metric(
        'Steps',
        formatSteps(steps),
        caption: w.stepsSource == 'sensor'
            ? 'Counted by your phone'
            : 'Estimated from distance',
      )
    else
      const _Metric('Steps', stepsUnavailable, muted: true),
    if (distance != null)
      _Metric(
        'Distance',
        formatDistanceKm(distance),
        caption: w.metricsNote == 'estimated'
            ? 'Estimated from steps'
            : 'Entered by you',
      )
    else
      const _Metric('Distance', 'Not recorded', muted: true),
    if (speed != null)
      _Metric('Average speed', formatSpeed(speed), caption: 'Active time only')
    else
      const _Metric('Average speed', 'Not available', muted: true),
  ];
}

String _intensityLabel(WorkoutIntensity i) => switch (i) {
  WorkoutIntensity.low => 'Low',
  WorkoutIntensity.mid => 'Mid',
  WorkoutIntensity.high => 'High',
};

class _Metric {
  const _Metric(this.label, this.value, {this.caption, this.muted = false});
  final String label;
  final String value;
  final String? caption;
  final bool muted;
}

class _MetricRow extends StatelessWidget {
  const _MetricRow(this.metric);
  final _Metric metric;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return Semantics(
      container: true,
      label:
          '${metric.label}, ${metric.value}${metric.caption == null ? '' : ', ${metric.caption}'}',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  metric.label,
                  style: text.bodyMedium?.copyWith(color: t.textMuted),
                ),
              ),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      metric.value,
                      textAlign: TextAlign.end,
                      style: text.titleSmall?.copyWith(
                        color: metric.muted ? t.textMuted : t.text,
                      ),
                    ),
                    if (metric.caption != null)
                      Text(
                        metric.caption!,
                        textAlign: TextAlign.end,
                        style: text.bodySmall?.copyWith(color: t.textMuted),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
