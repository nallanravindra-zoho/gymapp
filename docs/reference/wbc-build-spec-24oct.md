# Well-Being Companion: Build Spec (working title)

Audience for this file: the developer (or AI coding tool) building the app. Design inputs come from the product owner; technical decisions are confirmed by the developer. Items marked **[Proposal]** are defaults that can be changed.

---

## 1. Product Summary

A minimalist well-being app for daily movement, healthy breaks, sleep, and (later) screen time and hobbies. Principle: **one tap to log, one glance to understand.**

- **Audience:** family and friends. Self-made, non-commercial, free.
- **Platform:** Android first. Keep architecture and design portable to iOS.
- **Users:** desk workers who want regular breaks; people who work out consistently (no advanced performance analytics); small groups who want gentle accountability.
- **Constraints:** minimal running cost (free tiers, minimal LLM usage), flexible timeline, MVP as early as possible.

### Non-goals (for now)
- Heart rate / BPM or wearable-based performance metrics.
- Automatic sleep detection (sleep is entered manually).
- Monetization, ads, subscriptions.
- iOS release.
- Colour-blind-safe palette and screen-reader support (deferred). Keep large tap targets and dark mode.

---

## 2. Phases

| Phase | Scope |
|---|---|
| **MVP** | Workout logging (timer and manual), weekly strip, streaks, habit/break reminders, manual sleep log, basic milestones, lightweight groups with one weekly leaderboard, rule-based weekly insights |
| **v1.1** | Screen-time tracking (Android), steps via Health Connect and step leaderboards, daily and monthly boards, shareable weekly recap, curated tips library |
| **v1.2** | Preset-query chatbot, per-metric group privacy, optional LLM-phrased weekly recap |
| **v2** | GPS for walk/run (distance, simple route), hobbies and balance view, group challenges, free-text chatbot, iOS |

Screen time may move into the MVP if the usage-access setup proves quick.

---

## 3. Tech Stack **[Proposal]**

| Layer | Default | Notes |
|---|---|---|
| App | Flutter (Dart) | One codebase, strong custom UI (needed for per-section looks), iOS later |
| Local storage | SQLite via Drift (or Isar) | Local-first: logging works offline |
| Backend | Supabase (Postgres, Auth, Realtime, Row Level Security) | Free tier is likely enough. Firebase is an acceptable alternative |
| Auth | Google sign-in | Simplest on Android |
| Push | Firebase Cloud Messaging | Only for group events (cheers, invites). Habit reminders are local |
| Local notifications | `flutter_local_notifications` | Scheduled on device |
| Charts | `fl_chart` | Weekly views |
| Maps (v2) | MapLibre with OpenStreetMap tiles | Avoids paid map APIs |
| LLM (optional, v1.2+) | Any low-cost model API, one call per user per week | Server-side only, never ship keys in the app |

---

## 4. Design System

### 4.1 Principles
- Minimal: few screens, generous whitespace, one icon set, one typeface.
- Restricted palette: neutrals plus one accent, and two soft section tints. No more than four hues in total.
- Subtle section identity (same system, small variations):
  - **Workout:** slightly bolder. Heavier type weight, full-strength accent, solid icon fills.
  - **Sleep:** calmer. Desaturated cool tint, lighter weights, more spacing.
  - **Hobbies (v2):** slightly doodley. Hand-drawn style dividers and underlines, optional handwritten font on headings only.
- Dark mode supported from the start. Minimum tap target 48dp.

### 4.2 Colour tokens **[Proposal, replace with the owner's palette]**

| Token | Light | Dark | Use |
|---|---|---|---|
| `bg` | `#FAFAF8` | `#121413` | App background |
| `surface` | `#FFFFFF` | `#1B1D1C` | Cards |
| `text` | `#1C1F1E` | `#ECEDEC` | Primary text |
| `text-muted` | `#6B706E` | `#9AA09D` | Secondary text |
| `accent` | `#2F7D6B` | `#4FA68F` | Primary actions, streaks, selected states |
| `tint-sleep` | `#E8EDF3` | `#1E2530` | Sleep screens background wash |
| `tint-hobby` | `#F4ECDD` | `#2B261C` | Hobbies background wash (v2) |

Implementation: define tokens once in a theme object. Each section applies its own tint and weight through a `SectionTheme` wrapper. Do not duplicate screens per section.

### 4.3 Typography
One sans-serif family (for example Inter or the system font). Three sizes for body, title, and display. An optional handwritten font for hobby headings only (v2).

