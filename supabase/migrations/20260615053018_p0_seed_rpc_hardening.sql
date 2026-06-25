-- P0 seed text and Star RPC hardening.

create schema if not exists private;

update public.questions
set prompt = case sequence
  when 1 then '요즘 마음에 오래 남아 있는 장면은 어디에서 온 걸까요?'
  when 2 then '무언가를 결정할 때 가장 먼저 확인하는 것은 무엇인가요?'
  when 3 then '혼자 정리하는 시간은 나에게 어떤 의미인가요?'
  when 4 then '내 기분이 흔들릴 때 가장 먼저 알아차리는 것은 무엇인가요?'
  when 5 then '지금 FI-YOU와 함께 가장 먼저 바라보고 싶은 영역은 어디인가요?'
end,
helper_text = case sequence
  when 1 then '정답은 없어요. 지금 가까운 쪽이면 충분해요.'
  when 5 then '선택한 뒤 조금 더 설명해도 좋아요.'
  else helper_text
end
where question_set = 'onboarding_required'
  and sequence between 1 and 5;

update public.questions
set prompt = case sequence
  when 1 then '계획이 바뀌면 나는 보통 어떻게 하나요?'
  when 2 then '칭찬을 받으면 먼저 드는 생각은 무엇인가요?'
  when 3 then '혼자 있는 시간은 나에게 어떤 의미인가요?'
  when 4 then '관계에서 서운함이 생기면 나는 어떻게 하나요?'
  when 5 then '새로운 도전을 앞두면 어떤 감각이 큰가요?'
  when 6 then '반복되는 문제를 마주하면 나는 무엇을 확인하나요?'
  when 7 then '내가 편안함을 느끼는 환경은 어디에 가깝나요?'
  when 8 then '아이디어가 떠오르면 보통 어떻게 다루나요?'
  when 9 then '타인의 감정 변화에 나는 얼마나 민감한 편인가요?'
  when 10 then '일이 많아질 때 나는 무엇부터 정리하나요?'
  when 11 then '내가 쉽게 몰입하는 순간은 언제인가요?'
  when 12 then '부탁을 거절해야 할 때 나는 어떤 편인가요?'
  when 13 then '관계가 가까워질수록 내가 중요하게 보는 것은 무엇인가요?'
  when 14 then '실패를 겪은 뒤 나는 주로 무엇을 하나요?'
  when 15 then '나에게 좋은 피드백은 어떤 형태인가요?'
  when 16 then '감정이 커졌을 때 나는 보통 어떻게 하나요?'
  when 17 then '새로운 사람을 만날 때 나는 어떤 편인가요?'
  when 18 then '내가 자주 미루는 일은 어떤 성격인가요?'
  when 19 then '나를 움직이게 하는 말은 무엇에 가깝나요?'
  when 20 then '안정과 변화 중 지금 더 필요한 것은 무엇인가요?'
  when 21 then '내 생각을 표현할 때 가장 어려운 지점은 무엇인가요?'
  when 22 then '문제가 반복된다고 느낄 때 나는 무엇을 떠올리나요?'
  when 23 then '관계에서 신뢰가 쌓였다고 느끼는 순간은 언제인가요?'
  when 24 then '내가 잘 회복하는 방식은 무엇인가요?'
  when 25 then '하고 싶은 일이 많을 때 나는 무엇을 기준으로 고르나요?'
  when 26 then '나에게 성장은 어떤 느낌에 가깝나요?'
  when 27 then '다른 사람과 속도가 다를 때 나는 어떻게 하나요?'
  when 28 then '내가 반복해서 끌리는 장면은 어떤 것인가요?'
  when 29 then '내 마음을 더 잘 이해하려면 무엇이 필요할까요?'
  when 30 then '지금의 나에게 가장 필요한 다음 행동은 무엇인가요?'
end,
helper_text = '선택 후 필요하면 짧게 덧붙일 수 있어요.'
where question_set = 'basic_free'
  and sequence between 1 and 30;

update public.questions
set prompt = case sequence
  when 1 then '그 사람과 함께 있을 때 나는 주로 어떤 상태인가요?'
  when 2 then '그 사람에게 기대하는 것은 무엇에 가깝나요?'
  when 3 then '관계에서 가장 자주 반복되는 장면은 무엇인가요?'
  when 4 then '서운함이 생겼을 때 나는 어떻게 반응하나요?'
  when 5 then '그 사람과의 관계에서 지키고 싶은 경계는 무엇인가요?'
  when 6 then '대화가 어긋날 때 주로 생기는 일은 무엇인가요?'
  when 7 then '그 사람에게 내 마음을 표현하는 방식은 어떤가요?'
  when 8 then '관계가 좋아졌다고 느끼는 순간은 언제인가요?'
  when 9 then '그 사람과 거리감이 생기는 이유는 무엇에 가깝나요?'
  when 10 then '내가 이 관계에서 자주 참는 것은 무엇인가요?'
  when 11 then '그 사람의 반응 중 크게 남는 것은 무엇인가요?'
  when 12 then '관계에서 내가 먼저 바꾸고 싶은 것은 무엇인가요?'
  when 13 then '그 사람과의 관계가 나에게 주는 힘은 무엇인가요?'
  when 14 then '내가 이 관계에서 피하고 싶은 상황은 무엇인가요?'
  when 15 then '관계가 안정적이라고 느끼려면 무엇이 필요한가요?'
  when 16 then '그 사람에게 말하지 못한 생각은 어떤 성격인가요?'
  when 17 then '내가 관계 속에서 더 자주 하는 행동은 무엇인가요?'
  when 18 then '그 사람과의 관계에서 나는 얼마나 독립적인가요?'
  when 19 then '관계가 깊어질수록 내가 중요하게 보는 것은 무엇인가요?'
  when 20 then '이 관계의 다음 흐름에서 필요한 것은 무엇인가요?'
