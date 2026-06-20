-- FI-YOU P0 live Supabase contract.
-- Flutter should use these RPC facades with the anon/publishable key and an
-- authenticated user session. Derived AI/U-Map tables remain server-written.

alter table public.answers
  alter column selected_option_id drop not null;

alter table public.diaries
  add column if not exists metadata jsonb not null default '{}'::jsonb;

create table if not exists public.u_map_axis_contract (
  axis_key text primary key,
  display_order integer not null unique,
  label_ko text not null,
  description_ko text not null,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

insert into public.u_map_axis_contract(axis_key, display_order, label_ko, description_ko)
values
  ('self_expression', 1, '에너지 리듬', '기록에서 드러나는 표현 속도와 에너지의 흐름입니다.'),
  ('emotional_sensitivity', 2, '감정 인식', '마음의 반응을 알아차리고 이름 붙이는 흐름입니다.'),
  ('independence', 3, '가치 기준', '스스로 중요하게 여기는 기준을 확인하는 흐름입니다.'),
  ('initiative', 4, '선택 방식', '생각을 선택과 행동으로 옮기는 방식입니다.'),
  ('relationship', 5, '관계 흐름', '관계 안에서 반복해서 보이는 반응과 거리감입니다.'),
  ('stability', 6, '긴장과 회복', '흔들림 이후 정리하고 회복하는 방식입니다.'),
  ('growth', 7, '성장 동기', '배움, 변화, 시도를 향해 움직이는 흐름입니다.'),
  ('exploration', 8, '삶의 방향', '앞으로 살펴보고 싶은 가능성과 방향감입니다.')
on conflict (axis_key) do update
set display_order = excluded.display_order,
    label_ko = excluded.label_ko,
    description_ko = excluded.description_ko,
    active = true;

alter table public.u_map_axis_contract enable row level security;

drop policy if exists "u map axis contract public read" on public.u_map_axis_contract;
create policy "u map axis contract public read" on public.u_map_axis_contract
  for select using (active = true);

grant select on public.u_map_axis_contract to anon, authenticated;

create table if not exists public.insight_feedback (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  target_type text not null check (target_type in ('u_map_snapshot', 'signal', 'report_body', 'daily_insight')),
  target_id uuid,
  action text not null check (action in ('hide', 'disagree', 'revise_note', 'clear_note')),
  note text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, target_type, target_id, action)
);

create index if not exists insight_feedback_user_created_idx
  on public.insight_feedback(user_id, created_at desc);

create table if not exists public.ai_report_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  target_type text not null check (target_type in ('u_map_snapshot', 'signal', 'report_body', 'daily_insight', 'edge_function')),
  target_id uuid,
  reason text not null,
  details text,
  status text not null default 'received' check (status in ('received', 'triaged', 'resolved', 'rejected')),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists ai_report_requests_user_created_idx
  on public.ai_report_requests(user_id, created_at desc);

alter table public.insight_feedback enable row level security;
alter table public.ai_report_requests enable row level security;

drop policy if exists "insight feedback own select" on public.insight_feedback;
drop policy if exists "insight feedback own insert" on public.insight_feedback;
drop policy if exists "insight feedback own update" on public.insight_feedback;
create policy "insight feedback own select" on public.insight_feedback
  for select using ((select auth.uid()) = user_id);
create policy "insight feedback own insert" on public.insight_feedback
  for insert with check ((select auth.uid()) = user_id);
create policy "insight feedback own update" on public.insight_feedback
  for update using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "ai report requests own select" on public.ai_report_requests;
drop policy if exists "ai report requests own insert" on public.ai_report_requests;
create policy "ai report requests own select" on public.ai_report_requests
  for select using ((select auth.uid()) = user_id);
create policy "ai report requests own insert" on public.ai_report_requests
  for insert with check ((select auth.uid()) = user_id);

grant select, insert, update on public.insight_feedback to authenticated;
grant select, insert on public.ai_report_requests to authenticated;

