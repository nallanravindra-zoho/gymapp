import 'package:drift/drift.dart' show Value;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../../data/sync/local_reset.dart';
import '../../core/widgets/dialogs.dart';
import '../account/profile_services.dart';
import '../account/sync_providers.dart';
import '../../core/time/local_date.dart';
import '../metrics/bmi_card.dart';
import '../metrics/metrics_charts.dart' show chartDate;
import '../metrics/metrics_logic.dart';
import '../metrics/metrics_providers.dart';
import '../reminders/reminder_providers.dart';
import '../groups/groups_providers.dart';
import '../groups/groups_widgets.dart';
import '../reminders/reminder_planner.dart';
import '../streaks/streak_providers.dart';
import 'data_export.dart';

/// Profile, appearance, reminder and streak settings, and the person's data:
/// export, erase on this phone, delete the account.
enum SettingsSection {
  profile('My profile'),
  metrics('Personal metrics'),
  appearance('Appearance'),
  reminders('Reminders'),
  preferences('Goals & preferences'),
  data('Privacy & data');

  const SettingsSection(this.title);
  final String title;
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, this.section});

  /// Which part to show; null shows everything.
  final SettingsSection? section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStreamProvider).value;
    final signedIn = ref.watch(authUserProvider).value != null;
    final text = Theme.of(context).textTheme;

    const sectionOf = {
      'Profile': SettingsSection.profile,
      'Personal metrics': SettingsSection.metrics,
      'Appearance': SettingsSection.appearance,
      'Streaks': SettingsSection.preferences,
      'Day': SettingsSection.preferences,
      'Week calendar': SettingsSection.preferences,
      'Reminders': SettingsSection.reminders,
      'Your data': SettingsSection.data,
    };
    Widget block(String title, List<Widget> children, {String? note}) =>
        section != null && sectionOf[title] != section
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(title, style: text.titleLarge),
              if (note != null) ...[
                const SizedBox(height: 4),
                Text(
                  note,
                  style: text.bodySmall?.copyWith(
                    color: context.tokens.textMuted,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Card(child: Column(children: children)),
            ],
          );

    return Scaffold(
      appBar: AppBar(title: Text(section?.title ?? 'Settings')),
      body: user == null
          ? const SizedBox.shrink()
          : ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              children: [
                block(
                  'Profile',
                  [
                    const _PhotoTile(),
                    _NameTile(user: user),
                    _DobTile(user: user),
                    const _AgeTile(),
                    _GenderTile(user: user),
                  ],
                  note:
                      'Your name is shown to members of your groups. Date of '
                      'birth, gender and picture stay private on this phone '
                      'and are not shared with groups.',
                ),
                block('Personal metrics', [
                  _NumberTile(
                    title: 'Height',
                    unit: 'cm',
                    value: user.heightCm,
                    min: 30,
                    max: 272,
                    onSave: (v) =>
                        _save(ref, user, UsersCompanion(heightCm: Value(v))),
                  ),
                  _NumberTile(
                    title: 'Weight',
                    unit: 'kg',
                    value: user.weightKg,
                    min: 1,
                    max: 500,
                    onSave: (v) =>
                        _save(ref, user, UsersCompanion(weightKg: Value(v))),
                  ),
                ], note: 'Private to you. Never shared with groups.'),
                if (section == SettingsSection.metrics) ...[
                  const SizedBox(height: 16),
                  const BmiCard(),
                ],
                block('Appearance', [const _ThemeTile()]),
                block(
                  'Reminders',
                  [
                    const _PermissionWarning(),
                    _SoundTile(user: user),
                    _QuietHoursTile(user: user, start: true),
                    _QuietHoursTile(user: user, start: false),
                    _StepperTile(
                      title: 'Most reminders in a day',
                      value: user.dailyReminderCap,
                      min: 1,
                      max: 12,
                      format: (v) => '$v',
                      onChanged: (v) => _save(
                        ref,
                        user,
                        UsersCompanion(dailyReminderCap: Value(v)),
                      ),
                    ),
                  ],
                  note:
                      'No reminders are sent during quiet hours. If more are '
                      'due than the daily limit, the least important are dropped.',
                ),
                block('Streaks', [
                  _StepperTile(
                    title: 'Rest days per week',
                    value: user.weeklyRestDays,
                    min: 0,
                    max: 4,
                    format: (v) => '$v',
                    onChanged: (v) => _save(
                      ref,
                      user,
                      UsersCompanion(weeklyRestDays: Value(v)),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Streak freeze'),
                    subtitle: const Text(
                      'A missed day can be covered once per interval.',
                    ),
                    value: user.freezeEnabled,
                    onChanged: (v) => _save(
                      ref,
                      user,
                      UsersCompanion(freezeEnabled: Value(v)),
                    ),
                  ),
                  if (user.freezeEnabled)
                    _StepperTile(
                      title: 'Freeze interval',
                      value: user.freezeIntervalDays,
                      min: 3,
                      max: 30,
                      format: (v) => '$v days',
                      onChanged: (v) => _save(
                        ref,
                        user,
                        UsersCompanion(freezeIntervalDays: Value(v)),
                      ),
                    ),
                ], note: 'Changes apply to your streaks straight away.'),
                block(
                  'Week calendar',
                  [
                    _StepperTile(
                      title: 'Habits needed for a day icon',
                      value: user.habitThreshold,
                      min: 1,
                      max: 10,
                      format: (v) => '$v',
                      onChanged: (v) => _save(
                        ref,
                        user,
                        UsersCompanion(habitThreshold: Value(v)),
                      ),
                    ),
                  ],
                  note:
                      'A day shows the Healthy Habits icon once at least this '
                      'many active habits reached their daily target.',
                ),
                block(
                  'Day',
                  [
                    _StepperTile(
                      title: 'A new day starts at',
                      value: user.dayCutoffMinutes ~/ 60,
                      min: 0,
                      max: 5,
                      format: (v) => '${v.toString().padLeft(2, '0')}:00',
                      onChanged: (v) => _save(
                        ref,
                        user,
                        UsersCompanion(dayCutoffMinutes: Value(v * 60)),
                      ),
                    ),
                  ],
                  note:
                      'Entries before this time count towards the previous '
                      'day. Entries already logged keep their day.',
                ),
                block('Your data', [
                  ListTile(
                    minTileHeight: kMinTapTarget + 8,
                    title: const Text('Export all data'),
                    subtitle: const Text('Everything on this phone, as JSON.'),
                    trailing: const Icon(Icons.ios_share_outlined),
                    onTap: () => _export(context, ref, json: true),
                  ),
                  ListTile(
                    minTileHeight: kMinTapTarget + 8,
                    title: const Text('Export workouts'),
                    subtitle: const Text('A spreadsheet (CSV), one row each.'),
                    trailing: const Icon(Icons.ios_share_outlined),
                    onTap: () => _export(context, ref, json: false),
                  ),
                  if (!signedIn)
                    ListTile(
                      minTileHeight: kMinTapTarget + 8,
                      title: const Text('Erase data on this phone'),
                      subtitle: const Text(
                        'Removes your entries and settings from this phone.',
                      ),
                      onTap: () => _erase(context, ref, user),
                    ),
                  if (signedIn)
                    ListTile(
                      minTileHeight: kMinTapTarget + 8,
                      title: Text(
                        'Delete account',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      subtitle: const Text(
                        'Removes your account and its data from the server.',
                      ),
                      onTap: () => _deleteAccount(context, ref),
                    ),
                ]),
              ],
            ),
    );
  }
}

