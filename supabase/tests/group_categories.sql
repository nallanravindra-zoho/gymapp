-- Behaviour tests for 20261013000000_group_categories.sql (R9, R11).
--
-- Run on a database with the harness and ALL migrations applied (this one is
-- applied twice by the callers, to prove it can be re-run), as the superuser.
-- Every check raises an exception on failure, so a clean run means all passed.
--
-- This file holds the privacy guard for sleep, screen time and body metrics
-- (it replaces the blanket "no function mentions sleep" check that
-- tests/groups.sql had before categories existed).

\set ON_ERROR_STOP on
\set alice '''aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'''
\set bob   '''bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'''
\set cara  '''cccccccc-cccc-4ccc-8ccc-cccccccccccc'''
\set dan   '''dddddddd-dddd-4ddd-8ddd-dddddddddddd'''
\set eve   '''eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee'''
\set fay   '''ffffffff-ffff-4fff-8fff-ffffffffffff'''

set timezone = 'UTC';

insert into auth.users (id)
  values (:alice), (:bob), (:cara), (:dan), (:eve), (:fay);
insert into profiles (id, display_name, created_at, updated_at) values
  (:alice, 'Alice', now(), now()), (:bob, 'Bob', now(), now()),
  (:cara, 'Cara', now(), now()), (:dan, 'Dan', now(), now()),
  (:eve, 'Eve', now(), now()), (:fay, 'Fay', now(), now());

