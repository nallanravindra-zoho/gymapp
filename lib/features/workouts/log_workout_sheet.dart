import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/section_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../../data/tables/tables.dart';
import 'timer_screen.dart';
import 'workout_icons.dart';
import 'workout_providers.dart';

/// Opens the log sheet for a new workout, or for editing [existing].
Future<void> showLogWorkoutSheet(
  BuildContext context, {
  Workout? existing,
  bool startManual = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => SectionTheme(
      section: AppSection.workout,
      child: LogWorkoutSheet(existing: existing, startManual: startManual),
    ),
  );
}

class LogWorkoutSheet extends ConsumerStatefulWidget {
  const LogWorkoutSheet({super.key, this.existing, this.startManual = false});

  final Workout? existing;
  final bool startManual;

  @override
  ConsumerState<LogWorkoutSheet> createState() => _LogWorkoutSheetState();
}

class _LogWorkoutSheetState extends ConsumerState<LogWorkoutSheet> {
  static const _durations = [15, 30, 45, 60];

  String? _typeId;
  int _duration = 30;
  late bool _manual;
  late DateTime _start;
  late DateTime _end;
  WorkoutIntensity? _intensity;
  final _note = TextEditingController();
  bool _saving = false;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final w = widget.existing;
    final now = ref.read(clockProvider).now().toLocal();
    if (w != null) {
      _typeId = w.workoutTypeId;
      _start = w.startedAt.toLocal();
      _end = w.endedAt.toLocal();
      _intensity = w.intensity;
      _note.text = w.note ?? '';
      _manual = true;
    } else {
      _end = now;
      _start = now.subtract(Duration(minutes: _duration));
      _manual = widget.startManual;
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _addCustom() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _CustomTypeDialog(),
    );
    if (name == null || name.isEmpty) return;
    final user = await ref.read(currentUserProvider.future);
    final type = await ref
        .read(workoutRepositoryProvider)
        .addCustomType(userId: user.id, name: name);
    if (mounted) setState(() => _typeId = type.id);
  }

  Future<void> _save(List<WorkoutType> types) async {
    final typeId = _typeId;
    if (typeId == null || _saving) return;
    if (_manual && !_end.isAfter(_start)) {
      _toast('End time must be after start time.');
      return;
    }
    setState(() => _saving = true);

    final user = await ref.read(currentUserProvider.future);
    final repo = ref.read(workoutRepositoryProvider);
    final note = _note.text.trim();

    DateTime start = _start, end = _end;
    if (!_manual) {
      end = ref.read(clockProvider).now();
      start = end.subtract(Duration(minutes: _duration));
    }

    if (_editing) {
      await repo.update(
        id: widget.existing!.id,
        dayCutoffMinutes: user.dayCutoffMinutes,
        workoutTypeId: typeId,
        startedAt: start,
        endedAt: end,
        intensity: _intensity,
        clearIntensity: _intensity == null,
        note: note,
      );
    } else {
      await repo.add(
        userId: user.id,
        dayCutoffMinutes: user.dayCutoffMinutes,
        workoutTypeId: typeId,
        startedAt: start,
        endedAt: end,
        source: _manual ? WorkoutSource.manual : WorkoutSource.timer,
        intensity: _intensity,
        note: note.isEmpty ? null : note,
      );
    }

    final minutes = end.difference(start).inMinutes;
    final name = types.firstWhere((t) => t.id == typeId).name;
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(loggedMessage(minutes, name))));
  }

  Future<void> _delete() async {
    await ref.read(workoutRepositoryProvider).delete(widget.existing!.id);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Entry removed.')));
  }

  Future<void> _startTimer() async {
    final typeId = _typeId;
    if (typeId == null) return;
    await ref.read(activeTimerProvider.notifier).start(typeId);
    if (!mounted) return;
    final nav = Navigator.of(context);
    nav.pop();
    nav.push(MaterialPageRoute<void>(builder: (_) => const TimerScreen()));
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final types = ref.watch(workoutTypesProvider).value ?? const [];
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _editing ? 'Edit workout' : 'Log workout',
                    style: text.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final type in types)
                        _TypeTile(
                          label: type.name,
                          icon: workoutIcon(type.iconKey),
                          selected: type.id == _typeId,
                          onTap: () => setState(() => _typeId = type.id),
                        ),
                      _TypeTile(
                        label: 'Custom',
                        icon: Icons.add_rounded,
                        selected: false,
                        onTap: _addCustom,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_manual) ...[
                    _TimeRow(
                      label: 'Start',
                      value: _start,
                      onTap: () async {
                        final d = await _pick(_start);
                        if (d != null) setState(() => _start = d);
                      },
                    ),
                    _TimeRow(
                      label: 'End',
                      value: _end,
                      onTap: () async {
                        final d = await _pick(_end);
                        if (d != null) setState(() => _end = d);
                      },
                    ),
                  ] else ...[
                    Text('Duration', style: text.bodySmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final m in _durations)
                          ChoiceChip(
                            label: Text('$m'),
                            selected: _duration == m,
                            onSelected: (_) => setState(() => _duration = m),
                          ),
                      ],
                    ),
                  ],
                  if (!_editing)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => setState(() => _manual = !_manual),
                        child: Text(
                          _manual ? 'Use duration' : 'Enter times manually',
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text('Intensity (optional)', style: text.bodySmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final i in WorkoutIntensity.values)
                        ChoiceChip(
                          label: Text(_intensityLabel(i)),
                          selected: _intensity == i,
                          // Tapping the selected chip clears it: never required.
                          onSelected: (_) => setState(
                            () => _intensity = _intensity == i ? null : i,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _note,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Note (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_editing)
                TextButton(
                  onPressed: _delete,
                  child: Text('Delete', style: TextStyle(color: t.textMuted)),
                ),
              if (!_editing)
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, kMinTapTarget),
                    ),
                    onPressed: _typeId == null ? null : _startTimer,
                    child: const Text('Start timer'),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, kMinTapTarget),
                  ),
                  onPressed: _typeId == null || _saving
                      ? null
                      : () => _save(types),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _intensityLabel(WorkoutIntensity i) => switch (i) {
  WorkoutIntensity.low => 'Low',
  WorkoutIntensity.mid => 'Mid',
  WorkoutIntensity.high => 'High',
};

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 76,
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? t.accent.withValues(alpha: 0.14) : t.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? t.accent : t.textMuted.withValues(alpha: 0.2),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: selected ? t.accent : t.text),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(value).format(context);
    final date =
        '${value.year}-${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 12,
      title: Text(label),
      trailing: Text('$date  $time'),
      onTap: onTap,
    );
  }
}

/// Owns its text controller, so the controller outlives the dialog's exit
/// animation and is disposed only when the dialog is truly gone.
class _CustomTypeDialog extends StatefulWidget {
  const _CustomTypeDialog();

  @override
  State<_CustomTypeDialog> createState() => _CustomTypeDialogState();
}

class _CustomTypeDialogState extends State<_CustomTypeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom workout'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: const InputDecoration(hintText: 'Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}