Future<void> _save(WidgetRef ref, User user, UsersCompanion changes) =>
    ref.read(userRepositoryProvider).update(user.id, changes);

void _say(BuildContext context, String message) => ScaffoldMessenger.of(context)
  ..clearSnackBars()
  ..showSnackBar(SnackBar(content: Text(message)));

Future<void> _export(
  BuildContext context,
  WidgetRef ref, {
  required bool json,
}) async {
  try {
    final db = ref.read(databaseProvider);
    final now = ref.read(clockProvider).now();
    final export = json
        ? await buildJsonExport(db, now)
        : await buildWorkoutsCsv(db, now);
    await ref.read(exportSinkProvider).deliver(export);
  } catch (_) {
    if (context.mounted) _say(context, 'Could not create the file. Try again.');
  }
}

Future<void> _erase(BuildContext context, WidgetRef ref, User user) async {
  final ok = await confirm(
    context,
    title: 'Erase data on this phone?',
    body:
        'Your workouts, habits, sleep, screen time and settings on this phone '
        'will be removed. This cannot be undone.',
    action: 'Erase',
  );
  if (!ok || !context.mounted) return;
  final store = ref.read(syncStateProvider);
  await wipeLocalAccountData(ref.read(databaseProvider), user.id);
  await store.reset();
  await store.setAccountId(null);
  if (context.mounted) _say(context, 'Data on this phone erased.');
}

Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
  final ok = await confirm(
    context,
    title: 'Delete your account?',
    body:
        'This removes your account and everything stored for it on the '
        'server, including your place in groups. Data on this phone stays. '
        'This cannot be undone.',
    action: 'Delete account',
  );
  if (!ok || !context.mounted) return;
  final deleted = await ref.read(authServiceProvider).deleteAccount();
  if (!context.mounted) return;
  if (!deleted) {
    _say(
      context,
      'Could not delete the account. Check your connection and try again.',
    );
    return;
  }
  // The next account to sign in on this phone starts from what is here.
  final store = ref.read(syncStateProvider);
  await store.reset();
  await store.setAccountId(null);
  ref.invalidate(groupsListProvider);
  if (context.mounted) {
    _say(context, 'Account deleted. Your data is still on this phone.');
  }
}

