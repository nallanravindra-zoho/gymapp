-- Well-Being Companion: group categories, privacy per category and scoring (R9, R11).
--
-- Run once in the Supabase SQL editor, after 20261012000000_revised_requirements.sql.
-- Safe to run again: columns and tables are created only when missing, and
-- functions, triggers and policies are replaced.
--
-- What this adds
--   * Sharing per category and per group. group_members already has
--     share_workouts, share_breaks (shown as "Healthy Habits"), share_sleep,
--     share_screen_time and share_hobbies. Sleep, screen time and hobbies are
--     off until the member switches them on. The enum name "breaks" stays in
--     the database; only the labels in the app say Healthy Habits.
--   * create_group() and join_group() take the choices made in the onboarding
--     sheet, so nothing is shared for even a moment against the person's wish.
--   * Scoring, entirely on the server (one place, so every member is scored
--     the same way and nobody's raw data is sent to anyone else). The rules
--     are in docs/group-scoring.md; each rule is one small function below.
--   * group_score_snapshots: the scores of each member for each leaderboard
--     week (Monday to Sunday), so a closed week keeps its result.
--   * Reading for the app: group_available_categories(), group_overall_board(),
--     group_category_board() and group_member_metrics().
--
-- Privacy rules, in one place
--   * A category is only ever read for a member who has switched it on for
--     that group, and only shown to a member of the same group who has also
--     switched it on. Switching it off hides it at once (checked on every
--     read) and removes it from the stored snapshots.
--   * The overall number is stored (to rank with) but is never returned to
--     anyone: not by a function and not by a direct select. Clients only get a
--     rank and the names of the categories that count towards it.
--   * Body measurements, weight and height are never read by anything here.
--   * The functions that read sleep, screen time or targets are internal:
--     they are not executable by clients.

-- Sharing switches (also in 20261012; repeated so this file stands alone) -----
alter table public.group_members
  add column if not exists share_sleep boolean not null default false,
  add column if not exists share_screen_time boolean not null default false,
  add column if not exists share_hobbies boolean not null default false;

grant update (share_workouts, share_breaks, share_sleep, share_screen_time, share_hobbies)
  on public.group_members to authenticated;

-- Helpers --------------------------------------------------------------------

-- One category's switch for one member. Categories: workouts, habits, sleep,
-- screen_time. Anything else is "not shared".
create or replace function public.member_shares_category(
  p_group_id uuid, p_user_id uuid, p_category text)
returns boolean
language sql stable security definer set search_path = public
as $$
  select coalesce((
    select case p_category
             when 'workouts' then m.share_workouts
             when 'habits' then m.share_breaks
             when 'sleep' then m.share_sleep
             when 'screen_time' then m.share_screen_time
             else false end
    from public.group_members m
    where m.group_id = p_group_id and m.user_id = p_user_id
  ), false)
$$;

-- A boolean choice from the onboarding sheet, or the default when absent.
create or replace function public.pick_share(
  p_share jsonb, p_key text, p_default boolean)
returns boolean
language sql immutable
as $$
  select case when jsonb_typeof(p_share -> p_key) = 'boolean'
              then (p_share ->> p_key)::boolean else p_default end
$$;

-- Distance between two times of day, going the short way round midnight.
create or replace function public.minutes_apart(a integer, b integer)
returns integer
language sql immutable
as $$ select least(abs(a - b), 1440 - abs(a - b)) $$;

-- Full credit (10) up to [tolerance] away from the target, then falling in a
-- straight line to 0 once [tolerance + span] away. Used for sleep.
create or replace function public.score_proximity(
  deviation numeric, tolerance numeric, span numeric)
returns numeric
language sql immutable
as $$
  select 10 * greatest(0, least(1, 1 - (deviation - tolerance) / span))
$$;

-- Creating and joining, with the onboarding choices ------------------------------
-- p_share example: {"workouts": true, "habits": true, "sleep": false,
-- "screen_time": false, "hobbies": false}. Missing keys use the defaults
-- (workouts and habits on, everything else off).

drop function if exists public.create_group(text);
drop function if exists public.join_group(text);

create or replace function public.create_group(p_name text, p_share jsonb default null)
returns public.groups
language plpgsql security definer set search_path = public
as $$
declare
  uid uuid := (select auth.uid());
  g public.groups;
begin
  if uid is null then raise exception 'not_signed_in'; end if;
  if char_length(btrim(coalesce(p_name, ''))) not between 1 and 40 then
    raise exception 'invalid_name';
  end if;
  if (select count(*) from public.group_members where user_id = uid) >= 10 then
    raise exception 'too_many_groups';
  end if;
  insert into public.groups (name, owner_id, invite_code)
    values (btrim(p_name), uid, public.new_invite_code())
    returning * into g;
  insert into public.group_members
    (group_id, user_id, role, share_workouts, share_breaks, share_sleep,
     share_screen_time, share_hobbies)
  values (g.id, uid, 'owner',
    public.pick_share(p_share, 'workouts', true),
    public.pick_share(p_share, 'habits', true),
    public.pick_share(p_share, 'sleep', false),
    public.pick_share(p_share, 'screen_time', false),
    public.pick_share(p_share, 'hobbies', false));
  return g;
end $$;

create or replace function public.join_group(p_code text, p_share jsonb default null)
returns uuid
language plpgsql security definer set search_path = public
as $$
declare
  uid uuid := (select auth.uid());
  gid uuid;
begin
  if uid is null then raise exception 'not_signed_in'; end if;
  perform public.check_join_rate(uid);
  select id into gid from public.groups
    where invite_code = lower(btrim(p_code));
  if gid is null then
    insert into public.join_attempts (user_id) values (uid);
    return null;
  end if;
  if exists (select 1 from public.group_members
             where group_id = gid and user_id = uid) then
    return gid;
  end if;
  if (select count(*) from public.group_members where group_id = gid) >= 20 then
    raise exception 'group_full';
  end if;
  if (select count(*) from public.group_members where user_id = uid) >= 10 then
    raise exception 'too_many_groups';
  end if;
  insert into public.group_members
    (group_id, user_id, role, share_workouts, share_breaks, share_sleep,
     share_screen_time, share_hobbies)
  values (gid, uid, 'member',
    public.pick_share(p_share, 'workouts', true),
    public.pick_share(p_share, 'habits', true),
    public.pick_share(p_share, 'sleep', false),
    public.pick_share(p_share, 'screen_time', false),
    public.pick_share(p_share, 'hobbies', false));
  return gid;
end $$;

-- The roster now includes every switch (a new return type needs a drop).
drop function if exists public.group_roster(uuid);

create or replace function public.group_roster(p_group_id uuid)
returns table (
  user_id uuid, display_name text, role text, joined_at timestamptz,
  share_workouts boolean, share_breaks boolean,
  share_sleep boolean, share_screen_time boolean, share_hobbies boolean)
language sql stable security definer set search_path = public
as $$
  select m.user_id, coalesce(p.display_name, ''), m.role, m.joined_at,
         m.share_workouts, m.share_breaks,
         m.share_sleep, m.share_screen_time, m.share_hobbies
  from public.group_members m
  left join public.profiles p on p.id = m.user_id
  where m.group_id = p_group_id and public.is_group_member(p_group_id)
  order by m.joined_at, m.user_id
$$;

-- Daily scores (internal) --------------------------------------------------------
-- One row per category and day that has data, between two dates inclusive.
--   score  0 to 10 for that day (see docs/group-scoring.md)
--   amount the day's main figure, shown as a key metric:
--            workouts: active minutes (all sessions); habits: habit targets met;
--            sleep: minutes slept; screen_time: minutes of screen time
--   extra  the figure it was compared with, or a count:
--            workouts: sessions; habits: habits tracked;
--            sleep: target minutes; screen_time: the day's limit in minutes
-- Reads private tables, so clients cannot call it. It does not look at any
-- sharing switch: callers must.

create or replace function public.group_daily_scores(
  p_user_id uuid, p_from date, p_to date)
returns table (
  category text, day date, score numeric, amount numeric, extra numeric)
language sql stable security definer set search_path = public
as $$
  -- Workouts: the best single session decides the day. 45 active minutes is
  -- full credit; shorter sessions earn minutes / 45 of it. Further sessions
  -- add to the minutes shown but never to the score.
  select 'workouts'::text, w.local_date::date,
         round(10 * least(greatest(max(
           coalesce(w.active_seconds, w.duration_minutes * 60) / 60.0), 0) / 45.0, 1), 2),
         round(sum(coalesce(w.active_seconds, w.duration_minutes * 60) / 60.0), 1),
         count(*)::numeric
  from public.workouts w
  where w.user_id = p_user_id and w.deleted_at is null
    and w.local_date between to_char(p_from, 'YYYY-MM-DD') and to_char(p_to, 'YYYY-MM-DD')
  group by w.local_date

  union all

  -- Healthy Habits: for each active habit, today's count over its daily
  -- target, capped at 1 so extra logs add nothing. The day is the average over
  -- the habits, times 10. Only days with at least one log count as days with
  -- data; skipping a reminder is not a log.
  select 'habits'::text, d.local_date::date,
         round(10 * avg(least(coalesce(x.c, 0)::numeric / a.daily_target, 1)), 2),
         count(*) filter (where coalesce(x.c, 0) >= a.daily_target)::numeric,
         count(*)::numeric
  from (
    select distinct l.local_date
    from public.habit_logs l
    join public.habits h on h.id = l.habit_id and h.user_id = l.user_id
    where l.user_id = p_user_id and l.deleted_at is null and l.count > 0
      and h.deleted_at is null and h.is_active and h.daily_target > 0
      and l.local_date between to_char(p_from, 'YYYY-MM-DD') and to_char(p_to, 'YYYY-MM-DD')
  ) d
  join public.habits a
    on a.user_id = p_user_id and a.deleted_at is null and a.is_active
   and a.daily_target > 0
   -- A habit made later than the day does not count against it (one day of
   -- slack because created_at is a moment and local_date is the phone's day).
   and a.created_at::date <= d.local_date::date + 1
  left join lateral (
    select sum(l.count) as c from public.habit_logs l
    where l.user_id = p_user_id and l.habit_id = a.id
      and l.local_date = d.local_date and l.deleted_at is null
  ) x on true
  group by d.local_date

  union all

  -- Sleep Health: meeting the personal target, not sleeping longer.
  --   duration (60%): full credit within 30 minutes of the target duration,
  --                   none at 3 hours away, in either direction;
  --   schedule (40%): bedtime and wake time each against the personal target
  --                   times: full credit within 30 minutes, none at 2 hours.
  -- The longest log of a day is the night. With no target set, 23:00 to
  -- 07:00 (8 hours) is used, which is the app's own starting suggestion.
  select 'sleep'::text, n.local_date::date,
         round(0.6 * public.score_proximity(abs(n.duration_minutes - n.tdur), 30, 150)
             + 0.4 * (public.score_proximity(public.minutes_apart(n.bed_at, n.bed), 30, 90)
                    + public.score_proximity(public.minutes_apart(n.wake_at, n.wake), 30, 90)) / 2, 2),
         n.duration_minutes::numeric,
         n.tdur::numeric
  from (
    select distinct on (s.local_date)
           s.local_date, s.duration_minutes,
           t.bed, t.wake,
           case when (t.wake - t.bed + 1440) % 1440 = 0 then 1440
                else (t.wake - t.bed + 1440) % 1440 end as tdur,
           (((extract(epoch from s.bedtime_at)::bigint / 60 + s.tz_offset_minutes) % 1440) + 1440)::int % 1440 as bed_at,
           (((extract(epoch from s.wake_at)::bigint / 60 + s.tz_offset_minutes) % 1440) + 1440)::int % 1440 as wake_at
    from public.sleep_logs s
    cross join (
      select coalesce((select bedtime_minutes from public.sleep_targets where user_id = p_user_id), 1380) as bed,
             coalesce((select wake_minutes from public.sleep_targets where user_id = p_user_id), 420) as wake
    ) t
    where s.user_id = p_user_id and s.deleted_at is null and s.duration_minutes > 0
      and s.local_date between to_char(p_from, 'YYYY-MM-DD') and to_char(p_to, 'YYYY-MM-DD')
    order by s.local_date, s.duration_minutes desc
  ) n

  union all

  -- Screen Time: full credit at or under the day's own limit, falling in a
  -- straight line to 0 at twice the limit. Days without a limit have nothing
  -- to compare with and are left out.
  select 'screen_time'::text, s.local_date::date,
         round(10 * greatest(0, least(1, 2 - s.total_minutes::numeric / s.target_minutes)), 2),
         s.total_minutes::numeric,
         s.target_minutes::numeric
  from public.screen_time_daily s
  where s.user_id = p_user_id and s.deleted_at is null
    and s.target_minutes > 0 and s.total_minutes >= 0
    and s.local_date between to_char(p_from, 'YYYY-MM-DD') and to_char(p_to, 'YYYY-MM-DD')
$$;

-- Weekly category score: the mean of the daily scores on days with data.
create or replace function public.group_week_scores(p_user_id uuid, p_week_start date)
returns table (category text, score numeric, days integer)
language sql stable security definer set search_path = public
as $$
  select d.category, round(avg(d.score), 3), count(*)::int
  from public.group_daily_scores(p_user_id, p_week_start, p_week_start + 6) d
  group by d.category
$$;

-- Key metrics for one member, one category, one week: what the app shows when
-- a participant is opened. Figures only, no scores. Internal: the caller has
-- to have checked the sharing switches.
create or replace function public.group_category_metrics(
  p_user_id uuid, p_week_start date, p_category text)
returns jsonb
language sql stable security definer set search_path = public
as $$
  select case p_category
    when 'workouts' then jsonb_build_object(
      'active_days', count(*), 'active_minutes', round(sum(amount)),
      'sessions', sum(extra)::int)
    when 'habits' then jsonb_build_object(
      'days_logged', count(*), 'targets_met', sum(amount)::int,
      'habits_tracked', max(extra)::int)
    when 'sleep' then jsonb_build_object(
      'nights', count(*), 'average_minutes', round(avg(amount)),
      'target_minutes', max(extra)::int,
      'nights_near_target', count(*) filter (where abs(amount - extra) <= 30))
    when 'screen_time' then jsonb_build_object(
      'days', count(*), 'average_minutes', round(avg(amount)),
      'average_limit_minutes', round(avg(extra)),
      'days_within_limit', count(*) filter (where amount <= extra))
  end
  from public.group_daily_scores(p_user_id, p_week_start, p_week_start + 6) d
  where d.category = p_category
  having count(*) > 0
$$;

-- Snapshots ---------------------------------------------------------------------------
-- One row per member per leaderboard week (period_start is the Monday).
--   category_scores  {"workouts": {"score": 8.4, "days": 3}, ...}: only the
--                    categories the member shared when it was computed.
--   overall_score    the mean of those category scores. Stored to rank with.
--                    Never readable by clients.
--   overall_rank     1, 1, 3 style rank among the group's members.
-- Rows go when the member leaves (or their account is deleted) or the group
-- is removed.

create table if not exists public.group_score_snapshots (
  group_id uuid not null,
  period_start date not null,
  user_id uuid not null,
  category_scores jsonb not null default '{}',
  overall_score numeric check (overall_score is null or overall_score between 0 and 10),
  overall_rank integer check (overall_rank is null or overall_rank >= 1),
  computed_at timestamptz not null default now(),
  primary key (group_id, period_start, user_id),
  foreign key (group_id, user_id)
    references public.group_members (group_id, user_id) on delete cascade
);

alter table public.group_score_snapshots enable row level security;

-- Nobody reads another member's row directly: what others may see goes through
-- the functions below, which apply the sharing switches. Members read their
-- own rows, minus the overall number.
revoke all on public.group_score_snapshots from public, anon, authenticated;

drop policy if exists "group_score_snapshots: own rows" on public.group_score_snapshots;
create policy "group_score_snapshots: own rows" on public.group_score_snapshots
  for select to authenticated
  using (user_id = (select auth.uid()));

grant select (group_id, period_start, user_id, category_scores, overall_rank, computed_at)
  on public.group_score_snapshots to authenticated;

-- Works out the snapshot for a week. An open week (this one, or last week for
-- a day to allow for time zones) is recomputed when it is older than a
-- minute, when a member has joined, or after a sharing change. A closed week
-- is computed once, when first needed, and then kept.
create or replace function public.refresh_group_snapshot(p_group_id uuid, p_period date)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  members integer;
  have integer;
  oldest timestamptz;
  is_open boolean := p_period + 8 > (now() at time zone 'utc')::date;
begin
  select count(*) into members from public.group_members where group_id = p_group_id;
  select count(*), min(computed_at) into have, oldest
    from public.group_score_snapshots
    where group_id = p_group_id and period_start = p_period;
  if have > 0 and not is_open then return; end if;
  if have = members and oldest > now() - interval '1 minute' then return; end if;

  with scored as (
    select m.user_id, ws.category, ws.score, ws.days
    from public.group_members m
    cross join lateral public.group_week_scores(m.user_id, p_period) ws
    where m.group_id = p_group_id
      and case ws.category
            when 'workouts' then m.share_workouts
            when 'habits' then m.share_breaks
            when 'sleep' then m.share_sleep
            when 'screen_time' then m.share_screen_time
            else false end
  ), per_user as (
    select m.user_id,
           coalesce(jsonb_object_agg(s.category,
                      jsonb_build_object('score', s.score, 'days', s.days))
                    filter (where s.category is not null), '{}'::jsonb) as cs,
           round(avg(s.score), 3) as overall
    from public.group_members m
    left join scored s on s.user_id = m.user_id
    where m.group_id = p_group_id
    group by m.user_id
  )
  insert into public.group_score_snapshots
    (group_id, period_start, user_id, category_scores, overall_score,
     overall_rank, computed_at)
  select p_group_id, p_period, user_id, cs, overall, null, now() from per_user
  on conflict (group_id, period_start, user_id) do update
    set category_scores = excluded.category_scores,
        overall_score = excluded.overall_score,
        overall_rank = null,
        computed_at = now();

  update public.group_score_snapshots s
    set overall_rank = r.rk
    from (
      select user_id, rank() over (order by overall_score desc)::int as rk
      from public.group_score_snapshots
      where group_id = p_group_id and period_start = p_period
        and overall_score is not null
    ) r
    where s.group_id = p_group_id and s.period_start = p_period
      and s.user_id = r.user_id;
end $$;

-- Turning something off removes it from the stored snapshots straight away,
-- and any sharing change makes the group's open weeks be worked out again.
create or replace function public.group_members_sharing_changed()
returns trigger
language plpgsql security definer set search_path = public
as $$
declare
  dropped text[] := array_remove(array[
    case when old.share_workouts and not new.share_workouts then 'workouts' end,
    case when old.share_breaks and not new.share_breaks then 'habits' end,
    case when old.share_sleep and not new.share_sleep then 'sleep' end,
    case when old.share_screen_time and not new.share_screen_time then 'screen_time' end
  ], null);
begin
  if cardinality(dropped) > 0 then
    update public.group_score_snapshots
      set category_scores = category_scores - dropped,
          overall_score = null, overall_rank = null
      where group_id = new.group_id and user_id = new.user_id;
  end if;
  update public.group_score_snapshots set computed_at = 'epoch'
    where group_id = new.group_id;
  return null;
end $$;

drop trigger if exists group_members_sharing_changed on public.group_members;
create trigger group_members_sharing_changed
  after update of share_workouts, share_breaks, share_sleep, share_screen_time
  on public.group_members
  for each row execute function public.group_members_sharing_changed();

-- Reading, for the app --------------------------------------------------------------------

-- The tabs the caller can see for a week: 'overall' and any of workouts,
-- habits, sleep, screen_time. A category needs the caller to share it too, and
-- at least 2 members sharing it with data that week. Overall needs the caller
-- to share at least one category and at least 2 members to be ranked.
create or replace function public.group_available_categories(
  p_group_id uuid, p_week_start date)
returns table (category text)
language plpgsql volatile security definer set search_path = public
as $$
declare
  period date := date_trunc('week', p_week_start)::date;
  c text;
  any_shared boolean := false;
begin
  if not public.is_group_member(p_group_id) then return; end if;
  perform public.refresh_group_snapshot(p_group_id, period);
  foreach c in array array['workouts', 'habits', 'sleep', 'screen_time'] loop
    if public.member_shares_category(p_group_id, (select auth.uid()), c) then
      any_shared := true;
      if (select count(*) from public.group_score_snapshots s
          where s.group_id = p_group_id and s.period_start = period
            and s.category_scores ? c
            and public.member_shares_category(p_group_id, s.user_id, c)) >= 2 then
        category := c;
        return next;
      end if;
    end if;
  end loop;
  if any_shared and (
    select count(*) from public.group_score_snapshots s
    where s.group_id = p_group_id and s.period_start = period
      and s.overall_rank is not null) >= 2 then
    category := 'overall';
    return next;
  end if;
end $$;

-- The Overall tab: a rank and the categories behind it. There is no score.
-- The categories listed for a person are those they share and the caller
-- shares too.
create or replace function public.group_overall_board(
  p_group_id uuid, p_week_start date)
returns table (user_id uuid, display_name text, rank integer, categories text[])
language plpgsql volatile security definer set search_path = public
as $$
declare
  period date := date_trunc('week', p_week_start)::date;
  uid uuid := (select auth.uid());
begin
  if not public.is_group_member(p_group_id) then return; end if;
  if not exists (select 1 from public.group_available_categories(p_group_id, period) a
                 where a.category = 'overall') then
    return;
  end if;
  return query
    select s.user_id, coalesce(p.display_name, ''), s.overall_rank,
           array(select k from unnest(array['workouts', 'habits', 'sleep', 'screen_time']) k
                 where s.category_scores ? k
                   and public.member_shares_category(p_group_id, s.user_id, k)
                   and public.member_shares_category(p_group_id, uid, k))
    from public.group_score_snapshots s
    left join public.profiles p on p.id = s.user_id
    where s.group_id = p_group_id and s.period_start = period
      and s.overall_rank is not null
      and exists (select 1 from unnest(array['workouts', 'habits', 'sleep', 'screen_time']) k
                  where s.category_scores ? k
                    and public.member_shares_category(p_group_id, s.user_id, k))
    order by s.overall_rank, lower(coalesce(p.display_name, '')), s.user_id;
end $$;

-- One category tab: members who share it and have data, ranked, with their
-- key figures. No scores.
create or replace function public.group_category_board(
  p_group_id uuid, p_week_start date, p_category text)
returns table (user_id uuid, display_name text, rank integer, metrics jsonb)
language plpgsql volatile security definer set search_path = public
as $$
declare
  period date := date_trunc('week', p_week_start)::date;
begin
  if not public.is_group_member(p_group_id) then return; end if;
  if not exists (select 1 from public.group_available_categories(p_group_id, period) a
                 where a.category = p_category) then
    return;
  end if;
  return query
    select r.user_id, coalesce(p.display_name, ''), r.rk,
           public.group_category_metrics(r.user_id, period, p_category)
    from (
      select s.user_id,
             rank() over (order by (s.category_scores -> p_category ->> 'score')::numeric desc,
                                   (s.category_scores -> p_category ->> 'days')::int desc)::int as rk
      from public.group_score_snapshots s
      where s.group_id = p_group_id and s.period_start = period
        and s.category_scores ? p_category
        and public.member_shares_category(p_group_id, s.user_id, p_category)
    ) r
    left join public.profiles p on p.id = r.user_id
    order by r.rk, lower(coalesce(p.display_name, '')), r.user_id;
end $$;

-- A participant's shared key metrics for one category and week: the summary
-- and one figure per day. Only when that person shares the category with the
-- group and the caller is that person or shares it too.
create or replace function public.group_member_metrics(
  p_group_id uuid, p_user_id uuid, p_week_start date, p_category text)
returns jsonb
language plpgsql stable security definer set search_path = public
as $$
declare
  period date := date_trunc('week', p_week_start)::date;
  uid uuid := (select auth.uid());
  summary jsonb;
begin
  if not public.is_group_member(p_group_id) then return null; end if;
  if not public.member_shares_category(p_group_id, p_user_id, p_category) then
    return null;
  end if;
  if p_user_id <> uid
     and not public.member_shares_category(p_group_id, uid, p_category) then
    return null;
  end if;
  summary := public.group_category_metrics(p_user_id, period, p_category);
  if summary is null then return null; end if;
  return jsonb_build_object(
    'summary', summary,
    'days', (select coalesce(jsonb_agg(jsonb_build_object(
                      'date', d.day, 'amount', round(d.amount)) order by d.day), '[]'::jsonb)
             from public.group_daily_scores(p_user_id, period, period + 6) d
             where d.category = p_category));
end $$;

-- Permissions --------------------------------------------------------------------------------
revoke all on function
  public.member_shares_category(uuid, uuid, text),
  public.pick_share(jsonb, text, boolean),
  public.minutes_apart(integer, integer),
  public.score_proximity(numeric, numeric, numeric),
  public.create_group(text, jsonb),
  public.join_group(text, jsonb),
  public.group_roster(uuid),
  public.group_daily_scores(uuid, date, date),
  public.group_week_scores(uuid, date),
  public.group_category_metrics(uuid, date, text),
  public.refresh_group_snapshot(uuid, date),
  public.group_members_sharing_changed(),
  public.group_available_categories(uuid, date),
  public.group_overall_board(uuid, date),
  public.group_category_board(uuid, date, text),
  public.group_member_metrics(uuid, uuid, date, text)
from public, anon, authenticated;

-- member_shares_category() stays internal: asking about someone else's
-- switches is not something a client needs.
grant execute on function
  public.create_group(text, jsonb),
  public.join_group(text, jsonb),
  public.group_roster(uuid),
  public.group_available_categories(uuid, date),
  public.group_overall_board(uuid, date),
  public.group_category_board(uuid, date, text),
  public.group_member_metrics(uuid, uuid, date, text)
to authenticated;
