import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/widgets/app_widgets.dart';
import '../../data/app_database.dart';
import '../../data/providers.dart';
import '../goals/goal_providers.dart';
import 'food_list.dart';
import 'nutrition_logic.dart';
import 'nutrition_providers.dart';

/// Nutrition for the pilot: log what you eat by hand, count servings against
/// a daily goal, and see calories and macronutrients as estimates where they
/// are known. Photo recognition is a later phase.
class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(todayMealsProvider).value ?? const <MealLog>[];
    final recent = ref.watch(recentMealsProvider).value ?? const <MealLog>[];
    final target = ref.watch(nutritionGoalProvider).value;
    final totals = totalsOf(meals);
    final common = commonMeals(recent);
    final text = Theme.of(context).textTheme;
    final t = context.tokens;

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddMeal(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add meal'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.paddingOf(context).bottom + 96,
        ),
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Today', style: text.titleMedium)),
                    TextButton(
                      onPressed: () => showNutritionGoal(context),
                      child: Text(target == null ? 'Set a goal' : 'Edit goal'),
                    ),
                  ],
                ),
                Text(
                  target == null
                      ? servingsText(totals.servings)
                      : '${_n(totals.servings)} of $target servings',
                  style: text.headlineSmall,
                ),
                if (target != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (totals.servings / target).clamp(0, 1).toDouble(),
                      minHeight: 8,
                      backgroundColor: t.track,
                      color: t.cat(Cat.streak).icon,
                    ),
                  ),
                ],
                if (totals.calories != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '${kcalText(totals.calories!)}  •  '
                    'protein ${_g(totals.proteinG)}  •  '
                    'carbs ${_g(totals.carbsG)}  •  '
                    'fat ${_g(totals.fatG)}',
                    key: const Key('nutrition-totals'),
                    style: text.bodyMedium,
                  ),
                  Text(
                    'Estimates from the values on each meal.'
                    '${totals.withoutValues > 0 ? ' ${totals.withoutValues} without values are not counted.' : ''}',
                    style: text.bodySmall?.copyWith(color: t.textMuted),
                  ),
                ],
              ],
            ),
          ),
          if (common.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Add again', style: text.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in common)
                  ActionChip(
                    key: Key('again-${m.name}'),
                    label: Text(m.name),
                    onPressed: () => _again(context, ref, m),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Text('Meals today', style: text.titleMedium),
          const SizedBox(height: 8),
          if (meals.isEmpty)
            Text(
              'No meals logged today.',
              style: text.bodyMedium?.copyWith(color: t.textMuted),
            )
          else
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  for (var i = 0; i < meals.length; i++) ...[
                    _MealRow(meal: meals[i]),
                    if (i < meals.length - 1) const RowDivider(),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _again(BuildContext context, WidgetRef ref, MealLog m) async {
    final user = await ref.read(currentUserProvider.future);
    await ref
        .read(mealRepositoryProvider)
        .add(
          userId: user.id,
          dayCutoffMinutes: user.dayCutoffMinutes,
          name: m.name,
          servings: m.servings,
          calories: m.calories,
          proteinG: m.proteinG,
          carbsG: m.carbsG,
          fatG: m.fatG,
          source: m.source,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text('Logged. ${m.name}.')));
    }
  }
}

String _n(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

String _g(double v) => '${_n(v)} g';

class _MealRow extends ConsumerWidget {
  const _MealRow({required this.meal});

  final MealLog meal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    final bits = [
      servingsText(meal.servings),
      if (meal.calories != null) kcalText(meal.calories!),
      if (meal.source == 'listed') 'from the food list',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.name, style: text.titleSmall),
                Text(
                  bits.join('  •  '),
                  style: text.bodySmall?.copyWith(color: t.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove ${meal.name}',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () async {
              await ref.read(mealRepositoryProvider).delete(meal.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    const SnackBar(content: Text('Entry removed.')),
                  );
              }
            },
          ),
        ],
      ),
    );
  }
}

Future<void> showAddMeal(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => const AddMealSheet(),
);

Future<void> showNutritionGoal(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const NutritionGoalSheet(),
    );

/// Servings a day for the nutrition goal.
class NutritionGoalSheet extends ConsumerStatefulWidget {
  const NutritionGoalSheet({super.key});

  @override
  ConsumerState<NutritionGoalSheet> createState() => _NutritionGoalSheetState();
}

