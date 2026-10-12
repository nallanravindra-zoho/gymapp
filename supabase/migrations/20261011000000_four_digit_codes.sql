-- Well-Being Companion: invite codes are 4 digits, with a limit on guessing.
--
-- Run once in the Supabase SQL editor, after the earlier migrations.
--
-- Only 10,000 four-digit codes exist, so on their own they could be guessed.
-- To make that impractical, an account that enters wrong codes 5 times within
-- 15 minutes is refused ("too_many_attempts") until the oldest of those
-- attempts is 15 minutes old. Entering a valid code never counts against you,
-- and wrong guesses by one person never lock out anyone else.
--
-- Every group gets a new 4-digit code when this runs, so earlier codes stop
-- working. The owner can make a new code at any time from group settings.

create table if not exists public.join_attempts (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  attempted_at timestamptz not null default now()
);

create index if not exists join_attempts_user_idx
  on public.join_attempts (user_id, attempted_at);

-- Only the functions below touch this table.
alter table public.join_attempts enable row level security;
revoke all on public.join_attempts from public, anon, authenticated;

create or replace function public.new_invite_code()
returns text
language plpgsql volatile security definer set search_path = public
as $$
declare
  code text;
begin
  if (select count(*) from public.groups) >= 9000 then
    raise exception 'no_codes_left';
  end if;
  loop
    code := lpad(
      ((('x' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 8))::bit(32)::bigint)
        % 10000)::text,
      4, '0');
    exit when not exists (select 1 from public.groups where invite_code = code);
  end loop;
  return code;
end $$;

create or replace function public.check_join_rate(p_user_id uuid)
returns void
language plpgsql security definer set search_path = public
as $$
begin
  delete from public.join_attempts where attempted_at < now() - interval '1 day';
  if (select count(*) from public.join_attempts
      where user_id = p_user_id
        and attempted_at > now() - interval '15 minutes') >= 5 then
    raise exception 'too_many_attempts';
  end if;
end $$;

revoke all on function public.check_join_rate(uuid) from public, anon, authenticated;

-- A wrong code is recorded and returns nothing (raising an error would undo
-- the record). The app treats "nothing" as "invite not found".
create or replace function public.group_preview(p_code text)
returns table (name text, member_count integer, is_member boolean)
language plpgsql volatile security definer set search_path = public
as $$
declare
  uid uuid := (select auth.uid());
  g public.groups;
begin
  if uid is null then return; end if;
  perform public.check_join_rate(uid);
  select * into g from public.groups where invite_code = lower(btrim(p_code));
  if not found then
    insert into public.join_attempts (user_id) values (uid);
    return;
  end if;
  name := g.name;
  member_count := (select count(*)::int from public.group_members m
                   where m.group_id = g.id);
  is_member := public.is_group_member(g.id);
  return next;
end $$;

create or replace function public.join_group(p_code text)
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
  insert into public.group_members (group_id, user_id, role)
    values (gid, uid, 'member');
  return gid;
end $$;

-- Replace every earlier code (12 characters, or 8 digits) with 4 digits.
update public.groups
  set invite_code = public.new_invite_code()
  where invite_code !~ '^[0-9]{4}$';
