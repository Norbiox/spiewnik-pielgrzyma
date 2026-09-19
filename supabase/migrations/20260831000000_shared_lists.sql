-- Shared custom lists: schema, RLS policies and the two RPC functions that let a
-- user join a list by token without first being able to read it.
--
-- See docs/superpowers/specs/2026-08-31-shared-custom-lists-design.md for the
-- reasoning behind every grant and policy here.

create table public.shared_lists (
  id                  uuid primary key,
  share_token         uuid not null unique default gen_random_uuid(),
  owner_id            uuid not null references auth.users(id) on delete cascade,
  name                text not null,
  hymns_ids           int[] not null default '{}',
  archived_hymns_ids  int[] not null default '{}',
  version             bigint not null default 1
);

create table public.shared_list_members (
  list_id  uuid references public.shared_lists(id) on delete cascade,
  user_id  uuid references auth.users(id)          on delete cascade,
  primary key (list_id, user_id)
);

create index shared_list_members_user_id_idx on public.shared_list_members (user_id);

alter table public.shared_lists        enable row level security;
alter table public.shared_list_members enable row level security;

-- Supabase grants CRUD to anon/authenticated by default; strip anon entirely.
revoke all on public.shared_lists, public.shared_list_members from anon;

-- Members may edit contents, but never reassign ownership or the invite token.
revoke update on public.shared_lists from authenticated;
grant  update (name, hymns_ids, archived_hymns_ids, version)
       on public.shared_lists to authenticated;

-- security definer (not invoker as in the spec draft): this helper is called
-- from the shared_lists policies below and itself reads public.shared_lists.
-- With security invoker that inner read re-applies the same policy and Postgres
-- aborts with "infinite recursion detected in policy for relation". Running it
-- as the definer bypasses RLS for the membership lookup only; auth.uid() still
-- resolves to the calling user, and search_path is pinned so nothing can be
-- shadowed.
create or replace function public.is_list_participant(p_list_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.shared_lists l
    where l.id = p_list_id and l.owner_id = (select auth.uid())
  ) or exists (
    select 1 from public.shared_list_members m
    where m.list_id = p_list_id and m.user_id = (select auth.uid())
  );
$$;

create policy shared_lists_select on public.shared_lists
  for select to authenticated using (public.is_list_participant(id));

create policy shared_lists_update on public.shared_lists
  for update to authenticated using (public.is_list_participant(id));

create policy shared_lists_insert on public.shared_lists
  for insert to authenticated with check (owner_id = (select auth.uid()));

create policy shared_lists_delete on public.shared_lists
  for delete to authenticated using (owner_id = (select auth.uid()));

create policy members_select on public.shared_list_members
  for select to authenticated using (user_id = (select auth.uid()));

create policy members_delete on public.shared_list_members
  for delete to authenticated using (user_id = (select auth.uid()));
-- Deliberately no INSERT policy: joining is only possible through join_shared_list().

create or replace function public.preview_shared_list(p_token uuid)
returns table (id uuid, name text, hymns_count int)
language sql stable security definer set search_path = '' as $$
  select l.id, l.name, cardinality(l.hymns_ids)
  from public.shared_lists l
  where l.share_token = p_token;
$$;

create or replace function public.join_shared_list(p_token uuid)
returns uuid language plpgsql security definer set search_path = '' as $$
declare
  v_id uuid;
begin
  select l.id into v_id from public.shared_lists l where l.share_token = p_token;
  if v_id is null then
    raise exception 'list_not_found' using errcode = 'no_data_found';
  end if;
  insert into public.shared_list_members (list_id, user_id)
  values (v_id, auth.uid())
  on conflict do nothing;
  return v_id;
end;
$$;

revoke all on function public.preview_shared_list(uuid) from public, anon;
revoke all on function public.join_shared_list(uuid)    from public, anon;
grant execute on function public.preview_shared_list(uuid) to authenticated;
grant execute on function public.join_shared_list(uuid)    to authenticated;

alter publication supabase_realtime add table public.shared_lists;

-- Run by hand from the SQL editor when anonymous user count grows.
--
-- NOT the query from the Supabase docs: owner_id cascades, so deleting every
-- anonymous account older than 30 days would take live shared lists with it.
-- These two NOT EXISTS clauses are what keep participants alive.
--
-- delete from auth.users u
-- where u.is_anonymous
--   and u.created_at < now() - interval '30 days'
--   and not exists (select 1 from public.shared_lists        where owner_id = u.id)
--   and not exists (select 1 from public.shared_list_members where user_id  = u.id);