class _NutritionGoalSheetState extends ConsumerState<NutritionGoalSheet> {
  int? _servings;

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(nutritionGoalProvider).value;
    final n = _servings ?? saved ?? 5;
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Nutrition goal', style: text.titleLarge),
          const SizedBox(height: 4),
          Text(
            'A serving is whatever you count as one. This goal counts '
            'servings, not calories.',
            style: text.bodyMedium?.copyWith(color: t.textMuted),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                tooltip: 'Fewer servings',
                onPressed: n > 1
                    ? () => setState(() => _servings = n - 1)
                    : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              SizedBox(
                width: 150,
                child: Column(
                  children: [
                    Text('$n', style: text.displaySmall),
                    Text(
                      n == 1 ? 'serving daily' : 'servings daily',
                      style: text.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'More servings',
                onPressed: n < 12
                    ? () => setState(() => _servings = n + 1)
                    : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () async {
              await ref.read(nutritionGoalProvider.notifier).set(n);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
          if (saved != null)
            TextButton(
              onPressed: () async {
                await ref.read(nutritionGoalProvider.notifier).set(null);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Remove goal'),
            ),
        ],
      ),
    );
  }
}

/// Log a meal: a name (with suggestions from the food list), servings, and
/// optional calories and macronutrients.
class AddMealSheet extends ConsumerStatefulWidget {
  const AddMealSheet({super.key});

  @override
  ConsumerState<AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends ConsumerState<AddMealSheet> {
  final _name = TextEditingController();
  final _calories = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();
  double _servings = 1;
  FoodItem? _food;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _calories.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    super.dispose();
  }

  /// Fills the value fields from the chosen food for the current servings.
  void _fill() {
    final f = _food;
    if (f == null) return;
    final s = scaleFood(f, _servings);
    _calories.text = '${s.calories}';
    _protein.text = _n(s.proteinG);
    _carbs.text = _n(s.carbsG);
    _fat.text = _n(s.fatG);
  }

  void _pick(FoodItem f) {
    setState(() {
      _food = f;
      _name.text = f.name;
      _fill();
    });
  }

  void _setServings(double v) {
    setState(() {
      _servings = v;
      _fill();
    });
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() => _saving = true);
    final user = await ref.read(currentUserProvider.future);
    // Values stay tied to the list only while the name still matches it.
    final listed = _food != null && _food!.name == name;
    await ref
        .read(mealRepositoryProvider)
        .add(
          userId: user.id,
          dayCutoffMinutes: user.dayCutoffMinutes,
          name: name,
          servings: _servings,
          calories: int.tryParse(_calories.text.trim()),
          proteinG: double.tryParse(_protein.text.trim()),
          carbsG: double.tryParse(_carbs.text.trim()),
          fatG: double.tryParse(_fat.text.trim()),
          source: listed ? 'listed' : 'entered',
        );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text('Logged. $name.')));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = context.tokens;
    final matches = searchFoods(_name.text);
    final showMatches =
        matches.isNotEmpty &&
        !(matches.length == 1 && matches.first.name == _name.text.trim());

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add meal', style: text.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'What did you eat?'),
            onChanged: (_) => setState(() {
              if (_food != null && _food!.name != _name.text.trim()) {
                _food = null;
              }
            }),
          ),
          if (showMatches)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                children: [
                  for (final f in matches.take(5))
                    ActionChip(
                      key: Key('food-${f.name}'),
                      label: Text('${f.name} (${f.serving})'),
                      onPressed: () => _pick(f),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                tooltip: 'Fewer servings',
                onPressed: _servings > 0.5
                    ? () => _setServings(_servings - 0.5)
                    : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              SizedBox(
                width: 160,
                child: Text(
                  servingsText(_servings),
                  textAlign: TextAlign.center,
                  style: text.titleMedium,
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'More servings',
                onPressed: _servings < 10
                    ? () => _setServings(_servings + 0.5)
                    : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _food == null
                ? 'Calories and macronutrients are optional.'
                : '$foodListNote Change them if you know better.',
            style: text.bodySmall?.copyWith(color: t.textMuted),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _num(_calories, 'Calories', 'kcal')),
              const SizedBox(width: 8),
              Expanded(child: _num(_protein, 'Protein', 'g')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _num(_carbs, 'Carbs', 'g')),
              const SizedBox(width: 8),
              Expanded(child: _num(_fat, 'Fat', 'g')),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _name.text.trim().isEmpty || _saving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _num(TextEditingController c, String label, String suffix) =>
      TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, suffixText: suffix),
      );
}
