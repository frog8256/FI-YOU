-- P0 residual backend functions: diary revoke, deterministic signals/U-Map,
-- relation answer safety, and server-only purchase ledger draft.

create schema if not exists private;

alter table public.onboarding_answers
  alter column selected_option_id set not null;

alter table public.answers
  alter column selected_option_id set not null;

alter table public.relation_answers
  alter column selected_option_id set not null;

revoke insert, update on public.signals from authenticated;
revoke insert, update on public.u_map_snapshots from authenticated;
drop policy if exists "signals own insert" on public.signals;
drop policy if exists "u map snapshots own insert" on public.u_map_snapshots;

alter policy "relation answers own insert" on public.relation_answers
  with check (
    (select auth.uid()) = user_id
    and exists (
      select 1
      from public.relations r
      where r.id = relation_answers.relation_id
        and r.user_id = (select auth.uid())
        and r.archived_at is null
    )
  );

alter policy "relation answers own update" on public.relation_answers
  using (
    (select auth.uid()) = user_id
    and exists (
      select 1
      from public.relations r
      where r.id = relation_answers.relation_id
        and r.user_id = (select auth.uid())
        and r.archived_at is null
    )
  )
  with check (
    (select auth.uid()) = user_id
    and exists (
      select 1
      from public.relations r
      where r.id = relation_answers.relation_id
        and r.user_id = (select auth.uid())
        and r.archived_at is null
    )
  );

create or replace function private.refresh_u_map_snapshot(p_user_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_snapshot_id uuid;
  v_axis_scores jsonb;
  v_axis_clarity jsonb;
  v_dominant_signals jsonb;
  v_unclear_axes text[];
begin
  with allowed_axes(axis) as (
    values
      ('exploration'),
      ('independence'),
      ('relationship'),
      ('growth'),
      ('emotional_sensitivity'),
      ('stability'),
      ('initiative'),
      ('self_expression')
  ),
  aggregated as (
    select
      s.axis,
      avg(s.strength)::numeric as avg_strength,
      count(*)::integer as signal_count,
      avg(s.confidence)::numeric as avg_confidence
    from public.signals s
    where s.user_id = p_user_id
    group by s.axis
  ),
  scored as (
    select
      a.axis,
      coalesce(round(ag.avg_strength, 3), 0) as score,
      coalesce(round(least(1, (ag.signal_count::numeric / 5.0) + (ag.avg_confidence * 0.2)), 3), 0) as clarity,
      coalesce(ag.signal_count, 0) as signal_count
    from allowed_axes a
    left join aggregated ag on ag.axis = a.axis
  )
  select
    jsonb_object_agg(axis, score),
    jsonb_object_agg(axis, clarity),
    coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'axis', axis,
            'score', score,
            'clarity', clarity,
            'signalCount', signal_count
          )
          order by score desc, clarity desc
        )
        from (
          select *
          from scored
          where signal_count > 0
          order by score desc, clarity desc
          limit 3
        ) top_axes
      ),
      '[]'::jsonb
    ),
    coalesce(array_agg(axis order by axis) filter (where signal_count < 2), '{}'::text[])
  into v_axis_scores, v_axis_clarity, v_dominant_signals, v_unclear_axes
  from scored;

  insert into public.u_map_snapshots (
    user_id,
    axis_scores,
    axis_clarity,
    dominant_signals,
    unclear_axes,
    summary
  )
  values (
    p_user_id,
    coalesce(v_axis_scores, '{}'::jsonb),
    coalesce(v_axis_clarity, '{}'::jsonb),
    coalesce(v_dominant_signals, '[]'::jsonb),
    coalesce(v_unclear_axes, '{}'::text[]),
    'Deterministic MVP snapshot generated from recent answers and diary signals.'
  )
  returning id into v_snapshot_id;

  return v_snapshot_id;
end;
$$;