class _NameTile extends ConsumerWidget {
  const _NameTile({required this.user});
  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      minTileHeight: kMinTapTarget + 8,
      title: const Text('Name'),
      subtitle: Text(user.displayName.isEmpty ? 'Not set' : user.displayName),
      trailing: const Icon(Icons.edit_outlined),
      onTap: () async {
        final name = await showDialog<String>(
          context: context,
          builder: (_) => TextPromptDialog(
            title: 'Your name',
            label: 'Name',
            action: 'Save',
            initial: user.displayName,
            maxLength: 40,
          ),
        );
        if (name != null) {
          await _save(ref, user, UsersCompanion(displayName: Value(name)));
        }
      },
    );
  }
}

class _ThemeTile extends ConsumerWidget {
  const _ThemeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(value: ThemeMode.system, label: Text('System')),
          ButtonSegment(value: ThemeMode.light, label: Text('Light')),
          ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
        ],
        selected: {mode},
        onSelectionChanged: (s) =>
            ref.read(themeModeProvider.notifier).set(s.first),
      ),
    );
  }
}

class _QuietHoursTile extends ConsumerWidget {
  const _QuietHoursTile({required this.user, required this.start});
  final User user;
  final bool start;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minutes = start
        ? user.quietHoursStart ?? defaultQuietStart
        : user.quietHoursEnd ?? defaultQuietEnd;
    return ListTile(
      minTileHeight: kMinTapTarget + 8,
      title: Text(start ? 'Quiet hours start' : 'Quiet hours end'),
      trailing: Text(
        TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60).format(context),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
        );
        if (picked == null) return;
        final value = picked.hour * 60 + picked.minute;
        await _save(
          ref,
          user,
          start
              ? UsersCompanion(quietHoursStart: Value(value))
              : UsersCompanion(quietHoursEnd: Value(value)),
        );
      },
    );
  }
}

