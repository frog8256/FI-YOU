create table if not exists public.user_stories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  story_type text not null check (story_type in (
    'current_chapter',
    'emerging_direction',
    'internal_tension',
    'hidden_territory',
    'change_over_time'
  )),
  title text not null,
  description text not null,
  supporting_insights jsonb not null default '[]'::jsonb,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, story_type, title)
);

create table if not exists public.user_story_refresh_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  last_answered_count integer not null default 0 check (last_answered_count >= 0),
  last_insight_signature text,
  last_refreshed_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists user_stories_user_active_updated_idx
  on public.user_stories(user_id, active, updated_at desc);

create index if not exists user_stories_user_type_idx
  on public.user_stories(user_id, story_type);

alter table public.user_stories enable row level security;
alter table public.user_story_refresh_state enable row level security;

drop policy if exists "user stories own select" on public.user_stories;
create policy "user stories own select" on public.user_stories
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "user story refresh state own select" on public.user_story_refresh_state;
create policy "user story refresh state own select" on public.user_story_refresh_state
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

grant select on public.user_stories to authenticated;
grant select on public.user_story_refresh_state to authenticated;
grant all on public.user_stories to service_role;
grant all on public.user_story_refresh_state to service_role;

create or replace function public.touch_user_stories_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists touch_user_stories_updated_at on public.user_stories;
create trigger touch_user_stories_updated_at
  before update on public.user_stories
  for each row
  execute function public.touch_user_stories_updated_at();

revoke execute on function public.touch_user_stories_updated_at() from public, anon, authenticated;

create or replace function public.touch_user_story_refresh_state_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists touch_user_story_refresh_state_updated_at on public.user_story_refresh_state;
create trigger touch_user_story_refresh_state_updated_at
  before update on public.user_story_refresh_state
  for each row
  execute function public.touch_user_story_refresh_state_updated_at();

revoke execute on function public.touch_user_story_refresh_state_updated_at() from public, anon, authenticated;

comment on table public.user_stories
  is 'Reflective narrative stories generated from multiple insights without scores, labels, or diagnostics.';

comment on table public.user_story_refresh_state
  is 'Per-user refresh checkpoint for the Story Engine.';
