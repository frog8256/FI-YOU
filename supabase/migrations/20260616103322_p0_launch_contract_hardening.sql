-- FI-YOU P0 launch contract hardening.
-- Adds server-side state contracts for onboarding gates, question loop restore,
-- free explore idempotency, relation finalization, and empty/completion states.

create table if not exists public.free_explore_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  client_request_id text not null,
  status text not null default 'started' check (status in ('started', 'completed', 'cancelled')),
  star_cost integer not null default 30,
  star_ledger_id uuid references public.star_ledger(id),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, client_request_id)
);

create index if not exists free_explore_sessions_user_created_idx
  on public.free_explore_sessions(user_id, created_at desc);

alter table public.free_explore_sessions enable row level security;

drop policy if exists "free explore sessions own select" on public.free_explore_sessions;
create policy "free explore sessions own select" on public.free_explore_sessions
  for select using ((select auth.uid()) = user_id);

grant select on public.free_explore_sessions to authenticated;

create unique index if not exists entitlements_user_type_global_idx
  on public.entitlements(user_id, entitlement_type)
  where ref_id is null;

create or replace function public.get_launch_gate_state()
returns jsonb
language plpgsql
stable
security invoker
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_profile public.profiles;
  v_required_count integer;
  v_answer_count integer;
  v_basic_answer_count integer;
  v_latest_snapshot_id uuid;
  v_has_legal_consent boolean;
  v_profile_basics_completed boolean;
  v_required_completed boolean;
  v_home_allowed boolean;
  v_next_screen text;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  select *
    into v_profile
  from public.profiles
  where user_id = v_user;

  select count(*)
    into v_required_count
  from public.questions
  where question_set = 'onboarding_required'
    and active = true;

  select count(distinct oa.question_id)
    into v_answer_count
  from public.onboarding_answers oa
  join public.questions q on q.id = oa.question_id
  where oa.user_id = v_user
    and q.question_set = 'onboarding_required'
    and q.active = true;

  select count(distinct a.question_id)
    into v_basic_answer_count
  from public.answers a
  join public.questions q on q.id = a.question_id
  where a.user_id = v_user
    and q.question_set = 'basic_free'
    and q.active = true;

  select id
    into v_latest_snapshot_id
  from public.u_map_snapshots
  where user_id = v_user
  order by created_at desc
  limit 1;

  select exists (
    select 1
    from public.legal_consents lc
    where lc.user_id = v_user
    order by accepted_at desc
    limit 1
  )
    into v_has_legal_consent;

  v_profile_basics_completed :=
    v_profile.user_id is not null
    and nullif(btrim(coalesce(v_profile.nickname, '')), '') is not null
    and v_profile.birthday is not null;

  v_required_completed := v_required_count > 0 and v_answer_count >= v_required_count;
  v_home_allowed := v_profile_basics_completed and v_required_completed and coalesce(v_profile.onboarding_completed, false);

  v_next_screen := case
    when v_profile.user_id is null or not v_profile_basics_completed then 'profile'
    when not v_required_completed then 'onboarding_questions'
    when not coalesce(v_profile.onboarding_completed, false) then 'complete_onboarding'
    else 'home'
  end;

  return jsonb_build_object(
    'userId', v_user,
    'profileExists', v_profile.user_id is not null,
    'profileBasicsCompleted', v_profile_basics_completed,
    'onboardingCompletedFlag', coalesce(v_profile.onboarding_completed, false),
    'requiredQuestionCount', v_required_count,
    'requiredAnswerCount', v_answer_count,
    'requiredQuestionsCompleted', v_required_completed,
    'basicAnswerCount', v_basic_answer_count,
    'latestUMapSnapshotId', v_latest_snapshot_id,
    'hasLegalConsent', coalesce(v_has_legal_consent, false),
    'homeAllowed', v_home_allowed,
    'nextScreen', v_next_screen
  );
end;
$$;