/// A number with minus and plus buttons, for small bounded settings.
class _StepperTile extends StatelessWidget {
  const _StepperTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.format,
    required this.onChanged,
  });

  final String title;
  final int value;
  final int min;
  final int max;
  final String Function(int) format;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: kMinTapTarget + 8,
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Less: $title',
            constraints: const BoxConstraints(
              minWidth: kMinTapTarget,
              minHeight: kMinTapTarget,
            ),
            icon: const Icon(Icons.remove),
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 64,
            child: Text(
              format(value),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: 'More: $title',
            constraints: const BoxConstraints(
              minWidth: kMinTapTarget,
              minHeight: kMinTapTarget,
            ),
            icon: const Icon(Icons.add),
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

const _genders = {
  'female': 'Female',
  'male': 'Male',
  'non_binary': 'Non-binary',
  'prefer_not_to_say': 'Prefer not to say',
};

class _PhotoTile extends ConsumerWidget {
  const _PhotoTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStreamProvider).value;
    final path = user?.avatarUrl;
    final t = context.tokens;
    final has = path != null && path.isNotEmpty;
    return ListTile(
      minTileHeight: kMinTapTarget + 16,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: t.cat(Cat.leaf).tint,
        backgroundImage: has && File(path).existsSync()
            ? FileImage(File(path))
            : null,
        child: has && File(path).existsSync()
            ? null
            : Icon(Icons.person_rounded, color: t.cat(Cat.leaf).icon),
      ),
      title: const Text('Profile picture'),
      subtitle: Text(has ? 'Chosen from your gallery' : 'Choose from gallery'),
      trailing: has
          ? IconButton(
              tooltip: 'Remove profile picture',
              constraints: const BoxConstraints(
                minWidth: kMinTapTarget,
                minHeight: kMinTapTarget,
              ),
              icon: const Icon(Icons.close_rounded),
              onPressed: () async {
                await ref.read(profilePhotoStoreProvider).remove(path);
                await _save(
                  ref,
                  user!,
                  const UsersCompanion(avatarUrl: Value(null)),
                );
              },
            )
          : const Icon(Icons.photo_library_outlined),
      onTap: () async {
        if (user == null) return;
        final store = ref.read(profilePhotoStoreProvider);
        String? picked;
        try {
          picked = await store.chooseFromGallery();
        } catch (_) {
          if (context.mounted) {
            _say(context, 'Could not open your gallery. Try again.');
          }
          return;
        }
        if (picked == null) return;
        if (has && path != picked) await store.remove(path);
        await _save(ref, user, UsersCompanion(avatarUrl: Value(picked)));
      },
    );
  }
}

class _DobTile extends ConsumerWidget {
  const _DobTile({required this.user});
  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dob = user.dateOfBirth;
    return ListTile(
      minTileHeight: kMinTapTarget + 8,
      title: const Text('Date of birth'),
      subtitle: Text(dob == null ? 'Not set' : chartDate(dob)),
      trailing: const Icon(Icons.calendar_today_outlined),
      onTap: () async {
        final now = ref.read(clockProvider).now().toLocal();
        final initial = dob == null
            ? DateTime(now.year - 30, now.month, now.day)
            : DateTime.parse(dob);
        final d = await showDatePicker(
          context: context,
          initialDate: initial.isAfter(now) ? now : initial,
          firstDate: DateTime(1900),
          lastDate: now,
          helpText: 'Date of birth',
        );
        if (d == null) return;
        await _save(
          ref,
          user,
          UsersCompanion(
            dateOfBirth: Value(formatLocalDate(d.year, d.month, d.day)),
          ),
        );
      },
    );
  }
}

/// Age is calculated from the date of birth; it is never typed or stored.
class _AgeTile extends ConsumerWidget {
  const _AgeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final age = ref.watch(userAgeProvider);
    return ListTile(
      minTileHeight: kMinTapTarget + 8,
      title: const Text('Age'),
      subtitle: const Text('Worked out from your date of birth'),
      trailing: Text(
        age == null ? 'Not set' : '$age',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _GenderTile extends ConsumerWidget {
  const _GenderTile({required this.user});
  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      minTileHeight: kMinTapTarget + 8,
      title: const Text('Gender (optional)'),
      subtitle: Text(_genders[user.gender] ?? 'Not set'),
      trailing: const Icon(Icons.edit_outlined),
      onTap: () async {
        final picked = await showDialog<String>(
          context: context,
          builder: (ctx) => SimpleDialog(
            title: const Text('Gender'),
            children: [
              for (final e in _genders.entries)
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, e.key),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(e.value),
                  ),
                ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, ''),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('Not set'),
                ),
              ),
            ],
          ),
        );
        if (picked == null) return;
        await _save(
          ref,
          user,
          UsersCompanion(gender: Value(picked.isEmpty ? null : picked)),
        );
      },
    );
  }
}

