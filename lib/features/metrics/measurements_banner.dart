import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import 'metrics_logic.dart';
import 'metrics_providers.dart';
import 'metrics_screen.dart';

/// A calm banner for measurement day: a heads-up a couple of days before and
/// a shortcut to Metrics on the day. Shows nothing when reminders are off or
/// nothing is due soon. Placed on Today.
class MeasurementsBanner extends ConsumerWidget {
  const MeasurementsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(measurementNoticeProvider);
    if (!notice.visible) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    final due = notice.kind != MeasurementNoticeKind.upcoming;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        button: true,
        label: '${notice.message}. Open metrics',
        child: ExcludeSemantics(
          child: SoftCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const MetricsScreen()),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Row(
                children: [
                  const TintedIcon(
                    icon: Icons.straighten_rounded,
                    cat: Cat.leaf,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notice.message, style: text.titleSmall),
                        Text(
                          due ? 'Add your measurements' : 'A gentle heads-up',
                          style: text.bodySmall?.copyWith(color: t.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: t.textMuted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
