-- FI-YOU safe seed v2 text correction.
-- Keeps the append-only inactive candidate strategy and only normalizes candidate text.

with seed(question_set, sequence, prompt, helper_text, axis_keys) as (
  values
    ('onboarding_required', 101, '지금 마음에 가장 오래 남아 있는 장면은 어디에 가깝나요?', '기존 5문항을 대체하지 않는 v2 후보 질문입니다.', array['emotional_sensitivity','relationship','stability']::text[]),
    ('onboarding_required', 102, '선택 앞에서 먼저 확인하고 싶은 기준은 무엇인가요?', '기존 5문항을 대체하지 않는 v2 후보 질문입니다.', array['independence','stability','initiative']::text[]),
    ('onboarding_required', 103, '혼자 정리하는 시간은 지금의 나에게 어떤 의미인가요?', '기존 5문항을 대체하지 않는 v2 후보 질문입니다.', array['independence','emotional_sensitivity']::text[]),
    ('onboarding_required', 104, '감정이 흔들릴 때 가장 먼저 알아차리는 신호는 무엇인가요?', '기존 5문항을 대체하지 않는 v2 후보 질문입니다.', array['self_expression','stability','emotional_sensitivity']::text[]),
    ('onboarding_required', 105, 'FI-YOU에서 가장 먼저 선명하게 보고 싶은 영역은 무엇인가요?', '기존 5문항을 대체하지 않는 v2 후보 질문입니다.', array['exploration','growth','relationship']::text[])
)
update public.questions q
set prompt = s.prompt,
    helper_text = s.helper_text,
    axis_keys = s.axis_keys,
    active = false
from seed s
where q.question_set = s.question_set
  and q.sequence = s.sequence;

update public.questions
set prompt = '요즘의 선택에서 나를 가장 잘 보여주는 단서는 무엇인가요? #' || (sequence - 100),
    helper_text = '기존 30문항을 대체하지 않는 append-only v2 후보 질문입니다.',
    active = false
where question_set = 'basic_free'
  and sequence between 101 and 130;

update public.questions
set prompt = '이 관계에서 반복해서 경험하는 흐름은 무엇에 가깝나요? #' || (sequence - 100),
    helper_text = '기존 Relation-Map 20문항을 대체하지 않는 append-only v2 후보 질문입니다.',
    active = false
where question_set = 'relation_map'
  and sequence between 101 and 120;

with option_seed(option_sequence, label, axis_weights) as (
  values
    (1, '혼자 정리해보고 싶어요', '{"independence": 0.35, "stability": 0.15}'::jsonb),
    (2, '누군가와 나누며 확인하고 싶어요', '{"relationship": 0.35, "self_expression": 0.15}'::jsonb),
    (3, '작게라도 시도해보고 싶어요', '{"initiative": 0.35, "growth": 0.20}'::jsonb),
    (4, '감정의 흐름을 먼저 보고 싶어요', '{"emotional_sensitivity": 0.35, "stability": 0.15}'::jsonb),
    (5, '아직 잘 모르겠어요', '{"exploration": 0.20}'::jsonb)
)
update public.question_options qo
set label = os.label,
    axis_weights = os.axis_weights
from public.questions q, option_seed os
where qo.question_id = q.id
  and os.option_sequence = qo.sequence
  and q.sequence between 101 and 130
  and q.question_set in ('onboarding_required', 'basic_free', 'relation_map');
