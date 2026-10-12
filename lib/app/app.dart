import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/tokens.dart';
import '../core/widgets/app_widgets.dart';
import 'shell.dart';

/// User-selectable theme mode (Settings). Defaults to the phone's setting and
/// remembers the choice.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      for (final m in ThemeMode.values) {
        if (m.name == saved) state = m;
      }
    } catch (_) {
      // Keep following the phone's setting.
    }
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (_) {}
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Whether the welcome screen shows briefly when the app opens. Tests turn it
/// off so they start on Today.
final showSplashProvider = Provider<bool>((ref) => true);

class WellbeingApp extends ConsumerWidget {
  const WellbeingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Well-Being',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
      home: ref.watch(showSplashProvider)
          ? const _SplashGate()
          : const AppShell(),
    );
  }
}

/// Shows the welcome screen for a moment, then the app.
class _SplashGate extends StatefulWidget {
  const _SplashGate();

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  bool _done = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 350),
    child: _done
        ? const AppShell(key: ValueKey('shell'))
        : const SplashScreen(key: ValueKey('splash')),
  );
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SproutIcon(size: 72),
                    const SizedBox(height: 20),
                    Text(
                      'Well Being Companion',
                      textAlign: TextAlign.center,
                      style: text.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Better habits build a happier you',
                      textAlign: TextAlign.center,
                      style: text.bodyLarge?.copyWith(color: t.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const HillsHeader(height: 220, warm: true),
        ],
      ),
    );
  }
}
