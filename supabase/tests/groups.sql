-- Behaviour tests for 20261008000000_groups.sql.
--
-- Run after the harness and both migrations, as the superuser. Every check
-- raises an exception on failure, so a clean run means all passed.

\set ON_ERROR_STOP on
\set alice '''aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'''
\set bob   '''bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'''
\set cara  '''cccccccc-cccc-4ccc-8ccc-cccccccccccc'''

insert into auth.users (id) values (:cara);
-- alice and bob already exist if rls_and_sync.sql ran first.
insert into auth.users (id) values (:alice), (:bob) on conflict do nothing;

create or replace function pg_temp.as_user(uid text) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', uid, false);
  execute 'set role authenticated';
end $$;

create or replace function pg_temp.assert(cond boolean, msg text) returns void language plpgsql as $$
begin
  if not coalesce(cond, false) then raise exception 'FAILED: %', msg; end if;
end $$;

grant all on function pg_temp.as_user(text), pg_temp.assert(boolean, text) to public;

insert into profiles (id, display_name, created_at, updated_at) values
  (:alice, 'Alice', now(), now()), (:bob, 'Bob', now(), now()),
  (:cara, 'Cara', now(), now())
on conflict (id) do update set display_name = excluded.display_name;

-- Alice has a habit with a goal of 2 a day.
insert into habits (id, user_id, name, kind, daily_target, created_at, updated_at)
values ('a0000000-0000-4000-8000-000000000001', :alice, 'Water', 'water', 2,
  now(), now());
insert into habits (id, user_id, name, kind, daily_target, created_at, updated_at)
values ('b0000000-0000-4000-8000-000000000001', :bob, 'Stretch', 'stretch', 1,
  now(), now());

-- 1. Creating and joining ------------------------------------------------------
select pg_temp.as_user(:alice);
create temp table made as select * from create_group('  Sunday crew ');
grant all on made to public;
select pg_temp.assert((select name from made) = 'Sunday crew', 'name is trimmed');
select pg_temp.assert((select length(invite_code) from made) = 12, 'invite code made');
select pg_temp.assert((select count(*) from groups) = 1, 'alice sees her group');
select pg_temp.assert((select role from group_members where user_id = :alice) = 'owner',
  'creator is the owner');

do $$ begin
  begin perform create_group('   '); raise exception 'FAILED: blank name accepted';
  exception when raise_exception then
    if sqlerrm like 'FAILED%' then raise; end if;
  end;
end $$;

-- Nobody can make a group or a membership around the functions.
do $$ begin
  begin
    insert into groups (name, owner_id, invite_code)
      values ('x', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'abc');
    raise exception 'FAILED: direct group insert allowed';
  exception when insufficient_privilege then null; end;
  begin
    insert into group_members (group_id, user_id, role)
      select id, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'owner' from groups;
    raise exception 'FAILED: direct member insert allowed';
  exception when insufficient_privilege then null; end;
end $$;

reset role;
select pg_temp.as_user(:bob);
select pg_temp.assert((select count(*) from groups) = 0, 'bob sees no groups yet');
select pg_temp.assert((select count(*) from group_members) = 0, 'bob sees no members');
select pg_temp.assert((select count(*) from group_roster((select id from made))) = 0,
  'a non-member gets no roster');
select pg_temp.assert(
  (select count(*) from group_leaderboard((select id from made), '2026-05-11')) = 0,
  'a non-member gets no leaderboard');

do $$ begin
  begin perform join_group('nope'); raise exception 'FAILED: bad code accepted';
  exception when raise_exception then
    if sqlerrm like 'FAILED%' then raise; end if;
    if sqlerrm <> 'invite_not_found' then raise exception 'FAILED: wrong error %', sqlerrm; end if;
  end;
end $$;

select pg_temp.assert((select name from group_preview((select invite_code from made))) = 'Sunday crew',
  'preview shows the name before joining');
select pg_temp.assert((select member_count from group_preview(upper((select invite_code from made)))) = 1,
  'preview counts members and ignores case');

select join_group((select invite_code from made));
select join_group((select invite_code from made));  -- joining twice is harmless
select pg_temp.assert((select count(*) from group_members) = 2, 'bob joined once');
select pg_temp.assert((select role from group_members where user_id = :bob) = 'member',
  'joiner is a member');

