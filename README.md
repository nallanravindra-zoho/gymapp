# gymapp

Well-Being Companion: a minimalist Android-first app for workouts, habit breaks, sleep and screen time. Built with Flutter.

## Run locally

For sign-in and sync, copy `env.example.json` to `env.json`, fill it in (see `supabase/README.md`) and add `--dart-define-from-file=env.json` to the run command. The app works offline without it.

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
- `lib/features/screen_time`: usage source (Android channel), sync, Today and Week views, goal
- `lib/data/sync`: local-first sync engine (push/pull, last write wins), tested against a simulated server
- `supabase`: backend schema, row-level security and its tests; setup guide in `supabase/README.md`
- `lib/features/insights`: rule engine (spec 7.7), tips selection, weekly recap, Insights screen
- `lib/features/account`: Google sign-in, Account screen, sync controller and triggers
- `lib/features/groups`: groups tab, group screen (leaderboard, feed, cheers), settings, invite codes; online only, through `GroupsRemote`
- `lib/features/settings`: Settings screen (name, theme, quiet hours and limits, streak rules, day start), data export, erase, delete account
- `lib/app`: app root and tab shell
- `lib/features/*`: one folder per feature (filled in by later build steps)

## Status

Steps 1-12 of 13 done (settings, export and account deletion included; push notifications for groups still to come): project setup, local database, workouts, week view, streaks and milestones, habits and reminders, sleep, screen time, insights, sign-in and sync, groups.

The generated `*.g.dart` files are committed. After changing a table, regenerate with:

```
dart run build_runner build
```

## Reminders

Reminders are local notifications, off by default per habit. They are rebuilt every time the app opens or a habit changes, and cover the next 7 days. If the app is not opened for more than a week, reminders stop until it is. Notification access is requested when you first turn reminders on.

To check them, open Today, Breaks, Manage, then Reminders: it lists the next reminders, whether notifications are allowed and how many are set up on the phone, and can send a test now or in a minute.

Android specifics: scheduling is inexact (no exact-alarm permission), the boot receiver restores scheduled reminders after a restart, and the Log and Snooze buttons run in a background isolate.

## Screen time

Android only. It needs the Usage access permission, which the user grants in system settings after an explanation screen. A small Kotlin module (`UsageReader.kt`) reads app foreground time from Android's usage events and returns only totals: the day's minutes, minutes per category, and minutes per hour. App names never reach Dart or the database. Sharing in groups is off by default.

Usage data is only meaningful on a real device. Emulators have almost no usage history.

## Groups

Groups need an account and the second migration (`supabase/migrations/20261008000000_groups.sql`). They are read from the server when a screen opens and are not stored in the local database.

- Create a group, then use *Copy invite* in group settings and send it. The other person chooses *Join with a code* on the Groups tab and pastes the whole message, the link or just the code. Links look like `wellbeing://join/CODE`; tapping a link to open the app is not wired up yet (it needs a web domain, planned for release prep).
- A group holds up to 20 people and a person can be in up to 10 groups. The owner can make a new invite link, which stops the old one working. If the owner leaves, the longest-standing member becomes owner.
- Each member has two switches per group, *Workouts* and *Break goals*. The server checks them every time something is read, so turning one off hides earlier items at once. Sleep and screen time are not read by anything in the groups schema; a test checks that.
- The leaderboard is for the current Monday to Sunday week in each member's own local time. *Volume* is active minutes, *Consistency* is days with a workout or a met break goal (break goals count only for members who share breaks). Ties share a rank.
- Feed items are created on the server when a workout, break goal or streak milestone is synced. Only activity from the last two days is posted, so signing in on a new phone does not flood a group.
- Cheers are the only reaction. You cannot cheer your own items.

## Settings and your data

Open the avatar at top right, then *Settings*.

- Name, light/dark/system theme, quiet hours, the daily reminder limit, rest days per week, streak freeze and its interval, and when a new day starts. Streak and reminder changes apply straight away.
- *Export all data* writes a JSON file of everything on the phone (timestamps in UTC); *Export workouts* writes a CSV. Both open the phone's share sheet. Spreadsheet cells that start with `=`, `+`, `-` or `@` are prefixed with an apostrophe so notes never run as formulas.
- *Erase data on this phone* (signed out only) removes entries and settings from the phone.
- *Delete account* (signed in) calls the `delete_my_account()` database function (`supabase/migrations/20261009000000_delete_account.sql`, run it in the SQL editor). It removes the account and everything stored for it, including group memberships; a group the person owned passes to the longest-standing member. Data on the phone stays, and signing in later with any account starts from it.