create or replace function public.get_question_loop_state(p_question_set text)
returns jsonb
language plpgsql
stable
security invoker
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_total integer;
  v_answered integer;
  v_answered_ids uuid[];
  v_next_question_id uuid;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  if p_question_set not in ('onboarding_required', 'basic_free', 'relation_map') then
    raise exception 'invalid_question_set';
  end if;

  select count(*)
    into v_total
  from public.questions
  where question_set = p_question_set
    and active = true;

  if p_question_set = 'onboarding_required' then
    select
      count(distinct oa.question_id),
      coalesce(array_agg(distinct oa.question_id), '{}'::uuid[])
    into v_answered, v_answered_ids
    from public.onboarding_answers oa
    join public.questions q on q.id = oa.question_id
    where oa.user_id = v_user
      and q.question_set = p_question_set
      and q.active = true;
  elsif p_question_set = 'basic_free' then
    select
      count(distinct a.question_id),
      coalesce(array_agg(distinct a.question_id), '{}'::uuid[])
    into v_answered, v_answered_ids
    from public.answers a
    join public.questions q on q.id = a.question_id
    where a.user_id = v_user
      and q.question_set = p_question_set
      and q.active = true;
  else
    v_answered := 0;
    v_answered_ids := '{}'::uuid[];
  end if;

  select q.id
    into v_next_question_id
  from public.questions q
  where q.question_set = p_question_set
    and q.active = true
    and not (q.id = any(coalesce(v_answered_ids, '{}'::uuid[])))
  order by q.sequence asc
  limit 1;

  return jsonb_build_object(
    'questionSet', p_question_set,
    'totalActive', coalesce(v_total, 0),
    'answeredCount', coalesce(v_answered, 0),
    'answeredIds', coalesce(v_answered_ids, '{}'::uuid[]),
    'nextQuestionId', v_next_question_id,
    'completed', coalesce(v_total, 0) > 0 and coalesce(v_answered, 0) >= coalesce(v_total, 0)
  );
end;
$$;

create or replace function public.get_user_content_state()
returns jsonb
language plpgsql
stable
security invoker
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  return jsonb_build_object(
    'onboardingAnswers', (select count(*) from public.onboarding_answers where user_id = v_user),
    'basicAnswers', (
      select count(*)
      from public.answers a
      join public.questions q on q.id = a.question_id
      where a.user_id = v_user and q.question_set = 'basic_free' and q.active = true
    ),
    'activeDiaries', (select count(*) from public.diaries where user_id = v_user and deleted_at is null),
    'deletedDiaries', (select count(*) from public.diaries where user_id = v_user and deleted_at is not null),
    'signals', (select count(*) from public.signals where user_id = v_user),
    'uMapSnapshots', (select count(*) from public.u_map_snapshots where user_id = v_user),
    'relations', (select count(*) from public.relations where user_id = v_user and archived_at is null),
    'relationDrafts', (select count(*) from public.relations where user_id = v_user and status = 'draft' and archived_at is null),
    'entitlements', (select count(*) from public.entitlements where user_id = v_user),
    'starBalance', public.get_star_balance(),
    'latestSnapshotId', (
      select id
      from public.u_map_snapshots
      where user_id = v_user
      order by created_at desc
      limit 1
    )
  );
end;
$$;