### 4.4 Icons
One outline icon set (Material Symbols Rounded or Phosphor). Each workout type gets one icon:

| Type | Icon idea | Type | Icon idea |
|---|---|---|---|
| Yoga | seated figure | Back | back/spine |
| Zumba | dancing figure | Stability | balance figure |
| Walk | walking figure | Flexibility | stretch figure |
| Run | running figure | Other | dot / plus |
| Weights | dumbbell | Legs / Arms / Chest | body-part glyph or dumbbell variant |

### 4.5 Microcopy rules
- Neutral, sober, brief. No exclamation marks, no cheerleading, no emojis in system text.
- State facts, then stop.
- Never use guilt language (no "you missed", "don't break your streak").

| Situation | Copy |
|---|---|
| Workout saved | `Logged. 35 min yoga.` |
| Streak update | `5-day streak.` |
| Streak milestone | `7-day streak reached.` |
| Rest day marked | `Rest day recorded.` |
| Water reminder | `Water break.` |
| Stand reminder | `Stand and move for a minute.` |
| Weekly recap title | `Week summary` |
| Empty state | `No workouts logged this week.` |
| Tip footer | `General wellness suggestion. Not medical advice.` |

---

## 5. Navigation and Screens

Bottom tabs: **Today · Week · Groups · Insights · Chat**. Profile and Settings open from an avatar at top right.

### MVP screens

**Today**
- Header: date, current overall streak.
- Workout card: today's logged workouts or `Log workout`.
- Breaks card: dots or rings for each active habit (water, stand, stretch, custom), tap to log.
- Sleep card: last night's logged sleep or `Log sleep`.
- Quick actions: `Start timer`, `Add manual entry`.

**Log workout** (sheet)
1. Icon grid of workout types (plus `Add custom`).
2. Either `Start timer` (Start/Pause/Stop) or manual start and end time.
3. Optional **Intensity** tap: Low / Mid / High. Skipped by default and never required.
4. Optional note.
5. Save.

**Week**
- Mon to Sun strip showing the workout icon per day (multiple workouts: first icon plus count badge). Rest days show a quiet marker, not a gap.
- Totals: active minutes, active days, workouts per type.
- Streaks: overall and per type.
- Tap a day to view or edit entries.

**Habits and breaks**
- Setup flow per habit: `What do you want to track?` (water / stand / stretch / custom name), daily target count, reminder on/off, reminder times or interval, active days.
- Habit detail: today's count, streak, 4-week history.

**Sleep** (manual)
- Target bedtime and wake time.
- Log: actual bedtime and wake time (defaults to targets, adjustable).
- Consistency score for the last 7 days (see 7.5).
- Optional wind-down checklist (screens off, stretch, reading) with user-editable items.

**Groups**
- List of groups; create group; join by invite link.
- Group screen: member list, recent activity feed (workout type and duration, break completions), weekly leaderboard with a `Volume | Consistency` toggle, reactions (cheer) on feed items.
- Group settings: name, invite link, leave group.

**Insights**
- Weekly insights (rule-based, see 7.7) and one to three tips.
- Weekly recap card.

**Chat**
- MVP: placeholder or hidden. v1.2: preset queries.

**Profile and Settings**
- Name, avatar, sign out.
- Reminders: global quiet hours, daily reminder cap.
- Theme: light, dark, system.
- Data: export (JSON/CSV), delete account.
- Streak settings: weekly rest days.

---

## 6. Data Model

IDs are client-generated UUIDs. Every row has `created_at`, `updated_at`, and `deleted_at` (soft delete) for sync. Times are stored in UTC with the user's timezone offset recorded so the correct local day can be derived.

### 6.1 Core tables (MVP)

**users**
`id, display_name, avatar_url, timezone, day_cutoff_minutes (default 0), quiet_hours_start, quiet_hours_end, daily_reminder_cap, weekly_rest_days (default 2)`

**workout_types**
`id, user_id (null for built-ins), name, icon_key, is_builtin`

**workouts**
`id, user_id, workout_type_id, started_at, ended_at, duration_minutes, intensity (null | low | mid | high), note, source (timer | manual), local_date`

**habits**
`id, user_id, name, kind (water | stand | stretch | custom), daily_target, reminders_enabled, reminder_config (JSON: times or interval, active_days), is_active`

**habit_logs**
`id, habit_id, user_id, logged_at, count, local_date`

**sleep_targets**
`user_id, bedtime_minutes, wake_minutes`

