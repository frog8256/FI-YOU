-- FI-YOU P0 backend schema
-- Source of truth for users is auth.users. Public user data lives in profiles.

create extension if not exists "pgcrypto";
create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  nickname text,
  birthday date,
  preferred_language text not null default 'ko',
  onboarding_completed boolean not null default false,
  required_questions_completed_at timestamptz,
  focus_area text,
  focus_selected_at timestamptz,
  first_seen_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  question_set text not null check (question_set in ('onboarding_required', 'basic_free', 'relation_map')),
  sequence integer not null,
  prompt text not null,
  helper_text text,
  axis_keys text[] not null default '{}',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (question_set, sequence)
);
create table if not exists public.question_options (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.questions(id) on delete cascade,
  sequence integer not null,
  label text not null,
  axis_weights jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (question_id, sequence)
);
create table if not exists public.onboarding_answers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  question_id uuid not null references public.questions(id),
  selected_option_id uuid references public.question_options(id),
  optional_text text,
  answered_at timestamptz not null default now(),
  unique (user_id, question_id)
);
create table if not exists public.answers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  question_id uuid not null references public.questions(id),
  selected_option_id uuid references public.question_options(id),
  optional_text text,
  skipped boolean not null default false,
  answered_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, question_id)
);
create table if not exists public.diaries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  entry_date date not null default ((now() at time zone 'Asia/Seoul')::date),
  title text not null,
  body text not null,
  mood_label text,
  ai_emotion_label text,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index if not exists diaries_one_active_per_day
  on public.diaries(user_id, entry_date)
  where deleted_at is null;
create table if not exists public.signals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  source_type text not null check (source_type in ('onboarding_answer', 'normal_answer', 'diary', 'relation_answer', 'free_explore_chat')),
  source_id uuid not null,
  axis text not null check (axis in ('exploration', 'independence', 'relationship', 'growth', 'emotional_sensitivity', 'stability', 'initiative', 'self_expression')),
  polarity text not null default 'neutral' check (polarity in ('positive', 'negative', 'mixed', 'neutral')),
  strength numeric(4,3) not null default 0 check (strength >= 0 and strength <= 1),
  confidence numeric(4,3) not null default 0 check (confidence >= 0 and confidence <= 1),
  clarity_contribution numeric(6,3) not null default 0,
  a_model jsonb not null default '{}'::jsonb,
  c_model jsonb,
  evidence_summary text,
  observed_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
create index if not exists signals_user_axis_observed_idx
  on public.signals(user_id, axis, observed_at desc);
create table if not exists public.u_map_snapshots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  axis_scores jsonb not null default '{}'::jsonb,
  axis_clarity jsonb not null default '{}'::jsonb,
  dominant_signals jsonb not null default '[]'::jsonb,
  unclear_axes text[] not null default '{}',
  summary text,
  created_at timestamptz not null default now()
);
create index if not exists u_map_snapshots_user_created_idx
  on public.u_map_snapshots(user_id, created_at desc);
create table if not exists public.star_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  entry_type text not null check (entry_type in ('earn', 'spend', 'purchase', 'refund', 'revoke', 'adjust')),
  reason text not null,
  amount integer not null,
  requested_amount integer,
  ref_type text,
  ref_id uuid,
  idempotency_key text not null,
  provider_payment_id text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (idempotency_key),
  unique (provider_payment_id)
);
create index if not exists star_ledger_user_created_idx
  on public.star_ledger(user_id, created_at desc);
