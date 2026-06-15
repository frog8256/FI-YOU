-- FI-YOU P0: deterministic signal pipeline, diary reward revoke, relation answer RPC.

create schema if not exists private;

create or replace function private.axis_seed()
returns table(axis text)
language sql
stable
as $$
  values
    ('exploration'),
    ('independence'),
    ('relationship'),
    ('growth'),
    ('emotional_sensitivity'),
    ('stability'),
    ('initiative'),
    ('self_expression')
$$;

create or replace function private.rebuild_u_map_snapshot(p_user_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public, private
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
    array_agg(axis order by clarity asc) filter (where clarity < 35)
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

  select case
    when coalesce(jsonb_array_length(v_dominant), 0) = 0 then
      '아직은 흐릿한 윤곽이에요. 질문과 기록이 쌓이면 현재의 흐름이 조금씩 선명해져요.'
    else
      '현재까지의 기록을 바탕으로, 몇 가지 흐름이 조금씩 보이고 있어요. 이 결과는 고정된 유형이 아니라 지금까지 쌓인 단서의 윤곽이에요.'
  end into v_summary;

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
set search_path = public, private
as $$
declare
  v_axes text[];
  v_weights jsonb;
  v_strength numeric(4,3);
  v_confidence numeric(4,3);
  v_clarity numeric(6,3);
  v_axis text;
  v_weight numeric;
begin
  delete from public.signals
  where user_id = p_user_id
    and source_type = p_source_type
    and source_id = p_source_id;

  select q.axis_keys, coalesce(o.axis_weights, '{}'::jsonb)
  into v_axes, v_weights
  from public.questions q
  left join public.question_options o on o.id = p_selected_option_id
  where q.id = p_question_id;

  v_strength := least(1, 0.35 + case when length(coalesce(trim(p_optional_text), '')) > 0 then 0.18 else 0 end);
  v_confidence := least(1, 0.45 + case when length(coalesce(trim(p_optional_text), '')) > 0 then 0.20 else 0 end);
  v_clarity := 0.8 + least(2.2, length(coalesce(trim(p_optional_text), '')) / 120.0);

  if jsonb_typeof(v_weights) = 'object' and v_weights <> '{}'::jsonb then
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
          jsonb_build_object('source', 'choice', 'question_id', p_question_id, 'option_id', p_selected_option_id),
          case when length(coalesce(trim(p_optional_text), '')) > 0
            then jsonb_build_object('source', 'optional_text', 'text_length', length(trim(p_optional_text)))
            else null
          end,
          '현재까지의 답변에서 작은 단서가 더해졌어요.'
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
          jsonb_build_object('source', 'question_axis', 'question_id', p_question_id),
          case when length(coalesce(trim(p_optional_text), '')) > 0
            then jsonb_build_object('source', 'optional_text', 'text_length', length(trim(p_optional_text)))
            else null
          end,
          '현재까지의 답변에서 작은 단서가 더해졌어요.'
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
set search_path = public, private
as $$
declare
  v_text text := lower(coalesce(p_title, '') || ' ' || coalesce(p_body, ''));
  v_len integer := length(coalesce(trim(p_body), ''));
begin
  delete from public.signals
  where user_id = p_user_id
    and source_type = 'diary'
    and source_id = p_diary_id;

  if v_len = 0 then
    perform private.rebuild_u_map_snapshot(p_user_id);
    return;
  end if;

  insert into public.signals(user_id, source_type, source_id, axis, polarity, strength, confidence, clarity_contribution, a_model, c_model, evidence_summary)
  select
    p_user_id,
    'diary',
    p_diary_id,
    axis,
    'neutral',
    least(1, base_strength + least(0.25, v_len / 600.0)),
    least(1, 0.52 + least(0.25, v_len / 800.0)),
    least(4.5, 1.2 + v_len / 180.0),
    jsonb_build_object('source', 'diary_keyword', 'body_length', v_len),
    jsonb_build_object('title_present', length(coalesce(trim(p_title), '')) > 0),
    evidence
  from (
    values
      ('exploration', case when v_text ~ '(새로운|궁금|탐구|가능성|시도|여행|경험)' then 0.50 else 0.18 end, '새로운 가능성을 살펴보려는 단서가 보여요.'),
      ('independence', case when v_text ~ '(혼자|내 기준|독립|스스로|자유|나만)' then 0.52 else 0.18 end, '스스로 정리하거나 선택하려는 흐름이 보여요.'),
      ('relationship', case when v_text ~ '(관계|친구|가족|연인|상대|대화|사람)' then 0.52 else 0.18 end, '관계 안에서 느낀 흐름이 단서로 남았어요.'),
      ('growth', case when v_text ~ '(성장|배우|나아지|변화|목표|연습)' then 0.52 else 0.18 end, '조금 더 나아지고 싶은 방향이 보여요.'),
      ('emotional_sensitivity', case when v_text ~ '(마음|감정|불안|기쁨|서운|차분|힘들|편안)' then 0.55 else 0.20 end, '마음의 반응을 알아차린 단서가 보여요.'),
      ('stability', case when v_text ~ '(안정|계획|기준|정리|회복|쉬|루틴)' then 0.52 else 0.18 end, '안정과 회복을 찾는 흐름이 보여요.'),
      ('initiative', case when v_text ~ '(시작|실행|해보|움직|결정|도전)' then 0.52 else 0.18 end, '생각을 행동으로 옮기려는 단서가 보여요.'),
      ('self_expression', case when v_text ~ '(표현|말했|글|보여주|내 생각|의견)' then 0.52 else 0.18 end, '나를 표현하려는 흐름이 보여요.')
  ) as seed(axis, base_strength, evidence)
  where base_strength > 0.19 or v_len >= 120;

  perform private.rebuild_u_map_snapshot(p_user_id);
end;
$$;

create or replace function private.answer_signal_trigger()
returns trigger
language plpgsql
security definer
set search_path = public, private
as $$
begin
  perform private.refresh_question_signals(
    new.user_id,
    case when tg_table_name = 'onboarding_answers' then 'onboarding_answer' else 'normal_answer' end,
    new.id,
    new.question_id,
    new.selected_option_id,
    new.optional_text
  );
  return new;
end;
$$;

create or replace function private.diary_signal_trigger()
returns trigger
language plpgsql
security definer
set search_path = public, private
as $$
begin
  if new.deleted_at is null then
    perform private.refresh_diary_signals(new.user_id, new.id, new.body, new.title);
  else
    delete from public.signals
    where user_id = new.user_id
      and source_type = 'diary'
      and source_id = new.id;
    perform private.rebuild_u_map_snapshot(new.user_id);
  end if;
  return new;
end;
$$;

drop trigger if exists onboarding_answers_signal_refresh on public.onboarding_answers;
create trigger onboarding_answers_signal_refresh
after insert or update on public.onboarding_answers
for each row execute function private.answer_signal_trigger();

drop trigger if exists answers_signal_refresh on public.answers;
create trigger answers_signal_refresh
after insert or update on public.answers
for each row execute function private.answer_signal_trigger();

drop trigger if exists diaries_signal_refresh on public.diaries;
create trigger diaries_signal_refresh
after insert or update on public.diaries
for each row execute function private.diary_signal_trigger();

create or replace function public.revoke_diary_star(p_diary_id uuid)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_reward public.star_ledger;
  v_balance integer;
  v_revoke_amount integer;
  v_key text;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  select * into v_reward
  from public.star_ledger
  where user_id = v_user
    and ref_type = 'diary'
    and ref_id = p_diary_id
    and reason = 'diary_created'
    and entry_type = 'earn'
  order by created_at asc
  limit 1;

  if v_reward.id is null then
    return public.get_star_balance();
  end if;

  v_key := v_user::text || ':diary_reward_revoke:' || p_diary_id::text;
  if exists (select 1 from public.star_ledger where idempotency_key = v_key) then
    return public.get_star_balance();
  end if;

  select public.get_star_balance() into v_balance;
  v_revoke_amount := least(greatest(v_balance, 0), abs(v_reward.amount));

  if v_revoke_amount > 0 then
    insert into public.star_ledger(user_id, entry_type, reason, amount, requested_amount, ref_type, ref_id, idempotency_key, metadata)
    values (
      v_user,
      'revoke',
      'diary_deleted',
      -v_revoke_amount,
      -abs(v_reward.amount),
      'diary',
      p_diary_id,
      v_key,
      jsonb_build_object('source_ledger_id', v_reward.id)
    );
  else
    insert into public.star_ledger(user_id, entry_type, reason, amount, requested_amount, ref_type, ref_id, idempotency_key, metadata)
    values (
      v_user,
      'revoke',
      'diary_deleted',
      0,
      -abs(v_reward.amount),
      'diary',
      p_diary_id,
      v_key,
      jsonb_build_object('source_ledger_id', v_reward.id, 'note', 'balance already zero')
    );
  end if;

  return public.get_star_balance();
end;
$$;

create or replace function public.upsert_relation_answer(
  p_relation_id uuid,
  p_question_id uuid,
  p_selected_option_id uuid default null,
  p_optional_text text default null
)
returns public.relation_answers
language plpgsql
security definer
set search_path = public, private
as $$
declare
  v_user uuid := auth.uid();
  v_relation public.relations;
  v_existing public.relation_answers;
  v_count integer;
  v_result public.relation_answers;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  select * into v_relation
  from public.relations
  where id = p_relation_id
    and user_id = v_user
    and archived_at is null;

  if v_relation.id is null then
    raise exception 'relation_not_found';
  end if;

  select * into v_existing
  from public.relation_answers
  where relation_id = p_relation_id
    and question_id = p_question_id;

  if v_existing.id is null then
    select count(*) into v_count
    from public.relation_answers
    where relation_id = p_relation_id;

    if v_count >= v_relation.max_questions then
      raise exception 'relation_answer_limit_reached';
    end if;
  end if;

  insert into public.relation_answers(user_id, relation_id, question_id, selected_option_id, optional_text)
  values (v_user, p_relation_id, p_question_id, p_selected_option_id, p_optional_text)
  on conflict (relation_id, question_id) do update
    set selected_option_id = excluded.selected_option_id,
        optional_text = excluded.optional_text,
        answered_at = now()
  returning * into v_result;

  perform private.refresh_question_signals(
    v_user,
    'relation_answer',
    v_result.id,
    p_question_id,
    p_selected_option_id,
    p_optional_text
  );

  return v_result;
end;
$$;

grant execute on function public.revoke_diary_star(uuid) to authenticated;
grant execute on function public.upsert_relation_answer(uuid, uuid, uuid, text) to authenticated;

revoke execute on function public.revoke_diary_star(uuid) from anon;
revoke execute on function public.upsert_relation_answer(uuid, uuid, uuid, text) from anon;