create or replace function pg_temp.as_user(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  execute 'set role authenticated';
end $$;
create or replace function pg_temp.assert(cond boolean, msg text) returns void language plpgsql as $$
begin
  if not coalesce(cond, false) then raise exception 'FAILED: %', msg; end if;
end $$;
-- Runs a statement that must fail with this SQLSTATE class text.
create or replace function pg_temp.must_fail(stmt text, msg text) returns void language plpgsql as $$
begin
  begin
    execute stmt;
  exception when insufficient_privilege or raise_exception then
    return;
  end;
  raise exception 'FAILED: %', msg;
end $$;
grant all on function pg_temp.as_user(text), pg_temp.assert(boolean, text),
  pg_temp.must_fail(text, text) to public;

-- This week's Monday, and a day of it as text.
create temp table wk as select date_trunc('week', now())::date as d;
grant all on wk to public;
create or replace function pg_temp.day(n integer) returns text language sql as
  $$ select to_char((select d from wk) + n, 'YYYY-MM-DD') $$;
grant all on function pg_temp.day(integer) to public;

create or replace function pg_temp.workout(u uuid, n integer, minutes integer,
  active_s integer default null) returns void language sql as $$
  insert into workouts (id, user_id, workout_type_id, started_at, ended_at,
    duration_minutes, active_seconds, source, local_date, created_at, updated_at)
  values (gen_random_uuid(), u, 'builtin-run',
    ((select d from wk) + n)::timestamptz + interval '8 hours',
    ((select d from wk) + n)::timestamptz + interval '9 hours',
    minutes, active_s, 'manual', pg_temp.day(n), now(), now())
$$;

create or replace function pg_temp.sleep(u uuid, n integer, bed_hour numeric,
  minutes integer, tz integer default 0) returns void language sql as $$
  insert into sleep_logs (id, user_id, bedtime_at, wake_at, duration_minutes,
    tz_offset_minutes, local_date, created_at, updated_at)
  values (gen_random_uuid(), u,
    ((select d from wk) + n)::timestamptz + (bed_hour || ' hours')::interval
      - (tz || ' minutes')::interval,
    ((select d from wk) + n)::timestamptz + (bed_hour || ' hours')::interval
      + (minutes || ' minutes')::interval - (tz || ' minutes')::interval,
    minutes, tz, pg_temp.day(n), now(), now())
$$;

create or replace function pg_temp.screen(u uuid, n integer, total integer,
  target integer) returns void language sql as $$
  insert into screen_time_daily (id, user_id, local_date, total_minutes,
    target_minutes, created_at, updated_at)
  values (gen_random_uuid(), u, pg_temp.day(n), total, target, now(), now())
$$;

create or replace function pg_temp.habit_log(u uuid, h uuid, n integer, c integer)
returns void language sql as $$
  insert into habit_logs (id, user_id, habit_id, logged_at, count, local_date,
    created_at, updated_at)
  values (gen_random_uuid(), u, h, ((select d from wk) + n)::timestamptz + interval '10 hours',
    c, pg_temp.day(n), now(), now())
$$;

-- 1. Daily scoring rules (internal function, checked directly) --------------------------
-- Eve: workouts.
select pg_temp.workout(:eve, 0, 30);
select pg_temp.workout(:eve, 0, 30);
select pg_temp.workout(:eve, 0, 30);          -- 3 x 30: best session 30 -> 6.67
select pg_temp.workout(:eve, 1, 50);          -- over 45 -> capped at 10
select pg_temp.workout(:eve, 2, 60, 2700);    -- active 45 min wins over 60 elapsed
select pg_temp.workout(:eve, 3, 20);
update workouts set deleted_at = now(), updated_at = now()
  where user_id = :eve and local_date = pg_temp.day(3);   -- deleted: ignored

create temp table eve_w as
  select * from group_daily_scores(:eve, (select d from wk), (select d from wk) + 6)
  where category = 'workouts';
select pg_temp.assert((select count(*) from eve_w) = 3, 'a deleted workout day has no data');
select pg_temp.assert((select score from eve_w where day = (select d from wk)) = 6.67,
  'three 30 minute sessions score by the best one (6.67), not the total');
select pg_temp.assert((select amount from eve_w where day = (select d from wk)) = 90
  and (select extra from eve_w where day = (select d from wk)) = 3,
  'but the minutes and session count are still reported');
select pg_temp.assert((select score from eve_w where day = (select d from wk) + 1) = 10,
  'a 50 minute session is capped at 10');
select pg_temp.assert((select score from eve_w where day = (select d from wk) + 2) = 10
  and (select amount from eve_w where day = (select d from wk) + 2) = 45,
  'active time (45 min) is used when it is known');
select pg_temp.assert((select score from group_week_scores(:eve, (select d from wk))
  where category = 'workouts') = round((6.67 + 10 + 10) / 3, 3),
  'the weekly score is the mean over days with data');
select pg_temp.assert(not exists (select 1 from group_daily_scores(:eve, (select d from wk), (select d from wk) + 6)
  where score < 0 or score > 10), 'no daily score is outside 0 to 10');

-- Eve: healthy habits. Water 2 a day, stretch 4 a day.
insert into habits (id, user_id, name, kind, daily_target, created_at, updated_at) values
  ('e0000000-0000-4000-8000-000000000001', :eve, 'Water', 'water', 2, now() - interval '60 days', now()),
  ('e0000000-0000-4000-8000-000000000002', :eve, 'Stretch', 'stretch', 4, now() - interval '60 days', now()),
  ('e0000000-0000-4000-8000-000000000003', :eve, 'Retired', 'custom', 1, now() - interval '60 days', now());
update habits set is_active = false, updated_at = now() where name = 'Retired' and user_id = :eve;
select pg_temp.habit_log(:eve, 'e0000000-0000-4000-8000-000000000001', 0, 5);  -- 5 of 2: capped
select pg_temp.habit_log(:eve, 'e0000000-0000-4000-8000-000000000002', 0, 2);  -- 2 of 4
select pg_temp.habit_log(:eve, 'e0000000-0000-4000-8000-000000000003', 1, 1);  -- inactive habit
insert into habit_skips (id, user_id, habit_id, skipped_at, local_date, created_at, updated_at)
  values (gen_random_uuid(), :eve, 'e0000000-0000-4000-8000-000000000001', now(),
          pg_temp.day(2), now(), now());                                       -- a skip is not a log
select pg_temp.assert((select count(*) from group_daily_scores(:eve, (select d from wk), (select d from wk) + 6)
  where category = 'habits') = 1, 'only the day with a real log of an active habit has data');
select pg_temp.assert((select score from group_daily_scores(:eve, (select d from wk), (select d from wk) + 6)
  where category = 'habits') = 7.5,
  'water capped at 1 (5 of 2) and stretch 0.5 average to 7.5');
select pg_temp.assert((select amount from group_daily_scores(:eve, (select d from wk), (select d from wk) + 6)
  where category = 'habits') = 1, 'one habit target was met');
-- Logging far more water cannot raise it.
select pg_temp.habit_log(:eve, 'e0000000-0000-4000-8000-000000000001', 0, 50);
select pg_temp.assert((select score from group_daily_scores(:eve, (select d from wk), (select d from wk) + 6)
  where category = 'habits') = 7.5, 'repeated logging cannot inflate the habits score');

-- Eve: sleep, with no target set (23:00 to 07:00, 8 hours, is assumed).
select pg_temp.sleep(:eve, 0, 23, 480);                 -- on target: 10
select pg_temp.sleep(:eve, 0, 14, 30);                  -- a nap the same day: ignored
select pg_temp.sleep(:eve, 1, 23, 600);                 -- 10 h: 23:00 to 09:00
select pg_temp.sleep(:eve, 2, 23, 360);                 -- 6 h: 23:00 to 05:00
select pg_temp.sleep(:eve, 3, 23, 480, 330);            -- India: 23:00 local (17:30 UTC), on target
create temp table eve_s as
  select * from group_daily_scores(:eve, (select d from wk), (select d from wk) + 6)
  where category = 'sleep';
select pg_temp.assert((select count(*) from eve_s) = 4, 'one night per day');
select pg_temp.assert((select score from eve_s where day = (select d from wk)) = 10
  and (select amount from eve_s where day = (select d from wk)) = 480,
  'the longest log is the night, and meeting the target scores 10');
-- Ten hours: duration 120 off -> 4.0; bedtime 0 off -> 10, wake 120 off -> 0, so
-- schedule 5.0; 0.6 * 4 + 0.4 * 5 = 4.4.
select pg_temp.assert((select score from eve_s where day = (select d from wk) + 1) = 4.4,
  'sleeping 2 hours over the target scores 4.4, less than meeting it');
-- Six hours: duration 120 off -> 4.0; bedtime 10, wake 120 off -> 0: 4.4 too.
select pg_temp.assert((select score from eve_s where day = (select d from wk) + 2) = 4.4,
  'sleeping 2 hours under scores the same as 2 hours over');
select pg_temp.assert((select score from eve_s where day = (select d from wk) + 3) = 10,
  'times are read in the person''s own time zone');

-- Fay has her own target, 22:00 to 06:00, and meets it.
insert into sleep_targets (user_id, bedtime_minutes, wake_minutes, updated_at)
  values (:fay, 1320, 360, now());
select pg_temp.sleep(:fay, 0, 22, 480);
select pg_temp.assert((select score from group_daily_scores(:fay, (select d from wk), (select d from wk) + 6)
  where category = 'sleep') = 10 and (select extra from group_daily_scores(:fay, (select d from wk), (select d from wk) + 6)
  where category = 'sleep') = 480, 'a personal target is used instead of the default');
-- Bedtime exactly on the other side of midnight is not "far": 23:50 vs 00:10.
select pg_temp.assert(minutes_apart(1430, 10) = 20, 'times of day wrap around midnight');

-- Eve: screen time.
select pg_temp.screen(:eve, 0, 120, 120);   -- at the limit: 10
select pg_temp.screen(:eve, 1, 150, 120);   -- 25% over: 7.5
select pg_temp.screen(:eve, 2, 240, 120);   -- double: 0
select pg_temp.screen(:eve, 3, 300, 120);   -- more than double: still 0
select pg_temp.screen(:eve, 4, 30, 120);    -- well under: 10, not more
insert into screen_time_daily (id, user_id, local_date, total_minutes, created_at, updated_at)
  values (gen_random_uuid(), :eve, pg_temp.day(5), 500, now(), now());   -- no limit: left out
create temp table eve_t as
  select * from group_daily_scores(:eve, (select d from wk), (select d from wk) + 6)
  where category = 'screen_time';
select pg_temp.assert((select count(*) from eve_t) = 5, 'a day without a limit has no screen time score');
select pg_temp.assert((select array_agg(score order by day) from eve_t) = array[10, 7.5, 0, 0, 10]::numeric[],
  'full credit at or under the limit, falling to 0 at twice the limit');

-- Only the week asked for is read.
select pg_temp.assert((select count(*) from group_daily_scores(:eve, (select d from wk) + 7, (select d from wk) + 13)) = 0,
  'the next week has no data');

-- 2. A group with different sharing choices --------------------------------------------------
select pg_temp.as_user(:alice);
create temp table g as select * from create_group('Crew',
  '{"workouts": true, "habits": true, "sleep": true, "screen_time": true}');
grant all on g to public;
select pg_temp.assert((select share_sleep and share_screen_time from group_members where user_id = :alice),
  'the creator can opt in while creating');
reset role;
select pg_temp.as_user(:bob);
select pg_temp.assert(join_group((select invite_code from g),
  '{"workouts": true, "habits": true, "sleep": true, "screen_time": true, "hobbies": "yes"}') is not null,
  'bob joins');
select pg_temp.assert((select not share_hobbies from group_members where user_id = :bob),
  'a value that is not true or false is ignored, so hobbies stay off');
reset role;
select pg_temp.as_user(:cara);
select join_group((select invite_code from g));
select pg_temp.assert((select share_workouts and share_breaks and not share_sleep
                              and not share_screen_time and not share_hobbies
                       from group_members where user_id = :cara),
  'without choices: workouts and habits on, sleep, screen time and hobbies off');
reset role;
select pg_temp.as_user(:dan);
select pg_temp.assert((select count(*) from group_members) = 0, 'dan is outside the group');
reset role;

-- Alice: workouts 2 days, habits, sleep, screen time.
select pg_temp.workout(:alice, 0, 30);
select pg_temp.workout(:alice, 0, 45);                 -- 10
select pg_temp.workout(:alice, 1, 0, 1350);            -- 22.5 active min -> 5
insert into habits (id, user_id, name, kind, daily_target, created_at, updated_at) values
  ('a0000000-0000-4000-8000-0000000000a1', :alice, 'Water', 'water', 2, now() - interval '60 days', now()),
  ('a0000000-0000-4000-8000-0000000000a2', :alice, 'Stretch', 'stretch', 1, now() - interval '60 days', now());
select pg_temp.habit_log(:alice, 'a0000000-0000-4000-8000-0000000000a1', 0, 3);   -- water met, stretch not: 5
select pg_temp.sleep(:alice, 1, 23, 480);                                        -- 10
select pg_temp.screen(:alice, 0, 120, 120);                                      -- 10
-- Bob
select pg_temp.workout(:bob, 0, 90);                                             -- 10
insert into habits (id, user_id, name, kind, daily_target, created_at, updated_at) values
  ('b0000000-0000-4000-8000-0000000000b1', :bob, 'Water', 'water', 2, now() - interval '60 days', now()),
  ('b0000000-0000-4000-8000-0000000000b2', :bob, 'Stretch', 'stretch', 1, now() - interval '60 days', now());
select pg_temp.habit_log(:bob, 'b0000000-0000-4000-8000-0000000000b1', 0, 2);
select pg_temp.habit_log(:bob, 'b0000000-0000-4000-8000-0000000000b2', 0, 1);    -- 10
select pg_temp.sleep(:bob, 1, 22, 540);                  -- 9 h from 22:00: longer is not better
select pg_temp.screen(:bob, 0, 180, 120);                -- 5
-- Cara shares workouts only (the default), but has sleep and screen time data.
select pg_temp.workout(:cara, 0, 9);                     -- 2
select pg_temp.sleep(:cara, 1, 23, 480);
select pg_temp.screen(:cara, 0, 60, 120);

-- 3. Snapshots ----------------------------------------------------------------------------------
select pg_temp.as_user(:alice);
create temp table av as
  select category from group_available_categories((select id from g), (select d from wk));
grant all on av to public;
reset role;
select pg_temp.assert((select array_agg(category order by category) from av)
  = array['habits', 'overall', 'screen_time', 'sleep', 'workouts'],
  'alice shares everything and 2 or more members share each: all tabs');

select pg_temp.assert((select count(*) from group_score_snapshots) = 3, 'one snapshot row per member');
select pg_temp.assert((select category_scores ? 'sleep' from group_score_snapshots where user_id = :bob),
  'bob''s sleep is in his snapshot');
select pg_temp.assert(not (select category_scores ? 'sleep' or category_scores ? 'screen_time'
                           from group_score_snapshots where user_id = :cara),
  'cara does not share sleep or screen time, so they are not in her snapshot');
select pg_temp.assert((select category_scores -> 'workouts' ->> 'score' from group_score_snapshots where user_id = :alice)::numeric = 7.5
  and (select category_scores -> 'workouts' ->> 'days' from group_score_snapshots where user_id = :alice) = '2',
  'alice: workouts (10 + 5) / 2 = 7.5 over 2 days');
select pg_temp.assert((select overall_score from group_score_snapshots where user_id = :alice) = 8.125,
  'alice overall = mean(7.5, 5, 10, 10) = 8.125');
select pg_temp.assert((select overall_score from group_score_snapshots where user_id = :bob) = 8.283,
  'bob overall = mean(10, 10, 8.13, 5) = 8.2825 -> 8.283');
select pg_temp.assert((select overall_score from group_score_snapshots where user_id = :cara) = 2,
  'cara is scored on the one category she shares');
select pg_temp.assert((select array_agg(overall_rank order by user_id) from group_score_snapshots)
  = array[2, 1, 3], 'ranks: bob 1, alice 2, cara 3');
select pg_temp.assert((select period_start from group_score_snapshots limit 1) = (select d from wk),
  'the period is the Monday');

-- 4. What a member can read -----------------------------------------------------------------------
select pg_temp.as_user(:alice);
-- Direct access: only her own row, never the overall number.
select pg_temp.assert((select count(*) from group_score_snapshots) = 1, 'alice reads only her own snapshot row');
select pg_temp.assert((select overall_rank from group_score_snapshots) = 2, 'she can see her own rank');
select pg_temp.must_fail('select overall_score from group_score_snapshots',
  'the overall number is not readable');
select pg_temp.must_fail('select * from group_score_snapshots',
  'select * is refused too, because it would include the overall number');
select pg_temp.must_fail('update group_score_snapshots set overall_rank = 1',
  'snapshots cannot be edited by clients');
select pg_temp.must_fail('delete from group_score_snapshots', 'or deleted');
select pg_temp.must_fail('insert into group_score_snapshots (group_id, period_start, user_id) select id, current_date, ''aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'' from groups',
  'or created');
select pg_temp.must_fail('select group_daily_scores(''bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'', current_date, current_date)',
  'raw scoring is not callable by clients');
select pg_temp.must_fail('select refresh_group_snapshot((select id from groups), current_date)',
  'refreshing is not callable by clients');
select pg_temp.must_fail('select member_shares_category((select id from groups), ''bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'', ''sleep'')',
  'nor is asking about another member''s switches');

-- Overall: ranks and categories, no numbers.
create temp table ob as
  select * from group_overall_board((select id from g), (select d from wk));
select pg_temp.assert((select array_agg(display_name || ':' || rank order by rank) from ob)
  = array['Bob:1', 'Alice:2', 'Cara:3'], 'overall ranks');
select pg_temp.assert((select categories from ob where display_name = 'Bob')
  = array['workouts', 'habits', 'sleep', 'screen_time'], 'bob contributes four categories');
select pg_temp.assert((select categories from ob where display_name = 'Cara') = array['workouts'],
  'cara contributes only what she shares');
select pg_temp.assert((select array_agg(k order by k) from (
    select jsonb_object_keys(to_jsonb(o)) k from ob o limit 4) x)
  = array['categories', 'display_name', 'rank', 'user_id'],
  'the overall board has no score column');
select pg_temp.assert(not exists (select 1 from ob o where to_jsonb(o)::text ~ '8\.[0-9]'),
  'no overall number appears in the rows');

-- A category tab: ranked with key figures.
create temp table wb as
  select * from group_category_board((select id from g), (select d from wk), 'workouts');
select pg_temp.assert((select array_agg(display_name || ':' || rank order by rank, display_name) from wb)
  = array['Bob:1', 'Alice:2', 'Cara:3'], 'workouts: bob 10, alice 7.5, cara 2');
select pg_temp.assert((select metrics from wb where display_name = 'Alice')
  = '{"sessions": 3, "active_days": 2, "active_minutes": 98}', 'alice''s key workout figures: 75 + 22.5 minutes');
select pg_temp.assert((select count(*) from group_category_board((select id from g), (select d from wk), 'screen_time')) = 2,
  'cara''s screen time is not on the board: she does not share it');
select pg_temp.assert((select array_agg(display_name order by rank) from group_category_board((select id from g), (select d from wk), 'sleep'))
  = array['Alice', 'Bob'], 'sleep: meeting the target (alice) beats sleeping longer (bob)');
select pg_temp.assert((select metrics from group_category_board((select id from g), (select d from wk), 'sleep') where display_name = 'Bob')
  = '{"nights": 1, "average_minutes": 540, "target_minutes": 480, "nights_near_target": 0}',
  'sleep figures');
select pg_temp.assert((select count(*) from group_category_board((select id from g), (select d from wk), 'nonsense')) = 0,
  'an unknown category has no board');

-- Participant details.
select pg_temp.assert((group_member_metrics((select id from g), :bob, (select d from wk), 'sleep') -> 'summary' ->> 'average_minutes') = '540',
  'alice may open bob''s sleep: both share it');
select pg_temp.assert(jsonb_array_length(group_member_metrics((select id from g), :bob, (select d from wk), 'sleep') -> 'days') = 1,
  'with one figure per day');
select pg_temp.assert(group_member_metrics((select id from g), :cara, (select d from wk), 'sleep') is null,
  'cara does not share sleep, so there is nothing to open');
select pg_temp.assert(group_member_metrics((select id from g), :cara, (select d from wk), 'screen_time') is null,
  'nor screen time');
select pg_temp.assert(group_member_metrics((select id from g), :cara, (select d from wk), 'workouts') is not null,
  'but her workouts');
select pg_temp.assert(group_member_metrics((select id from g), :dan, (select d from wk), 'workouts') is null,
  'a stranger to the group has nothing');
reset role;

-- Cara shares workouts and habits only, so she sees only those.
select pg_temp.as_user(:cara);
select pg_temp.assert((select array_agg(category order by category) from
  group_available_categories((select id from g), (select d from wk))) = array['habits', 'overall', 'workouts'],
  'cara sees the tabs she shares (workouts, habits) and overall, but not sleep or screen time');
select pg_temp.assert((select count(*) from group_category_board((select id from g), (select d from wk), 'sleep')) = 0,
  'cara does not share sleep, so she cannot see anyone''s');
select pg_temp.assert((select count(*) from group_category_board((select id from g), (select d from wk), 'screen_time')) = 0,
  'nor screen time');
select pg_temp.assert(group_member_metrics((select id from g), :alice, (select d from wk), 'sleep') is null,
  'cara cannot open alice''s sleep');
select pg_temp.assert(group_member_metrics((select id from g), :alice, (select d from wk), 'workouts') is not null,
  'but can open her workouts');
select pg_temp.assert((select categories from group_overall_board((select id from g), (select d from wk)) where display_name = 'Alice')
  = array['workouts', 'habits'], 'in overall, alice''s sleep and screen time are not listed for cara');
select pg_temp.assert((select count(*) from group_score_snapshots) = 1, 'cara reads only her own row');
reset role;

-- Dan, outside the group, gets nothing.
select pg_temp.as_user(:dan);
select pg_temp.assert((select count(*) from group_available_categories((select id from g), (select d from wk))) = 0,
  'no categories for a non-member');
select pg_temp.assert((select count(*) from group_overall_board((select id from g), (select d from wk))) = 0
  and (select count(*) from group_category_board((select id from g), (select d from wk), 'workouts')) = 0
  and group_member_metrics((select id from g), :alice, (select d from wk), 'workouts') is null
  and (select count(*) from group_score_snapshots) = 0,
  'no boards, details or snapshots for a non-member');
reset role;

-- Anonymous callers cannot run any of it.
select pg_temp.assert(not has_function_privilege('anon', 'group_overall_board(uuid, date)', 'execute')
  and not has_function_privilege('anon', 'group_category_board(uuid, date, text)', 'execute')
  and not has_function_privilege('anon', 'group_member_metrics(uuid, uuid, date, text)', 'execute')
  and not has_function_privilege('anon', 'group_available_categories(uuid, date)', 'execute')
  and not has_function_privilege('anon', 'join_group(text, jsonb)', 'execute'),
  'anonymous users cannot call the group functions');

-- 5. Turning a category off hides it at once and clears it from snapshots ----------------------------
select pg_temp.as_user(:bob);
update group_members set share_sleep = false where user_id = :bob;
reset role;
select pg_temp.assert(not (select category_scores ? 'sleep' from group_score_snapshots where user_id = :bob),
  'bob''s sleep is removed from his stored snapshot at once');
select pg_temp.assert((select overall_score is null from group_score_snapshots where user_id = :bob),
  'and his stored overall is cleared until it is worked out again');
select pg_temp.as_user(:alice);
select pg_temp.assert(not exists (select 1 from group_available_categories((select id from g), (select d from wk)) where category = 'sleep'),
  'sleep needs 2 members sharing it: alice alone is not enough');
select pg_temp.assert((select count(*) from group_category_board((select id from g), (select d from wk), 'sleep')) = 0,
  'so the sleep board is empty');
select pg_temp.assert(group_member_metrics((select id from g), :bob, (select d from wk), 'sleep') is null,
  'and bob''s sleep cannot be opened');
select pg_temp.assert((select categories from group_overall_board((select id from g), (select d from wk)) where display_name = 'Bob')
  = array['workouts', 'habits', 'screen_time'], 'bob''s overall no longer lists sleep');
reset role;
select pg_temp.assert((select overall_score from group_score_snapshots where user_id = :bob) = 8.333,
  'his overall is worked out again without sleep: mean(10, 10, 5)');
select pg_temp.assert((select array_agg(overall_rank order by user_id) from group_score_snapshots) = array[2, 1, 3],
  'ranks are unchanged here');

-- Opting back in puts it back (sleep has 2 sharers again).
select pg_temp.as_user(:bob);
update group_members set share_sleep = true where user_id = :bob;
reset role;
select pg_temp.as_user(:alice);
select pg_temp.assert(exists (select 1 from group_available_categories((select id from g), (select d from wk)) where category = 'sleep'),
  'sleep is back after bob opts in again');
reset role;
select pg_temp.assert((select overall_score from group_score_snapshots where user_id = :bob) = 8.283,
  'and his overall includes it again');

-- 6. Enough data: at least 2 members sharing a category with data ------------------------------------
select pg_temp.as_user(:dan);
create temp table g2 as select * from create_group('Pair', '{"workouts": true}');
grant all on g2 to public;
reset role;
select pg_temp.workout(:dan, 0, 45);
select pg_temp.as_user(:dan);
select pg_temp.assert((select count(*) from group_available_categories((select id from g2), (select d from wk))) = 0,
  'a group of one has no tabs, not even overall');
reset role;
select pg_temp.as_user(:fay);
select join_group((select invite_code from g2), '{"workouts": true, "habits": false}');
reset role;
select pg_temp.as_user(:dan);
select pg_temp.assert((select count(*) from group_available_categories((select id from g2), (select d from wk))) = 0,
  'a second member who shares but has no data does not make a tab');
reset role;
select pg_temp.workout(:fay, 1, 20);
update group_score_snapshots set computed_at = 'epoch';   -- skip the one minute reuse
select pg_temp.as_user(:dan);
select pg_temp.assert((select array_agg(category order by category) from group_available_categories((select id from g2), (select d from wk)))
  = array['overall', 'workouts'], 'two members with data: workouts and overall');
select pg_temp.assert(not exists (select 1 from group_available_categories((select id from g2), (select d from wk)) where category = 'habits'),
  'habits never appears without data and sharing');
reset role;
-- The old Monday-to-Sunday leaderboard keeps working for workouts.
select pg_temp.as_user(:dan);
select pg_temp.assert((select count(*) from group_leaderboard((select id from g2), (select d from wk))) = 2,
  'the volume and consistency leaderboard still lists both');
reset role;

-- 7. Closed weeks are kept ---------------------------------------------------------------------------------
-- Five weeks ago: computed the first time it is asked for, then not changed.
create temp table old_wk as select (select d from wk) - 35 as d;
grant all on old_wk to public;
insert into workouts (id, user_id, workout_type_id, started_at, ended_at, duration_minutes,
  source, local_date, created_at, updated_at) values
  (gen_random_uuid(), :dan, 'builtin-run', (select d from old_wk)::timestamptz, (select d from old_wk)::timestamptz + interval '1 hour', 45,
   'manual', to_char((select d from old_wk), 'YYYY-MM-DD'), now(), now()),
  (gen_random_uuid(), :fay, 'builtin-run', (select d from old_wk)::timestamptz, (select d from old_wk)::timestamptz + interval '1 hour', 45,
   'manual', to_char((select d from old_wk), 'YYYY-MM-DD'), now(), now());
select pg_temp.as_user(:dan);
select pg_temp.assert((select count(*) from group_category_board((select id from g2), (select d from old_wk), 'workouts')) = 2,
  'last month''s week can be read');
reset role;
select pg_temp.assert((select (category_scores -> 'workouts' ->> 'days')::int from group_score_snapshots
  where user_id = :dan and period_start = (select d from old_wk)) = 1, 'one day in the closed week');
insert into workouts (id, user_id, workout_type_id, started_at, ended_at, duration_minutes,
  source, local_date, created_at, updated_at)
  values (gen_random_uuid(), :dan, 'builtin-run', (select d from old_wk)::timestamptz, (select d from old_wk)::timestamptz + interval '1 hour', 45,
   'manual', to_char((select d from old_wk) + 1, 'YYYY-MM-DD'), now(), now());
update group_score_snapshots set computed_at = 'epoch';
select pg_temp.as_user(:dan);
select count(*) from group_category_board((select id from g2), (select d from old_wk), 'workouts');
reset role;
select pg_temp.assert((select (category_scores -> 'workouts' ->> 'days')::int from group_score_snapshots
  where user_id = :dan and period_start = (select d from old_wk)) = 1,
  'the closed week keeps its snapshot even if data is added later');
-- The open week is worked out again (a new workout shows up).
update group_score_snapshots set computed_at = 'epoch';
select pg_temp.workout(:dan, 2, 45);
select pg_temp.as_user(:dan);
select count(*) from group_category_board((select id from g2), (select d from wk), 'workouts');
reset role;
select pg_temp.assert((select (category_scores -> 'workouts' ->> 'days')::int from group_score_snapshots
  where user_id = :dan and period_start = (select d from wk) and group_id = (select id from g2)) = 2,
  'this week is recomputed');

-- 8. Leaving removes a member''s snapshots; the app can still delete an account -----------------------------
select pg_temp.as_user(:cara);
delete from group_members where user_id = :cara and group_id = (select id from g);
reset role;
select pg_temp.assert(not exists (select 1 from group_score_snapshots where user_id = :cara),
  'a member who leaves leaves no snapshot rows');
select pg_temp.assert((select array_agg(overall_rank order by user_id) from group_score_snapshots where group_id = (select id from g)) is not null,
  'the others keep theirs');

-- Deleting an account removes its snapshots too.
delete from auth.users where id = :bob;
select pg_temp.assert(not exists (select 1 from group_score_snapshots where user_id = :bob),
  'deleting an account leaves no snapshot rows');

-- 9. The guard: which functions may read what ----------------------------------------------------------------
-- Replaces the blanket check in tests/groups.sql. Sleep, screen time and the
-- sleep target are read in exactly one function, which clients cannot call;
-- everything clients can call goes through the sharing switches.
select pg_temp.assert(
  (select array_agg(p.proname::text order by p.proname)
   from pg_proc p join pg_namespace n on n.oid = p.pronamespace
   where n.nspname = 'public' and p.prokind = 'f'
     and (pg_get_functiondef(p.oid) ilike '%sleep_logs%'
       or pg_get_functiondef(p.oid) ilike '%screen_time_daily%'
       or pg_get_functiondef(p.oid) ilike '%sleep_targets%'))
  = array['group_daily_scores'],
  'only group_daily_scores reads sleep logs, screen time or sleep targets');
select pg_temp.assert(
  not has_function_privilege('authenticated', 'group_daily_scores(uuid, date, date)', 'execute')
  and not has_function_privilege('authenticated', 'group_week_scores(uuid, date)', 'execute')
  and not has_function_privilege('authenticated', 'group_category_metrics(uuid, date, text)', 'execute')
  and not has_function_privilege('authenticated', 'refresh_group_snapshot(uuid, date)', 'execute')
  and not has_function_privilege('anon', 'group_daily_scores(uuid, date, date)', 'execute'),
  'the functions that read private data are not callable by clients');
-- Every function that calls group_daily_scores is either internal or checks membership.
select pg_temp.assert(
  (select array_agg(p.proname::text order by p.proname)
   from pg_proc p join pg_namespace n on n.oid = p.pronamespace
   where n.nspname = 'public' and p.prokind = 'f'
     and p.proname <> 'group_daily_scores'
     and pg_get_functiondef(p.oid) ilike '%group_daily_scores%')
  = array['group_category_metrics', 'group_member_metrics', 'group_week_scores'],
  'the only callers of the daily scoring are the metrics and weekly functions');
select pg_temp.assert(
  (select bool_and(pg_get_functiondef(p.oid) ilike '%member_shares_category%')
   from pg_proc p join pg_namespace n on n.oid = p.pronamespace
   where n.nspname = 'public' and p.proname in
     ('group_overall_board', 'group_category_board', 'group_member_metrics', 'group_available_categories')),
  'every function that returns scored data checks the sharing switches');
-- The refresh keeps to switched-on categories.
select pg_temp.assert(
  (select pg_get_functiondef('refresh_group_snapshot(uuid, date)'::regprocedure) ilike '%m.share_sleep%'
      and pg_get_functiondef('refresh_group_snapshot(uuid, date)'::regprocedure) ilike '%m.share_screen_time%'),
  'the snapshot is built only from categories a member shares');
-- Body measurements, weight and height are not used by any function at all.
select pg_temp.assert(
  (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
   where n.nspname = 'public' and p.prokind = 'f'
     and (pg_get_functiondef(p.oid) ilike '%body_measurements%'
       or pg_get_functiondef(p.oid) ilike '%weight_kg%'
       or pg_get_functiondef(p.oid) ilike '%height_cm%')) = 0,
  'no function reads body measurements, weight or height');
-- No policy outside the owner's own on the private tables (groups never read them).
select pg_temp.assert(
  (select count(*) from pg_policies
   where tablename in ('sleep_logs', 'sleep_targets', 'screen_time_daily', 'body_measurements', 'hobbies')
     and (qual ilike '%group%' or with_check ilike '%group%')) = 0,
  'no policy on a private table mentions groups');
-- Nothing a client can call returns the overall number.
select pg_temp.assert(
  (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
   where n.nspname = 'public' and p.prokind = 'f'
     and has_function_privilege('authenticated', p.oid, 'execute')
     and pg_get_function_result(p.oid) ilike '%overall_score%') = 0,
  'no client-callable function returns the overall score');
select pg_temp.assert(
  not has_column_privilege('authenticated', 'group_score_snapshots', 'overall_score', 'select'),
  'clients have no read access to the overall score column');

-- 10. Old code paths still work -----------------------------------------------------------------------------------
select pg_temp.as_user(:eve);
select pg_temp.assert((select name from create_group('Solo')) = 'Solo', 'create_group still works with just a name');
select pg_temp.assert((select share_workouts and share_breaks and not share_sleep and not share_screen_time
                       from group_members where user_id = :eve),
  'with the defaults');
reset role;

select 'ALL CHECKS PASSED' as result;
