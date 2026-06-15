-- Clean up P0 signal and U-Map text after residual hardening.
-- Keeps the applied migration history intact and replaces the active functions.

create or replace function private.rebuild_u_map_snapshot(p_user_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public, private, pg_temp
as $$
declare
  v_snapshot_id uuid;
  v_axis_scores jsonb;
  v_axis_clarity jsonb;
  v_unclear_axes text[];
  v_dominant jsonb;
  v_summary text;
begin
  if p_user_id is null then
    raise exception 'user_required';
  end if;

  with axis_rollup as (
    select
      a.axis,
      coalesce(sum(s.strength * s.confidence), 0) as signal_weight,
      coalesce(sum(s.clarity_contribution), 0) as clarity_weight,
      count(s.id) as signal_count
    from private.axis_seed() a
    left join public.signals s
      on s.user_id = p_user_id
     and s.axis = a.axis
    group by a.axis
  ),
  normalized as (
    select
      axis,
      least(100, greatest(8, round((signal_weight * 28) + (signal_count * 4) + 10)))::int as score,
      least(100, greatest(4, round((clarity_weight * 12) + (signal_count * 6) + 6)))::int as clarity
    from axis_rollup
  )
  select
    jsonb_object_agg(axis, score),
    jsonb_object_agg(axis, clarity),
    coalesce(array_agg(axis order by clarity asc) filter (where clarity < 35), '{}'::text[])
  into v_axis_scores, v_axis_clarity, v_unclear_axes
  from normalized;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'axis', axis,
        'strength', strength,
        'confidence', confidence,
        'evidence', evidence_summary
      )
      order by strength * confidence desc, observed_at desc
    ),
    '[]'::jsonb
  )
  into v_dominant
  from (
    select axis, strength, confidence, evidence_summary, observed_at
    from public.signals
    where user_id = p_user_id
    order by strength * confidence desc, observed_at desc
    limit 5
  ) top_signals;

  v_summary := case
    when coalesce(jsonb_array_length(v_dominant), 0) = 0 then
      '아직 U-Map 단서가 많지 않아요. 질문과 Diary가 쌓이면 현재 경향이 조금씩 선명해집니다.'
    else
      '현재까지의 답변과 기록을 바탕으로 만든 U-Map입니다. 이 결과는 고정 유형이 아니라 지금까지 보인 흐름이에요.'
  end;

  insert into public.u_map_snapshots(user_id, axis_scores, axis_clarity, dominant_signals, unclear_axes, summary)
  values (
    p_user_id,
    coalesce(v_axis_scores, '{}'::jsonb),
    coalesce(v_axis_clarity, '{}'::jsonb),
    coalesce(v_dominant, '[]'::jsonb),
    coalesce(v_unclear_axes, array[]::text[]),
    v_summary
  )
  returning id into v_snapshot_id;

  return v_snapshot_id;
end;
$$;

create or replace function private.refresh_question_signals(
  p_user_id uuid,
  p_source_type text,
  p_source_id uuid,
  p_question_id uuid,
  p_selected_option_id uuid,
  p_optional_text text
)
returns void
language plpgsql
security definer
set search_path = public, private, pg_temp
as $$
declare
  v_axes text[];
  v_weights jsonb;
  v_option_question_id uuid;
  v_strength numeric(4,3);
  v_confidence numeric(4,3);
  v_clarity numeric(6,3);
  v_axis text;
  v_weight numeric;
