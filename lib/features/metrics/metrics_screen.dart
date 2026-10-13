import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/dialogs.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../streaks/streak_providers.dart';
import 'bmi_card.dart';
import 'measurement_form.dart';
import 'measurement_guidance.dart';
import 'metrics_charts.dart';
import 'metrics_logic.dart';
import 'metrics_providers.dart';

/// Body measurements: add, edit and delete records, set how often they are
/// due, see BMI, and open the charts. All of it is private.
class MetricsScreen extends ConsumerWidget {
  const MetricsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    final user = ref.watch(userStreamProvider).value;
    final rows = ref.watch(measurementsProvider).value ?? const [];
    final cadence = MeasurementCadence.parse(user?.measurementCadence);

    void open(Widget w) =>
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => w));

    return Scaffold(
      appBar: AppBar(title: const Text('Body measurements')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline_rounded, size: 18, color: t.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Private to you. Metrics are never shared with groups.',
                  style: text.bodySmall?.copyWith(color: t.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(kMinTapTarget),
            ),
            onPressed: () => open(const MeasurementFormScreen()),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add measurements'),
          ),
          const SizedBox(height: 16),
          const BmiCard(),
          const SizedBox(height: 14),
          SoftCard(
            onTap: () => open(const MetricsChartsScreen()),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: Row(
                children: [
                  const TintedIcon(
                    icon: Icons.show_chart_rounded,
                    cat: Cat.leaf,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text('View charts', style: text.titleMedium)),
                  Icon(Icons.chevron_right_rounded, color: t.textMuted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (user != null)
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How often', style: text.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final c in MeasurementCadence.values)
                        ChoiceChip(
                          label: Text(c.label),
                          selected: c == cadence,
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          onSelected: (_) =>
                              ref.read(metricsActionsProvider).setCadence(c),
                        ),
                    ],
                  ),
                  if (user.nextMeasurementDue != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Next measurements: ${chartDate(user.nextMeasurementDue!)}',
                      style: text.bodyMedium,
                    ),
                  ],
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Remind me about measurement day'),
                    subtitle: const Text(
                      'Shows a note on Today a couple of days before.',
                    ),
                    value: user.measurementReminderEnabled,
                    onChanged: (v) => ref
                        .read(userRepositoryProvider)
                        .update(
                          user.id,
                          UsersCompanion(measurementReminderEnabled: Value(v)),
                        ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          const MeasurementGuidance(),
          const SizedBox(height: 20),
          Text('History', style: text.titleLarge),
          const SizedBox(height: 8),
          if (rows.isEmpty)
            Text(
              'No measurements yet.',
              style: text.bodyMedium?.copyWith(color: t.textMuted),
            )
          else
            for (final m in rows)
              _RecordTile(
                record: m,
                onEdit: () => open(MeasurementFormScreen(existing: m)),
                onDelete: () async {
                  final ok = await confirm(
                    context,
                    title: 'Delete this entry?',
                    body:
                        'The measurements from ${chartDate(m.localDate)} '
                        'will be removed.',
                    action: 'Delete',
                  );
                  if (ok) await ref.read(metricsActionsProvider).delete(m.id);
                },
              ),
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });
  final BodyMeasurement record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    String f(double v) => formatNumber(v);
    final parts = [
      if (record.weightKg != null) 'Weight ${f(record.weightKg!)} kg',
      if (record.heightCm != null) 'Height ${f(record.heightCm!)} cm',
      if (record.bmi != null) 'BMI ${record.bmi!.toStringAsFixed(1)}',
      if (record.waistIn != null) 'Waist ${f(record.waistIn!)} in',
      if (record.hipsIn != null) 'Hips ${f(record.hipsIn!)} in',
      if (record.chestIn != null) 'Chest ${f(record.chestIn!)} in',
      if (record.armIn != null) 'Arm ${f(record.armIn!)} in',
      if (record.thighIn != null) 'Thigh ${f(record.thighIn!)} in',
    ];
    final date = chartDate(record.localDate);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
        onTap: onEdit,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: text.titleSmall),
                  const SizedBox(height: 2),
                  Text(parts.join('  '), style: text.bodyMedium),
                  if (record.notes != null && record.notes!.isNotEmpty)
                    Text(
                      record.notes!,
                      style: text.bodySmall?.copyWith(color: t.textMuted),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Delete entry from $date',
              constraints: const BoxConstraints(
                minWidth: kMinTapTarget,
                minHeight: kMinTapTarget,
              ),
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