-- A member cannot rename the group or change anyone else's switches.
update groups set name = 'Bob''s now';
update group_members set share_workouts = false where user_id = :alice;
reset role;
select pg_temp.assert((select name from groups) = 'Sunday crew', 'only the owner renames');
select pg_temp.assert((select share_workouts from group_members where user_id = :alice),
  'nobody edits another member''s switches');

select pg_temp.as_user(:alice);
update groups set name = 'Sunday club';
reset role;
select pg_temp.assert((select name from groups) = 'Sunday club', 'the owner renames');

-- 2. Feed items follow what people log -------------------------------------------
-- Workouts (dates are relative so the "recent" rule holds whenever this runs).
select pg_temp.as_user(:alice);
insert into workouts (id, user_id, workout_type_id, started_at, ended_at,
  duration_minutes, source, local_date, created_at, updated_at)
values ('11111111-1111-4111-8111-111111111111', :alice, 'builtin-yoga',
  now() - interval '1 hour', now() - interval '30 minutes', 30, 'manual',
  to_char(now(), 'YYYY-MM-DD'), now(), now());
reset role;

select pg_temp.as_user(:bob);
select pg_temp.assert((select count(*) from group_events where kind = 'workout') = 1,
  'bob sees alice''s workout in the feed');
select pg_temp.assert((select payload->>'type_id' from group_events) = 'builtin-yoga',
  'the feed says what the workout was');
select pg_temp.assert((select payload->>'duration_minutes' from group_events) = '30',
  'and for how long');
reset role;

-- Old workouts are not announced (a new phone restoring history).
select pg_temp.as_user(:alice);
insert into workouts (id, user_id, workout_type_id, started_at, ended_at,
  duration_minutes, source, local_date, created_at, updated_at)
values ('22222222-2222-4222-8222-222222222222', :alice, 'builtin-run',
  now() - interval '30 days', now() - interval '30 days', 40, 'manual',
  to_char(now() - interval '30 days', 'YYYY-MM-DD'), now(), now());
reset role;
select pg_temp.assert((select count(*) from group_events where kind = 'workout') = 1,
  'old workouts stay out of the feed');

-- Editing a workout updates its item; deleting it removes the item.
select pg_temp.as_user(:alice);
update workouts set duration_minutes = 45, updated_at = now() + interval '1 second'
  where id = '11111111-1111-4111-8111-111111111111';
reset role;
select pg_temp.assert((select payload->>'duration_minutes' from group_events) = '45',
  'editing the workout updates the item');
select pg_temp.as_user(:alice);
update workouts set deleted_at = now(), updated_at = now() + interval '2 seconds'
  where id = '11111111-1111-4111-8111-111111111111';
reset role;
select pg_temp.assert((select count(*) from group_events) = 0,
  'deleting the workout removes the item');

-- Break goals post once the daily goal is reached, not before.
select pg_temp.as_user(:alice);
insert into habit_logs (id, user_id, habit_id, logged_at, count, local_date,
  created_at, updated_at)
values ('a1000000-0000-4000-8000-000000000001', :alice,
  'a0000000-0000-4000-8000-000000000001', now(), 1,
  to_char(now(), 'YYYY-MM-DD'), now(), now());
reset role;
select pg_temp.assert((select count(*) from group_events where kind = 'break_goal') = 0,
  'half a goal is not announced');
select pg_temp.as_user(:alice);
insert into habit_logs (id, user_id, habit_id, logged_at, count, local_date,
  created_at, updated_at)
values ('a1000000-0000-4000-8000-000000000002', :alice,
  'a0000000-0000-4000-8000-000000000001', now(), 1,
  to_char(now(), 'YYYY-MM-DD'), now(), now());
reset role;
select pg_temp.assert((select count(*) from group_events where kind = 'break_goal') = 1,
  'a met goal is announced');
select pg_temp.assert((select payload->>'habit_name' from group_events where kind = 'break_goal') = 'Water',
  'with the habit name');

-- 3. Sharing switches hide things straight away, and keep them hidden ---------
select pg_temp.as_user(:alice);
insert into workouts (id, user_id, workout_type_id, started_at, ended_at,
  duration_minutes, source, local_date, created_at, updated_at)
values ('33333333-3333-4333-8333-333333333333', :alice, 'builtin-walk',
  now() - interval '1 hour', now() - interval '30 minutes', 20, 'manual',
  to_char(now(), 'YYYY-MM-DD'), now(), now());
