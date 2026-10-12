import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import 'chant_screen.dart';

/// Hobbies: things to do for yourself that are not exercise. Om chanting is
/// the first.
class HobbiesScreen extends StatelessWidget {
  const HobbiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hobbies'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            'Time for yourself, counted gently.',
            style: text.bodyMedium?.copyWith(color: t.textMuted),
          ),
          const SizedBox(height: 16),
          SoftCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ChantScreen()),
            ),
            child: Row(
              children: [
                const TintedIcon(
                  icon: Icons.self_improvement_rounded,
                  cat: Cat.hobby,
                  size: 48,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Om chanting', style: text.titleMedium),
                      Text(
                        'Counts your chants by listening, with reminders',
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: t.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
