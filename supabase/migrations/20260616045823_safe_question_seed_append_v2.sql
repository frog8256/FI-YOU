-- FI-YOU safe question seed append v2.
-- This migration intentionally does not update or remove existing questions/options.
-- Existing answers reference question_options by FK, so replacement must be append/versioned.

create schema if not exists private;

create table if not exists private.question_seed_batches (
  batch_key text primary key,
  description text not null,
  active_for_ui boolean not null default false,
  created_at timestamptz not null default now()
);

insert into private.question_seed_batches(batch_key, description, active_for_ui)
values (
  'ai_logic_safe_append_v2_20260616',
  'Append-only candidate question seed for AI logic hardening. Existing FK-referenced options are untouched.',
  false
)
on conflict (batch_key) do nothing;

with seed(question_set, sequence, prompt, helper_text, axis_keys) as (
  values
    ('onboarding_required', 101, '지금 마음에 가장 오래 남아 있는 장면은 어디에 가깝나요?', '기존 5문항을 대체하지 않는 v2 후보 질문입니다.', array['emotional_sensitivity','relationship','stability']::text[]),
    ('onboarding_required', 102, '선택 앞에서 먼저 확인하고 싶은 기준은 무엇인가요?', '기존 5문항을 대체하지 않는 v2 후보 질문입니다.', array['independence','stability','initiative']::text[]),
    ('onboarding_required', 103, '혼자 정리하는 시간은 지금의 나에게 어떤 의미인가요?', '기존 5문항을 대체하지 않는 v2 후보 질문입니다.', array['independence','emotional_sensitivity']::text[]),
    ('onboarding_required', 104, '감정이 흔들릴 때 가장 먼저 알아차리는 신호는 무엇인가요?', '기존 5문항을 대체하지 않는 v2 후보 질문입니다.', array['self_expression','stability','emotional_sensitivity']::text[]),
    ('onboarding_required', 105, 'FI-YOU에서 가장 먼저 선명하게 보고 싶은 영역은 무엇인가요?', '기존 5문항을 대체하지 않는 v2 후보 질문입니다.', array['exploration','growth','relationship']::text[])
)
insert into public.questions(question_set, sequence, prompt, helper_text, axis_keys, active)
select question_set, sequence, prompt, helper_text, axis_keys, false
from seed
on conflict (question_set, sequence) do nothing;

with seed(sequence, prompt, axis_keys) as (
  select
    100 + gs,
    '요즘의 선택에서 나를 가장 잘 보여주는 단서는 무엇인가요? #' || gs,
    case
      when gs % 8 = 1 then array['exploration','growth']::text[]
      when gs % 8 = 2 then array['independence','stability']::text[]
      when gs % 8 = 3 then array['relationship','emotional_sensitivity']::text[]
      when gs % 8 = 4 then array['growth','initiative']::text[]
      when gs % 8 = 5 then array['self_expression','relationship']::text[]
      when gs % 8 = 6 then array['stability','emotional_sensitivity']::text[]
      when gs % 8 = 7 then array['initiative','exploration']::text[]
      else array['self_expression','independence']::text[]
    end
  from generate_series(1, 30) gs
)
insert into public.questions(question_set, sequence, prompt, helper_text, axis_keys, active)
select
  'basic_free',
  sequence,
  prompt,
  '기존 30문항을 대체하지 않는 append-only v2 후보 질문입니다.',
  axis_keys,
  false
from seed
on conflict (question_set, sequence) do nothing;

with seed(sequence, prompt, axis_keys) as (
  select
    100 + gs,
    '이 관계에서 반복해서 경험하는 흐름은 무엇에 가깝나요? #' || gs,
    case
      when gs % 5 = 1 then array['relationship','emotional_sensitivity']::text[]
      when gs % 5 = 2 then array['stability','relationship']::text[]
      when gs % 5 = 3 then array['self_expression','relationship']::text[]
      when gs % 5 = 4 then array['independence','emotional_sensitivity']::text[]
      else array['growth','relationship']::text[]
    end
  from generate_series(1, 20) gs
)
insert into public.questions(question_set, sequence, prompt, helper_text, axis_keys, active)
select
  'relation_map',
  sequence,
  prompt,
  '기존 Relation-Map 20문항을 대체하지 않는 append-only v2 후보 질문입니다.',
  axis_keys,
  false
from seed
on conflict (question_set, sequence) do nothing;

with option_seed(option_sequence, label, axis_weights) as (
  values
    (1, '혼자 정리해보고 싶어요', '{"independence": 0.35, "stability": 0.15}'::jsonb),
    (2, '누군가와 나누며 확인하고 싶어요', '{"relationship": 0.35, "self_expression": 0.15}'::jsonb),
    (3, '작게라도 시도해보고 싶어요', '{"initiative": 0.35, "growth": 0.20}'::jsonb),
    (4, '감정의 흐름을 먼저 보고 싶어요', '{"emotional_sensitivity": 0.35, "stability": 0.15}'::jsonb),
    (5, '아직 잘 모르겠어요', '{"exploration": 0.20}'::jsonb)
),
target_questions as (
  select id
  from public.questions
  where sequence between 101 and 130
    and question_set in ('onboarding_required', 'basic_free', 'relation_map')
)
insert into public.question_options(question_id, sequence, label, axis_weights)
select tq.id, os.option_sequence, os.label, os.axis_weights
from target_questions tq
cross join option_seed os
where not exists (
  select 1
  from public.question_options qo
  where qo.question_id = tq.id
    and qo.sequence = os.option_sequence
);

comment on table private.question_seed_batches
  is 'Tracks append-only question seed batches. v2 candidates are inactive until Product explicitly promotes them.';
