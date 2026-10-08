-- Well-Being Companion: groups (spec 6.2, 6.5, 7.6).
--
-- Run once in the Supabase SQL editor, after 20261007000000_private_data_and_sync.sql.
--
-- Privacy model
--   * Personal tables stay private. Groups never read them directly; they get
--     two derived things instead, and only what each member chose to share:
--       - group_events: feed items written by triggers when a member logs a
--         workout, meets a break goal or earns a milestone;
--       - group_leaderboard(): weekly totals computed on the server.
--   * Sleep and screen time are not read by anything in this file.
--   * Sharing is checked when reading, not only when writing: turning a switch
--     off hides that member's earlier feed items and leaderboard row at once.
--   * Clients cannot create groups, members or events directly. They use
--     create_group() and join_group(), which are the only way in.

-- Tables ---------------------------------------------------------------------

create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(btrim(name)) between 1 and 40),
  -- Not a foreign key: ownership passes to another member when the owner
  -- leaves or deletes their account (see group_members_after_delete).
  owner_id uuid not null,
  invite_code text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.group_members (
  group_id uuid not null references public.groups (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  role text not null check (role in ('owner', 'member')),
  joined_at timestamptz not null default now(),
  share_workouts boolean not null default true,
  share_breaks boolean not null default true,
  primary key (group_id, user_id)
);

create index if not exists group_members_user_idx
  on public.group_members (user_id);

create table if not exists public.group_events (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  kind text not null check (kind in ('workout', 'break_goal', 'milestone')),
  -- What the item is about (a workout id, "habit:date", a badge id), so that
  -- editing or removing the source updates or removes the item.
  source_key text not null,
  -- Which sharing switch governs the item: workouts or breaks.
  scope text not null check (scope in ('workouts', 'breaks')),
  payload jsonb not null default '{}',
  occurred_at timestamptz not null,
  unique (group_id, user_id, kind, source_key)
);

create index if not exists group_events_feed_idx
  on public.group_events (group_id, occurred_at desc);

create table if not exists public.reactions (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.group_events (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  kind text not null default 'cheer' check (kind in ('cheer')),
  created_at timestamptz not null default now(),
  unique (event_id, user_id, kind)
);

-- Helpers used by the policies ----------------------------------------------
-- Security definer so that a policy on group_members can ask about
-- group_members without recursing into itself.

create or replace function public.is_group_member(p_group_id uuid)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.group_members m
    where m.group_id = p_group_id and m.user_id = (select auth.uid())
  )
$$;

-- Does this member currently share this scope (workouts or breaks)?
create or replace function public.member_shares(
  p_group_id uuid, p_user_id uuid, p_scope text)
returns boolean
language sql stable security definer set search_path = public
as $$
  select coalesce((
    select case when p_scope = 'breaks' then m.share_breaks
                else m.share_workouts end
    from public.group_members m
    where m.group_id = p_group_id and m.user_id = p_user_id
  ), false)
$$;

grant execute on function public.is_group_member(uuid) to authenticated;
grant execute on function public.member_shares(uuid, uuid, text) to authenticated;

-- Row-level security ---------------------------------------------------------

alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.group_events enable row level security;
alter table public.reactions enable row level security;

-- groups: members read; the owner renames. Nothing else directly.
create policy "groups: members read" on public.groups
  for select to authenticated
  using (public.is_group_member(id));

create policy "groups: owner renames" on public.groups
  for update to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

grant select on public.groups to authenticated;
grant update (name) on public.groups to authenticated;

-- group_members: members see each other; everyone changes only their own
-- sharing switches and can remove only themselves (leave).
create policy "group_members: members read" on public.group_members
  for select to authenticated
  using (public.is_group_member(group_id));

create policy "group_members: own sharing" on public.group_members
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy "group_members: leave" on public.group_members
  for delete to authenticated
  using (user_id = (select auth.uid()));

grant select on public.group_members to authenticated;
grant update (share_workouts, share_breaks) on public.group_members to authenticated;
grant delete on public.group_members to authenticated;

-- group_events: members read items whose author currently shares that scope.
create policy "group_events: members read shared" on public.group_events
  for select to authenticated
  using (
    public.is_group_member(group_id)
    and public.member_shares(group_id, user_id, scope)
  );

grant select on public.group_events to authenticated;

-- reactions: members read reactions on items they can see, cheer other
-- people's items, and take back their own cheer.
create policy "reactions: members read" on public.reactions
  for select to authenticated
  using (exists (select 1 from public.group_events e where e.id = event_id));

create policy "reactions: cheer others" on public.reactions
  for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and exists (
      select 1 from public.group_events e
      where e.id = event_id and e.user_id <> (select auth.uid())
    )
  );

create policy "reactions: take back own" on public.reactions
  for delete to authenticated
  using (user_id = (select auth.uid()));

grant select, insert, delete on public.reactions to authenticated;

-- Creating, joining, inviting ------------------------------------------------