**sleep_logs**
`id, user_id, bedtime_at, wake_at, duration_minutes, local_date (wake date)`

**rest_days**
`id, user_id, local_date`

**streak_state** (cached, recomputable)
`user_id, scope (overall | workout_type:<id> | habit:<id>), current_streak, longest_streak, last_counted_date, freeze_available, freeze_last_granted_on`

**badges_awarded**
`id, user_id, badge_key, awarded_at, context (JSON)`

### 6.2 Groups (MVP)

**groups**
`id, name, owner_id, invite_code, created_at`

**group_members**
`group_id, user_id, role (owner | member), joined_at, share_workouts (bool, default true), share_breaks (bool, default true)`

**group_events** (feed items, written by client or database trigger)
`id, group_id, user_id, kind (workout | break_goal | milestone), payload (JSON: type, duration, habit name), occurred_at`

**reactions**
`id, event_id, user_id, kind (cheer), created_at`

**weekly_group_stats** (view or materialized table)
`group_id, user_id, week_start, active_minutes, active_days, break_goals_met`

### 6.3 Insights (MVP)

**weekly_insights**
`id, user_id, week_start, insight_key, params (JSON), generated_at`

**tips_library**
`id, trigger_key, text, source_label, is_active`

### 6.4 Later phases

- **screen_time_daily** (v1.1): `user_id, local_date, total_minutes, category_minutes (JSON), share_in_groups (bool)`
- **step_daily** (v1.1): `user_id, local_date, steps`
- **hobbies / hobby_logs** (v2): same shape as workout types and workouts, with `category` and `duration_minutes`
- **workout_routes** (v2): `workout_id, polyline, distance_m`

### 6.5 Security
Enable Row Level Security on every table. Rules:
- Users read and write only their own rows.
- Group members read group_events and weekly_group_stats for groups they belong to, limited to the metrics each member shares.
- Sleep logs and screen time are never visible to groups in the MVP.

---

## 7. Logic Rules

### 7.1 Day boundary
`local_date` is derived from the user's timezone and `day_cutoff_minutes` (default midnight). Compute and store it at write time so history does not shift if the timezone changes.

### 7.2 Streaks **[Proposal]**
- **Overall activity streak:** consecutive local days with at least one workout, a recorded rest day, or an applied freeze.
- **Per-type streak:** consecutive days with that workout type, counted the same way. Rest days do not apply to per-type streaks. Consider using "weeks with at least N sessions" for per-type streaks if daily proves too strict.
- **Habit streak:** consecutive days where the daily target is met.
- **Rest days:** the user can mark up to `weekly_rest_days` (default 2) per Mon to Sun week. A rest day keeps the overall streak alive but does not extend it.
- **Freeze:** one freeze is granted per rolling 7 days and is applied automatically to a single missed day. Show it neutrally: `Streak kept. Freeze used.`
- Recompute streaks from logs on app start and after edits. Cached values are for speed only.

### 7.3 Workout timer
Store `started_at` when the timer starts and compute elapsed time from timestamps. Do not rely on a running process. This avoids a foreground service in the MVP. Optionally show an ongoing notification while a timer is active. Pause stores accumulated paused time.

### 7.4 Reminders
- Habit reminders are local scheduled notifications. **Off by default**; enabled per habit.
- Global quiet hours and a daily reminder cap (default 6). If a day exceeds the cap, drop the lowest-priority reminders.
- Batch reminders that fall within 15 minutes into one notification.
- Prefer inexact scheduling. Use exact alarms only if minute-level timing is a real requirement, since they need an extra permission on recent Android versions.
- Reschedule after device reboot and after the user changes settings.
- Suppress a reminder if the habit's target is already met for the day.
- Notification actions: `Log` (increments the count) and `Snooze 30 min`. Cap snoozes at 2.

### 7.5 Sleep consistency score
For the last 7 days, compare actual bedtime and wake time against targets. Score = share of days within a 30-minute tolerance of both targets (shown as `5 of 7 days on schedule`). Show the number only, no colour judgement.

### 7.6 Leaderboards
- Week runs Monday to Sunday in each member's local time, aggregated per group.
- **Volume:** total active minutes in the week.
- **Consistency:** number of days with at least one workout or a met break goal.
- Ties share a rank. Members who have turned off `share_workouts` do not appear.
- MVP: weekly only. v1.1 adds daily and monthly. Steps volume is added in v1.1.

### 7.7 Weekly insights (rule-based)
Generated on Sunday evening or when the user opens Insights after the week ends. Each rule outputs `insight_key + params`, rendered with a text template.

