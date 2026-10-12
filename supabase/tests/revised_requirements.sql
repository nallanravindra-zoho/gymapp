-- Behaviour tests for 20261012000000_revised_requirements.sql.
--
-- Run on a database with the harness and ALL migrations applied (the revised
-- requirements migration is applied twice by the callers, to prove it can be
-- re-run). Every check raises an exception on failure.

\set ON_ERROR_STOP on
\set alice '''aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'''
\set bob   '''bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'''

insert into auth.users (id) values (:alice), (:bob);

create or replace function pg_temp.as_user(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  execute 'set role authenticated';
end $$;
create or replace function pg_temp.assert(cond boolean, msg text) returns void language plpgsql as $$
begin
  if not coalesce(cond, false) then raise exception 'FAILED: %', msg; end if;
end $$;
-- Runs a statement that must fail; reports a failure if it succeeds.
create or replace function pg_temp.must_fail(stmt text, msg text) returns void language plpgsql as $$
begin
  begin
    execute stmt;
  exception when others then
    return;
  end;
  raise exception 'FAILED: %', msg;
end $$;
grant all on function pg_temp.as_user(text), pg_temp.assert(boolean, text),
  pg_temp.must_fail(text, text) to public;

-- 1. The new tables are private by construction. -----------------------------------
do $$
declare t text;
begin
  foreach t in array array['hobbies', 'hobby_logs', 'body_measurements', 'habit_skips']
  loop
    if not (select relrowsecurity from pg_class
            where oid = ('public.' || t)::regclass) then
      raise exception 'FAILED: row level security is off on %', t;
    end if;
    if (select count(*) from pg_policies
        where schemaname = 'public' and tablename = t) <> 3 then
      raise exception 'FAILED: % should have exactly select, insert, update policies', t;
    end if;
    if exists (
      select 1 from pg_policies p
      where p.schemaname = 'public' and p.tablename = t
        and (coalesce(p.qual, '') || coalesce(p.with_check, '')) not like '%auth.uid()%'
    ) then
      raise exception 'FAILED: a policy on % is not tied to auth.uid()', t;
    end if;
    if has_table_privilege('authenticated', 'public.' || t, 'DELETE') then
      raise exception 'FAILED: authenticated can delete from %', t;
    end if;
    if has_table_privilege('anon', 'public.' || t, 'SELECT') then
      raise exception 'FAILED: anon can read %', t;
    end if;
    if not exists (select 1 from pg_trigger
                   where tgrelid = ('public.' || t)::regclass
                     and tgname = t || '_sync_guard') then
      raise exception 'FAILED: % has no sync guard', t;
    end if;
  end loop;
end $$;

-- 2. Alice writes to every new table; each write gets a sync_seq. -------------------
select pg_temp.as_user(:alice);
insert into hobbies (id, user_id, name, icon_key, is_builtin, goal_period, goal_value,
  goal_unit, reminder_enabled, reminder_config, created_at, updated_at)
values ('10000000-0000-4000-8000-000000000001', :alice, 'Music', 'music', true,
  'weekly', 3, 'sessions', true, '{"frequency":"weekly"}', now(), now());
insert into hobby_logs (id, user_id, hobby_id, started_at, ended_at, duration_minutes,
  count_or_sessions, source, local_date, note, created_at, updated_at)
values ('20000000-0000-4000-8000-000000000001', :alice,
  '10000000-0000-4000-8000-000000000001', now(), now(), 30, 1, 'timer',
  '2026-05-13', 'scales', now(), now());
insert into body_measurements (id, user_id, measured_at, local_date, weight_kg,
  height_cm, bmi, waist_in, created_at, updated_at)
values ('30000000-0000-4000-8000-000000000001', :alice, now(), '2026-05-13',
  70, 175, 22.9, 31.5, now(), now());
-- A partial record: only one value.
insert into body_measurements (id, user_id, measured_at, local_date, chest_in,
  created_at, updated_at)
values ('30000000-0000-4000-8000-000000000002', :alice, now(), '2026-05-14',
  36, now(), now());
insert into habits (id, user_id, name, kind, created_at, updated_at)
values ('40000000-0000-4000-8000-000000000001', :alice, 'Skin care', 'skinCare', now(), now()),
       ('40000000-0000-4000-8000-000000000002', :alice, 'Moisturize', 'moisturize', now(), now());
insert into habit_skips (id, user_id, habit_id, skipped_at, local_date, created_at, updated_at)
values ('50000000-0000-4000-8000-000000000001', :alice,
  '40000000-0000-4000-8000-000000000001', now(), '2026-05-13', now(), now());

select pg_temp.assert((select count(*) from hobbies where sync_seq > 0) = 1, 'hobbies stamped');
select pg_temp.assert((select count(*) from hobby_logs where sync_seq > 0) = 1, 'hobby_logs stamped');
select pg_temp.assert((select count(*) from body_measurements where sync_seq > 0) = 2, 'measurements stamped');
select pg_temp.assert((select count(*) from habit_skips where sync_seq > 0) = 1, 'habit_skips stamped');
select pg_temp.assert((select goal_unit from hobbies) = 'sessions', 'hobby goal stored');
select pg_temp.assert((select weight_kg from body_measurements where chest_in = 36) is null,
  'a partial measurement keeps its other values empty');
select pg_temp.assert(
  (select count(*) from habit_skips s join habits h on h.id = s.habit_id) = 1 and
  (select count(*) from habit_logs) = 0, 'a skip is not a habit log');

-- Defaults.
insert into hobbies (id, user_id, name, icon_key, created_at, updated_at)
values ('10000000-0000-4000-8000-000000000002', :alice, 'Reading', 'reading', now(), now());
select pg_temp.assert((select goal_unit from hobbies where name = 'Reading') = 'minutes'
  and (select reminder_enabled from hobbies where name = 'Reading') = false
  and (select reminder_config from hobbies where name = 'Reading') = '{}'
  and (select is_active from hobbies where name = 'Reading') = true
  and (select goal_period from hobbies where name = 'Reading') is null,
  'hobby defaults');
reset role;

-- 3. Bob sees none of it and cannot write as Alice. -----------------------------------
select pg_temp.as_user(:bob);
select pg_temp.assert((select count(*) from hobbies) = 0, 'bob sees no hobbies');
select pg_temp.assert((select count(*) from hobby_logs) = 0, 'bob sees no hobby logs');
select pg_temp.assert((select count(*) from body_measurements) = 0, 'bob sees no measurements');
select pg_temp.assert((select count(*) from habit_skips) = 0, 'bob sees no skips');
select pg_temp.must_fail($q$
  insert into body_measurements (id, user_id, measured_at, local_date, created_at, updated_at)
  values ('30000000-0000-4000-8000-000000000009', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
          now(), '2026-05-13', now(), now())$q$, 'bob wrote a measurement as alice');
select pg_temp.must_fail($q$
  insert into hobbies (id, user_id, name, icon_key, created_at, updated_at)
  values ('10000000-0000-4000-8000-000000000009', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
          'X', 'x', now(), now())$q$, 'bob wrote a hobby as alice');
select pg_temp.must_fail($q$
  insert into hobby_logs (id, user_id, hobby_id, started_at, duration_minutes, source,
    local_date, created_at, updated_at)
  values ('20000000-0000-4000-8000-000000000009', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
          '10000000-0000-4000-8000-000000000001', now(), 1, 'manual', '2026-05-13', now(), now())$q$,
  'bob wrote a hobby log as alice');
select pg_temp.must_fail($q$
  insert into habit_skips (id, user_id, habit_id, skipped_at, local_date, created_at, updated_at)
  values ('50000000-0000-4000-8000-000000000009', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
          '40000000-0000-4000-8000-000000000001', now(), '2026-05-13', now(), now())$q$,
  'bob wrote a skip as alice');
-- Updating or deleting her rows touches nothing.
update body_measurements set weight_kg = 1;
update hobbies set name = 'hacked';
select pg_temp.must_fail('delete from body_measurements', 'bob may not delete measurements');
reset role;
select pg_temp.assert((select weight_kg from body_measurements
  where id = '30000000-0000-4000-8000-000000000001') = 70, 'alice measurement untouched');
select pg_temp.assert((select count(*) from hobbies where name = 'hacked') = 0, 'alice hobby untouched');

-- 4. Stale writes are ignored, soft deletes sync like edits. ------------------------------
select pg_temp.as_user(:alice);
select sync_seq as seq_before from body_measurements
  where id = '30000000-0000-4000-8000-000000000001' \gset
update body_measurements set weight_kg = 99, updated_at = now() - interval '1 day'
  where id = '30000000-0000-4000-8000-000000000001';
select pg_temp.assert((select weight_kg from body_measurements
  where id = '30000000-0000-4000-8000-000000000001') = 70, 'a stale update is ignored');
update body_measurements set weight_kg = 69, updated_at = now() + interval '1 minute'
  where id = '30000000-0000-4000-8000-000000000001';
select pg_temp.assert((select sync_seq from body_measurements
  where id = '30000000-0000-4000-8000-000000000001') > :seq_before, 'a newer update gets a newer sync_seq');
update habit_skips set deleted_at = now() + interval '1 minute', updated_at = now() + interval '1 minute';
select pg_temp.assert((select deleted_at from habit_skips) is not null, 'soft delete works');
reset role;

-- 5. Constraints. --------------------------------------------------------------------------
select pg_temp.as_user(:alice);
select pg_temp.must_fail($q$
  insert into hobbies (id, user_id, name, icon_key, goal_period, created_at, updated_at)
  values (gen_random_uuid(), 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a', 'a', 'monthly', now(), now())$q$,
  'goal period must be daily or weekly');
select pg_temp.must_fail($q$
  insert into hobbies (id, user_id, name, icon_key, goal_unit, created_at, updated_at)
  values (gen_random_uuid(), 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a', 'a', 'hours', now(), now())$q$,
  'goal unit must be minutes or sessions');
select pg_temp.must_fail($q$
  insert into hobby_logs (id, user_id, hobby_id, started_at, duration_minutes, source,
    local_date, created_at, updated_at)
  values (gen_random_uuid(), 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', gen_random_uuid(),
          now(), 5, 'auto', '2026-05-13', now(), now())$q$, 'hobby log source must be timer or manual');
select pg_temp.must_fail($q$
  insert into habits (id, user_id, name, kind, created_at, updated_at)
  values (gen_random_uuid(), 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'a', 'bogus', now(), now())$q$,
  'habit kind must be known');
-- Workout metrics and their labels.
insert into workouts (id, user_id, workout_type_id, started_at, ended_at, duration_minutes,
  source, local_date, created_at, updated_at, calories_estimate, steps, steps_source,
  distance_km, avg_speed_kmh, paused_seconds, active_seconds, metrics_note)
values ('60000000-0000-4000-8000-000000000001', :alice, 'builtin-run', now(), now(), 30,
  'timer', '2026-05-13', now(), now(), 280, 4200, 'sensor', 4.5, 9.5, 120, 1680, 'estimated');
insert into workouts (id, user_id, workout_type_id, started_at, ended_at, duration_minutes,
  source, local_date, created_at, updated_at)
values ('60000000-0000-4000-8000-000000000002', :alice, 'builtin-yoga', now(), now(), 30,
  'manual', '2026-05-13', now(), now());
select pg_temp.assert((select paused_seconds from workouts
  where id = '60000000-0000-4000-8000-000000000002') = 0
  and (select calories_estimate from workouts
  where id = '60000000-0000-4000-8000-000000000002') is null, 'workout metric defaults');
select pg_temp.must_fail($q$
  update workouts set steps_source = 'guess', updated_at = now() + interval '1 hour' where id = '60000000-0000-4000-8000-000000000001'$q$,
  'steps source must be sensor or estimate');
select pg_temp.must_fail($q$
  update workouts set metrics_note = 'exact', updated_at = now() + interval '1 hour' where id = '60000000-0000-4000-8000-000000000001'$q$,
  'metrics note must be estimated or measured');
-- Screen time source and target.
insert into screen_time_daily (id, user_id, local_date, total_minutes, created_at, updated_at)
values ('70000000-0000-4000-8000-000000000001', :alice, '2026-05-13', 100, now(), now());
select pg_temp.assert((select source from screen_time_daily) = 'automatic'
  and (select target_minutes from screen_time_daily) is null
  and (select share_in_groups from screen_time_daily) = false, 'screen time defaults');
update screen_time_daily set source = 'manual', target_minutes = 180,
  updated_at = now() + interval '1 minute';
select pg_temp.assert((select source from screen_time_daily) = 'manual'
  and (select target_minutes from screen_time_daily) = 180, 'screen time manual + target');
select pg_temp.must_fail($q$update screen_time_daily set source = 'guess', updated_at = now() + interval '2 minutes'$q$,
  'screen time source must be automatic or manual');
-- Profile fields.
insert into profiles (id, display_name, created_at, updated_at) values (:alice, 'Alice', now(), now());
select pg_temp.assert((select measurement_cadence from profiles) = 'monthly'
  and (select measurement_reminder_enabled from profiles) = true
  and (select habit_threshold from profiles) = 1
  and (select reminder_sound from profiles) is null
  and (select date_of_birth from profiles) is null, 'profile defaults');
update profiles set date_of_birth = '1990-04-02', gender = 'female', height_cm = 165.5,
  weight_kg = 60.25, measurement_cadence = 'bimonthly', measurement_reminder_enabled = false,
  next_measurement_due = '2026-07-01', reminder_sound = 'content://s/1', habit_threshold = 3,
  updated_at = now() + interval '1 minute';
select pg_temp.assert((select date_of_birth from profiles) = '1990-04-02'
  and (select height_cm from profiles) = 165.5
  and (select measurement_cadence from profiles) = 'bimonthly'
  and (select habit_threshold from profiles) = 3, 'profile fields stored');
select pg_temp.must_fail($q$update profiles set measurement_cadence = 'daily', updated_at = now() + interval '2 minutes'$q$,
  'cadence must be one of four');
select pg_temp.must_fail($q$update profiles set habit_threshold = 0, updated_at = now() + interval '2 minutes'$q$,
  'habit threshold is at least 1');
reset role;

-- 6. Group sharing: new categories are off until opted in; measurements are never shared.
insert into profiles (id, display_name, created_at, updated_at) values (:bob, 'Bob', now(), now());
select pg_temp.as_user(:alice);
create temp table g as select * from create_group('Crew');
grant all on g to public;
reset role;
select pg_temp.as_user(:bob);
select join_group((select invite_code from g));
reset role;
select pg_temp.assert(
  (select share_workouts and share_breaks from group_members where user_id = :bob),
  'workouts and Healthy Habits keep their defaults');
select pg_temp.assert(
  (select not share_sleep and not share_screen_time and not share_hobbies
   from group_members where user_id = :bob), 'sleep, screen time and hobbies are off by default');
select pg_temp.as_user(:bob);
update group_members set share_sleep = true, share_hobbies = true where user_id = :bob;
select pg_temp.must_fail($q$update group_members set role = 'owner' where user_id = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'$q$,
  'role is not editable');
-- Alice cannot flip Bob's switches.
reset role;
select pg_temp.as_user(:alice);
update group_members set share_screen_time = true where user_id = :bob;
reset role;
select pg_temp.assert(
  (select share_sleep and share_hobbies and not share_screen_time
   from group_members where user_id = :bob),
  'bob opted in to sleep and hobbies; alice could not opt him in to screen time');

-- A group mate still cannot read measurements, hobbies, hobby logs or skips.
select pg_temp.as_user(:bob);
select pg_temp.assert((select count(*) from body_measurements) = 0, 'group mate cannot read measurements');
select pg_temp.assert((select count(*) from hobbies) = 0, 'group mate cannot read hobbies');
select pg_temp.assert((select count(*) from hobby_logs) = 0, 'group mate cannot read hobby logs');
select pg_temp.assert((select count(*) from habit_skips) = 0, 'group mate cannot read skips');
reset role;

-- 7. Deleting the account removes the new rows too. ----------------------------------------
select count(*) as n from body_measurements where user_id = :alice \gset
select pg_temp.assert(:n = 2, 'alice still has measurements before deleting');
select pg_temp.as_user(:alice);
select delete_my_account();
reset role;
select pg_temp.assert((select count(*) from hobbies where user_id = :alice) = 0, 'her hobbies are gone');
select pg_temp.assert((select count(*) from hobby_logs where user_id = :alice) = 0, 'her hobby logs are gone');
select pg_temp.assert((select count(*) from body_measurements where user_id = :alice) = 0, 'her measurements are gone');
select pg_temp.assert((select count(*) from habit_skips where user_id = :alice) = 0, 'her skips are gone');
select pg_temp.assert((select count(*) from habits where user_id = :alice) = 0, 'her habits are gone');

\echo ALL CHECKS PASSED
