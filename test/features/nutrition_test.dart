import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wellbeing/data/app_database.dart';
import 'package:wellbeing/features/nutrition/food_list.dart';
import 'package:wellbeing/features/nutrition/nutrition_logic.dart';

import '../test_helpers.dart';

MealLog meal(
  String name, {
  double servings = 1,
  int? calories,
  double? p,
  double? c,
  double? f,
  int minute = 0,
}) => MealLog(
  id: '$name-$minute',
  createdAt: DateTime.utc(2026, 5, 13),
  updatedAt: DateTime.utc(2026, 5, 13),
  deletedAt: null,
  userId: 'u',
  name: name,
  servings: servings,
  calories: calories,
  proteinG: p,
  carbsG: c,
  fatG: f,
  source: 'entered',
  loggedAt: DateTime.utc(2026, 5, 13, 8, minute),
  tzOffsetMinutes: 0,
  localDate: '2026-05-13',
);

Future<void> openNutrition(WidgetTester tester) async {
  await tester.tap(find.text('Goals'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Nutrition'));
  await tester.pumpAndSettle();
}

void main() {
  group('logic', () {
    test('values scale with servings and stay rounded', () {
      final dal = builtinFoods.firstWhere((f) => f.name == 'Dal, cooked');
      final s = scaleFood(dal, 1.5);
      expect(s.calories, 270);
      expect(s.proteinG, 18);
      expect(s.carbsG, 45);
      expect(s.fatG, 1.5);
    });

    test('food search ignores case and needs text', () {
      expect(searchFoods('ROT').map((f) => f.name), ['Roti (chapati)']);
      expect(searchFoods('  '), isEmpty);
      expect(searchFoods('zzz'), isEmpty);
    });

    test('every listed food has sane values', () {
      expect(
        builtinFoods.map((f) => f.name).toSet().length,
        builtinFoods.length,
      );
      for (final f in builtinFoods) {
        expect(f.calories, greaterThan(0), reason: f.name);
        // Energy should roughly agree with the macros (4, 4 and 9 kcal per g).
        final fromMacros = f.proteinG * 4 + f.carbsG * 4 + f.fatG * 9;
        expect(
          (fromMacros - f.calories).abs() / f.calories,
          lessThan(0.25),
          reason: '${f.name} calories do not match its macros',
        );
      }
    });

    test('totals add values where present and say what was left out', () {
      final t = totalsOf([
        meal('a', servings: 1.5, calories: 270, p: 18, c: 45, f: 1.5),
        meal('b', calories: 78, p: 6, c: 0.6, f: 5),
        meal('c'),
      ]);
      expect(t.servings, 3.5);
      expect(t.calories, 348);
      expect(t.proteinG, 24);
      expect(t.withoutValues, 1);
      expect(totalsOf([meal('x')]).calories, isNull);
      expect(totalsOf(const []).servings, 0);
    });

    test('common meals are the most frequent, newest example each', () {
      final logs = [
        meal('Dal', calories: 180, minute: 1),
        meal('dal', calories: 200, minute: 5),
        meal('Idli', minute: 2),
        meal('Apple', minute: 3),
        meal('Apple', minute: 4),
        meal('Apple', minute: 6),
      ];
      final c = commonMeals(logs, limit: 2);
      expect(c.map((m) => m.name), ['Apple', 'dal']);
      expect(c.last.calories, 200);
    });

    test('text', () {
      expect(servingsText(1), '1 serving');
      expect(servingsText(1.5), '1.5 servings');
      expect(servingsText(2), '2 servings');
      expect(kcalText(270), '~270 kcal');
      expect('$foodListNote${servingsText(1)}'.contains('!'), isFalse);
    });
  });

  group('screen', () {
    appTest('set a daily goal, log from the list, see estimates', (
      tester,
      db,
    ) async {
      await openNutrition(tester);
      expect(find.text('No meals logged today.'), findsOneWidget);

      await tester.tap(find.text('Set a goal'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('0 of 5 servings'), findsOneWidget);

      await tester.tap(find.text('Add meal'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'dal');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('food-Dal, cooked')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('More servings'));
      await tester.pumpAndSettle();
      expect(find.text('1.5 servings'), findsOneWidget);
      expect(find.textContaining('estimates'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('1.5 of 5 servings'), findsOneWidget);
      expect(find.textContaining('~270 kcal'), findsWidgets);
      // In the list of meals and as a quick "add again" chip.
      expect(find.text('Dal, cooked'), findsWidgets);
      final m = (await db.select(db.mealLogs).get()).single;
      expect(m.source, 'listed');
      expect(m.calories, 270);
      expect(m.servings, 1.5);
    });

    appTest('a typed meal needs no values and counts as a serving', (
      tester,
      db,
    ) async {
      await openNutrition(tester);
      await tester.tap(find.text('Add meal'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Homemade soup');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('1 serving'), findsWidgets);
      final m = (await db.select(db.mealLogs).get()).single;
      expect(m.source, 'entered');
      expect(m.calories, isNull);
      // No values, so no calorie line is invented.
      expect(find.byKey(const Key('nutrition-totals')), findsNothing);
    });

    appTest('a common meal can be added again and a meal removed', (
      tester,
      db,
    ) async {
      final user = await db.select(db.users).getSingle();
      Future<void> log() async {
        await db
            .into(db.mealLogs)
            .insert(
              MealLogsCompanion.insert(
                id: 'm${DateTime.now().microsecondsSinceEpoch}',
                createdAt: testNow,
                updatedAt: testNow,
                userId: user.id,
                name: 'Oats, cooked',
                loggedAt: testNow.subtract(const Duration(days: 1)),
                localDate: '2026-05-12',
              ),
            );
      }

      await log();
      await openNutrition(tester);
      expect(find.byKey(const Key('again-Oats, cooked')), findsOneWidget);
      await tester.tap(find.byKey(const Key('again-Oats, cooked')));
      await tester.pumpAndSettle();
      expect(find.text('Logged. Oats, cooked.'), findsOneWidget);
      expect((await db.select(db.mealLogs).get()).length, 2);

      await tester.tap(find.byTooltip('Remove Oats, cooked'));
      await tester.pumpAndSettle();
      expect(find.text('No meals logged today.'), findsOneWidget);
    });

    appTest('the nutrition goal shows on Goals and counts servings', (
      tester,
      db,
    ) async {
      await tester.tap(find.text('Goals'));
      await tester.pumpAndSettle();
      expect(find.text('Nutrition'), findsOneWidget);
      await tester.tap(find.text('Nutrition'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Set a goal'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('5 servings daily'), findsOneWidget);
    });
  });
}
