-- Card Delivery Engine state, history, and coverage contract.

create table if not exists public.user_exploration_state (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  total_cards_answered integer not null default 0 check (total_cards_answered >= 0),
  current_depth_level integer not null default 1 check (current_depth_level between 1 and 5),
  last_active_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_card_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  parent_node text not null,
  parent_node_id text,
  child_node text not null,
  child_node_id text,
  card_type text not null check (card_type in (
    'scenario_choice',
    'multiple_choice',
    'priority_selection',
    'binary_choice'
  )),
  depth_level integer not null check (depth_level between 1 and 5),
  time_axis text not null check (time_axis in (
    'present',
    'past',
    'future',
    'repeated_pattern',
    'imagined_scenario'
  )),
  answered boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.user_node_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  parent_node text not null,
  parent_node_id text,
  child_node text not null,
  child_node_id text,
  times_explored integer not null default 0 check (times_explored >= 0),
  last_explored_at timestamptz,
  coverage_score numeric(10, 4) not null default 0 check (coverage_score >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, child_node)
);

create unique index if not exists user_node_progress_user_child_id_idx
  on public.user_node_progress(user_id, child_node_id)
  where child_node_id is not null;

create index if not exists user_card_history_user_created_idx
  on public.user_card_history(user_id, created_at desc);

create index if not exists user_card_history_user_child_created_idx
  on public.user_card_history(user_id, child_node, created_at desc);

create index if not exists user_node_progress_user_parent_idx
  on public.user_node_progress(user_id, parent_node);

alter table public.user_exploration_state enable row level security;
alter table public.user_card_history enable row level security;
alter table public.user_node_progress enable row level security;

drop policy if exists "user exploration state own select" on public.user_exploration_state;
create policy "user exploration state own select" on public.user_exploration_state
  for select using (auth.uid() = user_id);

drop policy if exists "user card history own select" on public.user_card_history;
create policy "user card history own select" on public.user_card_history
  for select using (auth.uid() = user_id);

drop policy if exists "user node progress own select" on public.user_node_progress;
create policy "user node progress own select" on public.user_node_progress
  for select using (auth.uid() = user_id);

grant select on public.user_exploration_state to authenticated;
grant select on public.user_card_history to authenticated;
grant select on public.user_node_progress to authenticated;

create or replace function public.record_delivered_exploration_card(
  p_user_id uuid,
  p_parent_node text,
  p_parent_node_id text,
  p_child_node text,
  p_child_node_id text,
  p_card_type text,
  p_depth_level integer,
  p_time_axis text
)
returns public.user_card_history
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row public.user_card_history;
begin
  if auth.uid() is distinct from p_user_id and auth.role() <> 'service_role' then
    raise exception 'not_authorized';
  end if;

  insert into public.user_exploration_state(user_id, current_depth_level, last_active_at)
  values (p_user_id, p_depth_level, now())
  on conflict (user_id) do update
  set current_depth_level = excluded.current_depth_level,
      last_active_at = excluded.last_active_at,
      updated_at = now();

  insert into public.user_card_history(
    user_id,
    parent_node,
    parent_node_id,
    child_node,
    child_node_id,
    card_type,
    depth_level,
    time_axis
  )
  values (
    p_user_id,
    p_parent_node,
    p_parent_node_id,
    p_child_node,
    p_child_node_id,
    p_card_type,
    p_depth_level,
    p_time_axis
  )
  returning * into v_row;

  insert into public.user_node_progress(
    user_id,
    parent_node,
    parent_node_id,
    child_node,
    child_node_id,
    times_explored,
    last_explored_at,
    coverage_score
  )
  values (
    p_user_id,
    p_parent_node,
    p_parent_node_id,
    p_child_node,
    p_child_node_id,
    1,
    now(),
    1
  )
  on conflict (user_id, child_node) do update
  set parent_node = excluded.parent_node,
      parent_node_id = excluded.parent_node_id,
      child_node_id = coalesce(excluded.child_node_id, public.user_node_progress.child_node_id),
      times_explored = public.user_node_progress.times_explored + 1,
      last_explored_at = now(),
      coverage_score = public.user_node_progress.coverage_score + 1,
      updated_at = now();

  return v_row;
end;
$$;

create or replace function public.mark_exploration_card_answered(p_card_history_id uuid)
returns public.user_card_history
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_row public.user_card_history;
  v_was_answered boolean;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  select *
    into v_row
  from public.user_card_history
  where id = p_card_history_id
    and user_id = v_user
  for update;

  if v_row.id is null then
    raise exception 'card_history_not_found';
  end if;

  v_was_answered := v_row.answered;

  if not v_was_answered then
    update public.user_card_history
    set answered = true
    where id = p_card_history_id
    returning * into v_row;
  end if;

  insert into public.user_exploration_state(user_id, total_cards_answered, current_depth_level, last_active_at)
  values (v_user, case when v_was_answered then 0 else 1 end, v_row.depth_level, now())
  on conflict (user_id) do update
  set total_cards_answered = public.user_exploration_state.total_cards_answered +
      case when v_was_answered then 0 else 1 end,
      current_depth_level = v_row.depth_level,
      last_active_at = now(),
      updated_at = now();

  return v_row;
end;
$$;

revoke execute on function public.record_delivered_exploration_card(uuid, text, text, text, text, text, integer, text) from public, anon;
revoke execute on function public.mark_exploration_card_answered(uuid) from public, anon;

grant execute on function public.record_delivered_exploration_card(uuid, text, text, text, text, text, integer, text) to authenticated, service_role;
grant execute on function public.mark_exploration_card_answered(uuid) to authenticated;

comment on table public.user_exploration_state
  is 'Current per-user exploration progression state for the Card Delivery Engine.';

comment on table public.user_card_history
  is 'Every exploration card delivered to a user, including unanswered cards.';

comment on table public.user_node_progress
  is 'Per-user child-node coverage used by the Card Delivery Engine node selector.';
