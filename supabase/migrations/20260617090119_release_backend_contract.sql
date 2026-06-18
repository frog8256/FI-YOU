begin;

create extension if not exists pgcrypto;

create schema if not exists private;

alter table public.users
  add column if not exists onboarding_completed_at timestamptz,
  add column if not exists deletion_requested_at timestamptz;

alter table public.reports
  add column if not exists is_paid boolean not null default false,
  add column if not exists price_stars integer not null default 0 check (price_stars >= 0),
  add column if not exists product_code text;

alter table public.signatures
  add column if not exists is_current boolean not null default true;

create table if not exists public.onboarding_answers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  step_code text not null,
  answer_value jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint onboarding_answers_user_step_unique unique (user_id, step_code)
);

create table if not exists public.u_map_snapshots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  snapshot_type text not null default 'current',
  payload jsonb not null default '{}'::jsonb,
  source_report_id uuid references public.reports(id) on delete set null,
  calculated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table if not exists public.star_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  amount integer not null check (amount <> 0),
  entry_type text not null check (entry_type in ('grant', 'spend', 'revoke', 'refund', 'adjustment')),
  reason text not null,
  source_provider text not null default 'system'
    check (source_provider in ('system', 'admin', 'google_play', 'paddle', 'apple_storekit')),
  source_event_id text,
  reference_type text,
  reference_id uuid,
  idempotency_key text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create unique index if not exists star_ledger_user_idempotency_unique
  on public.star_ledger (user_id, idempotency_key)
  where idempotency_key is not null;

create unique index if not exists star_ledger_provider_event_unique
  on public.star_ledger (source_provider, source_event_id, user_id)
  where source_event_id is not null;