create or replace function public.new_invite_code()
returns text
language sql volatile
as $$ select substr(replace(gen_random_uuid()::text, '-', ''), 1, 12) $$;

create or replace function public.create_group(p_name text)
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
  insert into public.group_members (group_id, user_id, role)
    values (g.id, uid, 'owner');
  return g;
end $$;

-- What an invite code leads to, so the person can confirm before joining.
create or replace function public.group_preview(p_code text)
returns table (name text, member_count integer, is_member boolean)
language sql stable security definer set search_path = public
as $$
  select g.name,
         (select count(*)::int from public.group_members m where m.group_id = g.id),
         public.is_group_member(g.id)
  from public.groups g
  where g.invite_code = lower(btrim(p_code))
    and (select auth.uid()) is not null
$$;

create or replace function public.join_group(p_code text)
returns uuid
language plpgsql security definer set search_path = public
as $$
declare
  uid uuid := (select auth.uid());
  gid uuid;
begin
  if uid is null then raise exception 'not_signed_in'; end if;
  select id into gid from public.groups
    where invite_code = lower(btrim(p_code));
  if gid is null then raise exception 'invite_not_found'; end if;
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

-- A new code makes the old link stop working. Owner only.
create or replace function public.rotate_invite_code(p_group_id uuid)
returns text
language plpgsql security definer set search_path = public
as $$
declare
  code text := public.new_invite_code();
begin
  update public.groups set invite_code = code
    where id = p_group_id and owner_id = (select auth.uid());
  if not found then raise exception 'not_owner'; end if;
  return code;
end $$;

grant execute on function
  public.create_group(text),
  public.group_preview(text),
  public.join_group(text),
  public.rotate_invite_code(uuid)
to authenticated;

-- Leaving, or an account being deleted, removes a membership. The group then
-- passes to its longest-standing member, or is removed when nobody is left.
create or replace function public.group_members_after_delete()
returns trigger
language plpgsql security definer set search_path = public
as $$
declare
  next_owner uuid;
begin
  if not exists (select 1 from public.groups where id = old.group_id) then
    return null;
  end if;
  select user_id into next_owner from public.group_members
    where group_id = old.group_id
    order by (role = 'owner') desc, joined_at, user_id
    limit 1;
  if next_owner is null then
    delete from public.groups where id = old.group_id;
  elsif old.role = 'owner' then
    update public.group_members set role = 'owner'
      where group_id = old.group_id and user_id = next_owner;
    update public.groups set owner_id = next_owner where id = old.group_id;
  end if;
  return null;
end $$;

create trigger group_members_after_delete
  after delete on public.group_members
  for each row execute function public.group_members_after_delete();

-- Reading ----------------------------------------------------------------------

-- Names for the member list. Members only.
create or replace function public.group_roster(p_group_id uuid)
returns table (
  user_id uuid, display_name text, role text, joined_at timestamptz,
  share_workouts boolean, share_breaks boolean)
language sql stable security definer set search_path = public
as $$
  select m.user_id, coalesce(p.display_name, ''), m.role, m.joined_at,
         m.share_workouts, m.share_breaks
  from public.group_members m
  left join public.profiles p on p.id = m.user_id
  where m.group_id = p_group_id and public.is_group_member(p_group_id)
  order by m.joined_at, m.user_id
$$;

-- Weekly totals (spec 7.6). The week is Monday to Sunday in each member's
-- own local time, which is what local_date already holds. Members who do not
-- share workouts do not appear. Break goals count towards active days only
-- for members who share breaks.
create or replace function public.group_leaderboard(
  p_group_id uuid, p_week_start date)
returns table (
  user_id uuid, display_name text, active_minutes integer, active_days integer)
language sql stable security definer set search_path = public
as $$
  select
    m.user_id,
    coalesce(p.display_name, ''),
    coalesce((
      select sum(w.duration_minutes)::int from public.workouts w
      where w.user_id = m.user_id and w.deleted_at is null
        and w.local_date between to_char(p_week_start, 'YYYY-MM-DD')
                             and to_char(p_week_start + 6, 'YYYY-MM-DD')
    ), 0),
    (select count(*)::int from (
      select w.local_date from public.workouts w
      where w.user_id = m.user_id and w.deleted_at is null
        and w.local_date between to_char(p_week_start, 'YYYY-MM-DD')
                             and to_char(p_week_start + 6, 'YYYY-MM-DD')
      union
      select l.local_date
      from public.habit_logs l
      join public.habits h on h.id = l.habit_id and h.user_id = l.user_id
      where m.share_breaks
        and l.user_id = m.user_id and l.deleted_at is null
        and h.deleted_at is null
        and l.local_date between to_char(p_week_start, 'YYYY-MM-DD')
                             and to_char(p_week_start + 6, 'YYYY-MM-DD')
      group by l.habit_id, l.local_date, h.daily_target
      having sum(l.count) >= h.daily_target
    ) days)
  from public.group_members m
  left join public.profiles p on p.id = m.user_id
  where m.group_id = p_group_id
    and m.share_workouts
    and public.is_group_member(p_group_id)
