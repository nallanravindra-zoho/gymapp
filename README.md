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
- `lib/features/habits`: habit setup, breaks card, detail, reminder config
- `lib/features/reminders`: reminder planner (quiet hours, batching, cap), scheduler, Log/Snooze actions
- `lib/features/sleep`: sleep log, targets, 7-day consistency, wind-down checklist
- `lib/app`: app root and tab shell
- `lib/features/*`: one folder per feature (filled in by later build steps)

## Status

Steps 1-7 of 13 done: project setup, local database, workouts, week view, streaks and milestones, habits and reminders, sleep.

The generated `*.g.dart` files are committed. After changing a table, regenerate with:

```
dart run build_runner build
```

## Reminders

Reminders are local notifications, off by default per habit. They are rebuilt every time the app opens or a habit changes, and cover the next 7 days. If the app is not opened for more than a week, reminders stop until it is. Notification access is requested when you first turn reminders on.

Android specifics: scheduling is inexact (no exact-alarm permission), the boot receiver restores scheduled reminders after a restart, and the Log and Snooze buttons run in a background isolate.