revoke insert, update, delete on public.signals from anon, authenticated;
revoke insert, update, delete on public.u_map_snapshots from anon, authenticated;
grant select on public.signals, public.u_map_snapshots to authenticated;
drop policy if exists "signals own insert" on public.signals;
drop policy if exists "u map snapshots own insert" on public.u_map_snapshots;

create or replace function public.upsert_profile(
  p_nickname text default null,
  p_preferred_language text default 'ko',
  p_birthday date default null,
  p_focus_area text default null
)
returns public.profiles
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_result public.profiles;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  insert into public.profiles (
    user_id,
    nickname,
    preferred_language,
    birthday,
    focus_area,
    focus_selected_at,
    updated_at
  )
  values (
    v_user,
    nullif(btrim(coalesce(p_nickname, '')), ''),
    coalesce(nullif(btrim(coalesce(p_preferred_language, '')), ''), 'ko'),
    p_birthday,
    nullif(btrim(coalesce(p_focus_area, '')), ''),
    case when nullif(btrim(coalesce(p_focus_area, '')), '') is null then null else now() end,
    now()
  )
  on conflict (user_id) do update
    set nickname = coalesce(nullif(btrim(coalesce(excluded.nickname, '')), ''), public.profiles.nickname),
        preferred_language = coalesce(nullif(btrim(coalesce(excluded.preferred_language, '')), ''), public.profiles.preferred_language),
        birthday = coalesce(excluded.birthday, public.profiles.birthday),
        focus_area = coalesce(nullif(btrim(coalesce(excluded.focus_area, '')), ''), public.profiles.focus_area),
        focus_selected_at = case
          when excluded.focus_area is not null then now()
          else public.profiles.focus_selected_at
        end,
        updated_at = now()
  returning * into v_result;

  return v_result;
end;
$$;

create or replace function public.submit_question_answer(
  p_question_set text,
  p_question_id uuid,
  p_selected_option_id uuid default null,
  p_optional_text text default null,
  p_skipped boolean default false
)
returns jsonb
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_question public.questions;
  v_option_question_id uuid;
  v_answer_id uuid;
  v_latest_snapshot_id uuid;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  if p_question_set not in ('onboarding_required', 'basic_free') then
    raise exception 'unsupported_question_set_for_mobile_core';
  end if;

  select *
    into v_question
  from public.questions
  where id = p_question_id
    and question_set = p_question_set
    and active = true;

  if v_question.id is null then
    raise exception 'question_not_found';
  end if;

  if p_question_set = 'onboarding_required' and p_skipped then
    raise exception 'onboarding_question_cannot_be_skipped';
  end if;

  if not p_skipped and p_selected_option_id is null then
    raise exception 'selected_option_required';
  end if;

  if p_selected_option_id is not null then
    select question_id
      into v_option_question_id
    from public.question_options
    where id = p_selected_option_id;

    if v_option_question_id is distinct from p_question_id then
      raise exception 'selected_option_must_belong_to_question';
    end if;
  end if;

  if p_question_set = 'onboarding_required' then
    insert into public.onboarding_answers(user_id, question_id, selected_option_id, optional_text, answered_at)
    values (v_user, p_question_id, p_selected_option_id, nullif(btrim(coalesce(p_optional_text, '')), ''), now())
    on conflict (user_id, question_id) do update
      set selected_option_id = excluded.selected_option_id,
          optional_text = excluded.optional_text,
          answered_at = now()
    returning id into v_answer_id;
  else
    insert into public.answers(user_id, question_id, selected_option_id, optional_text, skipped, answered_at, updated_at)
    values (
      v_user,
      p_question_id,
      case when p_skipped then null else p_selected_option_id end,
      nullif(btrim(coalesce(p_optional_text, '')), ''),
      coalesce(p_skipped, false),
      now(),
      now()
    )
    on conflict (user_id, question_id) do update
      set selected_option_id = excluded.selected_option_id,
          optional_text = excluded.optional_text,
          skipped = excluded.skipped,
          updated_at = now()
    returning id into v_answer_id;
  end if;

  select id
    into v_latest_snapshot_id
  from public.u_map_snapshots
  where user_id = v_user
  order by created_at desc
  limit 1;

  return jsonb_build_object(
    'answerId', v_answer_id,
    'questionId', p_question_id,
    'questionSet', p_question_set,
    'skipped', coalesce(p_skipped, false),
    'latestUMapSnapshotId', v_latest_snapshot_id,
    'questionLoop', public.get_question_loop_state(p_question_set)
  );