begin
  if p_selected_option_id is null then
    raise exception 'selected_option_required';
  end if;

  select question_id, axis_weights
    into v_option_question_id, v_weights
  from public.question_options
  where id = p_selected_option_id;

  if v_option_question_id is distinct from p_question_id then
    raise exception 'selected_option_must_belong_to_question';
  end if;

  select axis_keys
    into v_axes
  from public.questions
  where id = p_question_id
    and active = true;

  if v_axes is null then
    raise exception 'question_not_found_or_inactive';
  end if;

  delete from public.signals
  where user_id = p_user_id
    and source_type = p_source_type
    and source_id = p_source_id;

  v_strength := least(1, 0.35 + case when length(coalesce(trim(p_optional_text), '')) > 0 then 0.18 else 0 end);
  v_confidence := least(1, 0.45 + case when length(coalesce(trim(p_optional_text), '')) > 0 then 0.20 else 0 end);
  v_clarity := 0.8 + least(2.2, length(coalesce(trim(p_optional_text), '')) / 120.0);

  if jsonb_typeof(coalesce(v_weights, '{}'::jsonb)) = 'object' and coalesce(v_weights, '{}'::jsonb) <> '{}'::jsonb then
    for v_axis, v_weight in
      select key, value::text::numeric
      from jsonb_each(v_weights)
    loop
      if v_axis in (select axis from private.axis_seed()) then
        insert into public.signals(user_id, source_type, source_id, axis, polarity, strength, confidence, clarity_contribution, a_model, c_model, evidence_summary)
        values (
          p_user_id,
          p_source_type,
          p_source_id,
          v_axis,
          'neutral',
          least(1, v_strength + least(0.25, greatest(0, v_weight))),
          v_confidence,
          v_clarity,
          jsonb_build_object('source', 'choice', 'questionId', p_question_id, 'optionId', p_selected_option_id),
          case when length(coalesce(trim(p_optional_text), '')) > 0
            then jsonb_build_object('source', 'optional_text', 'textLength', length(trim(p_optional_text)))
            else null
          end,
          '선택 답변에서 U-Map 단서가 생성되었어요.'
        );
      end if;
    end loop;
  else
    foreach v_axis in array coalesce(v_axes, array[]::text[]) loop
      if v_axis in (select axis from private.axis_seed()) then
        insert into public.signals(user_id, source_type, source_id, axis, polarity, strength, confidence, clarity_contribution, a_model, c_model, evidence_summary)
        values (
          p_user_id,
          p_source_type,
          p_source_id,
          v_axis,
          'neutral',
          v_strength,
          v_confidence,
          v_clarity,
          jsonb_build_object('source', 'question_axis', 'questionId', p_question_id),
          case when length(coalesce(trim(p_optional_text), '')) > 0
            then jsonb_build_object('source', 'optional_text', 'textLength', length(trim(p_optional_text)))
            else null
          end,
          '질문 응답에서 U-Map 단서가 생성되었어요.'
        );
      end if;
    end loop;
  end if;

  perform private.rebuild_u_map_snapshot(p_user_id);
end;
$$;

create or replace function private.refresh_diary_signals(
  p_user_id uuid,
  p_diary_id uuid,
  p_body text,
  p_title text
)
returns void
language plpgsql
security definer
set search_path = public, private, pg_temp
as $$
declare
  v_text text := lower(coalesce(p_title, '') || ' ' || coalesce(p_body, ''));
  v_len integer := length(coalesce(p_body, ''));
  v_axis text;
  v_strength numeric(4,3);
  v_confidence numeric(4,3);
begin
  delete from public.signals
  where user_id = p_user_id
    and source_type = 'diary'
    and source_id = p_diary_id;

  foreach v_axis in array array[
    'emotional_sensitivity',
    'self_expression',
    'relationship',
    'stability',
    'growth',
    'exploration',
    'independence',
    'initiative'
  ] loop
    v_strength := case v_axis
      when 'relationship' then case when v_text ~ '(친구|가족|연인|동료|관계|대화|사람)' then 0.78 else 0.34 end
      when 'stability' then case when v_text ~ '(휴식|안정|불안|차분|회복|정리)' then 0.76 else 0.32 end
      when 'growth' then case when v_text ~ '(성장|배움|나아|시도|개선|목표)' then 0.78 else 0.33 end
      when 'exploration' then case when v_text ~ '(새로운|궁금|탐색|여행|경험|가능성)' then 0.78 else 0.31 end
      when 'independence' then case when v_text ~ '(혼자|내 기준|자유|독립|선택)' then 0.76 else 0.31 end
      when 'initiative' then case when v_text ~ '(실행|행동|결정|시작|해냈|만들)' then 0.76 else 0.32 end
      when 'self_expression' then case when v_text ~ '(표현|말했|쓴다|기록|드러)' then 0.76 else 0.36 end
      else case when v_text ~ '(감정|기분|마음|좋았|싫었|속상|설렘)' then 0.80 else 0.38 end
    end;

    v_confidence := least(0.92, 0.42 + least(0.36, v_len / 350.0));

    insert into public.signals(user_id, source_type, source_id, axis, polarity, strength, confidence, clarity_contribution, a_model, c_model, evidence_summary)
    values (
      p_user_id,
      'diary',
      p_diary_id,
      v_axis,
      'neutral',
      v_strength,
      v_confidence,
      1.2 + least(3.2, v_len / 180.0),
      jsonb_build_object('source', 'diary_keyword', 'textLength', v_len),
      jsonb_build_object('source', 'diary_context', 'textLength', v_len),
      'Diary 기록에서 현재 경향을 살펴볼 단서가 생성되었어요.'
    );
  end loop;

  perform private.rebuild_u_map_snapshot(p_user_id);
end;
$$;