| Key | Rule | Example text |
|---|---|---|
| `stretch_on_workout_days` | Stretch completion higher on workout days by 20 percent or more | `Stretch breaks were completed more often on workout days.` |
| `active_days_change` | Active days differ from the previous week | `4 active days this week, up from 3.` |
| `longest_gap` | Gap of 3 or more days without activity | `Longest gap: 3 days (Tue to Thu).` |
| `water_consistency` | Water target met on 5 or more days | `Water target met on 5 of 7 days.` |
| `sleep_consistency` | Score change versus previous week | `Sleep schedule matched on 5 of 7 days.` |
| `screen_time_late` (v1.1) | Late-evening screen time higher on days with later bedtime | `Later bedtimes followed higher evening screen time.` |

Tips: for each insight, select at most one tip from `tips_library` by `trigger_key`. Show at most three tips per week. Every tip carries the footer `General wellness suggestion. Not medical advice.` Tips avoid extreme goals and are written by the owner or taken from open sources with attribution in `source_label`.

### 7.8 Milestones and badges
Streak badges at 7, 30, and 100 days (overall and per habit). Personal bests: longest streak, most active minutes in a week. Group goals: group total active minutes in a week reaching a set target. Celebrations are a short, quiet animation and one line of text. Each badge is awarded once.

### 7.9 Weekly recap card (shareable in v1.1)
Static card: week range, active days, total minutes, top workout type, longest streak. Rendered to an image for sharing through the Android share sheet. No personal data beyond the above.

---

## 8. Later-Phase Feature Notes

### 8.1 Screen time (v1.1, Android)
- Source: Android `UsageStatsManager`, which requires the user to grant **Usage access** in system settings. Show an in-app explanation screen first, then deep-link to the settings page.
- Read daily totals and per-app and category totals on the device. Upload only daily totals. Sharing in groups is opt-in and off by default.
- Browser time is available per app only, not per website.
- Show daily and weekly totals, an optional daily goal, and a late-evening view.
- On iOS this is heavily restricted, so plan for manual entry or omission there.
- Check current Google Play policy before publishing publicly. Internal or closed testing is sufficient for family and friends.

### 8.2 Steps (v1.1)
Read daily steps from Health Connect (Android). Handle the permission request and the case where Health Connect is not installed. Step leaderboards use daily totals per member.

### 8.3 Chatbot (v1.2)
- Preset queries first: week summary, longest streak, sleep consistency, screen-time trend.
- Each returns a report card computed from local or server data, with no LLM needed.
- Free-text via an LLM (v2): send only a compact summary of the user's own metrics, opt-in, with a system prompt that refuses medical advice.

### 8.4 GPS (v2)
Foreground location tracking for walk and run only, when the user starts a GPS workout. Store distance and a simplified polyline. Show a simple route map on OpenStreetMap tiles. Expect extra work for background location rules and battery use.

### 8.5 Hobbies (v2)
Categories: art, music, dance, reading, writing, custom. Time logging uses the same timer and manual pattern as workouts. Weekly time goals, hobby streaks, a balance view (movement, rest, play), and group challenges (for example a 30-day reading streak). Applies the doodle look through `SectionTheme`.

---

## 9. Android Permissions

| Permission | Phase | Purpose |
|---|---|---|
| `POST_NOTIFICATIONS` (runtime, Android 13+) | MVP | Reminders and group events |
| `RECEIVE_BOOT_COMPLETED` | MVP | Reschedule reminders after reboot |
| `SCHEDULE_EXACT_ALARM` | Only if needed | Exact reminder timing |
| Usage access (`PACKAGE_USAGE_STATS`, granted in settings) | v1.1 | Screen time |
| Health Connect read: steps | v1.1 | Step tracking |
| `ACCESS_FINE_LOCATION` and foreground location | v2 | GPS workouts |

Ask for each permission at the moment it is needed, with a one-line explanation.

---

## 10. Privacy and Safety

- Data is private by default. Group sharing is per member and limited to workouts and break completions in the MVP.
- Sleep and screen time are never shared with groups in the MVP.
- Provide data export and account deletion in Settings.
- Wellness tips are not medical advice and avoid extreme targets.
- Leaderboards are visible only within a group the user chose to join.

---

## 11. Cost Plan

- Hosting: Supabase and Firebase free tiers should cover a family-and-friends user base.
- AI: none required in the MVP. Insights are rule-based and tips come from a curated library.
- From v1.2, at most one LLM call per user per week, server-side, with a spend cap.
- Distribution: Google Play internal or closed testing, or a direct APK.