create table if not exists public.entitlements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  entitlement_type text not null,
  ref_id uuid,
  star_cost integer not null default 0,
  source_ledger_id uuid references public.star_ledger(id),
  unlocked_at timestamptz not null default now(),
  metadata jsonb not null default '{}'::jsonb,
  unique (user_id, entitlement_type, ref_id)
);
create table if not exists public.relations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  relationship_type text not null,
  status text not null default 'draft',
  max_questions integer not null default 20,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz
);
create table if not exists public.relation_answers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  relation_id uuid not null references public.relations(id) on delete cascade,
  question_id uuid not null references public.questions(id),
  selected_option_id uuid references public.question_options(id),
  optional_text text,
  answered_at timestamptz not null default now(),
  unique (relation_id, question_id)
);
alter table public.profiles enable row level security;
alter table public.questions enable row level security;
alter table public.question_options enable row level security;
alter table public.onboarding_answers enable row level security;
alter table public.answers enable row level security;
alter table public.diaries enable row level security;
alter table public.signals enable row level security;
alter table public.u_map_snapshots enable row level security;
alter table public.star_ledger enable row level security;
alter table public.entitlements enable row level security;
alter table public.relations enable row level security;
alter table public.relation_answers enable row level security;
create policy "profiles own select" on public.profiles for select using (auth.uid() = user_id);
create policy "profiles own insert" on public.profiles for insert with check (auth.uid() = user_id);
create policy "profiles own update" on public.profiles for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "questions public read" on public.questions for select using (active = true);
create policy "question options public read" on public.question_options for select using (
  exists (select 1 from public.questions q where q.id = question_id and q.active = true)
);
create policy "onboarding answers own select" on public.onboarding_answers for select using (auth.uid() = user_id);
create policy "onboarding answers own insert" on public.onboarding_answers for insert with check (auth.uid() = user_id);
create policy "onboarding answers own update" on public.onboarding_answers for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "answers own select" on public.answers for select using (auth.uid() = user_id);
create policy "answers own insert" on public.answers for insert with check (auth.uid() = user_id);
create policy "answers own update" on public.answers for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "diaries own select" on public.diaries for select using (auth.uid() = user_id);
create policy "diaries own insert" on public.diaries for insert with check (auth.uid() = user_id);
create policy "diaries own update" on public.diaries for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "signals own select" on public.signals for select using (auth.uid() = user_id);
create policy "signals own insert" on public.signals for insert with check (auth.uid() = user_id);
create policy "u map snapshots own select" on public.u_map_snapshots for select using (auth.uid() = user_id);
create policy "u map snapshots own insert" on public.u_map_snapshots for insert with check (auth.uid() = user_id);
create policy "star ledger own select" on public.star_ledger for select using (auth.uid() = user_id);
create policy "entitlements own select" on public.entitlements for select using (auth.uid() = user_id);
create policy "relations own select" on public.relations for select using (auth.uid() = user_id);
create policy "relations own insert" on public.relations for insert with check (auth.uid() = user_id);
create policy "relations own update" on public.relations for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "relation answers own select" on public.relation_answers for select using (auth.uid() = user_id);
create policy "relation answers own insert" on public.relation_answers for insert with check (auth.uid() = user_id);
create policy "relation answers own update" on public.relation_answers for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
grant usage on schema public to anon, authenticated;
grant select on public.questions, public.question_options to anon, authenticated;
grant select, insert, update on public.profiles, public.onboarding_answers, public.answers, public.diaries, public.signals, public.u_map_snapshots, public.relations, public.relation_answers to authenticated;
grant select on public.star_ledger, public.entitlements to authenticated;
create or replace function public.get_star_balance()
returns integer
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(sum(amount), 0)::integer
  from public.star_ledger
  where user_id = auth.uid();
$$;
create or replace function public.grant_daily_attendance_star(p_local_date date default ((now() at time zone 'Asia/Seoul')::date))
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_key text;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  v_key := v_user::text || ':attendance:' || p_local_date::text;

  insert into public.star_ledger(user_id, entry_type, reason, amount, requested_amount, ref_type, idempotency_key)
  values (v_user, 'earn', 'daily_attendance', 10, 10, 'attendance', v_key)
  on conflict (idempotency_key) do nothing;

  return public.get_star_balance();
end;
$$;
create or replace function public.grant_diary_star_once(p_diary_id uuid)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_entry_date date;
  v_body text;
  v_key text;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  select entry_date, body into v_entry_date, v_body
  from public.diaries
  where id = p_diary_id and user_id = v_user and deleted_at is null;

  if v_entry_date is null then
    raise exception 'diary_not_found';
  end if;

  if char_length(trim(v_body)) < 50 then
    raise exception 'diary_too_short';
  end if;

  v_key := v_user::text || ':diary_reward:' || v_entry_date::text;

  insert into public.star_ledger(user_id, entry_type, reason, amount, requested_amount, ref_type, ref_id, idempotency_key)
  values (v_user, 'earn', 'diary_created', 12, 12, 'diary', p_diary_id, v_key)
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

  v_key := v_user::text || ':spend:' || p_reason || ':' || coalesce(p_ref_id::text, p_ref_type, 'global');

  if exists (select 1 from public.star_ledger where idempotency_key = v_key) then
    return public.get_star_balance();
  end if;

  select public.get_star_balance() into v_balance;
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
  v_ledger_id uuid;
  v_result public.entitlements;
