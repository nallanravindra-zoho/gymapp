import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/section_theme.dart';
import '../../core/theme/tokens.dart';
import 'sleep_log_sheet.dart';
import 'sleep_logic.dart';
import 'sleep_providers.dart';
import 'sleep_screen.dart';

/// Today's sleep: last night's log, or `Log sleep`. Tap opens the Sleep screen.
class SleepCard extends ConsumerWidget {
  const SleepCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last = ref.watch(lastNightProvider);
    final t = context.tokens;

    return SectionTheme(
      section: AppSection.sleep,
      child: Builder(
        builder: (context) {
          final text = Theme.of(context).textTheme;
          return Card(
            color: t.tintSleep,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SleepScreen()),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.bedtime_outlined, color: t.textMuted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sleep', style: text.titleLarge),
                          const SizedBox(height: 4),
                          if (last != null)
                            Text(
                              formatSleepDuration(last.durationMinutes),
                              style: text.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                    if (last == null)
                      TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, kMinTapTarget),
                        ),
                        onPressed: () => showSleepLogSheet(context),
                        child: const Text('Log sleep'),
                      )
                    else
                      Icon(Icons.chevron_right_rounded, color: t.textMuted),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