update group_members set share_breaks = false where user_id = :alice;
reset role;

select pg_temp.as_user(:bob);
select pg_temp.assert((select count(*) from group_events where kind = 'workout') = 1,
  'workouts still shared');
select pg_temp.assert((select count(*) from group_events where kind = 'break_goal') = 0,
  'turning off breaks hides the earlier break item');
reset role;

select pg_temp.as_user(:alice);
update group_members set share_breaks = true where user_id = :alice;
reset role;
select pg_temp.as_user(:bob);
select pg_temp.assert((select count(*) from group_events where kind = 'break_goal') = 1,
  'turning it back on shows it again');
reset role;

-- While breaks are off, new break goals are not posted at all.
select pg_temp.as_user(:bob);
update group_members set share_breaks = false where user_id = :bob;
insert into habit_logs (id, user_id, habit_id, logged_at, count, local_date,
  created_at, updated_at)
values ('b1000000-0000-4000-8000-000000000001', :bob,
  'b0000000-0000-4000-8000-000000000001', now(), 1,
  to_char(now(), 'YYYY-MM-DD'), now(), now());
reset role;
select pg_temp.assert(
  (select count(*) from group_events where user_id = :bob and kind = 'break_goal') = 0,
  'a break goal met while not sharing is never posted');

-- Workouts off: the member disappears from feed and leaderboard.
select pg_temp.as_user(:alice);
update group_members set share_workouts = false where user_id = :alice;
reset role;
select pg_temp.as_user(:bob);
select pg_temp.assert((select count(*) from group_events where user_id = :alice and kind = 'workout') = 0,
  'workouts off hides the feed items');
select pg_temp.assert(
  (select count(*) from group_leaderboard((select id from made),
    (date_trunc('week', now()))::date) where user_id = :alice) = 0,
  'workouts off removes the leaderboard row');
reset role;
select pg_temp.as_user(:alice);
update group_members set share_workouts = true where user_id = :alice;
reset role;

-- 4. Leaderboard ----------------------------------------------------------------
-- A fixed week: Mon 2026-05-11 .. Sun 2026-05-17.
insert into workouts (id, user_id, workout_type_id, started_at, ended_at,
  duration_minutes, source, local_date, created_at, updated_at) values
 ('44444444-0000-4000-8000-000000000001', :alice, 'builtin-run',
   '2026-05-11 08:00+00', '2026-05-11 08:30+00', 30, 'manual', '2026-05-11', now(), now()),
 ('44444444-0000-4000-8000-000000000002', :alice, 'builtin-run',
   '2026-05-11 18:00+00', '2026-05-11 18:20+00', 20, 'manual', '2026-05-11', now(), now()),
 ('44444444-0000-4000-8000-000000000003', :alice, 'builtin-run',
   '2026-05-17 08:00+00', '2026-05-17 08:10+00', 10, 'manual', '2026-05-17', now(), now()),
 -- Outside the week (previous Sunday and next Monday).
 ('44444444-0000-4000-8000-000000000004', :alice, 'builtin-run',
   '2026-05-10 08:00+00', '2026-05-10 09:00+00', 60, 'manual', '2026-05-10', now(), now()),
 ('44444444-0000-4000-8000-000000000005', :alice, 'builtin-run',
   '2026-05-18 08:00+00', '2026-05-18 09:00+00', 60, 'manual', '2026-05-18', now(), now()),
 -- Deleted: does not count.
 ('44444444-0000-4000-8000-000000000006', :alice, 'builtin-run',
   '2026-05-12 08:00+00', '2026-05-12 09:00+00', 60, 'manual', '2026-05-12', now(), now()),
 ('44444444-0000-4000-8000-000000000007', :bob, 'builtin-yoga',
   '2026-05-13 08:00+00', '2026-05-13 08:45+00', 45, 'manual', '2026-05-13', now(), now());
