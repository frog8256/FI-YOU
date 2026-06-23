create table if not exists public.user_insights (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  insight_type text not null check (insight_type in (
    'emerging_pattern',
    'internal_tension',
    'exploration_gap',
    'consistent_theme',
    'change_over_time'
  )),
  title text not null,
  description text not null,
  supporting_nodes jsonb not null default '[]'::jsonb,
  supporting_answers jsonb not null default '[]'::jsonb,
  confidence_level text not null check (confidence_level in (
    'early',
    'forming',
    'consistent'
  )),
  evidence_count integer not null default 0 check (evidence_count >= 0),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, insight_type, title)
);

create table if not exists public.user_insight_refresh_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  last_answered_count integer not null default 0 check (last_answered_count >= 0),
  last_pattern_signature text,
  last_refreshed_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists user_insights_user_active_updated_idx
  on public.user_insights(user_id, active, updated_at desc);

create index if not exists user_insights_user_type_idx
  on public.user_insights(user_id, insight_type);

alter table public.user_insights enable row level security;
alter table public.user_insight_refresh_state enable row level security;

drop policy if exists "user insights own select" on public.user_insights;
create policy "user insights own select" on public.user_insights
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "user insight refresh state own select" on public.user_insight_refresh_state;
create policy "user insight refresh state own select" on public.user_insight_refresh_state
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

grant select on public.user_insights to authenticated;
grant select on public.user_insight_refresh_state to authenticated;

create or replace function public.touch_user_insights_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists touch_user_insights_updated_at on public.user_insights;
create trigger touch_user_insights_updated_at
  before update on public.user_insights
  for each row
  execute function public.touch_user_insights_updated_at();

revoke execute on function public.touch_user_insights_updated_at() from public, anon, authenticated;

create or replace function public.touch_user_insight_refresh_state_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists touch_user_insight_refresh_state_updated_at on public.user_insight_refresh_state;
create trigger touch_user_insight_refresh_state_updated_at
  before update on public.user_insight_refresh_state
  for each row
  execute function public.touch_user_insight_refresh_state_updated_at();

revoke execute on function public.touch_user_insight_refresh_state_updated_at() from public, anon, authenticated;

comment on table public.user_insights
  is 'Discovery-oriented insights generated from exploration history without scores, labels, or diagnostics.';

comment on table public.user_insight_refresh_state
  is 'Per-user refresh checkpoint for the Insight Engine.';
