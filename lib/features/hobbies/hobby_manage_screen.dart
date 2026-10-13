import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/dialogs.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import 'hobby_logic.dart';
import 'hobby_providers.dart';
import 'hobby_reminders.dart';
import 'hobby_setup_screen.dart';
import 'hobby_widgets.dart';

/// Manage hobbies: the list with goal and reminder at a glance, Add hobby,
/// and archived hobbies that can be restored.
class HobbyManageScreen extends ConsumerWidget {
  const HobbyManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    final hobbies = ref.watch(activeHobbiesProvider).value ?? const <Hobby>[];
    final archived =
        ref.watch(archivedHobbiesProvider).value ?? const <Hobby>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Manage hobbies')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          for (final h in hobbies) ...[
            _ManageRow(hobby: h),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 4),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const HobbySetupScreen()),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add hobby'),
          ),
          if (archived.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Archived', style: text.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Archived hobbies keep their history and are hidden from the list.',
              style: text.bodySmall?.copyWith(color: t.textMuted),
            ),
            const SizedBox(height: 8),
            for (final h in archived)
              ListTile(
                contentPadding: EdgeInsets.zero,
                minTileHeight: 56,
                leading: TintedIcon(
                  icon: hobbyIcon(h.iconKey),
                  cat: Cat.hobby,
                  size: 44,
                ),
                title: Text(h.name),
                trailing: TextButton(
                  onPressed: () =>
                      ref.read(hobbyRepositoryProvider).unarchive(h.id),
                  child: const Text('Restore'),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ManageRow extends ConsumerWidget {
  const _ManageRow({required this.hobby});
  final Hobby hobby;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final goal = HobbyGoal.of(hobby);
    final goalText = goal == null ? 'No goal' : goal.describe();
    final remindText = hobby.reminderEnabled
        ? describeHobbyReminder(
            HobbyReminderConfig.fromJson(hobby.reminderConfig),
          )
        : 'Reminder off';
    return SoftCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HobbySetupScreen(existing: hobby),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
      child: Row(
        children: [
          TintedIcon(icon: hobbyIcon(hobby.iconKey), cat: Cat.hobby, size: 50),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hobby.name, style: text.titleMedium),
                const SizedBox(height: 2),
                Text('$goalText  •  $remindText', style: text.bodySmall),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Archive ${hobby.name}',
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: Icon(Icons.archive_outlined, color: t.textMuted),
            onPressed: () async {
              final ok = await confirm(
                context,
                title: 'Archive ${hobby.name}?',
                body:
                    'It is hidden from your list and its reminders stop. '
                    'Your history is kept, and you can restore it later.',
                action: 'Archive',
              );
              if (ok) await ref.read(hobbyRepositoryProvider).archive(hobby.id);
            },
          ),
        ],
      ),
    );
  }
}
