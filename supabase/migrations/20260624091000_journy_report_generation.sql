-- Service-grade Journy reports: temporarily priced at 1 Star.

create table if not exists public.journy_reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'ready'
    check (status in ('generating', 'ready', 'failed')),
  star_cost integer not null default 0,
  source_window_start timestamptz,
  source_window_end timestamptz not null default now(),
  source_counts jsonb not null default '{}'::jsonb,
  chapter_title text not null,
  chapter_summary text not null,
  timeline_events jsonb not null default '[]'::jsonb,
  pattern_evolution jsonb not null default '[]'::jsonb,
  turning_points jsonb not null default '[]'::jsonb,
  next_steps jsonb not null default '[]'::jsonb,
  evidence jsonb not null default '[]'::jsonb,
  model_version text not null default 'journy-sql-v1',
  source_ledger_id uuid references public.star_ledger(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists journy_reports_user_created_idx
  on public.journy_reports(user_id, created_at desc);

create table if not exists public.journy_report_sources (
  id uuid primary key default gen_random_uuid(),
  report_id uuid not null references public.journy_reports(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  source_type text not null,
  source_id uuid,
  source_label text,
  created_at timestamptz not null default now()
);

create index if not exists journy_report_sources_report_idx
  on public.journy_report_sources(report_id);

alter table public.journy_reports enable row level security;
alter table public.journy_report_sources enable row level security;

drop policy if exists "journy reports own select" on public.journy_reports;
create policy "journy reports own select"
  on public.journy_reports
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "journy report sources own select" on public.journy_report_sources;
create policy "journy report sources own select"
  on public.journy_report_sources
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

grant select on public.journy_reports, public.journy_report_sources
  to authenticated;

create or replace function public.spend_star(
  p_reason text,
  p_amount integer,
  p_ref_type text default null,
  p_ref_id uuid default null
)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_balance integer;
  v_key text;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  if p_amount <= 0 then
    raise exception 'amount_must_be_positive';
  end if;

  if p_reason not in (
    'free_explore',
    'journy_report',
    'u_map_detail_report',
    'love_analysis',
    'relation_map',
    'past_compare'
  ) then
    raise exception 'invalid_spend_reason';
  end if;

  perform pg_advisory_xact_lock(hashtext(v_user::text));

  v_key := v_user::text || ':spend:' || p_reason || ':' ||
    coalesce(p_ref_id::text, p_ref_type, 'global');

  if exists (select 1 from public.star_ledger where idempotency_key = v_key) then
    return public.get_star_balance();
  end if;

  select coalesce(sum(amount), 0)::integer
    into v_balance
  from public.star_ledger
  where user_id = v_user;

  if v_balance < p_amount then
    raise exception 'insufficient_star';
  end if;

  insert into public.star_ledger(
    user_id,
    entry_type,
    reason,
    amount,
    requested_amount,
    ref_type,
    ref_id,
    idempotency_key
  )
  values (
    v_user,
    'spend',
    p_reason,
    -p_amount,
    -p_amount,
    p_ref_type,
    p_ref_id,
    v_key
  );

  return public.get_star_balance();
end;
$$;

revoke execute on function public.spend_star(text, integer, text, uuid)
  from public, anon;
grant execute on function public.spend_star(text, integer, text, uuid)
  to authenticated;

create or replace function public.generate_journy_report(
  p_star_cost integer default 1
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_report_id uuid := gen_random_uuid();
  v_balance integer;
  v_ledger_id uuid;
  v_report public.journy_reports;
  v_diary_count integer;
  v_answer_count integer;
  v_signal_count integer;
  v_window_start timestamptz;
  v_timeline jsonb;
  v_patterns jsonb;
  v_evidence jsonb;
  v_summary text;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  if p_star_cost <> 1 then
    raise exception 'invalid_journy_cost';
  end if;

  select min(source_time),
      count(*) filter (where source_type = 'diary'),
      count(*) filter (where source_type = 'answer'),
      count(*) filter (where source_type = 'signal')
    into v_window_start, v_diary_count, v_answer_count, v_signal_count
  from (
    select *
    from (
      select 'diary' as source_type, created_at as source_time
      from public.diaries
      where user_id = v_user and deleted_at is null
      order by created_at desc
      limit 30
    ) d
    union all
    select *
    from (
      select 'answer' as source_type, answered_at as source_time
      from public.answers
      where user_id = v_user
      order by answered_at desc
      limit 30
    ) a
    union all
    select *
    from (
      select 'signal' as source_type, observed_at as source_time
      from public.signals
      where user_id = v_user
      order by observed_at desc
      limit 30
    ) s
  ) sources;

  if coalesce(v_diary_count, 0) + coalesce(v_answer_count, 0) + coalesce(v_signal_count, 0) < 3 then
    raise exception 'insufficient_journy_sources';
  end if;

  if p_star_cost > 0 then
    v_balance := public.spend_star(
      'journy_report',
      p_star_cost,
      'journy_report',
      v_report_id
    );

    select id into v_ledger_id
    from public.star_ledger
    where user_id = v_user
      and reason = 'journy_report'
      and ref_id = v_report_id
    order by created_at desc
    limit 1;
  else
    v_balance := public.get_star_balance();
  end if;

  select coalesce(jsonb_agg(item order by item->>'dateLabel' desc), '[]'::jsonb)
    into v_timeline
  from (
    select jsonb_build_object(
      'dateLabel', to_char(entry_date, 'YYYY.MM.DD'),
      'title', title,
      'body', left(body, 220)
    ) as item
    from public.diaries
    where user_id = v_user and deleted_at is null
    order by entry_date desc
    limit 8
  ) timeline_rows;

  select coalesce(jsonb_agg(item), '[]'::jsonb)
    into v_patterns
  from (
    select jsonb_build_object(
      'title', initcap(replace(axis, '_', ' ')),
      'body', coalesce(max(evidence_summary), '최근 기록에서 반복적으로 관찰되는 신호입니다.'),
      'confidenceLabel', case
        when avg(confidence) >= 0.7 then '반복 신호 강함'
        when avg(confidence) >= 0.45 then '형성 중'
        else '초기 신호'
      end
    ) as item
    from public.signals
    where user_id = v_user
    group by axis
    order by avg(strength) desc
    limit 3
  ) pattern_rows;

  select coalesce(jsonb_agg(item), '[]'::jsonb)
    into v_evidence
  from (
    select jsonb_build_object(
      'label', title,
      'body', left(body, 180),
      'sourceType', 'Diary'
    ) as item
    from public.diaries
    where user_id = v_user and deleted_at is null
    order by entry_date desc
    limit 4
  ) evidence_rows;

  v_summary := case
    when coalesce(v_signal_count, 0) >= 5 then
      '최근 기록에서는 여러 신호가 하나의 방향으로 모이며, 지금의 선택 기준이 조금씩 선명해지는 흐름이 보입니다.'
    when coalesce(v_diary_count, 0) >= 3 then
      '최근 Diary를 중심으로 감정과 선택의 흐름이 이어지고 있어요. 아직 결론보다 관찰이 더 중요한 챕터입니다.'
    else
      '최근 탐구 답변과 기록을 바탕으로 첫 번째 Journy 리포트를 구성했어요. 다음 기록이 쌓이면 변화선이 더 선명해집니다.'
  end;

  insert into public.journy_reports(
    id,
    user_id,
    status,
    star_cost,
    source_window_start,
    source_counts,
    chapter_title,
    chapter_summary,
    timeline_events,
    pattern_evolution,
    turning_points,
    next_steps,
    evidence,
    source_ledger_id
  )
  values (
    v_report_id,
    v_user,
    'ready',
    p_star_cost,
    v_window_start,
    jsonb_build_object(
      'diary', coalesce(v_diary_count, 0),
      'answers', coalesce(v_answer_count, 0),
      'uMapSignals', coalesce(v_signal_count, 0)
    ),
    '지금의 흐름을 다시 읽는 시기',
    v_summary,
    v_timeline,
    v_patterns,
    jsonb_build_array(jsonb_build_object(
      'title', '최근 기록이 만든 전환점',
      'body', '반복된 기록이 단편적인 감정에서 하나의 흐름으로 묶이기 시작했어요.',
      'confidenceLabel', '중간 확신'
    )),
    jsonb_build_array(
      jsonb_build_object(
        'title', '다음 탐구 질문',
        'body', '지금 내가 붙잡고 있는 기준은 나를 보호하기 위한 것일까, 앞으로 나아가기 위한 것일까?',
        'confidenceLabel', '추천'
      ),
      jsonb_build_object(
        'title', '다음 Diary 프롬프트',
        'body', '오늘의 선택 하나를 골라, 그 선택 뒤에 있던 감정을 한 문장으로 적어보세요.',
        'confidenceLabel', '추천'
      )
    ),
    v_evidence,
    v_ledger_id
  )
  returning * into v_report;

  insert into public.journy_report_sources(report_id, user_id, source_type, source_id, source_label)
  select v_report.id, v_user, 'diary', id, title
  from public.diaries
  where user_id = v_user and deleted_at is null
  order by entry_date desc
  limit 8;

  return jsonb_build_object(
    'starBalance', v_balance,
    'report', jsonb_build_object(
      'id', v_report.id,
      'title', v_report.chapter_title,
      'summary', v_report.chapter_summary,
      'sourceWindowLabel', '최근 30개 기록 기반',
      'sourceCounts', v_report.source_counts,
      'timelineEvents', v_report.timeline_events,
      'patterns', v_report.pattern_evolution,
      'turningPoints', v_report.turning_points,
      'nextSteps', v_report.next_steps,
      'evidence', v_report.evidence,
      'createdAt', v_report.created_at,
      'starCost', v_report.star_cost
    )
  );
end;
$$;

revoke execute on function public.generate_journy_report(integer)
  from public, anon;
grant execute on function public.generate_journy_report(integer)
  to authenticated;

comment on function public.generate_journy_report(integer)
  is 'Creates a stored Journy report. Temporary price is 1 Star.';
