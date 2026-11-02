-- Behaviour tests for 20261102000002_meal_logs.sql.
--
-- Run on a database with the harness and ALL migrations applied (this one
-- twice, to prove it can be re-run). Every check raises an exception on
-- failure.

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

-- 1. Private by construction. ---------------------------------------------------------
do $$
begin
  if not (select relrowsecurity from pg_class where oid = 'public.meal_logs'::regclass) then
    raise exception 'FAILED: row level security is off';
  end if;
  if (select count(*) from pg_policies
      where schemaname = 'public' and tablename = 'meal_logs') <> 3 then
    raise exception 'FAILED: expected exactly select, insert, update policies';
  end if;
  if exists (
    select 1 from pg_policies p
    where p.schemaname = 'public' and p.tablename = 'meal_logs'
      and (coalesce(p.qual, '') || coalesce(p.with_check, '')) not like '%auth.uid()%'
  ) then
    raise exception 'FAILED: a policy is not tied to auth.uid()';
  end if;
  if has_table_privilege('authenticated', 'public.meal_logs', 'DELETE') then
    raise exception 'FAILED: authenticated can delete';
  end if;
  if has_table_privilege('anon', 'public.meal_logs', 'SELECT') then
    raise exception 'FAILED: anon can read';
  end if;
  if not exists (select 1 from pg_trigger
                 where tgrelid = 'public.meal_logs'::regclass
                   and tgname = 'meal_logs_sync_guard') then
    raise exception 'FAILED: no sync guard';
  end if;
end $$;

-- 2. Alice logs a listed meal with values and a typed one without. --------------------
select pg_temp.as_user(:alice);
insert into meal_logs (id, user_id, name, servings, calories, protein_g, carbs_g, fat_g,
  source, logged_at, local_date, created_at, updated_at)
values ('90000000-0000-4000-8000-000000000001', :alice, 'Dal', 1.5, 270, 18, 45, 1.5,
  'listed', now(), '2026-05-13', now(), now());
insert into meal_logs (id, user_id, name, logged_at, local_date, created_at, updated_at)
values ('90000000-0000-4000-8000-000000000002', :alice, 'Homemade soup', now(),
  '2026-05-13', now(), now());
select pg_temp.assert((select count(*) from meal_logs where sync_seq > 0) = 2, 'meals stamped');
select pg_temp.assert((select servings from meal_logs where name = 'Homemade soup') = 1
  and (select source from meal_logs where name = 'Homemade soup') = 'entered'
  and (select calories from meal_logs where name = 'Homemade soup') is null,
  'defaults: one serving, typed, no values');
reset role;

-- 3. Bob sees none of it and cannot write as Alice. -----------------------------------
select pg_temp.as_user(:bob);
select pg_temp.assert((select count(*) from meal_logs) = 0, 'bob sees none');
select pg_temp.must_fail($q$
  insert into meal_logs (id, user_id, name, logged_at, local_date, created_at, updated_at)
  values ('90000000-0000-4000-8000-000000000009', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
          'x', now(), '2026-05-13', now(), now())$q$, 'bob wrote a meal as alice');
update meal_logs set name = 'hacked';
select pg_temp.must_fail('delete from meal_logs', 'bob may not delete meals');
reset role;
select pg_temp.assert((select count(*) from meal_logs where name = 'hacked') = 0,
  'alice meals untouched');

-- 4. Stale writes are ignored; soft deletes sync like edits. ---------------------------
select pg_temp.as_user(:alice);
select sync_seq as seq_before from meal_logs
  where id = '90000000-0000-4000-8000-000000000001' \gset
update meal_logs set calories = 1, updated_at = now() - interval '1 day'
  where id = '90000000-0000-4000-8000-000000000001';
select pg_temp.assert((select calories from meal_logs
  where id = '90000000-0000-4000-8000-000000000001') = 270, 'a stale update is ignored');
update meal_logs set deleted_at = now() + interval '1 minute',
  updated_at = now() + interval '1 minute'
  where id = '90000000-0000-4000-8000-000000000001';
select pg_temp.assert((select sync_seq from meal_logs
  where id = '90000000-0000-4000-8000-000000000001') > :seq_before,
  'a soft delete gets a newer sync_seq');
reset role;

-- 5. Constraints. -----------------------------------------------------------------------
select pg_temp.as_user(:alice);
select pg_temp.must_fail($q$
  insert into meal_logs (id, user_id, name, logged_at, local_date, created_at, updated_at)
  values (gen_random_uuid(), 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', '   ', now(),
          '2026-05-13', now(), now())$q$, 'a name is required');
select pg_temp.must_fail($q$
  insert into meal_logs (id, user_id, name, servings, logged_at, local_date, created_at, updated_at)
  values (gen_random_uuid(), 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'x', 0, now(),
          '2026-05-13', now(), now())$q$, 'servings must be positive');
select pg_temp.must_fail($q$
  insert into meal_logs (id, user_id, name, calories, logged_at, local_date, created_at, updated_at)
  values (gen_random_uuid(), 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'x', -5, now(),
          '2026-05-13', now(), now())$q$, 'calories cannot be negative');
select pg_temp.must_fail($q$
  insert into meal_logs (id, user_id, name, source, logged_at, local_date, created_at, updated_at)
  values (gen_random_uuid(), 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'x', 'photo', now(),
          '2026-05-13', now(), now())$q$, 'source must be listed or entered');
reset role;

-- 6. Deleting the account removes the meals. --------------------------------------------
select pg_temp.as_user(:alice);
select delete_my_account();
reset role;
select pg_temp.assert((select count(*) from meal_logs) = 0, 'deleting the account removed the meals');

select 'meal_logs tests passed' as result;
