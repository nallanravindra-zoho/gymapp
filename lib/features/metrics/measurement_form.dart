import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../../core/time/local_date.dart';
import 'metrics_charts.dart' show chartDate;
import '../streaks/streak_providers.dart';
import 'metrics_logic.dart';
import 'metrics_providers.dart';

/// Add or edit one body measurement record. Every value is optional.
class MeasurementFormScreen extends ConsumerStatefulWidget {
  const MeasurementFormScreen({super.key, this.existing});
  final BodyMeasurement? existing;

  @override
  ConsumerState<MeasurementFormScreen> createState() => _FormState();
}

class _FormState extends ConsumerState<MeasurementFormScreen> {
  late DateTime _at;
  late bool _dateTouched;
  final _c = <String, TextEditingController>{};
  String? _error;

  static const _fields = <(String, String, String, double, double)>[
    ('weight', 'Weight (kg)', 'kg', 1, 500),
    ('height', 'Height (cm)', 'cm', 30, 272),
    ('waist', 'Waist (inches)', 'in', 1, 200),
    ('hips', 'Hips (inches)', 'in', 1, 200),
    ('chest', 'Chest (inches)', 'in', 1, 200),
    ('arm', 'Arm (inches)', 'in', 1, 100),
    ('thigh', 'Thigh (inches)', 'in', 1, 100),
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _at = e?.measuredAt.toLocal() ?? ref.read(clockProvider).now().toLocal();
    _dateTouched = false;
    String f(double? v) => v == null ? '' : formatNumber(v);
    final init = {
      'weight': f(e?.weightKg),
      'height': f(e?.heightCm),
      'waist': f(e?.waistIn),
      'hips': f(e?.hipsIn),
      'chest': f(e?.chestIn),
      'arm': f(e?.armIn),
      'thigh': f(e?.thighIn),
      'notes': e?.notes ?? '',
    };
    for (final k in init.keys) {
      _c[k] = TextEditingController(text: init[k]);
    }
    if (e == null) {
      final h = ref.read(userStreamProvider).value?.heightCm;
      if (h != null) _c['height']!.text = formatNumber(h);
    }
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = ref.read(clockProvider).now().toLocal();
    final d = await showDatePicker(
      context: context,
      initialDate: _at.isAfter(now) ? now : _at,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (d != null) {
      setState(() {
        _at = DateTime(d.year, d.month, d.day, 12);
        _dateTouched = true;
      });
    }
  }

  Future<void> _save() async {
    final values = <String, double?>{};
    for (final (key, label, _, lo, hi) in _fields) {
      final raw = _c[key]!.text.trim();
      if (raw.isEmpty) {
        values[key] = null;
        continue;
      }
      final v = parseNumber(raw);
      if (v == null || v < lo || v > hi) {
        setState(
          () => _error =
              'Check $label. Enter a number from '
              '${formatNumber(lo)} to ${formatNumber(hi)}.',
        );
        return;
      }
      values[key] = v;
    }
    if (values.values.every((v) => v == null)) {
      setState(() => _error = 'Enter at least one measurement.');
      return;
    }
    final notes = _c['notes']!.text.trim();
    final actions = ref.read(metricsActionsProvider);
    final e = widget.existing;
    final at = e != null && !_dateTouched ? e.measuredAt : _at;
    if (e == null) {
      await actions.add(
        at: at,
        weightKg: values['weight'],
        heightCm: values['height'],
        waistIn: values['waist'],
        hipsIn: values['hips'],
        chestIn: values['chest'],
        armIn: values['arm'],
        thighIn: values['thigh'],
        notes: notes.isEmpty ? null : notes,
      );
    } else {
      await actions.edit(
        e.id,
        at: at,
        weightKg: values['weight'],
        heightCm: values['height'],
        waistIn: values['waist'],
        hipsIn: values['hips'],
        chestIn: values['chest'],
        armIn: values['arm'],
        thighIn: values['thigh'],
        notes: notes.isEmpty ? null : notes,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final dateLabel = chartDate(
      localDateOf(_at.toUtc(), offsetMinutes: _at.timeZoneOffset.inMinutes),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null ? 'Add measurements' : 'Edit measurements',
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          Text(
            'Fill in what you have. Every value is optional.',
            style: text.bodyMedium?.copyWith(color: t.textMuted),
          ),
          const SizedBox(height: 12),
          ListTile(
            minTileHeight: kMinTapTarget + 8,
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            subtitle: Text(dateLabel),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickDate,
          ),
          for (final (key, label, _, _, _) in _fields)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _c[key],
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: label),
              ),
            ),
          TextField(
            controller: _c['notes'],
            maxLength: 200,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: text.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(kMinTapTarget),
            ),
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
