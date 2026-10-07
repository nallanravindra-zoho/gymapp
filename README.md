# gymapp

Well-Being Companion: a minimalist Android-first app for workouts, habit breaks, sleep and screen time. Built with Flutter.

## Run locally

Requires the Flutter SDK (stable, Dart 3.13+) and Android Studio with an emulator or a USB-debugging device.

```
git pull
flutter pub get
flutter run
```

Checks:

```
flutter analyze
flutter test
```

## Layout

- `lib/core/theme`: colour tokens, theme, `SectionTheme`
- `lib/core/widgets`: shared widgets
- `lib/core/time`: `local_date` helper (day cutoff, Mon-Sun weeks) and injectable clock
- `lib/data`: Drift schema (`tables/`), `app_database.dart`, repositories, Riverpod providers
- `lib/features/workouts`: log sheet, timestamp-based timer, icons, providers
- `lib/features/week`: Mon-Sun strip, totals, day sheet, rest days
- `lib/features/streaks`: streak engine (rest days, freeze), snapshot, badges, milestones screen, quiet celebration
- `lib/app`: app root and tab shell
- `lib/features/*`: one folder per feature (filled in by later build steps)

## Status

Steps 1-5 of 13 done: project setup, local database, workouts, week view, streaks and milestones.

The generated `*.g.dart` files are committed. After changing a table, regenerate with:

```
dart run build_runner build
```
