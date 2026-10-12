import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';

/// Brief, non-prescriptive notes on measuring consistently.
class MeasurementGuidance extends StatelessWidget {
  const MeasurementGuidance({super.key});

  static const tips = <(IconData, String, String)>[
    (
      Icons.straighten_rounded,
      'Waist',
      'Around the middle, level with your navel, after a normal breath out.',
    ),
    (
      Icons.accessibility_new_rounded,
      'Hips',
      'Around the widest part of your hips and buttocks, tape level all round.',
    ),
    (
      Icons.favorite_border_rounded,
      'Chest',
      'Around the fullest part of your chest, under the arms, tape level.',
    ),
    (
      Icons.fitness_center_rounded,
      'Arms',
      'Around the midpoint between shoulder and elbow, arm relaxed.',
    ),
    (
      Icons.directions_walk_rounded,
      'Thighs',
      'Around the upper thigh, just below the crease of the buttock.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    return SoftCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Text('How to measure', style: text.titleMedium),
          children: [
            for (final (icon, title, body) in tips)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, size: 22, color: t.accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: '$title. ', style: text.titleSmall),
                            TextSpan(text: body, style: text.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.schedule_rounded, size: 22, color: t.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Use a flexible tape, snug but not squeezing the skin. '
                    'Measure at a similar time of day, keep to the same '
                    'points each time, and note the unit (inches) and where '
                    'on the body you measured.',
                    style: text.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