create or replace function private.emit_question_signals(
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
set search_path = public, pg_temp
as $$
declare
  v_option_question_id uuid;
begin
  if p_source_type not in ('onboarding_answer', 'normal_answer', 'relation_answer') then
    raise exception 'invalid_signal_source_type';
  end if;

  select question_id
    into v_option_question_id
  from public.question_options
  where id = p_selected_option_id;

  if v_option_question_id is distinct from p_question_id then
    raise exception 'selected_option_must_belong_to_question';
  end if;

  delete from public.signals
  where user_id = p_user_id
    and source_type = p_source_type
    and source_id = p_source_id;

  insert into public.signals (
    user_id,
    source_type,
    source_id,
    axis,
    polarity,
    strength,
    confidence,
    clarity_contribution,
    a_model,
    c_model,
    evidence_summary
  )
  select
    p_user_id,
    p_source_type,
    p_source_id,
    axis_value.axis,
    'neutral',
    least(
      1,
      coalesce((qo.axis_weights ->> axis_value.axis)::numeric, 0.25)
      + case when nullif(btrim(coalesce(p_optional_text, '')), '') is null then 0 else 0.10 end
    )::numeric(4,3),
    case when nullif(btrim(coalesce(p_optional_text, '')), '') is null then 0.550 else 0.650 end::numeric(4,3),
    0.100,
    jsonb_build_object(
      'axis', axis_value.axis,
      'sourceType', p_source_type,
      'model', 'A_summary'
    ),
    jsonb_build_object(
      'scene', q.prompt,
      'reaction', qo.label,
      'freeTextPresent', nullif(btrim(coalesce(p_optional_text, '')), '') is not null
    ),
    left(q.prompt || ' / ' || qo.label, 240)
  from public.questions q
  join public.question_options qo on qo.id = p_selected_option_id and qo.question_id = q.id
  cross join lateral unnest(q.axis_keys) as axis_value(axis)
  where q.id = p_question_id
    and axis_value.axis in (
      'exploration',
      'independence',
      'relationship',
      'growth',
      'emotional_sensitivity',
      'stability',
      'initiative',
      'self_expression'
    );

  perform private.refresh_u_map_snapshot(p_user_id);
end;
$$;

create or replace function private.emit_diary_signals(p_diary_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_diary public.diaries;
  v_body text;
  v_length integer;
begin
  select *
    into v_diary
  from public.diaries
  where id = p_diary_id;

  if v_diary.id is null then
    return;
  end if;

  delete from public.signals
  where user_id = v_diary.user_id
    and source_type = 'diary'
    and source_id = p_diary_id;

  if v_diary.deleted_at is not null then
    perform private.refresh_u_map_snapshot(v_diary.user_id);
    return;
  end if;

  v_body := lower(coalesce(v_diary.body, ''));
  v_length := char_length(v_body);

  insert into public.signals (
    user_id,
    source_type,
    source_id,
    axis,
    polarity,
    strength,
    confidence,
    clarity_contribution,
    a_model,
    c_model,
    evidence_summary
  )
  select
    v_diary.user_id,
    'diary',
    p_diary_id,
    signal.axis,
    signal.polarity,
    signal.strength::numeric(4,3),
    signal.confidence::numeric(4,3),
    signal.clarity_contribution,
    jsonb_build_object('axis', signal.axis, 'model', 'A_summary', 'basis', signal.basis),
    jsonb_build_object('scene', 'diary', 'basis', signal.basis, 'length', v_length),
    signal.evidence
  from (
    values
      ('self_expression', 'positive', case when v_length >= 30 then 0.350 else 0.180 end, 0.450, 0.080, 'length', 'Diary text expresses inner state.'),
      ('growth', 'neutral', case when v_length >= 50 then 0.400 else 0.200 end, 0.450, 0.080, 'length', 'Diary entry contributes to growth trace.'),
      ('emotional_sensitivity', 'mixed', case when v_body ~ '(힘들|불안|슬프|화나|외롭|걱정)' then 0.550 else 0 end, 0.500, 0.100, 'emotion_keyword', 'Emotion keyword detected.'),
      ('relationship', 'neutral', case when v_body ~ '(친구|엄마|아빠|가족|연인|그 사람|관계|회사|동료)' then 0.500 else 0 end, 0.500, 0.100, 'relationship_keyword', 'Relationship keyword detected.'),
      ('exploration', 'neutral', case when v_body ~ '(왜|어떻게|궁금|알고 싶|생각해)' then 0.420 else 0 end, 0.450, 0.080, 'exploration_keyword', 'Exploration keyword detected.'),
      ('stability', 'positive', case when v_body ~ '(쉬|회복|잠|정리|안정|괜찮)' then 0.420 else 0 end, 0.450, 0.080, 'stability_keyword', 'Stability keyword detected.')
  ) as signal(axis, polarity, strength, confidence, clarity_contribution, basis, evidence)
  where signal.strength > 0;

  perform private.refresh_u_map_snapshot(v_diary.user_id);
end;
$$;

create or replace function private.handle_onboarding_answer_signal()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform private.emit_question_signals(
    new.user_id,
    'onboarding_answer',
    new.id,
    new.question_id,
    new.selected_option_id,
    new.optional_text
  );
  return new;
end;
$$;

create or replace function private.handle_answer_signal()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if new.skipped then
    return new;
  end if;

  perform private.emit_question_signals(
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

create or replace function private.handle_diary_signal()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform private.emit_diary_signals(new.id);
  return new;
end;
$$;

create or replace function private.validate_relation_answer()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_relation public.relations;
  v_question_set text;
  v_option_question_id uuid;
  v_existing_count integer;
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
      into v_existing_count
    from public.relation_answers
    where relation_id = new.relation_id;

    if v_existing_count >= least(v_relation.max_questions, 20) then
      raise exception 'relation_answer_limit_exceeded';
    end if;
  else
    new.user_id = old.user_id;
    new.relation_id = old.relation_id;
    new.question_id = old.question_id;
  end if;

  return new;
end;
$$;

create or replace function private.handle_relation_answer_signal()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  perform private.emit_question_signals(
    new.user_id,
    'relation_answer',
    new.id,
    new.question_id,
    new.selected_option_id,
    new.optional_text
  );
  return new;
end;
$$;

drop trigger if exists onboarding_answer_signal_after_write on public.onboarding_answers;
create trigger onboarding_answer_signal_after_write
after insert or update of selected_option_id, optional_text on public.onboarding_answers
for each row execute function private.handle_onboarding_answer_signal();

drop trigger if exists answer_signal_after_write on public.answers;
create trigger answer_signal_after_write
after insert or update of selected_option_id, optional_text, skipped on public.answers
for each row execute function private.handle_answer_signal();

drop trigger if exists diary_signal_after_write on public.diaries;
create trigger diary_signal_after_write
after insert or update of body, deleted_at on public.diaries
for each row execute function private.handle_diary_signal();

drop trigger if exists relation_answer_validate_before_write on public.relation_answers;
create trigger relation_answer_validate_before_write
before insert or update on public.relation_answers
for each row execute function private.validate_relation_answer();

drop trigger if exists relation_answer_signal_after_write on public.relation_answers;
create trigger relation_answer_signal_after_write
after insert or update of selected_option_id, optional_text on public.relation_answers
for each row execute function private.handle_relation_answer_signal();

create or replace function public.delete_diary_with_star_revoke(p_diary_id uuid)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_diary public.diaries;
  v_balance integer;
  v_deduct integer;
  v_revoke_key text;
  v_reward_exists boolean;
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

  if v_diary.deleted_at is null then
    update public.diaries
    set deleted_at = now(),
        updated_at = now()
    where id = p_diary_id
      and user_id = v_user;
  end if;

  v_revoke_key := v_user::text || ':diary_delete_revoke:' || p_diary_id::text;

  if exists (select 1 from public.star_ledger where idempotency_key = v_revoke_key) then
    return public.get_star_balance();
  end if;

  select exists (
    select 1
    from public.star_ledger
    where user_id = v_user
      and entry_type = 'earn'
      and reason = 'diary_created'
      and (
        ref_id = p_diary_id
        or idempotency_key = v_user::text || ':diary_reward:' || v_diary.entry_date::text
      )
  ) into v_reward_exists;

  if not v_reward_exists then
    return public.get_star_balance();
  end if;

  select coalesce(sum(amount), 0)::integer
    into v_balance
  from public.star_ledger
  where user_id = v_user;

  v_deduct := least(12, greatest(v_balance, 0));

  if v_deduct > 0 then
    insert into public.star_ledger (
      user_id,
      entry_type,
      reason,
      amount,
      requested_amount,
      ref_type,
      ref_id,
      idempotency_key,
      metadata
    )
    values (
      v_user,
      'revoke',
      'diary_deleted',
      -v_deduct,
      -12,
      'diary',
      p_diary_id,
      v_revoke_key,
      jsonb_build_object('policy', 'deduct up to current balance; never below zero')
    );
  end if;

  return public.get_star_balance();
end;
$$;

create or replace function public.upsert_relation_answer(
  p_relation_id uuid,
  p_question_id uuid,
  p_selected_option_id uuid,
  p_optional_text text default null
)
returns public.relation_answers
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_result public.relation_answers;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  if not exists (
    select 1
    from public.relations r
    where r.id = p_relation_id
      and r.user_id = v_user
      and r.archived_at is null
  ) then
    raise exception 'relation_not_found';
  end if;

  insert into public.relation_answers (
    user_id,
    relation_id,
    question_id,
    selected_option_id,
    optional_text
  )
  values (
    v_user,
    p_relation_id,
    p_question_id,
    p_selected_option_id,
    nullif(btrim(coalesce(p_optional_text, '')), '')
  )
  on conflict (relation_id, question_id)
  do update
    set selected_option_id = excluded.selected_option_id,
        optional_text = excluded.optional_text,
        answered_at = now()
  returning * into v_result;

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
set search_path = public
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

grant execute on function public.delete_diary_with_star_revoke(uuid) to authenticated;
grant execute on function public.upsert_relation_answer(uuid, uuid, uuid, text) to authenticated;

revoke execute on function public.record_star_purchase(uuid, text, integer, integer, jsonb) from public, anon, authenticated;
grant execute on function public.record_star_purchase(uuid, text, integer, integer, jsonb) to service_role;

revoke all on all functions in schema private from anon, authenticated;
