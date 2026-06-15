-- FI-YOU P0 final hardening for residual backend blockers.

create schema if not exists private;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'star_ledger_amount_nonzero'
      and conrelid = 'public.star_ledger'::regclass
  ) then
    alter table public.star_ledger
      add constraint star_ledger_amount_nonzero check (amount <> 0);
  end if;
end;
$$;

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
      '현재까지의 답변과 기록을 바탕으로 만든 초기 U-Map입니다. 이 결과는 고정 유형이 아니라 지금까지의 경향입니다.'
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
          '선택한 답변에서 U-Map 단서가 생성되었습니다.'
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
          '질문 축 기반으로 U-Map 단서가 생성되었습니다.'
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
    jsonb_build_object('source', 'diary_keyword', 'bodyLength', v_len),
    jsonb_build_object('titlePresent', length(coalesce(trim(p_title), '')) > 0),
    evidence
  from (
    values
      ('exploration', case when v_text ~ '(새로|궁금|탐구|가능성|시도|여행|경험)' then 0.50 else 0.18 end, '새로운 가능성을 살펴보려는 단서가 보입니다.'),
      ('independence', case when v_text ~ '(혼자|내 기준|독립|스스로|자유|나만)' then 0.52 else 0.18 end, '스스로 정리하거나 선택하려는 흐름이 보입니다.'),
      ('relationship', case when v_text ~ '(관계|친구|가족|연인|상대|그 사람|동료)' then 0.52 else 0.18 end, '관계 안에서의 경험이 단서로 잡혔습니다.'),
      ('growth', case when v_text ~ '(성장|배우|나아지|변화|목표|연습)' then 0.52 else 0.18 end, '조금 더 나아지고 싶은 방향이 보입니다.'),
      ('emotional_sensitivity', case when v_text ~ '(마음|감정|불안|기쁜|슬픈|차분|힘들|편안)' then 0.55 else 0.20 end, '마음의 반응을 알아차린 단서가 보입니다.'),
      ('stability', case when v_text ~ '(안정|계획|기준|정리|회복|루틴)' then 0.52 else 0.18 end, '안정과 회복을 찾는 흐름이 보입니다.'),
      ('initiative', case when v_text ~ '(시작|실행|해보|움직|결정|도전)' then 0.52 else 0.18 end, '생각을 행동으로 옮기려는 단서가 보입니다.'),
      ('self_expression', case when v_text ~ '(표현|말했|글|보여주|생각|의견)' then 0.52 else 0.18 end, '나를 표현하려는 흐름이 보입니다.')
  ) as seed(axis, base_strength, evidence)
  where base_strength > 0.19 or v_len >= 120;

  perform private.rebuild_u_map_snapshot(p_user_id);
end;
$$;

create or replace function private.validate_relation_answer()
returns trigger
language plpgsql
security definer
set search_path = public, private, pg_temp
as $$
declare
  v_relation public.relations;
  v_question_set text;
  v_option_question_id uuid;
  v_count integer;
begin
  select *
    into v_relation
  from public.relations
  where id = new.relation_id;

  if v_relation.id is null then
    raise exception 'relation_not_found';
  end if;

  if v_relation.user_id is distinct from new.user_id then
    raise exception 'relation_answer_user_mismatch';
  end if;

  if v_relation.archived_at is not null then
    raise exception 'relation_archived';
  end if;

  select question_set
    into v_question_set
  from public.questions
  where id = new.question_id
    and active = true;

  if v_question_set is distinct from 'relation_map' then
    raise exception 'relation_answer_question_must_be_relation_map';
  end if;

  select question_id
    into v_option_question_id
  from public.question_options
  where id = new.selected_option_id;

  if v_option_question_id is distinct from new.question_id then
    raise exception 'selected_option_must_belong_to_question';
  end if;

  if tg_op = 'INSERT' then
    select count(*)
      into v_count
    from public.relation_answers
    where relation_id = new.relation_id;

    if v_count >= least(v_relation.max_questions, 20) then
      raise exception 'relation_answer_limit_reached';
    end if;
  else
    new.user_id := old.user_id;
    new.relation_id := old.relation_id;
    new.question_id := old.question_id;
  end if;

  return new;
end;
$$;

drop trigger if exists relation_answers_validate_before_write on public.relation_answers;
create trigger relation_answers_validate_before_write
before insert or update on public.relation_answers
for each row execute function private.validate_relation_answer();

