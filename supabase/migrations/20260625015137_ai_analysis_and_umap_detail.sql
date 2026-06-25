-- AI analysis lineage and stored U-Map detail reports.

create table if not exists public.ai_analysis_runs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  target_type text,
  target_id uuid,
  run_type text not null check (run_type in (
    'diary_signal',
    'u_map_snapshot',
    'insight_refresh',
    'story_refresh',
    'journy_report',
    'u_map_detail_report'
  )),
  status text not null default 'succeeded' check (status in (
    'queued',
    'running',
    'succeeded',
    'failed',
    'rejected'
  )),
  model text not null default 'sql-rules-v1',
  prompt_version text not null default 'sql-v1',
  input_hash text,
  source_counts jsonb not null default '{}'::jsonb,
  safety_status text not null default 'passed' check (safety_status in (
    'passed',
    'rewritten',
    'blocked',
    'review_required'
  )),
  safety_flags jsonb not null default '[]'::jsonb,
  error_message text,
  metadata jsonb not null default '{}'::jsonb,
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists ai_analysis_runs_user_created_idx
  on public.ai_analysis_runs(user_id, created_at desc);

create index if not exists ai_analysis_runs_user_type_idx
  on public.ai_analysis_runs(user_id, run_type, created_at desc);

create index if not exists ai_analysis_runs_user_target_idx
  on public.ai_analysis_runs(user_id, target_type, target_id)
  where target_type is not null;

create table if not exists public.ai_observations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  run_id uuid references public.ai_analysis_runs(id) on delete set null,
  target_type text,
  target_id uuid,
  source_type text not null check (source_type in (
    'diary',
    'question_answer',
    'onboarding_answer',
    'exploration_card_answer',
    'signal',
    'u_map_snapshot',
    'derived'
  )),
  source_id uuid,
  domain text not null check (domain in (
    'self_image',
    'action_pattern',
    'life_direction',
    'personality',
    'values',
    'motivation',
    'emotion_pattern',
    'stress_response',
    'relationship',
    'decision_making',
    'u_map_axis'
  )),
  taxonomy_node_id text,
  taxonomy_node_label text,
  axis_key text,
  observation_type text not null check (observation_type in (
    'preference',
    'friction',
    'repeated_pattern',
    'tension',
    'gap',
    'change',
    'strength',
    'risk',
    'evidence'
  )),
  polarity text not null default 'neutral' check (polarity in (
    'positive',
    'negative',
    'mixed',
    'neutral'
  )),
  strength numeric(4,3) not null default 0 check (strength >= 0 and strength <= 1),
  confidence numeric(4,3) not null default 0 check (confidence >= 0 and confidence <= 1),
  evidence_summary text,
  evidence_ref jsonb not null default '{}'::jsonb,
  safety_tags jsonb not null default '[]'::jsonb,
  model_version text not null default 'sql-rules-v1',
  observed_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index if not exists ai_observations_user_created_idx
  on public.ai_observations(user_id, created_at desc);

create index if not exists ai_observations_user_axis_idx
  on public.ai_observations(user_id, axis_key, observed_at desc)
  where axis_key is not null;

create index if not exists ai_observations_run_idx
  on public.ai_observations(run_id);

create index if not exists ai_observations_user_target_idx
  on public.ai_observations(user_id, target_type, target_id)
  where target_type is not null;

