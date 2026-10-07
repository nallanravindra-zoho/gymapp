import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import 'screen_time_logic.dart';
import 'screen_time_providers.dart';
import 'screen_time_screen.dart';

/// Today's screen time, or a prompt to set it up. Tap opens the full screen.
class ScreenTimeCard extends ConsumerWidget {
  const ScreenTimeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final granted = ref.watch(screenTimeAccessProvider).value ?? false;
    final row = ref.watch(screenTimeTodayProvider);
    final goal = ref.watch(screenTimeGoalProvider).value;
    final text = Theme.of(context).textTheme;
    final t = context.tokens;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ScreenTimeScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.smartphone_outlined, color: t.textMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Screen time', style: text.titleLarge),
                    if (granted) ...[
                      const SizedBox(height: 4),
                      Text(
                        goal == null
                            ? formatScreenTime(row?.totalMinutes ?? 0)
                            : '${formatScreenTime(row?.totalMinutes ?? 0)} of ${formatScreenTime(goal)}',
                        style: text.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              if (!granted)
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, kMinTapTarget),
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ScreenTimeScreen(),
                    ),
                  ),
                  child: const Text('Set up'),
                )
              else
                Icon(Icons.chevron_right_rounded, color: t.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