end,
helper_text = '상대방을 단정하지 않고, 내 경험의 흐름을 기준으로 답해요.'
where question_set = 'relation_map'
  and sequence between 1 and 20;

update public.question_options
set label = case sequence
  when 1 then '혼자 정리하는 쪽에 가깝다'
  when 2 then '사람들과 나누며 확인하는 쪽에 가깝다'
  when 3 then '새롭게 시도해보는 쪽에 가깝다'
  when 4 then '안정적인 기준을 먼저 보는 쪽에 가깝다'
  when 5 then '아직은 잘 모르겠다'
  else label
end;

alter policy "profiles own select" on public.profiles using ((select auth.uid()) = user_id);
alter policy "profiles own insert" on public.profiles with check ((select auth.uid()) = user_id);
alter policy "profiles own update" on public.profiles using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
alter policy "onboarding answers own select" on public.onboarding_answers using ((select auth.uid()) = user_id);
alter policy "onboarding answers own insert" on public.onboarding_answers with check ((select auth.uid()) = user_id);
alter policy "onboarding answers own update" on public.onboarding_answers using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
alter policy "answers own select" on public.answers using ((select auth.uid()) = user_id);
alter policy "answers own insert" on public.answers with check ((select auth.uid()) = user_id);
alter policy "answers own update" on public.answers using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
alter policy "diaries own select" on public.diaries using ((select auth.uid()) = user_id);
alter policy "diaries own insert" on public.diaries with check ((select auth.uid()) = user_id);
alter policy "diaries own update" on public.diaries using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
alter policy "signals own select" on public.signals using ((select auth.uid()) = user_id);
alter policy "signals own insert" on public.signals with check ((select auth.uid()) = user_id);
alter policy "u map snapshots own select" on public.u_map_snapshots using ((select auth.uid()) = user_id);
alter policy "u map snapshots own insert" on public.u_map_snapshots with check ((select auth.uid()) = user_id);
alter policy "star ledger own select" on public.star_ledger using ((select auth.uid()) = user_id);
alter policy "entitlements own select" on public.entitlements using ((select auth.uid()) = user_id);
alter policy "relations own select" on public.relations using ((select auth.uid()) = user_id);
alter policy "relations own insert" on public.relations with check ((select auth.uid()) = user_id);
alter policy "relations own update" on public.relations using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
alter policy "relation answers own select" on public.relation_answers using ((select auth.uid()) = user_id);
alter policy "relation answers own insert" on public.relation_answers with check ((select auth.uid()) = user_id);
alter policy "relation answers own update" on public.relation_answers using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

create or replace function public.get_star_balance()
returns integer
language sql
stable
security invoker
set search_path = public
as $$
  select coalesce(sum(amount), 0)::integer
  from public.star_ledger
  where user_id = (select auth.uid());
$$;

create or replace function public.grant_daily_attendance_star(p_local_date date default null)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_local_date date := ((now() at time zone 'Asia/Seoul')::date);
  v_key text;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  perform pg_advisory_xact_lock(hashtext(v_user::text));

  v_key := v_user::text || ':attendance:' || v_local_date::text;

  insert into public.star_ledger(user_id, entry_type, reason, amount, requested_amount, ref_type, idempotency_key)
  values (v_user, 'earn', 'daily_attendance', 10, 10, 'attendance', v_key)
  on conflict (idempotency_key) do nothing;

  return public.get_star_balance();
end;
$$;

create or replace function public.spend_star(p_reason text, p_amount integer, p_ref_type text default null, p_ref_id uuid default null)
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

  if p_reason not in ('free_explore', 'love_analysis', 'relation_map', 'past_compare') then
    raise exception 'invalid_spend_reason';
  end if;

  perform pg_advisory_xact_lock(hashtext(v_user::text));

  v_key := v_user::text || ':spend:' || p_reason || ':' || coalesce(p_ref_id::text, p_ref_type, 'global');

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

  insert into public.star_ledger(user_id, entry_type, reason, amount, requested_amount, ref_type, ref_id, idempotency_key)
  values (v_user, 'spend', p_reason, -p_amount, -p_amount, p_ref_type, p_ref_id, v_key);

  return public.get_star_balance();
end;
$$;

create or replace function public.unlock_entitlement(p_entitlement_type text, p_cost integer, p_ref_id uuid default null)
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
    when 'love_analysis' then 30
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

create or replace function private.prevent_star_ledger_changes()
returns trigger
language plpgsql
as $$
begin
  raise exception 'star_ledger is append-only';
end;
$$;

drop trigger if exists star_ledger_prevent_update on public.star_ledger;
drop trigger if exists star_ledger_prevent_delete on public.star_ledger;

create trigger star_ledger_prevent_update
before update on public.star_ledger
for each row execute function private.prevent_star_ledger_changes();

create trigger star_ledger_prevent_delete
before delete on public.star_ledger
for each row execute function private.prevent_star_ledger_changes();

revoke execute on function public.get_star_balance() from public, anon;
revoke execute on function public.grant_daily_attendance_star(date) from public, anon;
revoke execute on function public.spend_star(text, integer, text, uuid) from public, anon;
revoke execute on function public.unlock_entitlement(text, integer, uuid) from public, anon;
grant execute on function public.get_star_balance() to authenticated;
grant execute on function public.grant_daily_attendance_star(date) to authenticated;
grant execute on function public.spend_star(text, integer, text, uuid) to authenticated;
grant execute on function public.unlock_entitlement(text, integer, uuid) to authenticated;