end;
$$;

create or replace function public.complete_onboarding(
  p_nickname text default null,
  p_preferred_language text default 'ko',
  p_birthday date default null,
  p_focus_area text default null
)
returns jsonb
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_required_count integer;
  v_answer_count integer;
  v_profile public.profiles;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  v_profile := public.upsert_profile(p_nickname, p_preferred_language, p_birthday, p_focus_area);

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

  if v_required_count = 0 then
    raise exception 'onboarding_questions_not_seeded';
  end if;

  if v_answer_count < v_required_count then
    raise exception 'required_onboarding_answers_missing';
  end if;

  if nullif(btrim(coalesce(v_profile.nickname, '')), '') is null then
    raise exception 'nickname_required';
  end if;

  update public.profiles
  set onboarding_completed = true,
      required_questions_completed_at = now(),
      updated_at = now()
  where user_id = v_user
  returning * into v_profile;

  return jsonb_build_object(
    'profile', to_jsonb(v_profile),
    'launchGate', public.get_launch_gate_state()
  );
end;
$$;

create or replace function public.upsert_diary(
  p_body text,
  p_mood_label text default null,
  p_title text default null,
  p_entry_date date default ((now() at time zone 'Asia/Seoul')::date),
  p_diary_id uuid default null,
  p_metadata jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_diary public.diaries;
  v_sanitized_metadata jsonb;
  v_star_balance integer;
  v_latest_snapshot_id uuid;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  if nullif(btrim(coalesce(p_body, '')), '') is null then
    raise exception 'diary_body_required';
  end if;

  v_sanitized_metadata := jsonb_build_object(
    'situation', left(coalesce(p_metadata ->> 'situation', ''), 120),
    'people', left(coalesce(p_metadata ->> 'people', ''), 80),
    'memorableSentence', left(coalesce(p_metadata ->> 'memorableSentence', ''), 180),
    'emotionTags', coalesce(p_metadata -> 'emotionTags', '[]'::jsonb)
  );

  if p_diary_id is null then
    select *
      into v_diary
    from public.diaries
    where user_id = v_user
      and entry_date = coalesce(p_entry_date, ((now() at time zone 'Asia/Seoul')::date))
      and deleted_at is null
    limit 1;

    if v_diary.id is null then
      insert into public.diaries(user_id, entry_date, title, body, mood_label, metadata, updated_at)
      values (
        v_user,
        coalesce(p_entry_date, ((now() at time zone 'Asia/Seoul')::date)),
        coalesce(nullif(btrim(coalesce(p_title, '')), ''), 'Diary'),
        btrim(p_body),
        nullif(btrim(coalesce(p_mood_label, '')), ''),
        v_sanitized_metadata,
        now()
      )
      returning * into v_diary;
    else
      update public.diaries
      set title = coalesce(nullif(btrim(coalesce(p_title, '')), ''), title),
          body = btrim(p_body),
          mood_label = nullif(btrim(coalesce(p_mood_label, '')), ''),
          metadata = coalesce(metadata, '{}'::jsonb) || v_sanitized_metadata,
          updated_at = now()
      where id = v_diary.id
        and user_id = v_user
      returning * into v_diary;
    end if;
  else
    update public.diaries
    set title = coalesce(nullif(btrim(coalesce(p_title, '')), ''), title),
        body = btrim(p_body),
        mood_label = nullif(btrim(coalesce(p_mood_label, '')), ''),
        metadata = coalesce(metadata, '{}'::jsonb) || v_sanitized_metadata,
        updated_at = now()
    where id = p_diary_id
      and user_id = v_user
      and deleted_at is null
    returning * into v_diary;

    if v_diary.id is null then
      raise exception 'diary_not_found';
    end if;
  end if;

  if char_length(v_diary.body) >= 50 then
    perform public.grant_diary_star_once(v_diary.id);
  end if;

  v_star_balance := public.get_star_balance();

  select id
    into v_latest_snapshot_id
  from public.u_map_snapshots
  where user_id = v_user
  order by created_at desc
  limit 1;

  return jsonb_build_object(
    'diary', to_jsonb(v_diary),
    'starBalance', v_star_balance,
    'latestUMapSnapshotId', v_latest_snapshot_id
  );
end;
$$;

create or replace function public.get_latest_u_map()
returns jsonb
language plpgsql
stable
security invoker
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_snapshot public.u_map_snapshots;
  v_axes jsonb;
  v_total_sources integer;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  select *
    into v_snapshot
  from public.u_map_snapshots
  where user_id = v_user
  order by created_at desc
  limit 1;

  select count(*)
    into v_total_sources
  from public.signals
  where user_id = v_user;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'axisKey', c.axis_key,
        'displayOrder', c.display_order,
        'labelKo', c.label_ko,
        'descriptionKo', c.description_ko,
        'score', coalesce((v_snapshot.axis_scores ->> c.axis_key)::integer, 0),
        'clarity', coalesce((v_snapshot.axis_clarity ->> c.axis_key)::integer, 0),
        'sourceCount', (
          select count(*)
          from public.signals s
          where s.user_id = v_user
            and s.axis = c.axis_key
        ),
        'evidence', coalesce((
          select jsonb_agg(
            jsonb_build_object(
              'signalId', s.id,
              'sourceType', s.source_type,
              'sourceId', s.source_id,
              'evidenceSummary', s.evidence_summary,
              'observedAt', s.observed_at
            )
            order by s.observed_at desc
          )
          from (
            select *
            from public.signals s
            where s.user_id = v_user
              and s.axis = c.axis_key
            order by s.observed_at desc
            limit 3
          ) s
        ), '[]'::jsonb)
      )
      order by c.display_order
    ),
    '[]'::jsonb
  )
  into v_axes
  from public.u_map_axis_contract c
  where c.active = true;

  return jsonb_build_object(
    'snapshotId', v_snapshot.id,
    'generatedAt', v_snapshot.created_at,
    'sourceCount', coalesce(v_total_sources, 0),
    'summary', v_snapshot.summary,
    'unclearAxes', coalesce(v_snapshot.unclear_axes, '{}'::text[]),
    'dominantSignals', coalesce(v_snapshot.dominant_signals, '[]'::jsonb),
    'axes', v_axes,
    'lowData', coalesce(v_total_sources, 0) < 6
  );