---

## 12. MVP Build Plan

Work in this order. Each step should leave the app in a runnable state.

- [ ] **1. Project setup:** Flutter project, folder structure, linting, theme tokens, light/dark mode, bottom tab shell.
- [ ] **2. Local database:** Drift schema for MVP tables (6.1), repositories, `local_date` helper.
- [ ] **3. Workouts:** type grid, timer (timestamp-based) and manual entry, optional Intensity (Low/Mid/High), edit and delete, Today workout card.
- [ ] **4. Week view:** Mon to Sun strip with icons, totals, rest day marking.
- [ ] **5. Streaks and milestones:** streak computation (7.2), cached state, badges at 7/30/100, quiet celebration.
- [ ] **6. Habits and reminders:** habit setup flow, logging, local notifications with quiet hours, cap, batching, notification actions, reboot rescheduling.
- [ ] **7. Sleep (manual):** targets, logging, consistency score, optional wind-down checklist.
- [ ] **8. Auth and sync:** Google sign-in, Supabase tables with RLS, sync queue (last write wins on `updated_at`), offline handling.
- [ ] **9. Groups:** create/join by invite link, feed, weekly leaderboard (volume and consistency), cheers, per-member sharing toggles, push for invites and cheers.
- [ ] **10. Insights:** rule engine (7.7), tips library seeded with a small set, Insights screen.
- [ ] **11. Settings and data:** quiet hours, reminder cap, rest days, export, delete account.
- [ ] **12. Release prep:** copy review against the microcopy rules, permissions flow, crash reporting, internal testing track build.

### Acceptance checks for the MVP
- A workout can be logged in three taps or fewer (type, save).
- Logging works offline and syncs later without duplicates.
- Reminders respect quiet hours and the daily cap, and are not sent once the target is met.
- Streaks stay correct after editing or deleting past entries.
- A group member sees only the metrics other members have chosen to share.
- No copy in the app contains exclamation marks.

---

## 13. Open Items

- Final palette and typeface from the owner's design input.
- Developer to confirm the stack in section 3.
- Streak rules in 7.2 (rest days per week, freeze frequency).
- Whether screen time moves into the MVP.
- Seed content for the tips library.

---

## 11. Current Product Decisions and UI Update (October 2026)

This section supersedes earlier conflicting or outdated scope notes above. Build the simplest usable version first; do not add extra screens or settings unless they solve a clear user need.

### 11.1 Product direction

- Android-first Flutter/Dart app, installed by direct APK for the first tester group.
- Free-first testing: rule-based insights and chatbot responses; no paid LLM dependency for the first pilot.
- Preserve WBC's friendly, colourful, nature-inspired visual personality, illustrated backgrounds and simple line icons. Do not flatten the design into a plain monochrome dashboard.
- Keep screens easy to scan, with a clear primary action, short labels, large tap targets and minimal configuration.
- User goals and targets are the organising principle. Logging should update progress against a target, not be the primary reason to open the app.

### 11.2 Main navigation and screens

Use five bottom-navigation destinations: **Home, Goals, Groups, Insights, Chat**.

- **Home:** greeting, a compact summary of today's progress against goals, the user's goals for today, and at most one useful rule-based suggestion.
- **Goals:** one overview of goal categories and progress. Allow a user to create/edit a goal without navigating through a long wizard.
- **Set a Goal:** choose a category, set a target, choose frequency and optional reminders. Only show fields relevant to the selected category and frequency.
- **Healthy Habits:** allow multiple user-defined habits (e.g., water, movement breaks, skincare). Each habit has a target and optional reminder schedule. Keep adding another habit easy.
- **Hobbies:** allow multiple hobbies, with daily, weekly, every-two-weeks, or monthly targets as appropriate. Make the difference between “every two weeks” and “twice a month” explicit in labels.
- **Meditation:** a calm, minimal screen. Users choose the duration they want each time; do not impose fixed sessions or a default goal that they must accept. Offer a few quick duration chips (e.g., 5, 10, 15 minutes) plus a simple custom-duration option. One clear Start button, a timer while meditating, and a simple completion state. Optional sound/guide settings should not clutter the main screen; defer them if not already implemented.
- **Insights:** simple daily, weekly and monthly views showing percentage of goals met and category-level progress. Do not let frequent reminders artificially outweigh other goals. Normalise progress against each goal's target and explain partial progress clearly.
- **Chat:** basic rule-based questions and insights from the user's saved goals and logs. Make it clear that these are general wellness suggestions, not medical advice. No paid LLM required for the first pilot.

