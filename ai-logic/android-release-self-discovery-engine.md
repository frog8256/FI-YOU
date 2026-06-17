# FI-YOU Android Release Self-Discovery Engine

## Release Scope

This document is the AI Logic / Self-Discovery Engine source of truth for the Flutter Android release preparation. The official website is out of scope for this track.

Release core loop:

Onboarding → initial question answer → Diary record → U-Map review → Signature review → recommended next question → repeat exploration

The engine must work without an AI API through a rule-based fallback. If an AI API is connected later, prompts and output schema must preserve the same safety contract.

## U-Map Axes

FI-YOU uses 8 axes for release. These are not personality types. They are record-based observation areas.

| Key | Label | Meaning | Main Signals |
| --- | --- | --- | --- |
| `energyRhythm` | 에너지 리듬 | 에너지가 차오르고 소모되는 방식, 혼자/함께/루틴/변화에서 느끼는 리듬 | 회복 장면, 피로 신호, 선호 환경, 루틴 |
| `emotionAwareness` | 감정 인식 | 감정을 알아차리고 이름 붙이며 다루는 방식 | 감정 단어, 몸의 신호, 기록/대화, 뒤늦은 인식 |
| `valuesCompass` | 가치 기준 | 선택의 기준이 되는 가치와 포기하기 어려운 태도 | 우선순위, 책임감, 배려, 솔직함, 자율성 |
| `decisionStyle` | 선택 방식 | 결정할 때 정보를 모으고 확신을 얻는 방식 | 정보 탐색, 내적 납득, 대화, 작은 실험 |
| `relationshipPattern` | 관계 흐름 | 관계 안에서 편안함, 거리감, 연결감을 경험하는 흐름 | 속도, 여백, 솔직함, 균형, 대화 조건 |
| `stressRecovery` | 긴장과 회복 | 긴장 신호를 알아차리고 회복을 시도하는 방식 | 부담 신호, 멈춤, 정리, 공유, 움직임 |
| `growthMotivation` | 성장 동기 | 계속 움직이게 만드는 동기와 성취의 의미 | 의미, 진전, 책임, 배움, 지속 |
| `lifeDirection` | 삶의 방향 | 앞으로 더 자주 만들고 싶은 삶의 감각과 방향 | 원하는 감각, 바꾸고 싶은 장면, 시간/관계/일/회복 |

## Question Sets

All questions must have 2-5 choices and optional free-text reflection.

### Onboarding Questions

| ID | Axis | Prompt |
| --- | --- | --- |
| `onboarding-001` | `energyRhythm` | FI-YOU를 처음 시작하는 지금, 나를 알아가는 방식으로 가장 편하게 느껴지는 것은 무엇인가요? |
| `onboarding-002` | `valuesCompass` | 최근의 나를 돌아볼 때, 지금 가장 놓치고 싶지 않은 감각은 무엇인가요? |
| `onboarding-003` | `relationshipPattern` | 관계나 일상 안에서 요즘 나에게 가장 필요한 여백은 어디에 가까운가요? |
| `onboarding-004` | `lifeDirection` | 앞으로 FI-YOU가 더 자주 비춰 줬으면 하는 내 모습은 무엇인가요? |

### Initial Questions

Initial questions cover all 8 axes with at least two prompts each. They establish the first U-Map and Signature.

| Axis | Question IDs |
| --- | --- |
| `energyRhythm` | `energy-001`, `energy-002` |
| `emotionAwareness` | `emotion-001`, `emotion-002` |
| `valuesCompass` | `values-001`, `values-002` |
| `decisionStyle` | `decision-001`, `decision-002` |
| `relationshipPattern` | `relation-001`, `relation-002` |
| `stressRecovery` | `stress-001`, `stress-002` |
| `growthMotivation` | `growth-001`, `growth-002` |
| `lifeDirection` | `direction-001`, `direction-002` |

### Repeat Questions

Repeat questions are used after the initial set or when the user returns after Diary activity.

| ID | Axis | Use |
| --- | --- | --- |
| `repeat-energy-001` | `energyRhythm` | Detect changed energy rhythm since previous records |
| `repeat-emotion-001` | `emotionAwareness` | Detect repeated emotional texture |
| `repeat-values-001` | `valuesCompass` | Compare current values with prior records |
| `repeat-relation-001` | `relationshipPattern` | Notice relationship flow without judging the other person |
| `repeat-growth-001` | `growthMotivation` | Encourage return by noticing small continuity |

