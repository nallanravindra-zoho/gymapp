import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/section_theme.dart';
import '../../core/time/local_date.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../week/week_providers.dart';
import 'sleep_logic.dart';
import 'sleep_providers.dart';

Future<void> showSleepLogSheet(BuildContext context, {SleepLog? existing}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => SectionTheme(
      section: AppSection.sleep,
      child: SleepLogSheet(existing: existing),
    ),
  );
}

/// Log or edit one night. Times default to the targets and can be adjusted.
class SleepLogSheet extends ConsumerStatefulWidget {
  const SleepLogSheet({super.key, this.existing});

  final SleepLog? existing;

  @override
  ConsumerState<SleepLogSheet> createState() => _SleepLogSheetState();
}

class _SleepLogSheetState extends ConsumerState<SleepLogSheet> {
  DateTime? _wakeDate; // calendar date of waking
  int? _bedMinutes;
  int? _wakeMinutes;
  bool _saving = false;

  bool get _editing => widget.existing != null;

  int _minutesOf(DateTime d) => d.hour * 60 + d.minute;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      final wake = e.wakeAt.toLocal();
      _wakeDate = DateTime(wake.year, wake.month, wake.day);
      _bedMinutes = _minutesOf(e.bedtimeAt.toLocal());
      _wakeMinutes = _minutesOf(wake);
    }
  }

  Future<int?> _pick(int initial) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial ~/ 60, minute: initial % 60),
    );
    return t == null ? null : t.hour * 60 + t.minute;
  }

  Future<void> _save({
    required DateTime wakeDate,
    required int bed,
    required int wake,
  }) async {
    if (_saving) return;
    setState(() => _saving = true);
    final user = await ref.read(currentUserProvider.future);
    final times = resolveSleepTimes(
      wakeDate: wakeDate,
      bedtimeMinutes: bed,
      wakeMinutes: wake,
    );
    await ref
        .read(sleepRepositoryProvider)
        .log(
          userId: user.id,
          dayCutoffMinutes: user.dayCutoffMinutes,
          bedtimeAt: times.bedtime,
          wakeAt: times.wake,
        );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            sleepLoggedMessage(times.wake.difference(times.bedtime).inMinutes),
          ),
        ),
      );
  }

  Future<void> _delete() async {
    await ref.read(sleepRepositoryProvider).delete(widget.existing!.id);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Entry removed.')));
  }

  @override
  Widget build(BuildContext context) {
    final target = ref.watch(effectiveSleepTargetProvider);
    final today = ref.watch(todayDateProvider).value;
    final todayDate = today == null ? DateTime.now() : parseLocalDate(today);

    final wakeDate =
        _wakeDate ?? DateTime(todayDate.year, todayDate.month, todayDate.day);
    final bed = _bedMinutes ?? target.bedtimeMinutes;
    final wake = _wakeMinutes ?? target.wakeMinutes;
    final times = resolveSleepTimes(
      wakeDate: wakeDate,
      bedtimeMinutes: bed,
      wakeMinutes: wake,
    );
    final minutes = times.wake.difference(times.bedtime).inMinutes;
    final text = Theme.of(context).textTheme;

    String fmt(int m) =>
        TimeOfDay(hour: m ~/ 60, minute: m % 60).format(context);
    final dateLabel =
        '${wakeDate.year}-${wakeDate.month.toString().padLeft(2, '0')}-'
        '${wakeDate.day.toString().padLeft(2, '0')}';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.paddingOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_editing ? 'Edit sleep' : 'Log sleep', style: text.titleLarge),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            minTileHeight: kMinTapTarget,
            title: const Text('Woke up on'),
            trailing: Text(dateLabel),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: wakeDate,
                firstDate: DateTime(2020),
                lastDate: todayDate,
              );
              if (d != null) setState(() => _wakeDate = d);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            minTileHeight: kMinTapTarget,
            title: const Text('Bedtime'),
            trailing: Text(fmt(bed)),
            onTap: () async {
              final m = await _pick(bed);
              if (m != null) setState(() => _bedMinutes = m);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            minTileHeight: kMinTapTarget,
            title: const Text('Wake up'),
            trailing: Text(fmt(wake)),
            onTap: () async {
              final m = await _pick(wake);
              if (m != null) setState(() => _wakeMinutes = m);
            },
          ),
          const SizedBox(height: 4),
          Text(formatSleepDuration(minutes), style: text.bodySmall),
          const SizedBox(height: 16),
          Row(
            children: [
              if (_editing)
                TextButton(onPressed: _delete, child: const Text('Delete')),
              const Spacer(),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(120, kMinTapTarget),
                ),
                onPressed: _saving
                    ? null
                    : () => _save(wakeDate: wakeDate, bed: bed, wake: wake),
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
