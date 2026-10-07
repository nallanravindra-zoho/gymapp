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
- `lib/app`: app root and tab shell
- `lib/features/*`: one folder per feature (filled in by later build steps)

## Status

Step 1 of 13 done: project setup, tokens, light/dark mode, five-tab shell.