$$;

grant execute on function
  public.group_roster(uuid),
  public.group_leaderboard(uuid, date)
to authenticated;

-- Feed items --------------------------------------------------------------------
-- Written by triggers on the personal tables, for every group the person is in
-- and shares that kind with. Only recent activity is posted, so signing in on
-- a new phone does not flood groups with old workouts.

create or replace function public.post_group_event(
  p_user_id uuid, p_kind text, p_scope text, p_source_key text,
  p_payload jsonb, p_occurred_at timestamptz)
returns void
language plpgsql security definer set search_path = public
as $$
begin
  if p_occurred_at < now() - interval '2 days' then
    -- Too old to post, but keep an existing item up to date.
    update public.group_events set payload = p_payload
      where user_id = p_user_id and kind = p_kind and source_key = p_source_key;
    return;
  end if;
  insert into public.group_events
    (group_id, user_id, kind, scope, source_key, payload, occurred_at)
  select m.group_id, p_user_id, p_kind, p_scope, p_source_key, p_payload,
         p_occurred_at
  from public.group_members m
  where m.user_id = p_user_id
    and case when p_scope = 'breaks' then m.share_breaks
             else m.share_workouts end
  on conflict (group_id, user_id, kind, source_key)
    do update set payload = excluded.payload;
end $$;

revoke all on function public.post_group_event(uuid, text, text, text, jsonb, timestamptz)
  from public, anon, authenticated;

create or replace function public.workouts_to_group_events()
returns trigger
language plpgsql security definer set search_path = public
as $$
begin
  if new.deleted_at is not null then
    delete from public.group_events
      where user_id = new.user_id and kind = 'workout'
        and source_key = new.id::text;
  else
    perform public.post_group_event(
      new.user_id, 'workout', 'workouts', new.id::text,
      jsonb_build_object(
        'type_id', new.workout_type_id,
        'type_name', (select t.name from public.workout_types t
                      where t.id::text = new.workout_type_id
                        and t.user_id = new.user_id),
        'duration_minutes', new.duration_minutes),
      new.ended_at);
  end if;
  return null;
end $$;

create trigger workouts_group_events
  after insert or update on public.workouts
  for each row execute function public.workouts_to_group_events();

create or replace function public.habit_logs_to_group_events()
returns trigger
language plpgsql security definer set search_path = public
as $$
declare
  h public.habits;
  total integer;
  key text := new.habit_id::text || ':' || new.local_date;
begin
  select * into h from public.habits
    where id = new.habit_id and user_id = new.user_id and deleted_at is null;
  if not found then return null; end if;
  select coalesce(sum(count), 0) into total from public.habit_logs
    where user_id = new.user_id and habit_id = new.habit_id
      and local_date = new.local_date and deleted_at is null;
  if total >= h.daily_target then
    perform public.post_group_event(
      new.user_id, 'break_goal', 'breaks', key,
      jsonb_build_object('habit_name', h.name, 'habit_kind', h.kind,
                         'count', total),
      new.logged_at);
  else
    delete from public.group_events
      where user_id = new.user_id and kind = 'break_goal' and source_key = key;
  end if;
  return null;
end $$;

create trigger habit_logs_group_events
  after insert or update on public.habit_logs
  for each row execute function public.habit_logs_to_group_events();

create or replace function public.badges_to_group_events()
returns trigger
language plpgsql security definer set search_path = public
as $$
begin
  if new.deleted_at is null then
    -- A habit's streak is a break milestone; the overall streak is a
    -- movement milestone. Each follows the matching sharing switch.
    perform public.post_group_event(
      new.user_id, 'milestone',
      case when starts_with(new.badge_key, 'streak_habit:') then 'breaks'
           else 'workouts' end,
      new.id::text,
      jsonb_build_object('badge_key', new.badge_key),
      new.awarded_at);
  end if;
  return null;
end $$;

create trigger badges_group_events
  after insert on public.badges_awarded
  for each row execute function public.badges_to_group_events();

-- Functions are executable by everyone by default. Only signed-in users may
-- call the ones meant for the app; the trigger functions are not callable.
revoke all on function
  public.is_group_member(uuid),
  public.member_shares(uuid, uuid, text),
  public.create_group(text),
  public.group_preview(text),
  public.join_group(text),
  public.rotate_invite_code(uuid),
  public.group_roster(uuid),
  public.group_leaderboard(uuid, date),
  public.new_invite_code(),
  public.group_members_after_delete(),
  public.workouts_to_group_events(),
  public.habit_logs_to_group_events(),
  public.badges_to_group_events()
from public, anon;

grant execute on function
  public.is_group_member(uuid),
  public.member_shares(uuid, uuid, text),
  public.create_group(text),
  public.group_preview(text),
  public.join_group(text),
  public.rotate_invite_code(uuid),
  public.group_roster(uuid),
  public.group_leaderboard(uuid, date),
  public.new_invite_code()
to authenticated;
