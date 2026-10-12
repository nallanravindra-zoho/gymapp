import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/time/local_date.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/dialogs.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../../data/tables/tables.dart';
import 'timer_screen.dart';
import 'workout_icons.dart';
import 'workout_providers.dart';

/// Opens the Log Workout screen for a new workout, or for editing [existing].
Future<void> openLogWorkout(
  BuildContext context, {
  Workout? existing,
  bool startManual = false,
  String? forDate,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => LogWorkoutScreen(
        existing: existing,
        startManual: startManual,
        forDate: forDate,
      ),
    ),
  );
}

class LogWorkoutScreen extends ConsumerStatefulWidget {
  const LogWorkoutScreen({
    super.key,
    this.existing,
    this.startManual = false,
    this.forDate,
  });

  final Workout? existing;
  final bool startManual;

  /// Local date (`YYYY-MM-DD`) to log for; opens in manual mode at 09:00.
  final String? forDate;

  @override
  ConsumerState<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends ConsumerState<LogWorkoutScreen> {
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
    } else if (widget.forDate != null) {
      final d = parseLocalDate(widget.forDate!);
      _start = DateTime(d.year, d.month, d.day, 9);
      _end = _start.add(Duration(minutes: _duration));
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

  Future<void> _customDuration() async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => const TextPromptDialog(
        title: 'Duration',
        label: 'Minutes',
        action: 'Set',
        keyboardType: TextInputType.number,
        maxLength: 3,
      ),
    );
    final minutes = int.tryParse(value ?? '');
    if (minutes == null || minutes < 1 || minutes > 600) return;
    setState(() {
      _duration = minutes;
      _end = _start.add(Duration(minutes: minutes));
    });
  }

  void _setDuration(int m) => setState(() {
    _duration = m;
    // In manual mode the duration moves the end time, so the chips are a
    // quick way to fill both.
    if (_manual) _end = _start.add(Duration(minutes: m));
  });

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(workoutTypesProvider).value ?? const <WorkoutType>[];
    // "Other" is gone from the picker (revised spec); an existing workout of
    // that type can still be opened and edited.
    final types = [
      for (final t in all)
        if (t.id != 'builtin-other' || t.id == _typeId) t,
    ];
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final width = MediaQuery.sizeOf(context).width - 40;
    final cell = width / 4;

    final chips = <int>{15, 30, 45, 60, _duration}.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit workout' : 'Log Workout'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, bottom + 28),
        children: [
          Wrap(
            runSpacing: 14,
            children: [
              for (final type in types)
                SizedBox(
                  width: cell,
                  child: _TypeTile(
                    label: type.name,
                    icon: workoutIcon(type.iconKey),
                    colors: workoutColors(context, type.iconKey),
                    selected: type.id == _typeId,
                    onTap: () => setState(() => _typeId = type.id),
                  ),
                ),
              SizedBox(
                width: cell,
                child: _TypeTile(
                  label: 'Custom',
                  icon: Icons.add_rounded,
                  colors: workoutColors(context, 'custom'),
                  selected: false,
                  outlined: true,
                  onTap: _addCustom,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const RowDivider(),
          const SizedBox(height: 16),
          ...[
            Text('Duration', style: text.bodySmall?.copyWith(color: t.text)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final m in chips)
                  _DurationChip(
                    label: '$m',
                    selected: _duration == m,
                    onTap: () => _setDuration(m),
                  ),
                _DurationChip(
                  label: '+',
                  selected: false,
                  onTap: _customDuration,
                ),
              ],
            ),
          ],
          const SizedBox(height: 22),
          if (_manual) ...[
            _TimeRow(
              label: 'Start',
              value: _start,
              onTap: () async {
                final d = await _pick(_start);
                if (d != null) setState(() => _start = d);
              },
            ),
            const RowDivider(),
            _TimeRow(
              label: 'End',
              value: _end,
              onTap: () async {
                final d = await _pick(_end);
                if (d != null) setState(() => _end = d);
              },
            ),
            const SizedBox(height: 18),
            Text('Intensity (optional)', style: text.bodySmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: [
                for (final i in WorkoutIntensity.values)
                  _DurationChip(
                    label: _intensityLabel(i),
                    selected: _intensity == i,
                    // Tapping the selected chip clears it: never required.
                    onTap: () =>
                        setState(() => _intensity = _intensity == i ? null : i),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _note,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Note (optional)'),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _typeId == null || _saving ? null : () => _save(types),
              child: const Text('Save'),
            ),
            if (_editing)
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(kMinTapTarget),
                  foregroundColor: t.textMuted,
                ),
                onPressed: _delete,
                child: const Text('Delete'),
              )
            else
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(kMinTapTarget),
                ),
                onPressed: () => setState(() => _manual = false),
                child: const Text('Use timer instead'),
              ),
          ] else ...[
            FilledButton(
              onPressed: _typeId == null ? null : _startTimer,
              child: const Text('Start timer'),
            ),
            const SizedBox(height: 6),
            const RowDivider(),
            InkWell(
              onTap: () => setState(() => _manual = true),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Or enter manually', style: text.bodyMedium),
                    ),
                    Icon(Icons.chevron_right_rounded, color: t.textMuted),
                  ],
                ),
              ),
            ),
            const RowDivider(),
          ],
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
    required this.colors,
    required this.selected,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final CatColors colors;
  final bool selected;
  final bool outlined;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tint = selected
        ? Color.alphaBlend(
            (dark ? t.accent : const Color(0xFF4CC274)).withValues(alpha: 0.45),
            colors.tint,
          )
        : colors.tint;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: ExcludeSemantics(
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: tint,
                  shape: BoxShape.circle,
                  border: outlined
                      ? Border.all(color: t.border, width: 1.4)
                      : null,
                ),
                child: Icon(
                  icon,
                  size: outlined ? 30 : 32,
                  color: selected ? t.accentDeep : colors.icon,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? t.accentDeep : t.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      selected: selected,
      label: label == '+' ? 'Other duration' : label,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: ExcludeSemantics(
          child: Container(
            constraints: const BoxConstraints(minWidth: 52, minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: selected ? t.accentSoft : t.track,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? t.accentDeep : t.text,
                ),
              ),
            ),
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
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      trailing: Text(
        '$date  $time',
        style: Theme.of(context).textTheme.titleSmall,
      ),
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