end;
$$;

create or replace function public.save_insight_feedback(
  p_target_type text,
  p_target_id uuid,
  p_action text,
  p_note text default null,
  p_metadata jsonb default '{}'::jsonb
)
returns public.insight_feedback
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_result public.insight_feedback;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  if p_action not in ('hide', 'disagree', 'revise_note', 'clear_note') then
    raise exception 'invalid_insight_feedback_action';
  end if;

  insert into public.insight_feedback(user_id, target_type, target_id, action, note, metadata)
  values (
    v_user,
    p_target_type,
    p_target_id,
    p_action,
    nullif(btrim(coalesce(p_note, '')), ''),
    coalesce(p_metadata, '{}'::jsonb)
  )
  on conflict (user_id, target_type, target_id, action) do update
    set note = excluded.note,
        metadata = public.insight_feedback.metadata || excluded.metadata,
        updated_at = now()
  returning * into v_result;

  return v_result;
end;
$$;

create or replace function public.report_ai_output(
  p_target_type text,
  p_target_id uuid,
  p_reason text,
  p_details text default null,
  p_metadata jsonb default '{}'::jsonb
)
returns public.ai_report_requests
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_result public.ai_report_requests;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  if nullif(btrim(coalesce(p_reason, '')), '') is null then
    raise exception 'report_reason_required';
  end if;

  insert into public.ai_report_requests(user_id, target_type, target_id, reason, details, metadata)
  values (
    v_user,
    p_target_type,
    p_target_id,
    left(btrim(p_reason), 80),
    nullif(left(btrim(coalesce(p_details, '')), 2000), ''),
    coalesce(p_metadata, '{}'::jsonb)
  )
  returning * into v_result;

  return v_result;