update workouts set deleted_at = now(), updated_at = now() + interval '1 second' where id = '44444444-0000-4000-8000-000000000006';
-- Alice met her water goal on Thursday 14th (no workout that day); Bob did too
-- on Friday, but Bob has breaks switched off.
insert into habit_logs (id, user_id, habit_id, logged_at, count, local_date,
  created_at, updated_at) values
 ('a2000000-0000-4000-8000-000000000001', :alice, 'a0000000-0000-4000-8000-000000000001',
   '2026-05-14 09:00+00', 2, '2026-05-14', now(), now()),
 -- Half of the goal on Saturday: does not count.
 ('a2000000-0000-4000-8000-000000000002', :alice, 'a0000000-0000-4000-8000-000000000001',
   '2026-05-16 09:00+00', 1, '2026-05-16', now(), now()),
 ('b2000000-0000-4000-8000-000000000001', :bob, 'b0000000-0000-4000-8000-000000000001',
   '2026-05-15 09:00+00', 1, '2026-05-15', now(), now());

select pg_temp.as_user(:bob);
select pg_temp.assert(
  (select active_minutes from group_leaderboard((select id from made), '2026-05-11')
     where user_id = :alice) = 60,
  'alice: 30 + 20 + 10 minutes, outside-week and deleted workouts left out');
select pg_temp.assert(
  (select active_days from group_leaderboard((select id from made), '2026-05-11')
     where user_id = :alice) = 3,
  'alice: Monday, Thursday (water goal) and Sunday are active days');
select pg_temp.assert(
  (select active_minutes from group_leaderboard((select id from made), '2026-05-11')
     where user_id = :bob) = 45, 'bob: 45 minutes');
select pg_temp.assert(
  (select active_days from group_leaderboard((select id from made), '2026-05-11')
     where user_id = :bob) = 1,
  'bob shares no breaks, so his Friday goal adds no active day');
select pg_temp.assert(
  (select display_name from group_leaderboard((select id from made), '2026-05-11')
     where user_id = :bob) = 'Bob', 'names come with the leaderboard');
select pg_temp.assert(
  (select count(*) from group_leaderboard((select id from made), '2026-04-27')
     where active_minutes > 0) = 0, 'other weeks are empty');
reset role;

-- 5. Cheers ------------------------------------------------------------------------
select pg_temp.as_user(:bob);
create temp table an_event as
  select id from group_events where user_id = :alice and kind = 'workout' limit 1;
grant all on an_event to public;
insert into reactions (event_id, user_id) select id, :bob from an_event;
select pg_temp.assert((select count(*) from reactions) = 1, 'bob cheered');
do $$ begin
  begin
    insert into reactions (event_id, user_id) select id, 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb' from an_event;
    raise exception 'FAILED: cheered twice';
  exception when unique_violation then null; end;
  begin
    insert into reactions (event_id, user_id)
      select id, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa' from an_event;
    raise exception 'FAILED: cheered as someone else';
  exception when insufficient_privilege then null; end;
end $$;
reset role;

select pg_temp.as_user(:alice);
select pg_temp.assert((select count(*) from reactions) = 1, 'alice sees the cheer');
do $$ begin
  begin
    insert into reactions (event_id, user_id)
      select id, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa' from group_events
      where user_id = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa' limit 1;
    raise exception 'FAILED: cheered own item';
  exception when insufficient_privilege then null; end;
end $$;
delete from reactions;
reset role;
select pg_temp.assert((select count(*) from reactions) = 1, 'alice cannot remove bob''s cheer');

-- Someone outside the group sees none of it and cannot cheer.
select pg_temp.as_user(:cara);
select pg_temp.assert((select count(*) from group_events) = 0, 'cara sees no feed');
select pg_temp.assert((select count(*) from reactions) = 0, 'cara sees no cheers');
do $$ begin
  begin
    insert into reactions (event_id, user_id)
      select id, 'cccccccc-cccc-4ccc-8ccc-cccccccccccc' from an_event;
    raise exception 'FAILED: outsider cheered';
  exception when insufficient_privilege then null; end;
end $$;
reset role;

select pg_temp.as_user(:bob);
delete from reactions;
reset role;
select pg_temp.assert((select count(*) from reactions) = 0, 'bob takes his cheer back');

-- 6. Sleep and screen time never reach a group --------------------------------------
select pg_temp.assert(
  (select count(*) from pg_proc p join pg_namespace n on n.oid = p.pronamespace
   where n.nspname = 'public' and p.prokind = 'f'
     and (pg_get_functiondef(p.oid) ilike '%sleep_logs%'
       or pg_get_functiondef(p.oid) ilike '%screen_time%'
       or pg_get_functiondef(p.oid) ilike '%sleep_targets%')) = 0,
  'no function in the schema reads sleep or screen time');