begin
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  select * into v_existing
  from public.entitlements
  where user_id = v_user and entitlement_type = p_entitlement_type and ref_id is not distinct from p_ref_id;

  if v_existing.id is not null then
    return v_existing;
  end if;

  v_reason := case p_entitlement_type
    when 'love_analysis' then 'love_analysis'
    when 'relation_map' then 'relation_map'
    when 'past_compare' then 'past_compare'
    else p_entitlement_type
  end;

  perform public.spend_star(v_reason, p_cost, 'entitlement', p_ref_id);

  select id into v_ledger_id
  from public.star_ledger
  where user_id = v_user and reason = v_reason and ref_id is not distinct from p_ref_id
  order by created_at desc
  limit 1;

  insert into public.entitlements(user_id, entitlement_type, ref_id, star_cost, source_ledger_id)
  values (v_user, p_entitlement_type, p_ref_id, p_cost, v_ledger_id)
  returning * into v_result;

  return v_result;
end;
$$;
grant execute on function public.get_star_balance() to authenticated;
grant execute on function public.grant_daily_attendance_star(date) to authenticated;
grant execute on function public.grant_diary_star_once(uuid) to authenticated;
grant execute on function public.spend_star(text, integer, text, uuid) to authenticated;
grant execute on function public.unlock_entitlement(text, integer, uuid) to authenticated;
insert into public.questions(question_set, sequence, prompt, helper_text, axis_keys)
values
('onboarding_required', 1, '요즘 마음에 오래 남아 있는 장면은 어디에서 온 걸까요?', '정답은 없어요. 지금 가까운 쪽이면 충분해요.', array['emotional_sensitivity','relationship','stability']),
('onboarding_required', 2, '무언가를 결정할 때 가장 먼저 확인하는 것은 무엇인가요?', null, array['independence','stability','initiative']),
('onboarding_required', 3, '혼자 정리하는 시간이 나에게 꽤 필요한 편인가요?', null, array['independence','emotional_sensitivity']),
('onboarding_required', 4, '내 기준이 흔들릴 때 바로 알아차리는 편인가요?', null, array['self_expression','stability']),
('onboarding_required', 5, '앞으로 FI-YOU와 함께 가장 먼저 밝혀보고 싶은 영역은 어디인가요?', '선택한 답을 조금 더 설명해도 좋아요.', array['exploration','growth','relationship'])
on conflict (question_set, sequence) do nothing;
insert into public.questions(question_set, sequence, prompt, helper_text, axis_keys)
select 'basic_free', gs, '오늘의 선택에서 나를 가장 잘 보여주는 기준은 무엇인가요? #' || gs, '선택한 답을 조금 더 설명해도 좋아요.', array['exploration','growth','self_expression']
from generate_series(1, 30) gs
on conflict (question_set, sequence) do nothing;
insert into public.questions(question_set, sequence, prompt, helper_text, axis_keys)
select 'relation_map', gs, '이 관계에서 반복해서 떠오르는 장면은 무엇에 가까운가요? #' || gs, '상대방을 단정하지 않고, 이 관계 안에서 내가 경험한 흐름을 살펴봐요.', array['relationship','emotional_sensitivity','stability']
from generate_series(1, 20) gs
on conflict (question_set, sequence) do nothing;
insert into public.question_options(question_id, sequence, label, axis_weights)
select q.id, opt.sequence, opt.label, opt.axis_weights
from public.questions q
cross join (values
  (1, '혼자 정리하는 쪽에 가까워요', '{"independence": 0.4, "emotional_sensitivity": 0.2}'::jsonb),
  (2, '사람들과 나누며 확인하는 쪽에 가까워요', '{"relationship": 0.4, "self_expression": 0.2}'::jsonb),
  (3, '새로운 시도를 해보는 쪽에 가까워요', '{"exploration": 0.4, "initiative": 0.3}'::jsonb),
  (4, '안정적인 기준을 먼저 보는 쪽에 가까워요', '{"stability": 0.4}'::jsonb),
  (5, '아직은 잘 모르겠어요', '{"exploration": 0.2}'::jsonb)
) as opt(sequence, label, axis_weights)
where not exists (
  select 1 from public.question_options qo where qo.question_id = q.id
);