create table if not exists public.u_map_detail_reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'ready' check (status in (
    'generating',
    'ready',
    'failed'
  )),
  star_cost integer not null default 0 check (star_cost >= 0),
  source_window_start timestamptz,
  source_window_end timestamptz not null default now(),
  source_counts jsonb not null default '{}'::jsonb,
  data_sufficiency jsonb not null default '{}'::jsonb,
  keywords jsonb not null default '[]'::jsonb,
  title text not null,
  core_sentence text not null,
  summary text not null,
  sections jsonb not null default '[]'::jsonb,
  action_plans jsonb not null default '[]'::jsonb,
  recording_guides jsonb not null default '[]'::jsonb,
  evidence jsonb not null default '[]'::jsonb,
  model_version text not null default 'u-map-detail-sql-v1',
  run_id uuid references public.ai_analysis_runs(id) on delete set null,
  source_snapshot_id uuid references public.u_map_snapshots(id) on delete set null,
  source_ledger_id uuid references public.star_ledger(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists u_map_detail_reports_user_created_idx
  on public.u_map_detail_reports(user_id, created_at desc);

create index if not exists u_map_detail_reports_run_idx
  on public.u_map_detail_reports(run_id);

alter table public.ai_analysis_runs enable row level security;
alter table public.ai_observations enable row level security;
alter table public.u_map_detail_reports enable row level security;

drop policy if exists "ai analysis runs own select" on public.ai_analysis_runs;
create policy "ai analysis runs own select"
  on public.ai_analysis_runs
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "ai observations own select" on public.ai_observations;
create policy "ai observations own select"
  on public.ai_observations
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "u map detail reports own select" on public.u_map_detail_reports;
create policy "u map detail reports own select"
  on public.u_map_detail_reports
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

grant select on public.ai_analysis_runs to authenticated;
grant select on public.ai_observations to authenticated;
grant select on public.u_map_detail_reports to authenticated;

grant all on public.ai_analysis_runs to service_role;
grant all on public.ai_observations to service_role;
grant all on public.u_map_detail_reports to service_role;

alter table public.insight_feedback
  drop constraint if exists insight_feedback_target_type_check;
alter table public.insight_feedback
  add constraint insight_feedback_target_type_check
  check (target_type in (
    'u_map_snapshot',
    'signal',
    'report_body',
    'daily_insight',
    'user_insight',
    'user_story',
    'journy_report',
    'u_map_detail_report'
  ));

alter table public.ai_report_requests
  drop constraint if exists ai_report_requests_target_type_check;
alter table public.ai_report_requests
  add constraint ai_report_requests_target_type_check
  check (target_type in (
    'u_map_snapshot',
    'signal',
    'report_body',
    'daily_insight',
    'edge_function',
    'user_insight',
    'user_story',
    'journy_report',
    'u_map_detail_report'
  ));

create or replace function public.touch_u_map_detail_reports_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists touch_u_map_detail_reports_updated_at
  on public.u_map_detail_reports;
create trigger touch_u_map_detail_reports_updated_at
  before update on public.u_map_detail_reports
  for each row
  execute function public.touch_u_map_detail_reports_updated_at();

revoke execute on function public.touch_u_map_detail_reports_updated_at()
  from public, anon, authenticated;

create or replace function public.generate_u_map_detail_report(
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
  v_run_id uuid;
  v_balance integer;
  v_ledger_id uuid;
  v_snapshot public.u_map_snapshots;
  v_signal_count integer := 0;
  v_diary_count integer := 0;
  v_answer_count integer := 0;
  v_card_answer_count integer := 0;
  v_axis_count integer := 0;
  v_record_count integer := 0;
  v_window_start timestamptz;
  v_top_axes jsonb := '[]'::jsonb;
  v_keywords jsonb := '[]'::jsonb;
  v_data_sufficiency jsonb;
  v_sections jsonb;
  v_action_plans jsonb;
  v_recording_guides jsonb;
  v_evidence jsonb;
  v_source_counts jsonb;
  v_core_sentence text;
  v_summary text;
  v_report public.u_map_detail_reports;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  if p_star_cost <> 1 then
    raise exception 'invalid_u_map_detail_cost';
  end if;

  select *
    into v_snapshot
  from public.u_map_snapshots
  where user_id = v_user
  order by created_at desc
  limit 1;

  select count(*), min(observed_at)
    into v_signal_count, v_window_start
  from public.signals
  where user_id = v_user;

  select count(*)
    into v_diary_count
  from public.diaries
  where user_id = v_user
    and deleted_at is null;

  select count(*)
    into v_answer_count
  from public.answers
  where user_id = v_user;

  select count(*)
    into v_card_answer_count
  from public.user_card_answers
  where user_id = v_user;

  select count(distinct axis)
    into v_axis_count
  from public.signals
  where user_id = v_user;

  v_record_count := coalesce(v_signal_count, 0)
    + coalesce(v_diary_count, 0)
    + coalesce(v_answer_count, 0)
    + coalesce(v_card_answer_count, 0);

  if v_record_count < 3 then
    raise exception 'insufficient_u_map_detail_sources';
  end if;

  if p_star_cost > 0 then
    v_balance := public.spend_star(
      'u_map_detail_report',
      p_star_cost,
      'u_map_detail_report',
      v_report_id
    );

    select id
      into v_ledger_id
    from public.star_ledger
    where user_id = v_user
      and reason = 'u_map_detail_report'
      and ref_id = v_report_id
    order by created_at desc
    limit 1;
  else
    v_balance := public.get_star_balance();
  end if;

  v_source_counts := jsonb_build_object(
    'nodes', coalesce(v_axis_count, 0),
    'records', coalesce(v_record_count, 0),
    'diary', coalesce(v_diary_count, 0),
    'answers', coalesce(v_answer_count, 0),
    'explorationCards', coalesce(v_card_answer_count, 0),
    'uMapSignals', coalesce(v_signal_count, 0)
  );

  insert into public.ai_analysis_runs(
    user_id,
    target_type,
    target_id,
    run_type,
    status,
    model,
    prompt_version,
    input_hash,
    source_counts,
    safety_status,
    completed_at,
    metadata
  )
  values (
    v_user,
    'u_map_detail_report',
    v_report_id,
    'u_map_detail_report',
    'succeeded',
    'u-map-detail-sql-v1',
    'u-map-detail-sql-v1',
    md5(v_user::text || ':' || coalesce(v_snapshot.id::text, 'no-snapshot') || ':' || v_record_count::text),
    v_source_counts,
    'passed',
    now(),
    jsonb_build_object(
      'sourceSnapshotId', v_snapshot.id,
      'starCost', p_star_cost
    )
  )
  returning id into v_run_id;

  insert into public.ai_observations(
    user_id,
    run_id,
    target_type,
    target_id,
    source_type,
    source_id,
    domain,
    axis_key,
    observation_type,
    polarity,
    strength,
    confidence,
    evidence_summary,
    evidence_ref,
    model_version
  )
  select
    v_user,
    v_run_id,
    'u_map_detail_report',
    v_report_id,
    'signal',
    s.id,
    'u_map_axis',
    s.axis,
    case
      when s.confidence >= 0.7 then 'repeated_pattern'
      else 'evidence'
    end,
    s.polarity,
    s.strength,
    s.confidence,
    left(coalesce(s.evidence_summary, 'Record-based U-Map clue'), 500),
    jsonb_build_object(
      'sourceType', s.source_type,
      'sourceId', s.source_id,
      'observedAt', s.observed_at
    ),
    'u-map-detail-sql-v1'
  from (
    select *
    from public.signals
    where user_id = v_user
    order by confidence desc, strength desc, observed_at desc
    limit 24
  ) s;

  select coalesce(jsonb_agg(item), '[]'::jsonb)
    into v_top_axes
  from (
    select jsonb_build_object(
      'axisKey', c.axis_key,
      'label', c.label_ko,
      'score', coalesce((v_snapshot.axis_scores ->> c.axis_key)::integer, 0),
      'clarity', coalesce((v_snapshot.axis_clarity ->> c.axis_key)::integer, 0),
      'sourceCount', count(s.id)
    ) as item
    from public.u_map_axis_contract c
    left join public.signals s
      on s.user_id = v_user
      and s.axis = c.axis_key
    where c.active = true
    group by c.axis_key, c.label_ko, c.display_order
    order by count(s.id) desc,
      coalesce((v_snapshot.axis_scores ->> c.axis_key)::integer, 0) desc,
      c.display_order
    limit 5
  ) axis_rows;

  select coalesce(jsonb_agg(keyword), '[]'::jsonb)
    into v_keywords
  from (
    select distinct keyword.value as keyword
    from jsonb_array_elements_text(
      coalesce(
        (
          select jsonb_agg(item.value ->> 'label')
          from jsonb_array_elements(v_top_axes) as item(value)
          where coalesce(item.value ->> 'label', '') <> ''
        ),
        '[]'::jsonb
      )
    ) as keyword(value)
    limit 6
  ) keyword_rows;

  v_data_sufficiency := jsonb_build_object(
    'score', least(96, greatest(24, 28 + coalesce(v_record_count, 0) * 4 + coalesce(v_axis_count, 0) * 5)),
    'label', case
      when v_record_count >= 20 and v_axis_count >= 5 then 'Strong enough for clear results'
      when v_record_count >= 8 then 'Enough records for a forming result'
      else 'Early result with limited records'
    end,
    'items', jsonb_build_array(
      jsonb_build_object(
        'label', 'U-Map signals',
        'value', coalesce(v_signal_count, 0)::text,
        'status', case when v_signal_count >= 8 then 'enough' else 'forming' end
      ),
      jsonb_build_object(
        'label', 'Source records',
        'value', coalesce(v_record_count, 0)::text,
        'status', case when v_record_count >= 12 then 'enough' else 'needs_more' end
      ),
      jsonb_build_object(
        'label', 'Diary records',
        'value', coalesce(v_diary_count, 0)::text,
        'status', case when v_diary_count >= 3 then 'reflected' else 'light' end
      )
    )
  );

  v_core_sentence := case
    when v_record_count >= 12 then
      'Analysis result: your current records show repeated patterns across several U-Map areas.'
    else
      'Analysis result: your current records are beginning to show early U-Map patterns.'
  end;

  v_summary := 'This report is based on the records currently saved in FI-YOU. It is not a fixed identity, diagnosis, score, or final decision.';

  v_sections := jsonb_build_array(
    jsonb_build_object(
      'type', 'clear_results',
      'title', 'Clear Results',
      'body', 'Analysis result: the strongest current clues are the areas that appear repeatedly across answers, Diary records, and U-Map signals.',
      'insights', jsonb_build_array('Treat these as current record-based results, not a fixed label.'),
      'evidenceLabels', jsonb_build_array('U-Map signals', 'Diary', 'Question answers')
    ),
    jsonb_build_object(
      'type', 'preference_results',
      'title', 'Preference Results',
      'body', 'Your records can be read as preference clues: which conditions feel easier to choose, repeat, or protect.',
      'insights', jsonb_build_array('Repeated axes suggest conditions worth testing in daily choices.'),
      'evidenceLabels', jsonb_build_array('Repeated choices', 'Recent records')
    ),
    jsonb_build_object(
      'type', 'interest_results',
      'title', 'Interest Results',
      'body', 'Interest is treated here as repeated attention, not a permanent category. Areas with more records are better candidates for follow-up questions.',
      'insights', jsonb_build_array('The next best signal comes from writing one concrete scene around the top area.'),
      'evidenceLabels', jsonb_build_array('Exploration cards', 'U-Map axes')
    ),
    jsonb_build_object(
      'type', 'aptitude_work_fit',
      'title', 'Work-Style Fit',
      'body', 'Work fit is framed as fit and friction conditions. The current record can suggest environments to test, not one correct role.',
      'insights', jsonb_build_array('Look for where energy, autonomy, clarity, and recovery conditions appear together.'),
      'evidenceLabels', jsonb_build_array('Decision clues', 'Action pattern clues')
    ),
    jsonb_build_object(
      'type', 'career_type_fit',
      'title', 'Career Direction Fit',
      'body', 'The report should point to role conditions, not a single career answer. Current data is best used to narrow experiments.',
      'insights', jsonb_build_array('Use this as a short-list builder for small career or project experiments.'),
      'evidenceLabels', jsonb_build_array('Life direction', 'Values', 'Motivation')
    ),
    jsonb_build_object(
      'type', 'relationship_fit',
      'title', 'Relationship Fit',
      'body', 'Relationship clues describe your recorded experiences and needs. They do not judge another person or predict a relationship.',
      'insights', jsonb_build_array('Notice where distance, clarity, trust, or emotional pace repeat in records.'),
      'evidenceLabels', jsonb_build_array('Relationship pattern', 'Emotion pattern')
    ),
    jsonb_build_object(
      'type', 'personality_temperament',
      'title', 'Temperament Clues',
      'body', 'Temperament is shown as current repeated rhythm, not a personality type. The clearest clues are the ones that appear across different source types.',
      'insights', jsonb_build_array('Use the result as language for observation, not as a self-definition.'),
      'evidenceLabels', jsonb_build_array('U-Map', 'Diary', 'Answers')
    ),
    jsonb_build_object(
      'type', 'friction_conditions',
      'title', 'Friction Conditions',
      'body', 'Friction points are conditions that may need protection, simplification, or more records before you act on them.',
      'insights', jsonb_build_array('Friction is useful because it shows where a next question should become more concrete.'),
      'evidenceLabels', jsonb_build_array('Stress response', 'Decision fatigue', 'Low clarity areas')
    ),
    jsonb_build_object(
      'type', 'evidence',
      'title', 'Evidence',
      'body', 'The report uses saved records and derived U-Map signals. Evidence count matters more than certainty language.',
      'insights', jsonb_build_array('More source diversity makes future reports more specific.'),
      'evidenceLabels', jsonb_build_array('Source counts', 'Recent evidence')
    ),
    jsonb_build_object(
      'type', 'needs_more_records',
      'title', 'Needs More Records',
      'body', 'Areas with fewer records should stay open. FI-YOU should ask more concrete questions before making them prominent.',
      'insights', jsonb_build_array('Add one Diary entry about a recent choice, conflict, or energy shift.'),
      'evidenceLabels', jsonb_build_array('Low-count axes', 'Unclear areas')
    )
  );

  v_action_plans := jsonb_build_array(
    jsonb_build_object(
      'title', 'Test one repeated clue',
      'body', 'Choose one repeated U-Map area and test it in one small decision this week.',
      'horizon', 'This week'
    ),
    jsonb_build_object(
      'title', 'Write one concrete scene',
      'body', 'Add a Diary record about a real moment where this clue appeared or did not fit.',
      'horizon', 'Today'
    )
  );

  v_recording_guides := jsonb_build_array(
    'What condition made today feel easier or harder?',
    'Which choice did you keep returning to?',
    'Where did you need more space, clarity, or support?'
  );

  select coalesce(jsonb_agg(item), '[]'::jsonb)
    into v_evidence
  from (
    select jsonb_build_object(
      'label', coalesce(title, 'Diary'),
      'body', left(body, 180),
      'sourceType', 'Diary'
    ) as item
    from public.diaries
    where user_id = v_user
      and deleted_at is null
    order by entry_date desc
    limit 3
  ) evidence_rows;

  if jsonb_array_length(v_evidence) = 0 then
    select coalesce(jsonb_agg(item), '[]'::jsonb)
      into v_evidence
    from (
      select jsonb_build_object(
        'label', initcap(replace(axis, '_', ' ')),
        'body', left(coalesce(evidence_summary, 'U-Map signal'), 180),
        'sourceType', 'U-Map'
      ) as item
      from public.signals
      where user_id = v_user
      order by observed_at desc
      limit 3
    ) signal_evidence_rows;
  end if;

  insert into public.u_map_detail_reports(
    id,
    user_id,
    status,
    star_cost,
    source_window_start,
    source_counts,
    data_sufficiency,
    keywords,
    title,
    core_sentence,
    summary,
    sections,
    action_plans,
    recording_guides,
    evidence,
    model_version,
    run_id,
    source_snapshot_id,
    source_ledger_id
  )
  values (
    v_report_id,
    v_user,
    'ready',
    p_star_cost,
    v_window_start,
    v_source_counts,
    v_data_sufficiency,
    v_keywords,
    'U-Map Analysis Report',
    v_core_sentence,
    v_summary,
    v_sections,
    v_action_plans,
    v_recording_guides,
    v_evidence,
    'u-map-detail-sql-v1',
    v_run_id,
    v_snapshot.id,
    v_ledger_id
  )
  returning * into v_report;

  return jsonb_build_object(
    'starBalance', v_balance,
    'report', jsonb_build_object(
      'id', v_report.id,
      'title', v_report.title,
      'coreSentence', v_report.core_sentence,
      'summary', v_report.summary,
      'dataSufficiency', v_report.data_sufficiency,
      'sourceCounts', v_report.source_counts,
      'keywords', v_report.keywords,
      'sections', v_report.sections,
      'actionPlans', v_report.action_plans,
      'recordingGuides', v_report.recording_guides,
      'evidence', v_report.evidence,
      'createdAt', v_report.created_at,
      'starCost', v_report.star_cost
    )
  );
end;
$$;

revoke execute on function public.generate_u_map_detail_report(integer)
  from public, anon;
grant execute on function public.generate_u_map_detail_report(integer)
  to authenticated;

comment on table public.ai_analysis_runs
  is 'Per-user lineage for AI or rules-based analysis runs, including model, prompt version, source counts, and safety status.';

comment on table public.ai_observations
  is 'Intermediate record-based observations produced by AI or rules before they are assembled into U-Map, insights, stories, and reports.';

comment on table public.u_map_detail_reports
  is 'Stored U-Map detail reports assembled from source records, signals, and observations.';

comment on function public.generate_u_map_detail_report(integer)
  is 'Creates a stored U-Map detail report, records analysis lineage and observations, spends the configured Star cost, and returns the Flutter DTO shape.';