create or replace function public.start_free_explore(
  p_client_request_id text,
  p_metadata jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user uuid := auth.uid();
  v_request_id text := nullif(btrim(coalesce(p_client_request_id, '')), '');
  v_session public.free_explore_sessions;
  v_balance integer;
  v_ledger_id uuid;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  if v_request_id is null then
    raise exception 'client_request_id_required';
  end if;

  perform pg_advisory_xact_lock(hashtext(v_user::text || ':free_explore:' || v_request_id));

  insert into public.free_explore_sessions(user_id, client_request_id, metadata)
  values (v_user, v_request_id, coalesce(p_metadata, '{}'::jsonb))
  on conflict (user_id, client_request_id) do update
    set updated_at = now(),
        metadata = public.free_explore_sessions.metadata || excluded.metadata
  returning * into v_session;

  if v_session.star_ledger_id is not null then
    return jsonb_build_object(
      'sessionId', v_session.id,
      'status', v_session.status,
      'starLedgerId', v_session.star_ledger_id,
      'starBalance', public.get_star_balance(),
      'idempotentReplay', true
    );
  end if;

  v_balance := public.spend_star('free_explore', 30, 'free_explore_session', v_session.id);

  select id
    into v_ledger_id
  from public.star_ledger
  where user_id = v_user
    and reason = 'free_explore'
    and ref_type = 'free_explore_session'
    and ref_id = v_session.id
  order by created_at desc
  limit 1;

  update public.free_explore_sessions
  set star_ledger_id = v_ledger_id,
      updated_at = now()
  where id = v_session.id
  returning * into v_session;

  return jsonb_build_object(
    'sessionId', v_session.id,
    'status', v_session.status,
    'starLedgerId', v_session.star_ledger_id,
    'starBalance', v_balance,
    'idempotentReplay', false
  );
end;
$$;

create or replace function public.finalize_relation_map(
  p_relation_id uuid,
  p_cost integer default 80
)
returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user uuid := auth.uid();
  v_relation public.relations;
  v_answer_count integer;
  v_required_count integer;
  v_entitlement public.entitlements;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  if p_cost <> 80 then
    raise exception 'invalid_relation_map_cost';
  end if;

  perform pg_advisory_xact_lock(hashtext(v_user::text || ':relation_map:' || p_relation_id::text));

  select *
    into v_relation
  from public.relations
  where id = p_relation_id
    and user_id = v_user
    and archived_at is null;

  if v_relation.id is null then
    raise exception 'relation_not_found';
  end if;

  select count(*)
    into v_required_count
  from public.questions
  where question_set = 'relation_map'
    and active = true;

  v_required_count := least(coalesce(nullif(v_relation.max_questions, 0), v_required_count), v_required_count, 20);

  select count(distinct question_id)
    into v_answer_count
  from public.relation_answers
  where user_id = v_user
    and relation_id = p_relation_id;

  if v_answer_count < v_required_count then
    raise exception 'relation_answers_incomplete';
  end if;

  v_entitlement := public.unlock_entitlement('relation_map', 80, p_relation_id);

  update public.relations
  set status = 'completed',
      updated_at = now()
  where id = p_relation_id
    and user_id = v_user
    and status is distinct from 'completed';

  return jsonb_build_object(
    'relationId', p_relation_id,
    'status', 'completed',
    'answerCount', v_answer_count,
    'requiredCount', v_required_count,
    'entitlementId', v_entitlement.id,
    'starCost', v_entitlement.star_cost,
    'starBalance', public.get_star_balance()
  );
end;
$$;

revoke execute on function public.get_launch_gate_state() from public, anon;
revoke execute on function public.get_question_loop_state(text) from public, anon;
revoke execute on function public.get_user_content_state() from public, anon;
revoke execute on function public.start_free_explore(text, jsonb) from public, anon;
revoke execute on function public.finalize_relation_map(uuid, integer) from public, anon;

grant execute on function public.get_launch_gate_state() to authenticated;
grant execute on function public.get_question_loop_state(text) to authenticated;
grant execute on function public.get_user_content_state() to authenticated;
grant execute on function public.start_free_explore(text, jsonb) to authenticated;
grant execute on function public.finalize_relation_map(uuid, integer) to authenticated;

comment on function public.get_launch_gate_state()
  is 'Returns server-side launch gate state. FE must not enter Home unless homeAllowed is true.';

comment on function public.get_question_loop_state(text)
  is 'Returns active question loop progress by question_set using question ids, not UI indexes.';

comment on function public.start_free_explore(text, jsonb)
  is 'Starts a free explore session with Star spend idempotent by user_id + client_request_id.';

comment on function public.finalize_relation_map(uuid, integer)
  is 'Finalizes Relation-Map only after relation ownership and answer-count checks, then unlocks entitlement idempotently.';