### 11.3 Goal and frequency rules

- Workout: one primary weekly target (for example, sessions per week). Individual workout logs contribute to that target.
- Healthy habits: multiple goals allowed; each normally has a daily target.
- Sleep: daily target.
- Screen time: daily target, with Android Usage Access and a manual fallback when unavailable.
- Hobbies: multiple goals allowed; frequency may be daily, weekly, every two weeks, or monthly.
- Nutrition: daily target; manual logging for the first pilot. Food-photo recognition and automatic nutrient logging are future-phase features.
- If a goal's frequency is genuinely unspecified, use once per day as the fallback. Never override a clearly selected weekly or monthly frequency with a daily assumption.
- Weekly goals should show progress toward the target while the week is still in progress; do not label the goal failed before the week ends.
- For reminders, the start/end endpoints are inclusive. Example: hourly reminders from 12:00 to 17:00 produce six scheduled reminders. Avoid duplicate reminders when a goal is edited.

### 11.4 Workout tracking and indicative calories

- Walk and Run offer location permission at the moment the user starts GPS tracking, not during onboarding. Show distance in kilometres, elapsed/active time and average pace. Provide pause, resume and finish controls.
- If permission is denied or GPS is unavailable, offer manual duration and optional distance entry; label the data source.
- Calories are indicative estimates. Use the MET method: estimated kcal = MET × 3.5 × body weight in kg ÷ 200 × minutes. This estimates gross energy expenditure. If displaying active calories instead, use (MET − 1) and label the definition consistently.
- Source candidate for activity values: 2024 Adult Compendium of Physical Activities (https://pacompendium.com/adult-compendium/). Match values to the closest activity and intensity; do not treat one MET value as exact for every person. Keep the MET mapping configurable and cite the source in developer documentation.
- Use saved user weight if available; otherwise ask for weight or label the estimate as generic. Display rounded estimates (e.g., “~180 kcal”), not false precision.

### 11.5 Nutrition roadmap

- Pilot: manual food and portion logging, with calories and macronutrients where a reliable database entry is available. Support quick re-entry of common meals.
- Future: optional food-photo identification plus portion estimation, matched to a nutrition database. Present the result as an estimate and ask the user to review/confirm before saving. Images alone cannot establish exact ingredients or portion weight reliably.
- Evaluate food database coverage for Indian foods and recipes before committing. USDA FoodData Central API documentation: https://fdc.nal.usda.gov/api-guide/ . Confirm applicable terms, coverage and API limits before release.

### 11.6 Free-first chatbot

- For the first tester release, implement deterministic report cards and rule-based suggestions using local goal/log data. Do not require an LLM API key or paid service.
- Suggested queries: “How am I doing this week?”, “Which goals need attention?”, “How consistent was my sleep?”, and “Suggest one small next step.”
- Do not invent insights when there is insufficient data. State what time period and data the insight uses.
- If an LLM is introduced later, keep credentials on a backend, minimise personal data sent, enforce usage limits, and require explicit user approval before AI changes a goal or reminder.

### 11.7 UI principles for all new screens

- Reuse the supplied `wbc-sample-screens.png` as a visual direction reference, not as a pixel-perfect specification.
- Preserve warm cream backgrounds, green/teal accents, gentle category colours, rounded cards, simple line icons and occasional illustrations.
- Keep each screen focused on one task. Avoid excessive charts, nested menus, and long forms. Show advanced controls only when needed.
- Meditation is intentionally flexible: the user chooses the session duration on each use. Do not force a meditation schedule or goal as a prerequisite to start.
- Keep all progress and calorie values clearly labelled as calculated or estimated where appropriate.

### 11.8 Minimum acceptance tests for this UI revision

- A new user can set a goal with a small number of steps and see it on Home/Goals.
- Multiple healthy-habit and hobby goals can be created, edited and tracked independently.
- Weekly workout progress is not marked incomplete before the week ends.
- Meditation can start with a quick-pick or custom duration without requiring a preconfigured goal.
- Insights percentages are calculated against targets and do not over-weight reminder frequency.
- Walk/run location permission is requested only when tracking starts; denial leaves manual logging available.
- Calorie estimates vary based on activity, duration and available body weight and are labelled approximate.
- The core chatbot works offline from local data/rules without an LLM API.
- The app retains the visual style in the supplied mock screens while keeping controls uncluttered.