-- 7. Invite codes ----------------------------------------------------------------------
select pg_temp.as_user(:bob);
do $$ begin
  begin perform rotate_invite_code((select id from made)); raise exception 'FAILED: member rotated the code';
  exception when raise_exception then
    if sqlerrm like 'FAILED%' then raise; end if;
  end;
end $$;
reset role;
select pg_temp.as_user(:alice);
create temp table old_code as select invite_code as c from groups;
grant all on old_code to public;
create temp table new_code as select rotate_invite_code((select id from made)) as c;
grant all on new_code to public;
reset role;
select pg_temp.assert((select invite_code from groups) <> (select c from old_code),
  'a new code replaces the old one');
select pg_temp.as_user(:cara);
do $$ begin
  begin perform join_group((select c from old_code)); raise exception 'FAILED: old code still works';
  exception when raise_exception then
    if sqlerrm like 'FAILED%' then raise; end if;
  end;
end $$;
reset role;

-- 8. Leaving, ownership and size limits --------------------------------------------------
select pg_temp.as_user(:cara);
select join_group((select c from new_code));
reset role;
select pg_temp.assert((select count(*) from group_members) = 3, 'cara joined with the new code');

-- The owner leaves: the longest-standing member takes over.
select pg_temp.as_user(:alice);
delete from group_members where user_id = :alice;
reset role;
select pg_temp.assert((select owner_id from groups) = :bob, 'bob (joined first) becomes the owner');
select pg_temp.assert((select role from group_members where user_id = :bob) = 'owner',
  'and his role says so');
-- Alice no longer sees the group or its feed.
select pg_temp.as_user(:alice);
select pg_temp.assert((select count(*) from groups) = 0, 'alice left the group');
select pg_temp.assert((select count(*) from group_events) = 0, 'and no longer sees its feed');
reset role;
-- Her own data is untouched.
select pg_temp.assert((select count(*) from workouts where user_id = :alice) > 0,
  'leaving does not delete personal data');

-- The new owner can rotate the code.
select pg_temp.as_user(:bob);
select rotate_invite_code((select id from groups));
reset role;

-- A person removed with their account takes the same path.
delete from auth.users where id = :bob;
select pg_temp.assert((select owner_id from groups) = :cara, 'cara takes over when bob''s account goes');

-- The last member leaving removes the group and everything in it.
select pg_temp.as_user(:cara);
delete from group_members where user_id = :cara;
reset role;
select pg_temp.assert((select count(*) from groups) = 0, 'an empty group is removed');
select pg_temp.assert((select count(*) from group_events) = 0, 'with its feed');

-- Limits.
select pg_temp.as_user(:cara);
do $$ declare i int; begin
  for i in 1..10 loop perform create_group('g' || i); end loop;
  begin perform create_group('one too many'); raise exception 'FAILED: 11th group allowed';
  exception when raise_exception then
    if sqlerrm like 'FAILED%' then raise; end if;
    if sqlerrm <> 'too_many_groups' then raise exception 'FAILED: wrong error %', sqlerrm; end if;
  end;
end $$;
reset role;

delete from group_members where user_id = :cara;
select pg_temp.as_user(:alice);
create temp table full_group as select * from create_group('Full');
grant all on full_group to public;
reset role;
insert into auth.users (id) select gen_random_uuid() from generate_series(1, 19);
insert into group_members (group_id, user_id, role)
  select (select id from full_group), u.id, 'member'
  from auth.users u where u.id not in (:alice, :bob, :cara) limit 19;
select pg_temp.as_user(:cara);
do $$ begin
  begin perform join_group((select invite_code from full_group)); raise exception 'FAILED: 21st member allowed';
  exception when raise_exception then
    if sqlerrm like 'FAILED%' then raise; end if;
    if sqlerrm <> 'group_full' then raise exception 'FAILED: wrong error %', sqlerrm; end if;
  end;
end $$;
reset role;

-- 9. Anonymous users get nothing ------------------------------------------------------------
set role anon;
do $$ begin
  begin perform 1 from groups; raise exception 'FAILED: anon read groups';
  exception when insufficient_privilege then null; end;
  begin perform 1 from group_events; raise exception 'FAILED: anon read events';
  exception when insufficient_privilege then null; end;
  begin perform create_group('x'); raise exception 'FAILED: anon created a group';
  exception when insufficient_privilege then null; end;
end $$;
reset role;

select 'ALL CHECKS PASSED' as result;