Implementation source: `src/lib/aiLogic.ts`.

## Rule-Based Fallback

The fallback is the release baseline. It must be enabled even if AI API is not connected.

1. Each selected choice contributes `signalHints`.
2. Optional text and Diary body are scanned with a lightweight Korean keyword lexicon.
3. Diary entries can contribute to U-Map axes when their body contains axis-related keywords.
4. Axis `evidenceCount` equals answer count for that axis plus up to 3 Diary hits.
5. Axis `clarity` is capped at 92 and calculated from evidence count, answer text richness, and Diary text richness.
6. Axis `flow` is derived from clarity:
   - `0-24`: `emerging`
   - `25-54`: `forming`
   - `55-74`: `clearer`
   - `75-92`: `active`
7. Signature uses the strongest repeated signal, expressed only as a current flow summary.
8. Next question recommendation:
   - First finish unanswered onboarding questions.
   - Then rank axes by low clarity.
   - Add a small penalty to axes answered in the last 3 answers to avoid repetition fatigue.
   - Before 12 answers, prefer `initial` questions.
   - After 12 answers, prefer `repeat` questions.
   - If all targeted questions are answered, return any unanswered repeat question.

## Payload Schema

### Question Payload

```json
{
  "questionId": "values-001",
  "stage": "initial",
  "axis": "valuesCompass",
  "area": "valuesCompass",
  "areaLabel": "가치 기준",
  "question": "최근 선택 하나를 떠올렸을 때, 끝까지 지키고 싶었던 기준은 무엇에 가까웠나요?",
  "choices": [
    { "id": "honesty", "label": "솔직함과 납득 가능함", "signalHints": ["depth", "autonomy"] },
    { "id": "care", "label": "상대에 대한 배려", "signalHints": ["connection", "balance"] }
  ],
  "optionalTextPrompt": "그 기준이 중요했던 이유가 있다면 한 문장만 더해 주세요.",
  "whyThisQuestion": "가치 기준 축의 단서가 아직 더 쌓이면 좋겠어요. 현재 기록을 조금 더 선명하게 보기 위한 질문입니다."
}
```

### Answer Payload

```json
{
  "id": "answer-uuid",
  "questionId": "values-001",
  "axis": "valuesCompass",
  "area": "valuesCompass",
  "question": "최근 선택 하나를 떠올렸을 때, 끝까지 지키고 싶었던 기준은 무엇에 가까웠나요?",
  "selectedChoiceId": "honesty",
  "selectedChoiceLabel": "솔직함과 납득 가능함",
  "optionalText": "결국 내가 납득해야 오래 갈 수 있다고 느꼈어요.",
  "text": "솔직함과 납득 가능함. 결국 내가 납득해야 오래 갈 수 있다고 느꼈어요.",
  "createdAt": "2026-06-17T00:00:00.000Z"
}
```

### U-Map Axis Payload

```json
{
  "label": "가치 기준",
  "summary": "현재까지의 기록에서는 가치 기준에 대한 단서가 3개 정도 쌓였어요.",
  "signals": ["솔직함과 납득 가능함", "Diary: 오늘 선택은 오래 생각해도 납득되는 쪽이었다..."],
  "clarity": 58,
  "flow": "clearer",
  "evidenceCount": 3,
  "nextDepth": "가치 기준 안에서 반복되는 선택의 이유를 더 보면 흐름이 선명해질 수 있어요."
}
```

### Signature Payload

```json
{
  "name": "안쪽의 의미를 천천히 밝히는 흐름",
  "summary": "현재까지의 기록을 바탕으로 보면, 겉으로 보이는 선택보다 안쪽의 의미를 오래 살피는 흐름이 조금씩 보여요.",
  "evidence": [
    "가치 기준 답변에서 \"솔직함과 납득 가능함\"이라는 단서가 보여요.",
    "Diary 기록에서 \"왜 이 선택이 마음에 남는지 계속 생각했다\"라는 흐름이 보여요."
  ],
  "confidenceNote": "Signature는 고정 유형이 아니라 현재까지의 기록에서 보이는 흐름 요약입니다. 답변과 Diary가 쌓이면 자연스럽게 달라질 수 있어요."
}
```

## AI API Prompt/Schema Rules

If AI API is connected:

