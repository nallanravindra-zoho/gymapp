# Group scoring and privacy (R9, R11)

Group leaderboards rank people on how well they meet their **own targets**, not
on raw totals, so minutes, habits, sleep and screen time can be compared.
Everything is computed on the server, in one place
(`supabase/migrations/20261013000000_group_categories.sql`). It is deliberately
not duplicated in Dart: other members' data never reaches a phone, so a Dart
copy could only drift. The rules are tested with exact numbers in
`supabase/tests/group_categories.sql`.

## Daily scores (0 to 10 per category per day)

| Category | Day has data when | Daily score |
|---|---|---|
| Workouts | at least one workout | The **best single session** decides: `10 x min(active minutes / 45, 1)`. 45 active minutes or more is 10 of 10. Further sessions that day change nothing. Active time (`active_seconds`) is used when known, otherwise the logged duration. |
| Healthy Habits | at least one log of an active habit | For each active habit: `min(count / daily target, 1)`, so a habit contributes at most 1 however often it is logged. The day is `10 x average over the active habits`, so a habit not touched that day counts 0. A skipped reminder is not a log. |
| Sleep Health | a sleep log (the longest one of the day is the night) | `0.6 x duration + 0.4 x schedule`. Duration: 10 within 30 minutes of the person's target duration, falling in a straight line to 0 at 3 hours away, **on either side** (sleeping longer is not rewarded). Schedule: bedtime and wake time each 10 within 30 minutes of the personal target times (wrapping midnight), 0 at 2 hours away; the two are averaged. With no target set, 23:00 to 07:00 is assumed. |
| Screen Time | a day with a limit | 10 at or under the day's own limit (`target_minutes`), then `10 x (2 - total / limit)`, so 0 at twice the limit. Days without a limit have nothing to compare with and are left out. Being far under the limit is not rewarded more. |

## Weekly category score

The mean of the daily scores over the days **with data** (Monday to Sunday in
each member's own local dates). Days with no data neither help nor hurt: a rest
day is not a failure, and a missing sleep log is not a bad night. The cost is
that one excellent day can equal a week of excellent days; the category boards
break exact ties by the number of days with data. Every daily score is capped
at 10, so the weekly score is too.

## Overall rank

A member's overall score is the **mean of their weekly scores in the categories
they share** (and have data in). Members are compared on that normalised
number, so someone who shares fewer categories is neither advantaged nor
penalised by the missing ones. The app says so: "Ranked on the categories each
person shares". Ranks are `1, 1, 3` style (ties share a rank).

**The overall number is never shown or returned.** It is stored in
`group_score_snapshots.overall_score`, which clients cannot select; they get
only `overall_rank` and the list of categories that count for each person
(shown as small chips).

## What is shared and who sees it

* Per group, per category switch on `group_members`: `share_workouts`,
  `share_breaks` (labelled **Healthy Habits**; the stored name is kept so no
  data migration is needed), `share_sleep`, `share_screen_time`,
  `share_hobbies` (reserved, nothing uses it yet). Workouts and Healthy Habits
  start on; sleep, screen time and hobbies start **off**. The choice is made in
  a sheet before the first create or join and can be changed in group settings.
* A category is read for a member only if they share it, and shown only to a
  member of the same group who shares it too (a person who does not share sleep
  cannot see anyone's). A member who does not share a category is not ranked in
  it. Switching a category off takes effect on the next read and is also
  removed from stored snapshots straight away.
* A category tab appears only with at least **2 members** sharing it with data
  that week, and only if you share it. Overall appears when you share at least
  one category and at least 2 members are ranked.
* Tapping a participant shows key figures (never scores) for the category, as
  far as both of you share it.
* Weight, height and body measurements are never read by any group function.

## Snapshots (`group_score_snapshots`)

One row per `(group, Monday, member)` holding `category_scores` JSON
(`{"workouts": {"score": 7.5, "days": 2}, ...}` only for categories shared when
computed), `overall_score` and `overall_rank`. The open week is recomputed when
read if older than a minute, when someone joined or when a sharing switch
changed; a closed week is computed the first time it is asked for and then
kept (a member who opts in later is not added to a closed week). Clients may
select only their own row and not the overall column; everything about other
members goes through the board functions, which apply the switches on every
read. Rows are removed when a member leaves or deletes their account.

## Invites

Joining is by the 4-digit code (validated, 5 wrong tries per 15 minutes per
account, owner can make a new code which stops the old one). The code is shared
through the share sheet as text. An owner-generated link is not provided: link
handling was removed earlier at the owner's request.
