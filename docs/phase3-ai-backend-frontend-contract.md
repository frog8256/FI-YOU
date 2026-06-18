# FI-YOU Phase 3 AI Logic Backend/Frontend Contract

## Scope

Phase 3 covers Android release AI Logic for:

- Questions
- Diary
- U-Map
- Signature
- Relationship insight
- Star and paid report wording guardrails
- Report output contracts

AI Logic does not sell questions and must not pressure users into payment. Android in-app payments use Google Play Billing. Web payments use Paddle. Paid reports are framed as expanded organization of records, not as more accurate identity judgment.

## Backend Contracts

### Store Current U-Map

Store the current calculated U-Map as user-owned backend state.

Recommended payload field:

```json
{
  "userId": "uuid",
  "uMap": {},
  "uMapClarity": {},
  "source": {
    "answerIds": ["uuid"],
    "diaryIds": ["uuid"],
    "generatedBy": "rule-based|ai-api",
    "schemaVersion": "phase3-2026-06-17"
  },
  "calculatedAt": "timestamp"
}
```

### Store Signature

Signature must be a current-flow snapshot, not a fixed type.

```json
{
  "userId": "uuid",
  "signatureType": "primary",
  "label": "안쪽의 의미를 천천히 밝히는 흐름",
  "summary": "현재까지의 기록을 바탕으로 보면...",
  "evidence": ["..."],
  "confidenceNote": "Signature는 고정 유형이 아니라...",
  "schemaVersion": "phase3-2026-06-17",
  "createdAt": "timestamp"
}
```

### Store Relation Insight

Relationship analysis is optional but must be scoped to the user's experience.

```json
{
  "userId": "uuid",
  "relationId": "uuid",
  "displayLabel": "친구 A",
  "summary": "현재 기록을 바탕으로 보면, 이 관계 안에서 내가...",
  "myExperienceFlow": "...",
  "comfortSignals": ["..."],
  "tensionSignals": ["..."],
  "nextReflection": "...",
  "boundaryNote": "이 결과는 상대가 어떤 사람인지 판단하지 않고...",
  "safetyNote": "관계 분석은 상대 성향, 관계의 미래, 지속 여부를 단정하지 않습니다.",
  "evidence": ["..."],
  "createdAt": "timestamp"
}
```

### Store Report

Reports can be free or paid. Paid reports are expanded views only.

```json
{
  "userId": "uuid",
  "reportId": "uuid",
  "tier": "free|paid",
  "title": "확장 자기탐구 리포트",
  "summary": "유료 리포트는 판정 기능이 아니라, 현재 기록을 더 깊고 긴 호흡으로 정리해 흐름을 더 선명하게 살펴보는 확장 보기입니다.",
  "sections": [],
  "sourceSummary": {
    "answerCount": 12,
    "diaryCount": 4,
    "clearAreas": ["가치 기준"],
    "unclearAreas": ["삶의 방향"]
  },
  "refreshPolicy": "새 질문 답변이나 Diary 기록이 쌓이면 리포트 내용은 달라질 수 있습니다.",
  "paymentToneNote": "Star 또는 유료 리포트는 자기이해를 압박하거나 불안을 자극하지 않아야 하며, 질문 자체는 판매하지 않습니다."
}
```

## Frontend Refresh Events

Frontend should refresh or request recalculation when:

- User completes onboarding question.
- User submits any question answer.
- User creates, edits, or deletes a Diary entry.
- User opens U-Map after new answers or Diary entries.
- User opens Signature after 3 or more new records since last Signature generation.
- User opens relation insight after adding relation notes or relation-related Diary.
- User purchases or unlocks a paid report, but only after the free core loop remains accessible.

Recommended debounce:

- Question answer: immediate local update, backend sync in background.
- Diary save: refresh U-Map/Signature after save succeeds.
- Report generation: explicit user action, show source count before generating.

## Product QA Rules

- No "analysis accuracy" wording.
- No "you are this type" wording.
- No medical, counseling, therapy, diagnosis, or mental illness judgment.
- Relation insight never claims what the other person is.
- Paid report copy never says it reveals the "true" or "more accurate" self.
- Star shortage copy must suggest continuing the free loop first.

## Schema Files

- `ai-logic/output-schema.json`: current core analysis output.
- `ai-logic/phase3-output-schema.json`: U-Map, Signature, Relation, Report, Safety combined contract.
- `ai-logic/phase3-qa-samples.json`: QA sample data and expected checks.