create or replace function public.delete_diary_with_star_revoke(p_diary_id uuid)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_diary public.diaries;
  v_reward public.star_ledger;
  v_balance integer;
  v_revoke_amount integer;
  v_key text;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  perform pg_advisory_xact_lock(hashtext(v_user::text));

  select *
    into v_diary
  from public.diaries
  where id = p_diary_id
    and user_id = v_user;

  if v_diary.id is null then
    raise exception 'diary_not_found';
  end if;

  update public.diaries
  set deleted_at = coalesce(deleted_at, now()),
      updated_at = now()
  where id = p_diary_id
    and user_id = v_user;

  select *
    into v_reward
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

  select coalesce(sum(amount), 0)::integer
    into v_balance
  from public.star_ledger
  where user_id = v_user;

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
      jsonb_build_object('sourceLedgerId', v_reward.id, 'policy', 'deduct up to current balance')
    );
  end if;

  return public.get_star_balance();
end;
$$;

create or replace function public.revoke_diary_star(p_diary_id uuid)
returns integer
language plpgsql
security definer
set search_path = public
as $$
begin
  return public.delete_diary_with_star_revoke(p_diary_id);
end;
$$;

drop function if exists public.upsert_relation_answer(uuid, uuid, uuid, text);

create function public.upsert_relation_answer(
  p_relation_id uuid,
  p_question_id uuid,
  p_selected_option_id uuid,
  p_optional_text text default null
)
returns public.relation_answers
language plpgsql
security definer
set search_path = public, private, pg_temp
as $$
declare
  v_user uuid := auth.uid();
  v_relation public.relations;
  v_question_set text;
  v_option_question_id uuid;
  v_existing public.relation_answers;
  v_count integer;
  v_result public.relation_answers;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  if p_selected_option_id is null then
    raise exception 'selected_option_required';
  end if;

  select *
    into v_relation
  from public.relations
  where id = p_relation_id
    and user_id = v_user
    and archived_at is null;

  if v_relation.id is null then
    raise exception 'relation_not_found';
  end if;

  select question_set
    into v_question_set
  from public.questions
  where id = p_question_id
    and active = true;

  if v_question_set is distinct from 'relation_map' then
    raise exception 'relation_answer_question_must_be_relation_map';
  end if;

  select question_id
    into v_option_question_id
  from public.question_options
  where id = p_selected_option_id;

  if v_option_question_id is distinct from p_question_id then
    raise exception 'selected_option_must_belong_to_question';
  end if;

  select *
    into v_existing
  from public.relation_answers
  where relation_id = p_relation_id
    and question_id = p_question_id;

  if v_existing.id is null then
    select count(*)
      into v_count
    from public.relation_answers
    where relation_id = p_relation_id;

    if v_count >= least(v_relation.max_questions, 20) then
      raise exception 'relation_answer_limit_reached';
    end if;
  end if;

  insert into public.relation_answers(user_id, relation_id, question_id, selected_option_id, optional_text)
  values (v_user, p_relation_id, p_question_id, p_selected_option_id, nullif(btrim(coalesce(p_optional_text, '')), ''))
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

create or replace function public.record_star_purchase(
  p_user_id uuid,
  p_provider_payment_id text,
  p_star_amount integer,
  p_amount_krw integer default null,
  p_metadata jsonb default '{}'::jsonb
)
returns public.star_ledger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_result public.star_ledger;
  v_key text;
begin
  if p_user_id is null then
    raise exception 'user_required';
  end if;

  if nullif(btrim(coalesce(p_provider_payment_id, '')), '') is null then
    raise exception 'provider_payment_id_required';
  end if;

  if p_star_amount <= 0 then
    raise exception 'star_amount_must_be_positive';
  end if;

  v_key := 'purchase:' || p_provider_payment_id;

  insert into public.star_ledger (
    user_id,
    entry_type,
    reason,
    amount,
    requested_amount,
    ref_type,
    idempotency_key,
    provider_payment_id,
    metadata
  )
  values (
    p_user_id,
    'purchase',
    'star_purchase',
    p_star_amount,
    p_star_amount,
    'purchase',
    v_key,
    p_provider_payment_id,
    coalesce(p_metadata, '{}'::jsonb) || jsonb_build_object('amountKrw', p_amount_krw)
  )
  on conflict (provider_payment_id) do update
    set provider_payment_id = excluded.provider_payment_id
  returning * into v_result;

  return v_result;
end;
$$;

revoke execute on function public.record_star_purchase(uuid, text, integer, integer, jsonb) from public, anon, authenticated;
grant execute on function public.record_star_purchase(uuid, text, integer, integer, jsonb) to service_role;

grant execute on function public.delete_diary_with_star_revoke(uuid) to authenticated;
grant execute on function public.revoke_diary_star(uuid) to authenticated;
grant execute on function public.upsert_relation_answer(uuid, uuid, uuid, text) to authenticated;
revoke execute on function public.delete_diary_with_star_revoke(uuid) from anon;
revoke execute on function public.revoke_diary_star(uuid) from anon;
revoke execute on function public.upsert_relation_answer(uuid, uuid, uuid, text) from anon;

revoke all on all functions in schema private from anon, authenticated;
