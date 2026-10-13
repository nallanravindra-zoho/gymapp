import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import 'metrics_logic.dart';
import 'metrics_providers.dart';

/// BMI as a screening figure, with careful wording: not a diagnosis and not a
/// measure of body fat. Adult categories show only for people aged 18 or more.
class BmiCard extends ConsumerWidget {
  const BmiCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bmi = ref.watch(latestBmiProvider);
    final age = ref.watch(userAgeProvider);
    final a = assessBmi(bmi: bmi, age: age);
    final text = Theme.of(context).textTheme;
    final t = context.tokens;

    String? line;
    switch (a.status) {
      case BmiStatus.noData:
        line = 'Add your height and weight to see your BMI.';
      case BmiStatus.needsDob:
        line =
            'Adding your date of birth enables interpretation of this figure.';
      case BmiStatus.minor:
        line =
            'Adult BMI categories do not apply under 18. Age-appropriate '
            'assessment is needed, so a health professional is the right '
            'person to ask.';
      case BmiStatus.adult:
        line = '${bmiBandLabel(a.band!)} (general reference).';
    }
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const TintedIcon(
                icon: Icons.speed_rounded,
                cat: Cat.leaf,
                size: 40,
              ),
              const SizedBox(width: 12),
              Text('BMI', style: text.titleMedium),
              const Spacer(),
              if (a.bmi != null)
                Semantics(
                  label: 'BMI ${a.bmi!.toStringAsFixed(1)}',
                  child: ExcludeSemantics(
                    child: Text(
                      a.bmi!.toStringAsFixed(1),
                      style: text.headlineSmall,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(line, style: text.bodyMedium),
          const SizedBox(height: 10),
          Text(
            'BMI is a screening measure. It is not a diagnosis and it does '
            'not measure body fat. Thresholds differ between populations, '
            'including South Asian populations, so the general reference '
            'ranges may not suit everyone.',
            style: text.bodySmall?.copyWith(color: t.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            'Source: NHS BMI calculator, $nhsBmiUrl',
            style: text.bodySmall?.copyWith(color: t.textMuted),
          ),
        ],
      ),
    );
  }
}
