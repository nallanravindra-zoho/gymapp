import 'package:flutter/material.dart';

import '../../core/format/durations.dart';
import '../../core/theme/tokens.dart';
import '../../core/time/local_date.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/app_database.dart';
import 'workout_icons.dart';

const _short = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// One saved workout as a card: optional weekday and date on the left, the
/// type's icon, its name and duration, and a chevron. The same card is used
/// on Week, in the day summary and in the history list.
class WorkoutRow extends StatelessWidget {
  const WorkoutRow({
    super.key,
    required this.workout,
    required this.type,
    required this.onTap,
    this.showDate = true,
  });

  final Workout workout;
  final WorkoutType? type;
  final VoidCallback onTap;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final key = type?.iconKey ?? 'custom';
    final colors = workoutColors(context, key);
    final date = parseLocalDate(workout.localDate);
    final name = type?.name ?? 'Workout';

    return Semantics(
      button: true,
      label:
          '$name, ${durationShort(workout.durationMinutes)}, ${_short[date.weekday - 1]} ${date.day}',
      child: SoftCard(
        onTap: onTap,
        radius: 20,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: ExcludeSemantics(
          child: Row(
            children: [
              if (showDate)
                SizedBox(
                  width: 52,
                  child: Column(
                    children: [
                      Text(
                        _short[date.weekday - 1],
                        style: text.bodySmall?.copyWith(
                          color: t.accentDeep.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        '${date.day}',
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: t.accentDeep.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              TintedIcon(
                icon: workoutIcon(key),
                tint: colors.tint,
                color: colors.icon,
                size: 54,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: text.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      durationShort(workout.durationMinutes),
                      style: text.bodyMedium?.copyWith(color: t.textMuted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: t.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