- The API output must match `ai-logic/output-schema.json`.
- The prompt must not invent records or infer diagnosis.
- The model can summarize only evidence present in answers or Diary.
- Any uncertain area must say it is not yet sufficiently visible.
- The model must preserve `clarity`, `flow`, and "current records" language.
- The model must not output fixed type names, mental-health labels, deterministic career advice, or compatibility claims.

## Relation Insight Rule

Relationship analysis is included in the release scope, but it is intentionally narrow.

Allowed:

- "이 관계 안에서 내가 편안함을 느끼는 조건이 일부 보여요."
- "가까워질 때 내 속도와 여백이 중요해지는 흐름이 보여요."
- "대화가 가능할 때 긴장이 줄어드는 단서가 있어요."

Not allowed:

- "상대는 이런 사람입니다."
- "둘은 잘 맞습니다."
- "이 관계는 오래갑니다."
- "헤어져야 합니다."

## Report and Star Tone Rule

Questions are never sold. Star and paid reports may unlock expanded organization, but they must not imply that paid users receive a more accurate self.

Allowed:

- "확장 리포트는 현재 기록을 더 깊고 긴 호흡으로 정리해 흐름을 더 선명하게 살펴보는 보기입니다."
- "무료 핵심 탐구 루프는 계속 사용할 수 있어요."
- "기록이 더 쌓이면 리포트도 달라질 수 있어요."

Not allowed:

- "구매하면 더 정확한 나를 알 수 있습니다."
- "이 리포트를 보지 않으면 중요한 흐름을 놓칩니다."
- "Star가 부족하면 질문을 계속할 수 없습니다."

## Refresh Timing

Frontend should refresh AI Logic results when:

- A question answer is submitted.
- A Diary entry is created, edited, or deleted.
- U-Map is opened after new records.
- Signature is opened after 3 or more new records since the last Signature snapshot.
- Relation insight is opened after relation notes or relation-related Diary changes.
- A paid report is unlocked, while keeping the free core loop accessible.

## Forbidden/Recommended Expressions

| Forbidden | Recommended |
| --- | --- |
| 당신은 OO형입니다. | 현재까지의 기록을 바탕으로 보면, 이런 흐름이 조금씩 보여요. |
| 정확도 90%입니다. | 이 축은 현재 기록 안에서 비교적 선명하게 드러났어요. |
| 당신은 회피형입니다. | 갈등 상황에서 잠시 거리를 두고 정리하려는 단서가 보여요. |
| 당신은 불안정합니다. | 변화가 큰 상황에서 긴장 신호를 민감하게 알아차리는 흐름이 보여요. |
| 이 직업이 맞습니다. | 이런 업무 환경에서 강점이 살아날 가능성이 있어요. |
| 이 사람과 궁합이 좋습니다. | 이 관계 안에서 내가 편안함을 느끼는 조건이 일부 보여요. |
| 앞으로 이렇게 될 것입니다. | 현재 기록만 보면 이런 방향을 더 살펴볼 수 있어요. |

## Korean Text Recovery Risk

Release risk exists if broken Korean appears in app-facing files, prompts, schemas, legal text, or seed data.

Recovered/rewritten:

- `src/lib/aiLogic.ts`
- `ai-logic/android-release-self-discovery-engine.md`
- `ai-logic/safety-language-rules.md`
- `ai-logic/question-generation-prompt.md`
- `ai-logic/analysis-prompt.md`
- `ai-logic/output-schema.json`
- `docs/ai-logic-principles.md`

Still needs cross-team review before AAB signing:

- Supabase question seed data, if any, must match the release question catalog.
- Flutter string resources must not contain legacy mojibake.
- Store listing and in-app policy copy must use non-diagnostic language.

## Product QA Review Requests

- Confirm every question has 2-5 choices and optional text input.
- Confirm onboarding completes before regular next-question recommendation.
- Confirm U-Map displays "선명도/흐름", not "정확도".
- Confirm Signature does not look like a fixed MBTI-style type.
- Confirm relationship wording describes the user's experience, not the other person.
- Confirm empty-state Signature is clearly temporary and low-pressure.
- Confirm Diary can improve U-Map without requiring AI API.
- Confirm next question does not repeat the same axis too often.
- Confirm all analysis strings avoid medical, counseling, diagnosis, prediction, or destiny language.
- Confirm Android small screens show choices and optional text without truncation.
- Confirm paid report copy says "expanded view", not "more accurate self".
- Confirm Star copy never blocks or sells the core question loop.
