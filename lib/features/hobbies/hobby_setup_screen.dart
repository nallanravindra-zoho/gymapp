import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/time/local_date.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../../data/tables/tables.dart';
import '../reminders/reminder_providers.dart';
import '../week/week_providers.dart';
import 'hobby_reminders.dart';
import 'hobby_widgets.dart';

/// Add or edit a hobby: name, a daily or weekly goal, and a reminder.
class HobbySetupScreen extends ConsumerStatefulWidget {
  const HobbySetupScreen({super.key, this.existing});

  final Hobby? existing;

  @override
  ConsumerState<HobbySetupScreen> createState() => _HobbySetupScreenState();
}

class _HobbySetupScreenState extends ConsumerState<HobbySetupScreen> {
  final _name = TextEditingController();
  final _goalValue = TextEditingController(text: '30');
  String _iconKey = 'hobby';
  bool _goalOn = false;
  HobbyGoalPeriod _period = HobbyGoalPeriod.daily;
  HobbyGoalUnit _unit = HobbyGoalUnit.minutes;
  bool _remind = false;
  HobbyReminderConfig _config = const HobbyReminderConfig();
  String? _error;
  bool _saving = false;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final h = widget.existing;
    if (h != null) {
      _name.text = h.name;
      _iconKey = h.iconKey;
      if (h.goalPeriod != null && (h.goalValue ?? 0) > 0) {
        _goalOn = true;
        _period = h.goalPeriod!;
        _unit = h.goalUnit;
        _goalValue.text = '${h.goalValue}';
      }
      _remind = h.reminderEnabled;
      _config = HobbyReminderConfig.fromJson(h.reminderConfig);
    }
    _prepareStartDate();
  }

  Future<void> _prepareStartDate() async {
    if (_config.startDate != null) return;
    final today = await ref.read(todayDateProvider.future);
    if (mounted) setState(() => _config = _config.copyWith(startDate: today));
  }

  @override
  void dispose() {
    _name.dispose();
    _goalValue.dispose();
    super.dispose();
  }

  void _toast(String message) => ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _ensureNotificationAccess() async {
    final scheduler = ref.read(notificationSchedulerProvider);
    if (await scheduler.hasPermission()) return;
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Allow notifications'),
        content: const Text('Reminders need permission to show notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (ok != true) {
      if (mounted) {
        _toast('Reminders will start once notifications are allowed.');
      }
      return;
    }
    final granted = await scheduler.requestPermission();
    if (!granted && mounted) _toast('Notifications are off for this app.');
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter a name.');
      return;
    }
    int? goal;
    if (_goalOn) {
      goal = int.tryParse(_goalValue.text.trim());
      if (goal == null || goal < 1) {
        setState(() => _error = 'Enter a goal of 1 or more.');
        return;
      }
    }
    if (_remind &&
        _config.frequency == HobbyReminderFrequency.biweekly &&
        _config.startDate == null) {
      setState(() => _error = 'Choose a start date.');
      return;
    }
    setState(() {
      _error = null;
      _saving = true;
    });
    if (_remind) await _ensureNotificationAccess();

    final user = await ref.read(currentUserProvider.future);
    final repo = ref.read(hobbyRepositoryProvider);
    if (_editing) {
      await repo.update(
        widget.existing!.id,
        HobbiesCompanion(
          name: Value(name),
          iconKey: Value(_iconKey),
          goalPeriod: Value(_goalOn ? _period : null),
          goalValue: Value(_goalOn ? goal : null),
          goalUnit: Value(_unit),
          reminderEnabled: Value(_remind),
          reminderConfig: Value(_config.toJson()),
        ),
      );
    } else {
      await repo.addCustom(
        userId: user.id,
        name: name,
        iconKey: _iconKey,
        goalPeriod: _goalOn ? _period : null,
        goalValue: _goalOn ? goal : null,
        goalUnit: _unit,
        reminderEnabled: _remind,
        reminderConfig: _config.toJson(),
      );
    }
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _config.minuteOfDay ~/ 60,
        minute: _config.minuteOfDay % 60,
      ),
    );
    if (t != null) {
      setState(
        () => _config = _config.copyWith(minuteOfDay: t.hour * 60 + t.minute),
      );
    }
  }

  Future<void> _pickStartDate() async {
    final today = await ref.read(todayDateProvider.future);
    if (!mounted) return;
    final cur = parseLocalDate(_config.startDate ?? today);
    final first = parseLocalDate(today);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(cur.year, cur.month, cur.day),
      firstDate: DateTime(first.year, first.month, first.day - 365),
      lastDate: DateTime(first.year + 2, first.month, first.day),
    );
    if (picked != null) {
      setState(
        () => _config = _config.copyWith(
          startDate: formatLocalDate(picked.year, picked.month, picked.day),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit hobby' : 'Add hobby')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(kMinTapTarget),
            ),
            onPressed: _saving ? null : _save,
            child: const Text('Save'),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in hobbyIconChoices.entries)
                Semantics(
                  button: true,
                  selected: _iconKey == e.key,
                  label: 'Icon ${e.key}',
                  child: ChoiceChip(
                    label: Icon(e.value, size: 22),
                    selected: _iconKey == e.key,
                    onSelected: (_) => setState(() => _iconKey = e.key),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Goal'),
            subtitle: const Text('A target for each day or each week'),
            value: _goalOn,
            onChanged: (v) => setState(() => _goalOn = v),
          ),
          if (_goalOn) ..._goalFields(context),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reminder'),
            value: _remind,
            onChanged: (v) => setState(() => _remind = v),
          ),
          if (_remind) ..._reminderFields(context),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _error!,
                style: text.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _goalFields(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return [
      PillTabs<HobbyGoalPeriod>(
        options: const {
          HobbyGoalPeriod.daily: 'Daily',
          HobbyGoalPeriod.weekly: 'Weekly',
        },
        selected: _period,
        onChanged: (v) => setState(() => _period = v),
      ),
      const SizedBox(height: 10),
      PillTabs<HobbyGoalUnit>(
        options: const {
          HobbyGoalUnit.minutes: 'Minutes',
          HobbyGoalUnit.sessions: 'Sessions',
        },
        selected: _unit,
        onChanged: (v) => setState(() {
          _unit = v;
          // A sensible starting number for the new unit.
          if (int.tryParse(_goalValue.text.trim()) == null) {
            _goalValue.text = v == HobbyGoalUnit.minutes ? '30' : '3';
          }
        }),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _goalValue,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: _unit == HobbyGoalUnit.minutes
              ? 'Minutes per ${_period == HobbyGoalPeriod.daily ? 'day' : 'week'}'
              : 'Sessions per ${_period == HobbyGoalPeriod.daily ? 'day' : 'week'}',
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        _period == HobbyGoalPeriod.weekly
            ? 'A weekly goal can be met on any days from Monday to Sunday.'
            : 'A daily goal is checked for each day.',
        style: text.bodySmall,
      ),
    ];
  }

  List<Widget> _reminderFields(BuildContext context) {
    final f = _config.frequency;
    return [
      Wrap(
        spacing: 8,
        children: [
          for (final v in HobbyReminderFrequency.values)
            ChoiceChip(
              label: Text(switch (v) {
                HobbyReminderFrequency.daily => 'Daily',
                HobbyReminderFrequency.weekly => 'Weekly',
                HobbyReminderFrequency.biweekly => 'Biweekly',
                HobbyReminderFrequency.monthly => 'Monthly',
              }),
              selected: f == v,
              onSelected: (_) =>
                  setState(() => _config = _config.copyWith(frequency: v)),
            ),
        ],
      ),
      const SizedBox(height: 4),
      if (f == HobbyReminderFrequency.weekly)
        Wrap(
          spacing: 8,
          children: [
            for (var d = 1; d <= 7; d++)
              ChoiceChip(
                label: Text(weekdayName(d).substring(0, 3)),
                selected: _config.weekday == d,
                onSelected: (_) =>
                    setState(() => _config = _config.copyWith(weekday: d)),
              ),
          ],
        ),
      if (f == HobbyReminderFrequency.biweekly)
        PickerTile(
          label: 'Start date',
          value: _config.startDate ?? 'Choose',
          onTap: _pickStartDate,
        ),
      if (f == HobbyReminderFrequency.monthly) ...[
        PickerTile(
          label: 'Day of month',
          value: '${_config.dayOfMonth}',
          onTap: () async {
            final d = await showDialog<int>(
              context: context,
              builder: (ctx) => SimpleDialog(
                title: const Text('Day of month'),
                children: [
                  SizedBox(
                    width: 280,
                    height: 320,
                    child: GridView.count(
                      crossAxisCount: 7,
                      children: [
                        for (var i = 1; i <= 31; i++)
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, i),
                            child: Text('$i'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
            if (d != null) {
              setState(() => _config = _config.copyWith(dayOfMonth: d));
            }
          },
        ),
        if (_config.dayOfMonth > 28)
          Text(
            'In months without a day ${_config.dayOfMonth}, the reminder '
            'comes on the last day of the month.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
      PickerTile(
        label: 'Time',
        value: formatMinuteOfDay(context, _config.minuteOfDay),
        onTap: _pickTime,
      ),
    ];
  }
}
