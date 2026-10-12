import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/time/local_date.dart';
import '../../data/providers.dart';
import '../../data/tables/tables.dart';
import '../week/week_providers.dart';
import 'screen_time_logic.dart';
import 'screen_time_providers.dart';

/// Manual entry, the fallback for when usage access is unavailable (R7).
/// Saved with source `manual`, so it is never mistaken for phone-read data.
Future<void> showManualScreenTimeDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final today = await ref.read(todayDateProvider.future);
  if (!context.mounted) return;
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => ManualScreenTimeDialog(today: today),
  );
  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Screen time saved.')));
  }
}

class ManualScreenTimeDialog extends ConsumerStatefulWidget {
  const ManualScreenTimeDialog({super.key, required this.today});

  final String today;

  @override
  ConsumerState<ManualScreenTimeDialog> createState() =>
      _ManualScreenTimeDialogState();
}

class _ManualScreenTimeDialogState
    extends ConsumerState<ManualScreenTimeDialog> {
  final _hours = TextEditingController();
  final _minutes = TextEditingController();
  late String _date = widget.today;
  String? _error;

  @override
  void dispose() {
    _hours.dispose();
    _minutes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final total = parseManualMinutes(_hours.text, _minutes.text);
    if (total == null) {
      setState(() => _error = 'Enter whole hours, and minutes from 0 to 59.');
      return;
    }
    final user = await ref.read(currentUserProvider.future);
    await ref
        .read(screenTimeRepositoryProvider)
        .upsertDay(
          userId: user.id,
          localDate: _date,
          totalMinutes: total,
          source: ScreenTimeSource.manual,
          targetMinutes: ref.read(screenTimeGoalProvider).value,
        );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final dates = [
      for (var i = 0; i < 7; i++) shiftLocalDate(widget.today, -i),
    ];
    return AlertDialog(
      title: const Text('Add screen time'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Type the total for a day. It is saved as a manual entry.',
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _date,
            decoration: const InputDecoration(labelText: 'Day'),
            items: [
              for (final d in dates)
                DropdownMenuItem(
                  value: d,
                  child: Text(
                    d == widget.today
                        ? 'Today'
                        : d == shiftLocalDate(widget.today, -1)
                        ? 'Yesterday'
                        : d,
                  ),
                ),
            ],
            onChanged: (v) => setState(() => _date = v ?? _date),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hours,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Hours'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _minutes,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Minutes'),
                ),
              ),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
