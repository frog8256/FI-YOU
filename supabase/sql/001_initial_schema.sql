begin;

create extension if not exists pgcrypto;

create schema if not exists private;

create or replace function private.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url text,
  timezone text not null default 'Asia/Seoul',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  prompt text not null,
  category text not null,
  question_type text not null check (question_type in ('text', 'single_choice', 'multi_choice', 'scale', 'json')),
  answer_schema jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.answers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  question_id uuid not null references public.questions(id) on delete restrict,
  answer_text text,
  answer_value jsonb,
  answered_at timestamptz not null default now(),
  last_edited_at timestamptz,
  edit_count integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint answers_user_question_unique unique (user_id, question_id),
  constraint answers_has_content check (
    nullif(btrim(coalesce(answer_text, '')), '') is not null
    or answer_value is not null
  )
);

create table if not exists private.answer_revisions (
  id bigint generated always as identity primary key,
  answer_id uuid not null references public.answers(id) on delete cascade,
  user_id uuid not null references public.users(id) on delete cascade,
  question_id uuid not null references public.questions(id) on delete restrict,
  old_answer_text text,
  new_answer_text text,
  old_answer_value jsonb,
  new_answer_value jsonb,
  changed_at timestamptz not null default now(),
  changed_by uuid
);

create table if not exists public.diary (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  entry_date date not null default current_date,
  title text,
  body text not null,
  mood_score smallint check (mood_score between 1 and 10),
  tags text[] not null default '{}'::text[],
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  report_type text not null,
  status text not null default 'pending' check (status in ('pending', 'processing', 'ready', 'failed')),
  title text,
  summary text,
  payload jsonb not null default '{}'::jsonb,
  generated_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.signatures (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  signature_type text not null,
  label text not null,
  summary text,
  confidence numeric(5,4) check (confidence is null or (confidence >= 0 and confidence <= 1)),
  source_report_id uuid references public.reports(id) on delete set null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.traits (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  description text,
  dimension text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.u_map (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  trait_id uuid not null references public.traits(id) on delete restrict,
  score numeric(6,3) not null check (score >= -100 and score <= 100),
  confidence numeric(5,4) check (confidence is null or (confidence >= 0 and confidence <= 1)),
  evidence_count integer not null default 0 check (evidence_count >= 0),
  source text,
  metadata jsonb not null default '{}'::jsonb,
  calculated_at timestamptz not null default now(),
  constraint u_map_user_trait_unique unique (user_id, trait_id)
);

create table if not exists public.points_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  amount integer not null check (amount <> 0),
  reason text not null,
  reference_type text,
  reference_id uuid,
  idempotency_key text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create unique index if not exists points_ledger_user_idempotency_unique
  on public.points_ledger (user_id, idempotency_key)
  where idempotency_key is not null;

create table if not exists public.relationships (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.users(id) on delete cascade,
  addressee_id uuid not null references public.users(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending', 'accepted', 'blocked', 'declined')),
  relationship_type text not null default 'friend',
  created_at timestamptz not null default now(),
  accepted_at timestamptz,
  updated_at timestamptz not null default now(),
  constraint relationships_no_self check (requester_id <> addressee_id)
);

create unique index if not exists relationships_unordered_pair_unique
  on public.relationships (
    least(requester_id, addressee_id),
    greatest(requester_id, addressee_id),
    relationship_type
  );

create index if not exists answers_user_id_idx on public.answers (user_id);
create index if not exists answers_question_id_idx on public.answers (question_id);
create index if not exists diary_user_date_idx on public.diary (user_id, entry_date desc);
create index if not exists signatures_user_type_idx on public.signatures (user_id, signature_type);
create index if not exists u_map_user_id_idx on public.u_map (user_id);
create index if not exists points_ledger_user_created_idx on public.points_ledger (user_id, created_at desc);
create index if not exists reports_user_created_idx on public.reports (user_id, created_at desc);
create index if not exists relationships_requester_idx on public.relationships (requester_id);
create index if not exists relationships_addressee_idx on public.relationships (addressee_id);

create or replace function private.audit_answer_changes()
returns trigger
language plpgsql
security definer
set search_path = private, public, pg_temp
as $$
begin
  if tg_op = 'INSERT' then
    new.answered_at = coalesce(new.answered_at, now());
    new.created_at = coalesce(new.created_at, now());
    new.updated_at = coalesce(new.updated_at, now());
    new.edit_count = 0;
    return new;
  end if;

  if tg_op = 'UPDATE' then
    if old.answer_text is distinct from new.answer_text
       or old.answer_value is distinct from new.answer_value then
      insert into private.answer_revisions (
        answer_id,
        user_id,
        question_id,
        old_answer_text,
        new_answer_text,
        old_answer_value,
        new_answer_value,
        changed_by
      )
      values (
        old.id,
        old.user_id,
        old.question_id,
        old.answer_text,
        new.answer_text,
        old.answer_value,
        new.answer_value,
        auth.uid()
      );

      new.last_edited_at = now();
      new.edit_count = old.edit_count + 1;
    end if;

    new.answered_at = old.answered_at;
    new.created_at = old.created_at;
    new.updated_at = now();
    return new;
  end if;

  return new;
end;
$$;

create trigger set_users_updated_at
before update on public.users
for each row execute function private.set_updated_at();

create trigger audit_answers_changes
before insert or update on public.answers
for each row execute function private.audit_answer_changes();

create trigger set_diary_updated_at
before update on public.diary
for each row execute function private.set_updated_at();

create trigger set_reports_updated_at
before update on public.reports
for each row execute function private.set_updated_at();

create trigger set_signatures_updated_at
before update on public.signatures
for each row execute function private.set_updated_at();

create trigger set_relationships_updated_at
before update on public.relationships
for each row execute function private.set_updated_at();

alter table public.users enable row level security;
alter table public.questions enable row level security;
alter table public.answers enable row level security;
alter table public.diary enable row level security;
alter table public.signatures enable row level security;
alter table public.traits enable row level security;
alter table public.u_map enable row level security;
alter table public.points_ledger enable row level security;
alter table public.reports enable row level security;
alter table public.relationships enable row level security;

create policy "users_select_own"
  on public.users for select
  to authenticated
  using ((select auth.uid()) = id);

create policy "users_insert_own"
  on public.users for insert
  to authenticated
  with check ((select auth.uid()) = id);

create policy "users_update_own"
  on public.users for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

create policy "questions_select_active"
  on public.questions for select
  to authenticated
  using (is_active);

create policy "answers_select_own"
  on public.answers for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "answers_insert_own"
  on public.answers for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "answers_update_own"
  on public.answers for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "diary_select_own"
  on public.diary for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "diary_insert_own"
  on public.diary for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "diary_update_own"
  on public.diary for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "diary_delete_own"
  on public.diary for delete
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "signatures_select_own"
  on public.signatures for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "traits_select_active"
  on public.traits for select
  to authenticated
  using (is_active);

create policy "u_map_select_own"
  on public.u_map for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "points_ledger_select_own"
  on public.points_ledger for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "reports_select_own"
  on public.reports for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "relationships_select_involved"
  on public.relationships for select
  to authenticated
  using ((select auth.uid()) in (requester_id, addressee_id));

create policy "relationships_insert_as_requester"
  on public.relationships for insert
  to authenticated
  with check ((select auth.uid()) = requester_id);

create policy "relationships_update_involved"
  on public.relationships for update
  to authenticated
  using ((select auth.uid()) in (requester_id, addressee_id))
  with check ((select auth.uid()) in (requester_id, addressee_id));

revoke all on schema private from anon, authenticated;
revoke all on all tables in schema private from anon, authenticated;
revoke all on all functions in schema private from anon, authenticated;
revoke all on all tables in schema public from anon, authenticated;

grant usage on schema public to anon, authenticated;

grant select on public.users to authenticated;
grant insert (id, display_name, avatar_url, timezone) on public.users to authenticated;
grant update (display_name, avatar_url, timezone) on public.users to authenticated;
grant select on public.questions to authenticated;
grant insert (user_id, question_id, answer_text, answer_value) on public.answers to authenticated;
grant update (answer_text, answer_value) on public.answers to authenticated;
grant select (id, user_id, question_id, answer_text, answer_value) on public.answers to authenticated;
grant select on public.diary to authenticated;
grant insert (user_id, entry_date, title, body, mood_score, tags) on public.diary to authenticated;
grant update (entry_date, title, body, mood_score, tags) on public.diary to authenticated;
grant delete on public.diary to authenticated;
grant select on public.signatures to authenticated;
grant select on public.traits to authenticated;
grant select on public.u_map to authenticated;
grant select on public.points_ledger to authenticated;
grant select on public.reports to authenticated;
grant select on public.relationships to authenticated;
grant insert (requester_id, addressee_id, relationship_type) on public.relationships to authenticated;
grant update (status) on public.relationships to authenticated;

commit;