create table if not exists public.entitlements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  entitlement_type text not null check (entitlement_type in ('paid_report', 'subscription', 'feature', 'star_pack')),
  resource_type text,
  resource_id uuid,
  product_code text,
  status text not null default 'active'
    check (status in ('active', 'revoked', 'refunded', 'cancelled', 'expired', 'pending')),
  source_provider text not null check (source_provider in ('system', 'admin', 'google_play', 'paddle', 'apple_storekit')),
  source_event_id text,
  valid_from timestamptz not null default now(),
  valid_until timestamptz,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.report_bodies (
  report_id uuid primary key references public.reports(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists entitlements_provider_event_unique
  on public.entitlements (source_provider, source_event_id)
  where source_event_id is not null;

create unique index if not exists entitlements_unique_active_resource
  on public.entitlements (user_id, entitlement_type, resource_type, resource_id)
  where status = 'active' and resource_id is not null;

create table if not exists public.payment_events (
  id uuid primary key default gen_random_uuid(),
  provider text not null check (provider in ('google_play', 'paddle', 'apple_storekit')),
  event_id text not null,
  user_id uuid references public.users(id) on delete set null,
  product_code text,
  provider_transaction_id text,
  purchase_token_hash text,
  status text not null default 'received'
    check (status in ('received', 'verified', 'rejected', 'refunded', 'cancelled', 'expired', 'disputed', 'failed')),
  amount_stars integer not null default 0 check (amount_stars >= 0),
  entitlement_type text,
  resource_type text,
  resource_id uuid,
  raw_event jsonb not null default '{}'::jsonb,
  processed_at timestamptz,
  created_at timestamptz not null default now(),
  constraint payment_events_provider_event_unique unique (provider, event_id)
);

create table if not exists public.relations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  label text not null,
  note text,
  status text not null default 'draft' check (status in ('draft', 'active', 'archived', 'deleted')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.relation_answers (
  id uuid primary key default gen_random_uuid(),
  relation_id uuid references public.relations(id) on delete cascade,
  relationship_id uuid references public.relationships(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  question_id uuid references public.questions(id) on delete set null,
  prompt_code text,
  answer_text text,
  answer_value jsonb,
  visibility text not null default 'own_only' check (visibility in ('own_only', 'shared')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint relation_answers_has_content check (
    nullif(btrim(coalesce(answer_text, '')), '') is not null
    or answer_value is not null
  ),
  constraint relation_answers_has_parent check (
    relation_id is not null or relationship_id is not null
  )
);

create table if not exists public.account_deletion_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  status text not null default 'requested'
    check (status in ('requested', 'processing', 'completed', 'failed', 'cancelled')),
  reason text,
  requested_at timestamptz not null default now(),
  processed_at timestamptz,
  metadata jsonb not null default '{}'::jsonb
);

create index if not exists onboarding_answers_user_idx on public.onboarding_answers (user_id);
create index if not exists u_map_snapshots_user_created_idx on public.u_map_snapshots (user_id, created_at desc);
create index if not exists star_ledger_user_created_idx on public.star_ledger (user_id, created_at desc);
create index if not exists entitlements_user_status_idx on public.entitlements (user_id, status);
create index if not exists report_bodies_user_idx on public.report_bodies (user_id);
create index if not exists payment_events_user_created_idx on public.payment_events (user_id, created_at desc);
create index if not exists relations_user_status_idx on public.relations (user_id, status, updated_at desc);
create index if not exists relation_answers_relation_idx on public.relation_answers (relation_id);
create index if not exists relation_answers_relationship_idx on public.relation_answers (relationship_id);
create index if not exists account_deletion_requests_user_idx on public.account_deletion_requests (user_id, requested_at desc);
create index if not exists signatures_current_idx on public.signatures (user_id, signature_type, is_current, created_at desc);
create index if not exists reports_paid_access_idx on public.reports (user_id, is_paid, status);

drop trigger if exists set_onboarding_answers_updated_at on public.onboarding_answers;
create trigger set_onboarding_answers_updated_at
before update on public.onboarding_answers
for each row execute function private.set_updated_at();

drop trigger if exists set_entitlements_updated_at on public.entitlements;
create trigger set_entitlements_updated_at
before update on public.entitlements
for each row execute function private.set_updated_at();

drop trigger if exists set_report_bodies_updated_at on public.report_bodies;
create trigger set_report_bodies_updated_at
before update on public.report_bodies
for each row execute function private.set_updated_at();

drop trigger if exists set_relations_updated_at on public.relations;
create trigger set_relations_updated_at
before update on public.relations
for each row execute function private.set_updated_at();

drop trigger if exists set_relation_answers_updated_at on public.relation_answers;
create trigger set_relation_answers_updated_at
before update on public.relation_answers
for each row execute function private.set_updated_at();

alter table public.onboarding_answers enable row level security;
alter table public.u_map_snapshots enable row level security;
alter table public.star_ledger enable row level security;
alter table public.entitlements enable row level security;
alter table public.report_bodies enable row level security;
alter table public.payment_events enable row level security;
alter table public.relations enable row level security;
alter table public.relation_answers enable row level security;
alter table public.account_deletion_requests enable row level security;

drop policy if exists "onboarding_answers_select_own" on public.onboarding_answers;
create policy "onboarding_answers_select_own"
  on public.onboarding_answers for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "onboarding_answers_insert_own" on public.onboarding_answers;
create policy "onboarding_answers_insert_own"
  on public.onboarding_answers for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "onboarding_answers_update_own" on public.onboarding_answers;
create policy "onboarding_answers_update_own"
  on public.onboarding_answers for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "u_map_snapshots_select_own" on public.u_map_snapshots;
create policy "u_map_snapshots_select_own"
  on public.u_map_snapshots for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "star_ledger_select_own" on public.star_ledger;
create policy "star_ledger_select_own"
  on public.star_ledger for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "entitlements_select_own" on public.entitlements;
create policy "entitlements_select_own"
  on public.entitlements for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "report_bodies_select_allowed" on public.report_bodies;
create policy "report_bodies_select_allowed"
  on public.report_bodies for select
  to authenticated
  using (
    (select auth.uid()) = user_id
    and exists (
      select 1
      from public.reports r
      where r.id = report_id
        and r.user_id = (select auth.uid())
        and (
          r.is_paid = false
          or exists (
            select 1
            from public.entitlements e
            where e.user_id = (select auth.uid())
              and e.entitlement_type = 'paid_report'
              and e.resource_type = 'report'
              and e.resource_id = r.id
              and e.status = 'active'
              and (e.valid_until is null or e.valid_until > now())
          )
        )
    )
  );

drop policy if exists "relations_select_own" on public.relations;
create policy "relations_select_own"
  on public.relations for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "relations_insert_own" on public.relations;
create policy "relations_insert_own"
  on public.relations for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "relations_update_own" on public.relations;
create policy "relations_update_own"
  on public.relations for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "relations_delete_own" on public.relations;
create policy "relations_delete_own"
  on public.relations for delete
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "relation_answers_select_allowed" on public.relation_answers;
create policy "relation_answers_select_allowed"
  on public.relation_answers for select
  to authenticated
  using (
    (select auth.uid()) = user_id
    or (
      visibility = 'shared'
      and (
        exists (
          select 1
          from public.relations rel
          where rel.id = relation_id
            and rel.user_id = (select auth.uid())
        )
        or exists (
          select 1
          from public.relationships r
          where r.id = relationship_id
            and (select auth.uid()) in (r.requester_id, r.addressee_id)
        )
      )
    )
  );

drop policy if exists "relation_answers_insert_own_involved" on public.relation_answers;
create policy "relation_answers_insert_own_involved"
  on public.relation_answers for insert
  to authenticated
  with check (
    (select auth.uid()) = user_id
    and (
      exists (
        select 1
        from public.relations rel
        where rel.id = relation_id
          and rel.user_id = (select auth.uid())
      )
      or exists (
        select 1
        from public.relationships r
        where r.id = relationship_id
          and (select auth.uid()) in (r.requester_id, r.addressee_id)
      )
    )
  );

drop policy if exists "relation_answers_update_own" on public.relation_answers;
create policy "relation_answers_update_own"
  on public.relation_answers for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "relation_answers_delete_own" on public.relation_answers;
create policy "relation_answers_delete_own"
  on public.relation_answers for delete
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "account_deletion_requests_select_own" on public.account_deletion_requests;
create policy "account_deletion_requests_select_own"
  on public.account_deletion_requests for select
  to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "account_deletion_requests_insert_own" on public.account_deletion_requests;
create policy "account_deletion_requests_insert_own"
  on public.account_deletion_requests for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

revoke all on public.onboarding_answers from anon, authenticated;
revoke all on public.u_map_snapshots from anon, authenticated;
revoke all on public.star_ledger from anon, authenticated;
revoke all on public.entitlements from anon, authenticated;
revoke all on public.report_bodies from anon, authenticated;
revoke all on public.payment_events from anon, authenticated;
revoke all on public.relations from anon, authenticated;
revoke all on public.relation_answers from anon, authenticated;
revoke all on public.account_deletion_requests from anon, authenticated;

grant select, insert, update on public.onboarding_answers to authenticated;
grant select on public.u_map_snapshots to authenticated;
grant select on public.star_ledger to authenticated;
grant select on public.entitlements to authenticated;
grant select on public.report_bodies to authenticated;
grant select, insert, update, delete on public.relations to authenticated;
grant select, insert, update, delete on public.relation_answers to authenticated;
grant select, insert on public.account_deletion_requests to authenticated;

grant insert (id, display_name, avatar_url, timezone, onboarding_completed_at) on public.users to authenticated;
grant update (display_name, avatar_url, timezone, onboarding_completed_at, deletion_requested_at) on public.users to authenticated;

revoke select on public.points_ledger from authenticated;
revoke select on public.reports from authenticated;
revoke select on public.relationships from authenticated;
revoke insert on public.relationships from authenticated;
revoke update on public.relationships from authenticated;
grant select (
  id,
  user_id,
  report_type,
  status,
  title,
  summary,
  generated_at,
  created_at,
  updated_at,
  is_paid,
  price_stars,
  product_code
) on public.reports to authenticated;
grant select on public.relationships to authenticated;
grant insert (requester_id, addressee_id, relationship_type) on public.relationships to authenticated;
grant update (status) on public.relationships to authenticated;

create or replace function public.get_my_profile()
returns jsonb
language plpgsql
stable
as $$
declare
  v_user public.users;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;

  select * into v_user
  from public.users
  where id = auth.uid();

  if v_user.id is null then
    return null;
  end if;

  return jsonb_build_object(
    'id', v_user.id,
    'displayName', v_user.display_name,
    'avatarUrl', v_user.avatar_url,
    'timezone', v_user.timezone,
    'onboardingCompletedAt', v_user.onboarding_completed_at
  );
end;
$$;

create or replace function public.bootstrap_my_profile(
  p_display_name text default null,
  p_avatar_url text default null,
  p_timezone text default 'Asia/Seoul'
)
returns jsonb
language plpgsql
as $$
declare
  v_user public.users;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;

  insert into public.users (id, display_name, avatar_url, timezone)
  values (
    auth.uid(),
    nullif(btrim(p_display_name), ''),
    nullif(btrim(p_avatar_url), ''),
    coalesce(nullif(btrim(p_timezone), ''), 'Asia/Seoul')
  )
  on conflict (id) do update
  set
    display_name = coalesce(excluded.display_name, public.users.display_name),
    avatar_url = coalesce(excluded.avatar_url, public.users.avatar_url),
    timezone = coalesce(excluded.timezone, public.users.timezone)
  returning * into v_user;

  return jsonb_build_object(
    'id', v_user.id,
    'displayName', v_user.display_name,
    'avatarUrl', v_user.avatar_url,
    'timezone', v_user.timezone,
    'onboardingCompletedAt', v_user.onboarding_completed_at
  );
end;
$$;

create or replace function public.upsert_my_profile(
  display_name text default null,
  avatar_url text default null,
  timezone text default 'Asia/Seoul'
)
returns jsonb
language sql
as $$
  select public.bootstrap_my_profile(display_name, avatar_url, timezone);
$$;

create or replace function public.complete_onboarding(
  p_display_name text default null,
  p_timezone text default 'Asia/Seoul',
  p_answers jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
as $$
declare
  v_item jsonb;
  v_user public.users;
begin
  perform public.bootstrap_my_profile(p_display_name, null, p_timezone);

  if jsonb_typeof(coalesce(p_answers, '{}'::jsonb)) = 'object' then
    for v_item in
      select jsonb_build_object('key', key, 'value', value)
      from jsonb_each(p_answers)
    loop
      insert into public.onboarding_answers (user_id, step_code, answer_value)
      values (auth.uid(), v_item->>'key', v_item->'value')
      on conflict (user_id, step_code) do update
      set answer_value = excluded.answer_value;
    end loop;
  end if;

  update public.users
  set
    display_name = coalesce(nullif(btrim(p_display_name), ''), display_name),
    timezone = coalesce(nullif(btrim(p_timezone), ''), timezone),
    onboarding_completed_at = coalesce(onboarding_completed_at, now())
  where id = auth.uid()
  returning * into v_user;

  return jsonb_build_object(
    'id', v_user.id,
    'displayName', v_user.display_name,
    'avatarUrl', v_user.avatar_url,
    'timezone', v_user.timezone,
    'onboardingCompletedAt', v_user.onboarding_completed_at
  );
end;
$$;

create or replace function public.get_questions()
returns jsonb
language sql
stable
as $$
  select coalesce(jsonb_agg(
    jsonb_build_object(
      'id', q.id,
      'code', q.code,
      'prompt', q.prompt,
      'category', q.category,
      'questionType', q.question_type,
      'answerSchema', q.answer_schema,
      'sortOrder', q.sort_order
    )
    order by q.sort_order, q.created_at
  ), '[]'::jsonb)
  from public.questions q
  where q.is_active;
$$;

create or replace function public.get_next_question()
returns jsonb
language plpgsql
stable
as $$
declare
  v_question public.questions;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;

  select q.* into v_question
  from public.questions q
  where q.is_active
    and not exists (
      select 1
      from public.answers a
      where a.user_id = auth.uid()
        and a.question_id = q.id
    )
  order by q.sort_order, q.created_at
  limit 1;

  if v_question.id is null then
    select q.* into v_question
    from public.questions q
    where q.is_active
    order by q.sort_order, q.created_at
    limit 1;
  end if;

  if v_question.id is null then
    return null;
  end if;

  return jsonb_build_object(
    'id', v_question.id,
    'code', v_question.code,
    'prompt', v_question.prompt,
    'category', v_question.category,
    'questionType', v_question.question_type,
    'answerSchema', v_question.answer_schema,
    'sortOrder', v_question.sort_order
  );
end;
$$;

create or replace function public.upsert_my_answer(
  question_id uuid,
  answer_text text default null,
  answer_value jsonb default null
)
returns jsonb
language plpgsql
as $$
declare
  v_answer public.answers;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;

  if nullif(btrim(coalesce($2, '')), '') is null
     and $3 is null then
    raise exception 'answer_required';
  end if;

  insert into public.answers (user_id, question_id, answer_text, answer_value)
  values (auth.uid(), $1, nullif(btrim($2), ''), $3)
  on conflict (user_id, question_id) do update
  set
    answer_text = excluded.answer_text,
    answer_value = excluded.answer_value
  returning * into v_answer;

  return jsonb_build_object(
    'id', v_answer.id,
    'questionId', v_answer.question_id,
    'answerText', v_answer.answer_text,
    'answerValue', v_answer.answer_value
  );
end;
$$;

create or replace function public.get_my_answers()
returns jsonb
language sql
stable
as $$
  select coalesce(jsonb_agg(
    jsonb_build_object(
      'id', a.id,
      'questionId', a.question_id,
      'answerText', a.answer_text,
      'answerValue', a.answer_value
    )
    order by a.created_at
  ), '[]'::jsonb)
  from public.answers a
  where a.user_id = auth.uid();
$$;

create or replace function public.get_my_diaries(
  from_date date default null,
  to_date date default null
)
returns jsonb
language sql
stable
as $$
  select coalesce(jsonb_agg(
    jsonb_build_object(
      'id', d.id,
      'entryDate', d.entry_date,
      'title', d.title,
      'body', d.body,
      'moodScore', d.mood_score,
      'tags', d.tags,
      'createdAt', d.created_at,
      'updatedAt', d.updated_at
    )
    order by d.entry_date desc, d.created_at desc
  ), '[]'::jsonb)
  from public.diary d
  where d.user_id = auth.uid()
    and (from_date is null or d.entry_date >= from_date)
    and (to_date is null or d.entry_date <= to_date);
$$;

create or replace function public.save_my_diary(
  p_diary_id uuid default null,
  p_entry_date date default current_date,
  p_title text default null,
  p_body text default null,
  p_mood_score smallint default null,
  p_tags text[] default '{}'::text[]
)
returns jsonb
language plpgsql
as $$
declare
  v_diary public.diary;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;

  if nullif(btrim(coalesce(p_body, '')), '') is null then
    raise exception 'diary_body_required';
  end if;

  if p_mood_score is not null and (p_mood_score < 1 or p_mood_score > 10) then
    raise exception 'invalid_mood_score';
  end if;

  if p_diary_id is null then
    insert into public.diary (user_id, entry_date, title, body, mood_score, tags)
    values (
      auth.uid(),
      coalesce(p_entry_date, current_date),
      nullif(btrim(p_title), ''),
      btrim(p_body),
      p_mood_score,
      coalesce(p_tags, '{}'::text[])
    )
    returning * into v_diary;
  else
    update public.diary
    set
      entry_date = coalesce(p_entry_date, entry_date),
      title = nullif(btrim(p_title), ''),
      body = btrim(p_body),
      mood_score = p_mood_score,
      tags = coalesce(p_tags, '{}'::text[])
    where id = p_diary_id
      and user_id = auth.uid()
    returning * into v_diary;
  end if;

  if v_diary.id is null then
    raise exception 'diary_not_found';
  end if;

  return jsonb_build_object(
    'id', v_diary.id,
    'entryDate', v_diary.entry_date,
    'title', v_diary.title,
    'body', v_diary.body,
    'moodScore', v_diary.mood_score,
    'tags', v_diary.tags,
    'createdAt', v_diary.created_at,
    'updatedAt', v_diary.updated_at
  );
end;
$$;

create or replace function public.create_my_diary(
  entry_date date default current_date,
  title text default null,
  body text default null,
  mood_score smallint default null,
  tags text[] default '{}'::text[]
)
returns jsonb
language sql
as $$
  select public.save_my_diary(null, entry_date, title, body, mood_score, tags);
$$;

create or replace function public.update_my_diary(
  id uuid,
  entry_date date default current_date,
  title text default null,
  body text default null,
  mood_score smallint default null,
  tags text[] default '{}'::text[]
)
returns jsonb
language sql
as $$
  select public.save_my_diary(id, entry_date, title, body, mood_score, tags);
$$;

create or replace function public.get_my_diary(id uuid)
returns jsonb
language sql
stable
as $$
  select jsonb_build_object(
    'id', d.id,
    'entryDate', d.entry_date,
    'title', d.title,
    'body', d.body,
    'moodScore', d.mood_score,
    'tags', d.tags,
    'createdAt', d.created_at,
    'updatedAt', d.updated_at
  )
  from public.diary d
  where d.id = $1
    and d.user_id = auth.uid();
$$;

create or replace function public.delete_my_diary(id uuid)
returns jsonb
language plpgsql
as $$
declare
  v_deleted uuid;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;

  delete from public.diary
  where public.diary.id = $1
    and user_id = auth.uid()
  returning id into v_deleted;

  return jsonb_build_object('deleted', v_deleted is not null, 'id', v_deleted);
end;
$$;

create or replace function public.get_my_u_map()
returns jsonb
language sql
stable
as $$
  select coalesce(jsonb_agg(
    jsonb_build_object(
      'traitId', t.id,
      'traitCode', t.code,
      'name', t.name,
      'description', t.description,
      'dimension', t.dimension,
      'score', u.score,
      'confidence', u.confidence,
      'evidenceCount', u.evidence_count,
      'source', u.source,
      'calculatedAt', u.calculated_at
    )
    order by t.dimension, t.name
  ), '[]'::jsonb)
  from public.u_map u
  join public.traits t on t.id = u.trait_id
  where u.user_id = auth.uid()
    and t.is_active;
$$;

create or replace function public.get_current_signature(signature_type text default 'primary')
returns jsonb
language plpgsql
stable
as $$
declare
  v_signature public.signatures;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;

  select * into v_signature
  from public.signatures s
  where s.user_id = auth.uid()
    and s.signature_type = coalesce(nullif(btrim($1), ''), 'primary')
    and s.is_current
  order by s.created_at desc
  limit 1;

  if v_signature.id is null then
    return null;
  end if;

  return jsonb_build_object(
    'id', v_signature.id,
    'signatureType', v_signature.signature_type,
    'label', v_signature.label,
    'summary', v_signature.summary,
    'confidence', v_signature.confidence,
    'metadata', v_signature.metadata,
    'createdAt', v_signature.created_at
  );
end;
$$;

create or replace function public.get_my_reports()
returns jsonb
language sql
stable
as $$
  select coalesce(jsonb_agg(
    jsonb_build_object(
      'id', r.id,
      'reportType', r.report_type,
      'status', r.status,
      'title', r.title,
      'summary', r.summary,
      'isPaid', r.is_paid,
      'priceStars', r.price_stars,
      'productCode', r.product_code,
      'requiredProductId', r.product_code,
      'hasAccess', (
        r.is_paid = false
        or exists (
          select 1
          from public.entitlements e
          where e.user_id = auth.uid()
            and e.entitlement_type = 'paid_report'
            and e.resource_type = 'report'
            and e.resource_id = r.id
            and e.status = 'active'
            and (e.valid_until is null or e.valid_until > now())
        )
      ),
      'generatedAt', r.generated_at,
      'createdAt', r.created_at
    )
    order by r.created_at desc
  ), '[]'::jsonb)
  from public.reports r
  where r.user_id = auth.uid();
$$;

create or replace function public.get_my_report(report_id uuid)
returns jsonb
language plpgsql
stable
as $$
declare
  v_report_id uuid;
  v_report_type text;
  v_status text;
  v_title text;
  v_summary text;
  v_is_paid boolean;
  v_price_stars integer;
  v_product_code text;
  v_generated_at timestamptz;
  v_has_access boolean;
  v_payload jsonb;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;

  select
    id,
    report_type,
    status,
    title,
    summary,
    is_paid,
    price_stars,
    product_code,
    generated_at
  into
    v_report_id,
    v_report_type,
    v_status,
    v_title,
    v_summary,
    v_is_paid,
    v_price_stars,
    v_product_code,
    v_generated_at
  from public.reports
  where id = $1
    and user_id = auth.uid();

  if v_report_id is null then
    return null;
  end if;

  v_has_access :=
    v_is_paid = false
    or exists (
      select 1
      from public.entitlements e
      where e.user_id = auth.uid()
        and e.entitlement_type = 'paid_report'
        and e.resource_type = 'report'
        and e.resource_id = v_report_id
        and e.status = 'active'
        and (e.valid_until is null or e.valid_until > now())
    );

  if v_has_access then
    select rb.payload into v_payload
    from public.report_bodies rb
    where rb.report_id = v_report_id
      and rb.user_id = auth.uid();
  end if;

  return jsonb_build_object(
    'id', v_report_id,
    'reportType', v_report_type,
    'status', v_status,
    'title', v_title,
    'summary', v_summary,
    'isPaid', v_is_paid,
    'priceStars', v_price_stars,
    'productCode', v_product_code,
    'requiredProductId', v_product_code,
    'hasAccess', v_has_access,
    'payload', coalesce(v_payload, '{}'::jsonb),
    'generatedAt', v_generated_at
  );
end;
$$;

create or replace function public.get_my_star_balance()
returns jsonb
language sql
stable
as $$
  select jsonb_build_object(
    'balance', coalesce(sum(amount), 0),
    'asOf', now()
  )
  from public.star_ledger
  where user_id = auth.uid();
$$;

create or replace function public.get_my_star_ledger()
returns jsonb
language sql
stable
as $$
  select coalesce(jsonb_agg(
    jsonb_build_object(
      'id', id,
      'amount', amount,
      'entryType', entry_type,
      'reason', reason,
      'sourceProvider', source_provider,
      'referenceType', reference_type,
      'referenceId', reference_id,
      'createdAt', created_at
    )
    order by created_at desc
  ), '[]'::jsonb)
  from public.star_ledger
  where user_id = auth.uid();
$$;

create or replace function public.get_my_entitlements()
returns jsonb
language sql
stable
as $$
  select coalesce(jsonb_agg(
    jsonb_build_object(
      'id', id,
      'entitlementType', entitlement_type,
      'resourceType', resource_type,
      'resourceId', resource_id,
      'productId', product_code,
      'productCode', product_code,
      'status', status,
      'validFrom', valid_from,
      'validUntil', valid_until
    )
    order by created_at desc
  ), '[]'::jsonb)
  from public.entitlements
  where user_id = auth.uid();
$$;

create or replace function public.get_store_products(platform text default 'android')
returns jsonb
language sql
stable
as $$
  select case
    when platform = 'android' then jsonb_build_array(
      jsonb_build_object('id', 'fiyou_star_100', 'productId', 'fiyou_star_100', 'title', '100 Stars', 'description', 'Star pack for expanded FI-YOU views.', 'priceLabel', 'Google Play', 'kind', 'consumable', 'starAmount', 100),
      jsonb_build_object('id', 'fiyou_star_300', 'productId', 'fiyou_star_300', 'title', '330 Stars', 'description', 'Star pack for expanded FI-YOU views.', 'priceLabel', 'Google Play', 'kind', 'consumable', 'starAmount', 330),
      jsonb_build_object('id', 'fiyou_star_700', 'productId', 'fiyou_star_700', 'title', '800 Stars', 'description', 'Star pack for expanded FI-YOU views.', 'priceLabel', 'Google Play', 'kind', 'consumable', 'starAmount', 800),
      jsonb_build_object('id', 'fiyou_star_1500', 'productId', 'fiyou_star_1500', 'title', '1800 Stars', 'description', 'Star pack for expanded FI-YOU views.', 'priceLabel', 'Google Play', 'kind', 'consumable', 'starAmount', 1800),
      jsonb_build_object('id', 'fiyou_report_umap_deep_1', 'productId', 'fiyou_report_umap_deep_1', 'title', 'Expanded U-Map report', 'description', 'Unlock an expanded organization of your own U-Map records.', 'priceLabel', 'Google Play', 'kind', 'consumable'),
      jsonb_build_object('id', 'fiyou_report_signature_deep_1', 'productId', 'fiyou_report_signature_deep_1', 'title', 'Expanded Signature report', 'description', 'Unlock an expanded organization of your own Signature records.', 'priceLabel', 'Google Play', 'kind', 'consumable'),
      jsonb_build_object('id', 'fiyou_report_relation_1', 'productId', 'fiyou_report_relation_1', 'title', 'Relation reflection report', 'description', 'Unlock an expanded relationship reflection based on submitted records.', 'priceLabel', 'Google Play', 'kind', 'consumable'),
      jsonb_build_object('id', 'fiyou_report_past_self_1', 'productId', 'fiyou_report_past_self_1', 'title', 'Past-self comparison report', 'description', 'Unlock an expanded comparison of your own past records.', 'priceLabel', 'Google Play', 'kind', 'consumable'),
      jsonb_build_object('id', 'fiyou_plus', 'productId', 'fiyou_plus', 'title', 'FI-YOU Plus', 'description', 'Optional subscription for expanded FI-YOU views.', 'priceLabel', 'Google Play', 'kind', 'subscription')
    )
    else '[]'::jsonb
  end;
$$;

create or replace function public.get_paid_report_access(report_id uuid)
returns jsonb
language sql
stable
as $$
  select jsonb_build_object(
    'reportId', r.id,
    'isPaid', r.is_paid,
    'priceStars', r.price_stars,
    'hasAccess', (
      r.user_id = auth.uid()
      and (
        r.is_paid = false
        or exists (
          select 1
          from public.entitlements e
          where e.user_id = auth.uid()
            and e.entitlement_type = 'paid_report'
            and e.resource_type = 'report'
            and e.resource_id = r.id
            and e.status = 'active'
            and (e.valid_until is null or e.valid_until > now())
        )
      )
    )
  )
  from public.reports r
  where r.id = $1
    and r.user_id = auth.uid();
$$;

create or replace function public.get_my_relations()
returns jsonb
language sql
stable
as $$
  select coalesce(jsonb_agg(
    jsonb_build_object(
      'id', rel.id,
      'label', rel.label,
      'note', rel.note,
      'status', rel.status,
      'createdAt', rel.created_at,
      'updatedAt', rel.updated_at
    )
    order by rel.updated_at desc
  ), '[]'::jsonb)
  from public.relations rel
  where rel.user_id = auth.uid()
    and rel.status <> 'deleted';
$$;

create or replace function public.create_my_relation(
  label text,
  note text default null
)
returns jsonb
language plpgsql
as $$
declare
  v_relation public.relations;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;

  if nullif(btrim(coalesce(label, '')), '') is null then
    raise exception 'relation_label_required';
  end if;

  insert into public.relations (user_id, label, note, status)
  values (auth.uid(), btrim(label), nullif(btrim(note), ''), 'active')
  returning * into v_relation;

  return jsonb_build_object(
    'id', v_relation.id,
    'label', v_relation.label,
    'note', v_relation.note,
    'status', v_relation.status,
    'createdAt', v_relation.created_at,
    'updatedAt', v_relation.updated_at
  );
end;
$$;

create or replace function public.create_relation_request(
  p_addressee_id uuid,
  p_relationship_type text default 'friend'
)
returns jsonb
language plpgsql
as $$
declare
  v_relation public.relationships;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;

  if p_addressee_id = auth.uid() then
    raise exception 'cannot_create_relation_with_self';
  end if;

  begin
    insert into public.relationships (requester_id, addressee_id, relationship_type)
    values (auth.uid(), p_addressee_id, coalesce(nullif(btrim(p_relationship_type), ''), 'friend'))
    returning * into v_relation;
  exception when unique_violation then
    select * into v_relation
    from public.relationships
    where least(requester_id, addressee_id) = least(auth.uid(), p_addressee_id)
      and greatest(requester_id, addressee_id) = greatest(auth.uid(), p_addressee_id)
      and relationship_type = coalesce(nullif(btrim(p_relationship_type), ''), 'friend')
    limit 1;
  end;

  return jsonb_build_object(
    'id', v_relation.id,
    'requesterId', v_relation.requester_id,
    'addresseeId', v_relation.addressee_id,
    'status', v_relation.status,
    'relationshipType', v_relation.relationship_type
  );
end;
$$;

create or replace function public.update_relation_status(
  p_relationship_id uuid,
  p_status text
)
returns jsonb
language plpgsql
as $$
declare
  v_relation public.relationships;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;

  if p_status not in ('pending', 'accepted', 'blocked', 'declined') then
    raise exception 'invalid_relation_status';
  end if;

  update public.relationships
  set
    status = p_status,
    accepted_at = case when p_status = 'accepted' then coalesce(accepted_at, now()) else accepted_at end
  where id = p_relationship_id
    and auth.uid() in (requester_id, addressee_id)
  returning * into v_relation;

  if v_relation.id is null then
    raise exception 'relation_not_found';
  end if;

  return jsonb_build_object(
    'id', v_relation.id,
    'status', v_relation.status,
    'acceptedAt', v_relation.accepted_at
  );
end;
$$;

create or replace function public.upsert_relation_answer(
  p_relationship_id uuid,
  p_question_id uuid default null,
  p_prompt_code text default null,
  p_answer_text text default null,
  p_answer_value jsonb default null,
  p_visibility text default 'own_only'
)
returns jsonb
language plpgsql
as $$
declare
  v_answer public.relation_answers;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;

  if p_visibility not in ('own_only', 'shared') then
    raise exception 'invalid_visibility';
  end if;

  if nullif(btrim(coalesce(p_answer_text, '')), '') is null
     and p_answer_value is null then
    raise exception 'answer_required';
  end if;

  insert into public.relation_answers (
    relationship_id,
    user_id,
    question_id,
    prompt_code,
    answer_text,
    answer_value,
    visibility
  )
  values (
    p_relationship_id,
    auth.uid(),
    p_question_id,
    nullif(btrim(p_prompt_code), ''),
    nullif(btrim(p_answer_text), ''),
    p_answer_value,
    p_visibility
  )
  returning * into v_answer;

  return jsonb_build_object(
    'id', v_answer.id,
    'relationshipId', v_answer.relationship_id,
    'questionId', v_answer.question_id,
    'promptCode', v_answer.prompt_code,
    'answerText', v_answer.answer_text,
    'answerValue', v_answer.answer_value,
    'visibility', v_answer.visibility
  );
end;
$$;

create or replace function public.get_relation_answers(p_relationship_id uuid)
returns jsonb
language sql
stable
as $$
  select coalesce(jsonb_agg(
    jsonb_build_object(
      'id', a.id,
      'relationshipId', a.relationship_id,
      'questionId', a.question_id,
      'promptCode', a.prompt_code,
      'answerText', a.answer_text,
      'answerValue', a.answer_value,
      'visibility', a.visibility,
      'createdAt', a.created_at
    )
    order by a.created_at
  ), '[]'::jsonb)
  from public.relation_answers a
  where a.relationship_id = p_relationship_id;
$$;

create or replace function public.request_account_deletion(reason text default null)
returns jsonb
language plpgsql
as $$
declare
  v_request public.account_deletion_requests;
begin
  if auth.uid() is null then
    raise exception 'not_authenticated';
  end if;

  insert into public.account_deletion_requests (user_id, reason)
  values (auth.uid(), nullif(btrim($1), ''))
  returning * into v_request;

  update public.users
  set deletion_requested_at = coalesce(deletion_requested_at, now())
  where id = auth.uid();

  return jsonb_build_object(
    'id', v_request.id,
    'status', v_request.status,
    'requestedAt', v_request.requested_at
  );
end;
$$;

grant execute on function public.get_my_profile() to authenticated;
grant execute on function public.bootstrap_my_profile(text, text, text) to authenticated;
grant execute on function public.upsert_my_profile(text, text, text) to authenticated;
grant execute on function public.complete_onboarding(text, text, jsonb) to authenticated;
grant execute on function public.get_questions() to authenticated;
grant execute on function public.get_next_question() to authenticated;
grant execute on function public.upsert_my_answer(uuid, text, jsonb) to authenticated;
grant execute on function public.get_my_answers() to authenticated;
grant execute on function public.get_my_diaries(date, date) to authenticated;
grant execute on function public.save_my_diary(uuid, date, text, text, smallint, text[]) to authenticated;
grant execute on function public.create_my_diary(date, text, text, smallint, text[]) to authenticated;
grant execute on function public.update_my_diary(uuid, date, text, text, smallint, text[]) to authenticated;
grant execute on function public.get_my_diary(uuid) to authenticated;
grant execute on function public.delete_my_diary(uuid) to authenticated;
grant execute on function public.get_my_u_map() to authenticated;
grant execute on function public.get_current_signature(text) to authenticated;
grant execute on function public.get_my_reports() to authenticated;
grant execute on function public.get_my_report(uuid) to authenticated;
grant execute on function public.get_my_star_balance() to authenticated;
grant execute on function public.get_my_star_ledger() to authenticated;
grant execute on function public.get_my_entitlements() to authenticated;
grant execute on function public.get_store_products(text) to authenticated;
grant execute on function public.get_paid_report_access(uuid) to authenticated;
grant execute on function public.get_my_relations() to authenticated;
grant execute on function public.create_my_relation(text, text) to authenticated;
grant execute on function public.create_relation_request(uuid, text) to authenticated;
grant execute on function public.update_relation_status(uuid, text) to authenticated;
grant execute on function public.upsert_relation_answer(uuid, uuid, text, text, jsonb, text) to authenticated;
grant execute on function public.get_relation_answers(uuid) to authenticated;
grant execute on function public.request_account_deletion(text) to authenticated;

commit;
