-- FI-YOU P0 closeout: align love analysis cost with Product/UI and expose calendar day state.

create or replace function public.unlock_entitlement(
  p_entitlement_type text,
  p_cost integer,
  p_ref_id uuid default null
)
returns public.entitlements
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_existing public.entitlements;
  v_reason text;
  v_expected_cost integer;
  v_ledger_id uuid;
  v_result public.entitlements;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  v_reason := case p_entitlement_type
    when 'love_analysis' then 'love_analysis'
    when 'relation_map' then 'relation_map'
    when 'past_compare' then 'past_compare'
    when 'free_explore' then 'free_explore'
    else null
  end;

  v_expected_cost := case p_entitlement_type
    when 'love_analysis' then 50
    when 'relation_map' then 1
    when 'past_compare' then 30
    when 'free_explore' then 30
    else null
  end;

  if v_reason is null or v_expected_cost is null then
    raise exception 'invalid_entitlement_type';
  end if;

  if p_cost <> v_expected_cost then
    raise exception 'invalid_entitlement_cost';
  end if;

  perform pg_advisory_xact_lock(hashtext(v_user::text));

  select * into v_existing
  from public.entitlements
  where user_id = v_user
    and entitlement_type = p_entitlement_type
    and ref_id is not distinct from p_ref_id;

  if v_existing.id is not null then
    return v_existing;
  end if;

  perform public.spend_star(v_reason, v_expected_cost, 'entitlement', p_ref_id);

  select id into v_ledger_id
  from public.star_ledger
  where user_id = v_user
    and reason = v_reason
    and ref_id is not distinct from p_ref_id
  order by created_at desc
  limit 1;

  insert into public.entitlements(user_id, entitlement_type, ref_id, star_cost, source_ledger_id)
  values (v_user, p_entitlement_type, p_ref_id, v_expected_cost, v_ledger_id)
  returning * into v_result;

  return v_result;
end;
$$;

comment on function public.unlock_entitlement(text, integer, uuid)
  is 'Unlock Star-gated features. love_analysis cost is 50 Star per Product/UI policy.';

create or replace function public.get_calendar_day_states(
  p_month date default ((now() at time zone 'Asia/Seoul')::date)
)
returns table (
  day_date date,
  attended boolean,
  diary_written boolean,
  star_earned integer,
  diary_id uuid
)
language sql
stable
security invoker
set search_path = public
as $$
  with bounds as (
    select
      date_trunc('month', coalesce(p_month, (now() at time zone 'Asia/Seoul')::date))::date as start_date,
      (date_trunc('month', coalesce(p_month, (now() at time zone 'Asia/Seoul')::date)) + interval '1 month - 1 day')::date as end_date
  ),
  days as (
    select generate_series(start_date, end_date, interval '1 day')::date as day_date
    from bounds
  ),
  diary_by_day as (
    select distinct on (entry_date)
      entry_date,
      id
    from public.diaries
    where user_id = auth.uid()
      and deleted_at is null
      and entry_date between (select start_date from bounds) and (select end_date from bounds)
    order by entry_date, created_at desc
  ),
  ledger_by_day as (
    select
      (created_at at time zone 'Asia/Seoul')::date as ledger_date,
      bool_or(reason = 'daily_attendance' and amount > 0) as attended,
      coalesce(sum(amount) filter (
        where reason in ('daily_attendance', 'diary_created', 'diary_deleted')
      ), 0)::integer as star_earned
    from public.star_ledger
    where user_id = auth.uid()
      and (created_at at time zone 'Asia/Seoul')::date between (select start_date from bounds) and (select end_date from bounds)
    group by 1
  )
  select
    d.day_date,
    coalesce(l.attended, false) as attended,
    dbd.id is not null as diary_written,
    coalesce(l.star_earned, 0) as star_earned,
    dbd.id as diary_id
  from days d
  left join diary_by_day dbd on dbd.entry_date = d.day_date
  left join ledger_by_day l on l.ledger_date = d.day_date
  order by d.day_date;
$$;

revoke execute on function public.get_calendar_day_states(date) from public, anon;
grant execute on function public.get_calendar_day_states(date) to authenticated;

comment on function public.get_calendar_day_states(date)
  is 'Returns per-day attendance, diary presence, Star reward sum, and diary id for the authenticated user calendar.';
