-- FI-YOU P0 launch QA support: legal consent, KPI events, data export/delete request.

create table if not exists public.legal_consents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  terms_version text not null,
  privacy_version text not null,
  ai_notice_version text not null,
  locale text not null default 'ko',
  user_agent text,
  accepted_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  unique (user_id, terms_version, privacy_version, ai_notice_version)
);

create table if not exists public.app_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  event_name text not null,
  properties jsonb not null default '{}'::jsonb,
  session_id text,
  created_at timestamptz not null default now()
);

create index if not exists app_events_user_created_idx
  on public.app_events(user_id, created_at desc);

create index if not exists app_events_name_created_idx
  on public.app_events(event_name, created_at desc);

create table if not exists public.data_export_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'requested' check (status in ('requested', 'processing', 'ready', 'failed', 'cancelled')),
  requested_at timestamptz not null default now(),
  completed_at timestamptz,
  metadata jsonb not null default '{}'::jsonb
);

create index if not exists data_export_requests_user_requested_idx
  on public.data_export_requests(user_id, requested_at desc);

create table if not exists public.account_deletion_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'requested' check (status in ('requested', 'processing', 'completed', 'cancelled')),
  reason text,
  requested_at timestamptz not null default now(),
  completed_at timestamptz,
  metadata jsonb not null default '{}'::jsonb
);

create unique index if not exists account_deletion_one_active_idx
  on public.account_deletion_requests(user_id)
  where status in ('requested', 'processing');

alter table public.legal_consents enable row level security;
alter table public.app_events enable row level security;
alter table public.data_export_requests enable row level security;
alter table public.account_deletion_requests enable row level security;

drop policy if exists "legal consents own select" on public.legal_consents;
drop policy if exists "legal consents own insert" on public.legal_consents;
create policy "legal consents own select" on public.legal_consents
  for select using ((select auth.uid()) = user_id);
create policy "legal consents own insert" on public.legal_consents
  for insert with check ((select auth.uid()) = user_id);

drop policy if exists "app events own select" on public.app_events;
drop policy if exists "app events own insert" on public.app_events;
create policy "app events own select" on public.app_events
  for select using ((select auth.uid()) = user_id);
create policy "app events own insert" on public.app_events
  for insert with check ((select auth.uid()) = user_id);

drop policy if exists "data export requests own select" on public.data_export_requests;
drop policy if exists "data export requests own insert" on public.data_export_requests;
create policy "data export requests own select" on public.data_export_requests
  for select using ((select auth.uid()) = user_id);
create policy "data export requests own insert" on public.data_export_requests
  for insert with check ((select auth.uid()) = user_id);

drop policy if exists "account deletion requests own select" on public.account_deletion_requests;
drop policy if exists "account deletion requests own insert" on public.account_deletion_requests;
create policy "account deletion requests own select" on public.account_deletion_requests
  for select using ((select auth.uid()) = user_id);
create policy "account deletion requests own insert" on public.account_deletion_requests
  for insert with check ((select auth.uid()) = user_id);

grant select, insert on public.legal_consents to authenticated;
grant select, insert on public.app_events to authenticated;
grant select, insert on public.data_export_requests to authenticated;
grant select, insert on public.account_deletion_requests to authenticated;

create or replace function public.record_legal_consent(
  p_terms_version text default '2026-06-16',
  p_privacy_version text default '2026-06-16',
  p_ai_notice_version text default '2026-06-16',
  p_locale text default 'ko',
  p_user_agent text default null
)
returns public.legal_consents
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_result public.legal_consents;
begin
  if v_user is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  insert into public.legal_consents(user_id, terms_version, privacy_version, ai_notice_version, locale, user_agent)
  values (v_user, p_terms_version, p_privacy_version, p_ai_notice_version, coalesce(p_locale, 'ko'), p_user_agent)
  on conflict (user_id, terms_version, privacy_version, ai_notice_version)
  do update set accepted_at = now(), locale = excluded.locale, user_agent = excluded.user_agent
  returning * into v_result;

  return v_result;
end;
$$;

create or replace function public.record_app_event(
  p_event_name text,
  p_properties jsonb default '{}'::jsonb,
  p_session_id text default null
)
returns uuid
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_id uuid;
begin
  if v_user is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  insert into public.app_events(user_id, event_name, properties, session_id)
  values (v_user, p_event_name, coalesce(p_properties, '{}'::jsonb), p_session_id)
  returning id into v_id;

  return v_id;
end;
$$;

create or replace function public.request_data_export(p_metadata jsonb default '{}'::jsonb)
returns public.data_export_requests
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_result public.data_export_requests;
begin
  if v_user is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  insert into public.data_export_requests(user_id, metadata)
  values (v_user, coalesce(p_metadata, '{}'::jsonb))
  returning * into v_result;

  return v_result;
end;
$$;

create or replace function public.request_account_deletion(
  p_reason text default null,
  p_metadata jsonb default '{}'::jsonb
)
returns public.account_deletion_requests
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_result public.account_deletion_requests;
begin
  if v_user is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  select *
  into v_result
  from public.account_deletion_requests
  where user_id = v_user
    and status in ('requested', 'processing')
  order by requested_at desc
  limit 1;

  if v_result.id is not null then
    return v_result;
  end if;

  insert into public.account_deletion_requests(user_id, reason, metadata)
  values (v_user, p_reason, coalesce(p_metadata, '{}'::jsonb))
  returning * into v_result;

  return v_result;
end;
$$;

create or replace function public.reset_my_records()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_deleted_answers integer := 0;
  v_deleted_diaries integer := 0;
  v_deleted_relations integer := 0;
begin
  if v_user is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  delete from public.onboarding_answers where user_id = v_user;
  get diagnostics v_deleted_answers = row_count;

  delete from public.answers where user_id = v_user;

  update public.diaries
  set deleted_at = coalesce(deleted_at, now()),
      updated_at = now()
  where user_id = v_user
    and deleted_at is null;
  get diagnostics v_deleted_diaries = row_count;

  delete from public.signals where user_id = v_user;
  delete from public.u_map_snapshots where user_id = v_user;
  delete from public.entitlements where user_id = v_user;
  delete from public.relations where user_id = v_user;
  get diagnostics v_deleted_relations = row_count;

  update public.profiles
  set onboarding_completed = false,
      required_questions_completed_at = null,
      focus_area = null,
      focus_selected_at = null,
      updated_at = now()
  where user_id = v_user;

  return jsonb_build_object(
    'onboarding_answers_deleted', v_deleted_answers,
    'diaries_deleted', v_deleted_diaries,
    'relations_deleted', v_deleted_relations
  );
end;
$$;

revoke execute on function public.record_legal_consent(text, text, text, text, text) from public, anon;
revoke execute on function public.record_app_event(text, jsonb, text) from public, anon;
revoke execute on function public.request_data_export(jsonb) from public, anon;
revoke execute on function public.request_account_deletion(text, jsonb) from public, anon;
revoke execute on function public.reset_my_records() from public, anon;

grant execute on function public.record_legal_consent(text, text, text, text, text) to authenticated;
grant execute on function public.record_app_event(text, jsonb, text) to authenticated;
grant execute on function public.request_data_export(jsonb) to authenticated;
grant execute on function public.request_account_deletion(text, jsonb) to authenticated;
grant execute on function public.reset_my_records() to authenticated;
