# Well Being Companion (WBC): context for Claude Code

Android Flutter wellness app (workouts, healthy habits, hobbies, sleep, screen time, streaks and badges, groups). Repo: nallanravindra-zoho/gymapp. Work on a `claude/...` branch; open a pull request only when asked.

## Stack
Flutter 3.47 / Dart 3.13, Riverpod 3, Drift (SQLite, schema v2, local-first), Supabase (Postgres 16 with RLS, Google sign-in via google_sign_in), Kotlin method-channel bridges (usage stats, steps, system settings, ringtone picker). Plugins: flutter_local_notifications, share_plus, image_picker, record + flutter_tts + audioplayers + wakelock_plus (Om chanting). Font: Plus Jakarta Sans. FCM push was deliberately skipped.

## Commands
- `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs` (after Drift table changes)
- `flutter analyze` (must be clean), `flutter test` (about 805 tests), `dart format <files>`
- Run/build: copy `env.example.json` to `env.json` (see supabase/README.md), then `flutter run --dart-define-from-file=env.json`. Without it the app works offline only.
- CI: GitHub Actions (`.github/workflows`): analyze, tests, debug APK, release build check, backend SQL tests on real PostgreSQL 16. Signed release steps: docs/release.md.

## Source of truth for requirements
The spec and "Revised Requirements, 10 October 2026" (R1 to R14) are NOT in the repo; the user has them (wellbeing-app-spec.md and ui-sample-screens.png, in wellbeing-app-spec-with-ui_10_Oct.zip). Where the picture and the written text disagree, the written text wins. All of R1 to R11 are implemented (see "Status").

## Architecture notes
- `lib/data`: Drift tables (`tables/tables.dart`), repositories, sync (`sync/sync_tables.dart` maps each table to the server). New synced table = Drift table + SyncTable + Supabase migration with RLS + tests.
- `lib/features/<area>`: today, week, workouts, habits, hobbies, sleep, screen_time, streaks, groups, insights, chat, metrics, account, settings, reminders.
- Design system: `lib/core/theme/tokens.dart` (AppTokens, category colours), `lib/core/widgets/app_widgets.dart` (SoftCard, TintedIcon, PillTabs...). No raw hex in widgets.
- Streaks: four strict category streaks (workout, healthy habits, hobbies, sleep target); rest days and freeze affect only the "overall" streak. Badges at 7/30/50/100/200/500, deterministic keys like `workout_7`.
- Groups: 4-digit invite code (rate limited), no invite links by user's choice. Scoring happens only on the server (docs/group-scoring.md); the numeric overall score is never shown or returned.
- Reminders: one notification per habit with Log and Skip; Skip never counts. No ongoing notifications.
- Supabase migrations are run MANUALLY by the user in the SQL editor, in order. Latest: 20261009 delete_account, 20261010/20261011 invite codes, 20261012 revised requirements tables, 20261013 group categories.

## Conventions the user cares about
- Calm copy, no exclamation marks (a test enforces it), non-prescriptive health text, estimates labelled as estimates.
- Min tap target 48dp, light and dark themes.
- Tests: `appTest` helper in test/test_helpers.dart (in-memory DB, fixed clock Wed 2026-05-13 10:00 UTC, fakes). Fake awaits on root-zone futures can hang under fake async; do not await stream cancel in controllers.
- Never push to main directly; user asks for merges explicitly.

## Status (as of 2 Nov 2026)
Merged to main: redesign to match reference screens, new icon/splash, Hobbies + Om chanting (timer + manual counter, optional mic mode), all R1 to R11 features, groups categories. CI green.

## Not verified on a real device
Notification Log/Skip buttons and reboot restore, ringtone and gallery pickers, step counter bridge, Usage Access flow, mic chant counting, layout on narrow phones.

## Known gaps / ideas
- Reference-screen side-by-side comparison done only for Today, Log Workout, Timer, Week, Habits, Sleep, Screen Time; Groups, Insights, Chat, Milestones, Daily Summary, Profile were restyled but not compared.
- Icons are Material icons, not custom art.
- Hobby reminders are a rolling window (daily ones run out after about 30 days if the app is never opened).
- Chant/hobby timers: hobby timer is in memory only.
- No hobby score in groups (server switch `share_hobbies` exists, no UI).
