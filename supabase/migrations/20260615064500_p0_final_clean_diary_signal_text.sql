-- Final correction for Korean evidence text in active deterministic signal functions.

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
      '현재까지의 답변과 기록을 바탕으로 만든 U-Map입니다. 고정된 결론이 아니라 지금까지 보인 흐름이에요.'
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
    'exploration',
    'independence',
    'relationship',
    'growth',
    'emotional_sensitivity',
    'stability',
    'initiative',
    'self_expression'
  ] loop
    v_strength := case v_axis
      when 'exploration' then case when v_text ~ '(새로운|궁금|탐구|가능성|시도|여행|경험)' then 0.50 else 0.18 end
      when 'independence' then case when v_text ~ '(혼자|내 기준|독립|스스로|자유|나만)' then 0.52 else 0.18 end
      when 'relationship' then case when v_text ~ '(관계|친구|가족|연인|대화|그 사람|동료)' then 0.52 else 0.18 end
      when 'growth' then case when v_text ~ '(성장|배우|나아지|변화|목표|연습)' then 0.52 else 0.18 end
      when 'emotional_sensitivity' then case when v_text ~ '(마음|감정|불안|기분|아픔|차분|힘들|편안)' then 0.55 else 0.20 end
      when 'stability' then case when v_text ~ '(안정|계획|기준|정리|회복|루틴)' then 0.52 else 0.18 end
      when 'initiative' then case when v_text ~ '(시작|실행|해보|움직|결정|도전)' then 0.52 else 0.18 end
      else case when v_text ~ '(표현|말했|글|보여주|생각|의견)' then 0.52 else 0.18 end
    end;

    if v_strength > 0.19 or v_len >= 120 then
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
        jsonb_build_object('source', 'diary_keyword', 'bodyLength', v_len),
        jsonb_build_object('source', 'diary_context', 'bodyLength', v_len, 'titlePresent', length(coalesce(trim(p_title), '')) > 0),
        case v_axis
          when 'exploration' then '새로운 가능성을 탐색하려는 흐름이 보입니다.'
          when 'independence' then '스스로 정리하거나 선택하려는 흐름이 보입니다.'
          when 'relationship' then '관계 안에서의 경험을 살펴볼 단서가 보입니다.'
          when 'growth' then '조금 더 나아지고 싶은 방향이 보입니다.'
          when 'emotional_sensitivity' then '마음의 반응을 알아차린 단서가 보입니다.'
          when 'stability' then '안정과 회복을 찾는 흐름이 보입니다.'
          when 'initiative' then '생각을 행동으로 옮기려는 단서가 보입니다.'
          else '나를 표현하려는 흐름이 보입니다.'
        end
      );
    end if;
  end loop;

  perform private.rebuild_u_map_snapshot(p_user_id);
end;
$$;

revoke all on all functions in schema private from anon, authenticated;
