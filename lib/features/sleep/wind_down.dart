import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../week/week_providers.dart';

class WindDownItem {
  const WindDownItem(this.id, this.label);
  final String id;
  final String label;
}

const defaultWindDownItems = [
  WindDownItem('screens', 'Screens off'),
  WindDownItem('stretch', 'Stretch'),
  WindDownItem('read', 'Read a book'),
];

class WindDownState {
  const WindDownState({required this.items, required this.checked});

  final List<WindDownItem> items;

  /// Ids ticked today. Resets each day.
  final Set<String> checked;

  WindDownState copyWith({List<WindDownItem>? items, Set<String>? checked}) =>
      WindDownState(
        items: items ?? this.items,
        checked: checked ?? this.checked,
      );
}

const _itemsKey = 'winddown_items';
const _checkedKey = 'winddown_checked_ids';
const _checkedDateKey = 'winddown_checked_date';

/// Optional wind-down checklist (spec 5, Sleep). Items are editable; ticks
/// belong to one day and reset the next. Stored on the device only.
class WindDownNotifier extends AsyncNotifier<WindDownState> {
  @override
  Future<WindDownState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final today = await ref.watch(todayDateProvider.future);

    var items = defaultWindDownItems;
    final raw = prefs.getString(_itemsKey);
    if (raw != null) {
      try {
        items = [
          for (final m in jsonDecode(raw) as List)
            WindDownItem(m['id'] as String, m['label'] as String),
        ];
      } catch (_) {}
    }

    final sameDay = prefs.getString(_checkedDateKey) == today;
    final checked = sameDay
        ? (prefs.getStringList(_checkedKey) ?? const <String>[]).toSet()
        : <String>{};
    return WindDownState(items: items, checked: checked);
  }

  Future<void> _save(WindDownState s) async {
    final prefs = await SharedPreferences.getInstance();
    final today = await ref.read(todayDateProvider.future);
    await prefs.setString(
      _itemsKey,
      jsonEncode([
        for (final i in s.items) {'id': i.id, 'label': i.label},
      ]),
    );
    await prefs.setStringList(_checkedKey, s.checked.toList());
    await prefs.setString(_checkedDateKey, today);
    state = AsyncData(s);
  }

  Future<void> toggle(String id) async {
    final s = state.value;
    if (s == null) return;
    final checked = {...s.checked};
    checked.contains(id) ? checked.remove(id) : checked.add(id);
    await _save(s.copyWith(checked: checked));
  }

  Future<void> add(String label) async {
    final s = state.value;
    final text = label.trim();
    if (s == null || text.isEmpty) return;
    await _save(
      s.copyWith(items: [...s.items, WindDownItem(const Uuid().v4(), text)]),
    );
  }

  Future<void> rename(String id, String label) async {
    final s = state.value;
    final text = label.trim();
    if (s == null || text.isEmpty) return;
    await _save(
      s.copyWith(
        items: [
          for (final i in s.items) i.id == id ? WindDownItem(id, text) : i,
        ],
      ),
    );
  }

  Future<void> remove(String id) async {
    final s = state.value;
    if (s == null) return;
    await _save(
      s.copyWith(
        items: s.items.where((i) => i.id != id).toList(),
        checked: {...s.checked}..remove(id),
      ),
    );
  }
}

final windDownProvider = AsyncNotifierProvider<WindDownNotifier, WindDownState>(
  WindDownNotifier.new,
);