/// A single optional decimal value (height, weight).
class _NumberTile extends StatelessWidget {
  const _NumberTile({
    required this.title,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    required this.onSave,
  });

  final String title;
  final String unit;
  final double? value;
  final double min;
  final double max;
  final ValueChanged<double> onSave;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: kMinTapTarget + 8,
      title: Text(title),
      subtitle: Text(
        value == null ? 'Not set' : '${formatNumber(value!)} $unit',
      ),
      trailing: const Icon(Icons.edit_outlined),
      onTap: () async {
        final raw = await showDialog<String>(
          context: context,
          builder: (_) => TextPromptDialog(
            title: title,
            label: '$title ($unit)',
            action: 'Save',
            initial: value == null ? '' : formatNumber(value!),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        );
        if (raw == null) return;
        final v = parseNumber(raw);
        if (v == null || v < min || v > max) {
          if (context.mounted) {
            _say(
              context,
              'Enter a number from ${formatNumber(min)} to ${formatNumber(max)}.',
            );
          }
          return;
        }
        onSave(v);
      },
    );
  }
}

/// Reminder sound: the phone's default, or one chosen in the Android picker.
class _SoundTile extends ConsumerWidget {
  const _SoundTile({required this.user});
  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uri = user.reminderSound;
    return ListTile(
      minTileHeight: kMinTapTarget + 8,
      title: const Text('Reminder sound'),
      subtitle: uri == null
          ? const Text('Phone default')
          : FutureBuilder<String?>(
              key: ValueKey(uri),
              future: ref.read(ringtonePickerProvider).titleOf(uri),
              builder: (_, snap) => Text(snap.data ?? 'Chosen sound'),
            ),
      trailing: uri == null
          ? const Icon(Icons.music_note_outlined)
          : IconButton(
              tooltip: 'Use phone default sound',
              constraints: const BoxConstraints(
                minWidth: kMinTapTarget,
                minHeight: kMinTapTarget,
              ),
              icon: const Icon(Icons.restart_alt_rounded),
              onPressed: () => _save(
                ref,
                user,
                const UsersCompanion(reminderSound: Value(null)),
              ),
            ),
      onTap: () async {
        final choice = await ref.read(ringtonePickerProvider).pick(uri);
        if (choice == null) return;
        await _save(
          ref,
          user,
          UsersCompanion(reminderSound: Value(choice.uri)),
        );
      },
    );
  }
}

/// Shown when the phone no longer allows notifications. Settings stay saved;
/// this only points to where to switch them back on.
class _PermissionWarning extends ConsumerStatefulWidget {
  const _PermissionWarning();

  @override
  ConsumerState<_PermissionWarning> createState() => _PermissionWarningState();
}

class _PermissionWarningState extends ConsumerState<_PermissionWarning>
    with WidgetsBindingObserver {
  bool? _allowed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    final ok = await ref.read(notificationSchedulerProvider).hasPermission();
    if (mounted) setState(() => _allowed = ok);
  }

  @override
  Widget build(BuildContext context) {
    if (_allowed != false) return const SizedBox.shrink();
    final t = context.tokens;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.cat(Cat.streak).tint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.notifications_off_outlined,
                color: t.cat(Cat.streak).icon,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Notifications are turned off for this app on your phone. '
                  'Your reminder settings are kept, and reminders will not '
                  'arrive until you allow notifications again.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(0, kMinTapTarget),
            ),
            onPressed: () =>
                ref.read(systemSettingsProvider).openNotificationSettings(),
            child: const Text('Open phone settings'),
          ),
        ],
      ),
    );
  }
}