end;
$$;

create or replace function public.get_privacy_request_state()
returns jsonb
language plpgsql
stable
security invoker
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_export public.data_export_requests;
  v_deletion public.account_deletion_requests;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  select *
    into v_export
  from public.data_export_requests
  where user_id = v_user
  order by requested_at desc
  limit 1;

  select *
    into v_deletion
  from public.account_deletion_requests
  where user_id = v_user
  order by requested_at desc
  limit 1;

  return jsonb_build_object(
    'latestExportRequest', case when v_export.id is null then null else to_jsonb(v_export) end,
    'latestDeletionRequest', case when v_deletion.id is null then null else to_jsonb(v_deletion) end,
    'deletionSlaDays', 30,
    'exportSlaDays', 7
  );
end;
$$;

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
    and nullif(btrim(coalesce(v_profile.preferred_language, '')), '') is not null;

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

create or replace function private.handle_answer_signal()
returns trigger
language plpgsql
security definer
set search_path = public, private, pg_temp
as $$
begin
  if new.skipped then
    delete from public.signals
    where user_id = new.user_id
      and source_type = 'normal_answer'
      and source_id = new.id;

    perform private.rebuild_u_map_snapshot(new.user_id);
    return new;
  end if;

  perform private.refresh_question_signals(
    new.user_id,
    'normal_answer',
    new.id,
    new.question_id,
    new.selected_option_id,
    new.optional_text
  );
  return new;
end;
$$;

revoke execute on function public.upsert_profile(text, text, date, text) from public, anon;
revoke execute on function public.submit_question_answer(text, uuid, uuid, text, boolean) from public, anon;
revoke execute on function public.complete_onboarding(text, text, date, text) from public, anon;
revoke execute on function public.upsert_diary(text, text, text, date, uuid, jsonb) from public, anon;
revoke execute on function public.get_latest_u_map() from public, anon;
revoke execute on function public.save_insight_feedback(text, uuid, text, text, jsonb) from public, anon;
revoke execute on function public.report_ai_output(text, uuid, text, text, jsonb) from public, anon;
revoke execute on function public.get_privacy_request_state() from public, anon;

grant execute on function public.upsert_profile(text, text, date, text) to authenticated;
grant execute on function public.submit_question_answer(text, uuid, uuid, text, boolean) to authenticated;
grant execute on function public.complete_onboarding(text, text, date, text) to authenticated;
grant execute on function public.upsert_diary(text, text, text, date, uuid, jsonb) to authenticated;
grant execute on function public.get_latest_u_map() to authenticated;
grant execute on function public.save_insight_feedback(text, uuid, text, text, jsonb) to authenticated;
grant execute on function public.report_ai_output(text, uuid, text, text, jsonb) to authenticated;
grant execute on function public.get_privacy_request_state() to authenticated;

revoke all on all functions in schema private from anon, authenticated;

comment on function public.submit_question_answer(text, uuid, uuid, text, boolean)
  is 'Flutter live contract: saves onboarding/basic question answers by stable ids and lets triggers refresh signals/U-Map.';

comment on function public.upsert_diary(text, text, text, date, uuid, jsonb)
  is 'Flutter live contract: creates or updates a user diary with privacy-bounded metadata, diary star reward, and U-Map refresh.';

comment on function public.get_latest_u_map()
  is 'Flutter live contract: latest U-Map snapshot with eight Korean axis labels, source counts, and recent evidence.';
