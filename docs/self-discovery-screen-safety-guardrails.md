# FI-YOU Self-Discovery Screen Safety Guardrails

Date: 2026-06-19
Owner: Self-Discovery Logic / Insight Safety Lead
Scope: question answer, answer-save feedback, insight expression, Diary-to-U-Map feedback, U-Map 8 axes, insight detail controls, empty/error copy, Flutter mock copy

## Core Rule

FI-YOU does not diagnose, type, counsel, treat, or define the user. Every screen should present the output as a current, record-based clue that can change as answers and Diary entries accumulate.

## Allowed Expressions

- "현재 기록에서 보이는 흐름"
- "오늘 발견된 단서"
- "답변에서 작은 단서가 더해졌어요."
- "Diary 기록이 U-Map에 참고 단서로 반영됐어요."
- "이 표현이 맞지 않으면 숨기거나 수정할 수 있어요."
- "아직 충분히 드러나지 않은 영역이에요."
- "다음 질문으로 조금 더 살펴볼 수 있어요."
- "고정된 결론이 아니라 지금까지의 기록 요약이에요."
- "관계는 상대를 판단하지 않고, 내가 관계 안에서 경험한 흐름만 다뤄요."

## Forbidden Expressions

- "당신은 OO 유형입니다."
- "OO형 / OO타입 / 성격 유형"
- "진단 / 치료 / 상담 / 정신건강 평가"
- "정확도 / 신뢰도 / 분석 정확도 / 더 정확한 분석"
- "진짜 나 / 숨겨진 나 / 운명"
- "궁합 / 천생연분 / 반드시 만남 / 반드시 헤어짐"
- "정상 / 비정상"
- "우울증 / 불안장애 / 정신질환 등 병명 또는 상태 라벨"
- "이 직업이 맞습니다."
- "상대는 이런 사람입니다."
- "당신은 ~한 사람입니다."
- "결제하면 더 정확하게 알 수 있습니다."

## Screen-Level Guardrails

### Question Answer Screen

Use one clear question with 2-5 balanced choices and optional free text. The question should ask about a concrete scene, preference, reaction, or record, not a trait label.

Safe:

- "최근에 마음이 오래 머문 장면은 어디에 가까웠나요?"
- "선택 앞에서 먼저 확인하고 싶었던 기준은 무엇이었나요?"
- "답변은 정답이 아니라 오늘의 흐름을 남기는 방식이에요."

Avoid:

- "당신의 유형을 알아볼게요."
- "정확한 결과를 위해 솔직히 답하세요."
- "당신의 성격을 판단하는 질문입니다."

### After Answer Save

The save feedback should be light and non-final. Do not say that an insight has been confirmed.

Safe:

- "답변이 저장됐어요. 오늘의 U-Map 단서가 하나 더해졌습니다."
- "선택한 답변에서 작은 흐름을 살펴볼 수 있어요."
- "아직 결론은 아니에요. 다음 기록과 함께 더 자연스럽게 이어집니다."

Avoid:

- "분석이 완료됐어요."
- "유형이 확정됐어요."
- "정확한 결과가 나왔어요."

### Insight Generation / Expression

Insight should be framed as a clue, not a judgment. Use "보여요", "가까워요", "단서가 있어요", "현재 기록에서는" rather than "입니다", "확실합니다", "증명합니다".

Safe:

- "현재 기록에서는 선택 전에 충분히 납득하고 싶어 하는 흐름이 보여요."
- "관계 안에서 속도와 여백을 함께 살피는 단서가 있습니다."
- "이 문장이 맞지 않으면 숨기거나 수정할 수 있어요."

Avoid:

- "당신은 신중형입니다."
- "당신은 회피 성향입니다."
- "이 관계는 맞지 않습니다."

### Diary Save To U-Map

Diary feedback should explain that the entry can contribute to U-Map, not that the app has extracted a truth.

Safe:

- "Diary가 저장됐어요. 반복되는 단서가 있다면 U-Map에 천천히 반영됩니다."
- "오늘 기록은 감정 인식과 긴장-회복 축을 살펴보는 참고가 될 수 있어요."
- "기록이 쌓이면 표현은 달라질 수 있습니다."

Avoid:

- "Diary 분석 완료"
- "정확한 감정 상태가 파악됐어요."
- "문제 원인을 찾았어요."

### Insight Detail Controls

Every generated insight/detail should support user agency:

- Edit: "이 문장을 내 표현에 맞게 수정"
- Hide: "이 단서 숨기기"
- Disagree: "동의하지 않음"
- Why: "왜 이 단서가 보였나요?"
- Restore: "숨긴 단서 다시 보기"

Consent copy:

- "FI-YOU의 문장이 내 느낌과 다를 수 있어요. 맞지 않으면 숨기거나 수정해 주세요."
- "동의하지 않음을 선택하면 이 단서는 이후 요약에서 덜 강조됩니다."
- "이 선택은 나를 평가하는 값이 아니라, 기록을 더 내 언어에 가깝게 정리하기 위한 신호예요."

## `오늘 발견된 단서` Samples

1. "오늘 답변에서는 선택 전에 충분히 납득하고 싶어 하는 흐름이 조금 보였어요."
2. "관계 안에서 편안함과 거리감을 함께 살피는 단서가 남았습니다."
3. "감정이 커질 때 바로 결론내리기보다 잠시 정리하려는 흐름이 보여요."
4. "작은 진전이 있을 때 다시 움직일 힘을 얻는 단서가 있습니다."
5. "요즘의 기록에서는 조용한 회복 시간의 중요성이 조금 더 선명해졌어요."

## `U-Map에 반영됨` Samples

1. "답변이 저장됐어요. U-Map에 오늘의 단서가 하나 더해졌습니다."
2. "Diary가 저장됐어요. 반복되는 표현이 있다면 U-Map 흐름에 천천히 반영됩니다."
3. "현재 기록을 바탕으로 U-Map 선명도가 조금 업데이트됐어요."
4. "새 기록이 에너지 리듬과 감정 인식 축을 살펴보는 참고가 됐어요."
5. "아직 결론은 아니지만, 오늘 기록이 다음 질문 추천에 작은 힌트가 됩니다."

## Disagreement UX Copy

Primary message:

"이 단서가 지금의 나와 다르게 느껴질 수 있어요."

Actions:

- "동의하지 않음"
- "내 표현으로 수정"
- "이 단서 숨기기"
- "나중에 다시 보기"

After disagree:

"알려줘서 고마워요. 이 단서는 이후 요약에서 덜 강조됩니다."

After edit:

"수정한 표현을 기준으로 앞으로의 기록을 더 조심스럽게 정리할게요."

After hide:

"이 단서를 숨겼어요. 필요하면 설정에서 다시 볼 수 있습니다."

## U-Map 8 Axes Safety Review

| Key | Safe Label | Safe Description | Safety Note |
| --- | --- | --- | --- |
| `energyRhythm` | 에너지 리듬 | 에너지가 차오르고 소모되는 방식, 회복에 도움이 되는 환경과 속도 | 체력/건강 진단처럼 말하지 않는다. |
| `emotionAwareness` | 감정 인식 | 감정을 알아차리고 이름 붙이며 기록하는 방식 | 정신건강 평가나 병명으로 연결하지 않는다. |
| `valuesCompass` | 가치 기준 | 선택할 때 놓치고 싶지 않은 기준과 우선순위 | 도덕성 평가처럼 말하지 않는다. |
| `decisionStyle` | 선택 방식 | 결정 전에 정보를 모으고 납득을 얻는 흐름 | 우유부단/충동적 같은 라벨을 쓰지 않는다. |
| `relationshipPattern` | 관계 흐름 | 관계 안에서 편안함, 거리감, 연결감을 경험하는 방식 | 상대의 성향, 의도, 미래를 단정하지 않는다. |
| `stressRecovery` | 긴장과 회복 | 부담 신호를 알아차리고 다시 정리하는 방식 | 치료/상담/위기 대응처럼 보이지 않게 한다. |
| `growthMotivation` | 성장 동기 | 계속 움직이게 만드는 의미, 진전, 배움의 단서 | 성공/실패 예측으로 말하지 않는다. |
| `lifeDirection` | 삶의 방향 | 앞으로 더 자주 만들고 싶은 삶의 감각과 장면 | 운명/정답/직업 적합도처럼 말하지 않는다. |

## Empty / Error Copy

Question empty:

"지금 열 수 있는 질문을 준비하는 중이에요. 잠시 후 다시 시도해 주세요."

Insight empty:

"아직 단서를 정리하기에는 기록이 많지 않아요. 오늘의 질문이나 Diary 한 줄부터 시작해도 충분합니다."

U-Map empty:

"아직 U-Map이 흐릿해요. 답변과 Diary가 쌓이면 8개 축이 조금씩 선명해집니다."

Signature empty:

"아직 Signature를 정리하는 중이에요. 고정 이름이 아니라 기록이 쌓이며 달라지는 요약입니다."

Network error:

"기록을 불러오지 못했어요. 저장된 내용은 사라지지 않도록 다시 확인하겠습니다."

Save error:

"저장하지 못했어요. 연결을 확인한 뒤 다시 시도해 주세요."

Safety fallback:

"이 표현은 조심스럽게 다시 정리할 필요가 있어요. FI-YOU는 진단이나 판단 대신 기록의 흐름만 다룹니다."

## Flutter-Safe Mock Copy Set

The following strings are safe to hardcode for prototype UI.

```dart
const fiyouSafeMockCopy = {
  'questionTitle': '오늘의 질문',
  'questionHelper': '정답이 아니라 지금의 흐름을 남기는 질문이에요.',
  'answerSaved': '답변이 저장됐어요. 오늘의 U-Map 단서가 하나 더해졌습니다.',
  'todayInsightTitle': '오늘 발견된 단서',
  'todayInsightBody': '현재 기록에서는 선택 전에 충분히 납득하고 싶어 하는 흐름이 조금 보였어요.',
  'todayInsightCaveat': '고정된 결론이 아니라 지금까지의 기록 요약이에요.',
  'diarySaved': 'Diary가 저장됐어요. 반복되는 단서가 있다면 U-Map에 천천히 반영됩니다.',
  'uMapReflected': '현재 기록을 바탕으로 U-Map 선명도가 조금 업데이트됐어요.',
  'uMapEmpty': '아직 U-Map이 흐릿해요. 답변과 Diary가 쌓이면 8개 축이 조금씩 선명해집니다.',
  'insightEmpty': '아직 단서를 정리하기에는 기록이 많지 않아요. 오늘의 질문이나 Diary 한 줄부터 시작해도 충분합니다.',
  'disagreeTitle': '이 단서가 지금의 나와 다르게 느껴질 수 있어요.',
  'disagreeAction': '동의하지 않음',
  'editAction': '내 표현으로 수정',
  'hideAction': '이 단서 숨기기',
  'disagreeSaved': '알려줘서 고마워요. 이 단서는 이후 요약에서 덜 강조됩니다.',
  'networkError': '기록을 불러오지 못했어요. 저장된 내용은 사라지지 않도록 다시 확인하겠습니다.',
  'saveError': '저장하지 못했어요. 연결을 확인한 뒤 다시 시도해 주세요.',
  'safetyFallback': 'FI-YOU는 진단이나 판단 대신 기록의 흐름만 다룹니다.',
};
```

## PM Handoff Notes

- Flutter may hardcode the mock copy above for the next screen pass.
- UI should expose edit/hide/disagree controls wherever an insight sentence appears.
- Backend should store user disagreement as feedback metadata, not as a score about the user.
- Any AI-generated sentence must pass the forbidden-expression filter before display.

## PM Review Summary For Flutter Core Screens

### 1. Question Answer Screen

Safety principle:

- Ask about a recent scene, preference, reaction, or record.
- Present answers as self-exploration inputs, not a test.
- Avoid pressure copy such as "accurate result" or "personality type".

Usable copy:

- "오늘의 질문"
- "정답이 아니라 지금의 흐름을 남기는 질문이에요."
- "가장 가까운 답을 고르고, 필요하면 한 문장을 더 남겨 주세요."
- "이 답변은 U-Map의 작은 단서로만 사용됩니다."

Avoid:

- "정확한 분석을 위해 답해주세요."
- "당신의 성격유형을 확인합니다."
- "이 질문으로 당신이 어떤 사람인지 알 수 있어요."

Required user controls:

- "건너뛰기"
- "나중에 답하기"
- "직접 적기"
- "답변 수정"

### 2. Question Complete / Clue Feedback

Safety principle:

- Completion feedback must be provisional.
- Say "단서가 더해짐", not "분석 완료" or "결과 확정".

Usable copy:

- "답변이 저장됐어요. 오늘의 U-Map 단서가 하나 더해졌습니다."
- "선택한 답변에서 작은 흐름을 살펴볼 수 있어요."
- "아직 결론은 아니에요. 다음 기록과 함께 더 자연스럽게 이어집니다."
- "오늘 발견된 단서: 선택 전에 충분히 납득하고 싶어 하는 흐름이 조금 보였어요."

Avoid:

- "분석이 완료됐어요."
- "정확도 92%"
- "신뢰도 높음"
- "유형이 확정됐어요."

Required user controls:

- "단서 자세히 보기"
- "이 단서 숨기기"
- "동의하지 않음"
- "내 표현으로 수정"

### 3. Diary Complete Feedback

Safety principle:

- Diary is a record, not a clinical entry.
- Feedback should say the record may contribute to U-Map over time.

Usable copy:

- "Diary가 저장됐어요. 반복되는 단서가 있다면 U-Map에 천천히 반영됩니다."
- "오늘 기록은 감정 인식과 긴장-회복 축을 살펴보는 참고가 될 수 있어요."
- "기록이 쌓이면 표현은 달라질 수 있습니다."
- "한 줄의 기록도 현재의 탐색에 충분한 시작이 됩니다."

Avoid:

- "Diary 분석 완료"
- "감정 상태가 진단됐어요."
- "문제 원인을 찾았어요."
- "치료가 필요한 신호입니다."

Required user controls:

- "수정하기"
- "삭제하기"
- "U-Map 반영 보기"
- "이 기록을 Insight에 사용하지 않기"

### 4. U-Map Detail / 8 Axes

Safety principle:

- U-Map axes are current record areas, not personality traits.
- Use "선명도" only as record density/repeated clue visibility, never accuracy or reliability.

Usable copy:

- "U-Map은 현재 기록에서 보이는 흐름을 8개 축으로 정리한 지도예요."
- "조금씩 선명해지는 영역"
- "아직 더 기록이 필요한 영역"
- "다음 질문으로 더 살펴볼 수 있어요."

Avoid:

- "정확도"
- "신뢰도"
- "성격유형"
- "당신은 감정적인 사람입니다."
- "이 축은 확정됐습니다."

Required user controls:

- "축 설명 보기"
- "관련 기록 보기"
- "이 축 숨기기"
- "이 표현에 동의하지 않음"

### 5. Insight / Clue Detail Screen

Safety principle:

- Every Insight must be editable, hideable, and rejectable.
- Detail view should show why the clue appeared, but only via user-owned records.

Usable copy:

- "현재 기록에서 이런 단서가 보였어요."
- "근거가 된 기록"
- "이 표현이 맞지 않으면 숨기거나 수정할 수 있어요."
- "동의하지 않음을 선택하면 이후 요약에서 덜 강조됩니다."

Avoid:

- "당신은 이런 사람입니다."
- "AI가 판단한 결과입니다."
- "이 단서는 신뢰도가 높습니다."
- "반드시 이렇게 행동합니다."

Required user controls:

- "내 표현으로 수정"
- "동의하지 않음"
- "이 단서 숨기기"
- "근거 기록 보기"
- "삭제 요청"

### 6. Empty / Error States

Safety principle:

- Empty states should lower pressure.
- Error states should reassure that records are protected and avoid implying user failure.

Usable copy:

- "아직 단서를 정리하기에는 기록이 많지 않아요."
- "오늘의 질문이나 Diary 한 줄부터 시작해도 충분합니다."
- "아직 U-Map이 흐릿해요. 답변과 Diary가 쌓이면 8개 축이 조금씩 선명해집니다."
- "기록을 불러오지 못했어요. 저장된 내용은 사라지지 않도록 다시 확인하겠습니다."

Avoid:

- "데이터가 부족해 분석할 수 없습니다."
- "정확한 결과를 위해 더 많이 입력하세요."
- "오류로 분석이 실패했습니다."
- "사용자 상태를 확인할 수 없습니다."

Required user controls:

- "다시 시도"
- "오늘의 질문으로 이동"
- "Diary 작성하기"
- "문의하기"

### Android Pre-Launch Review Risks

- Replace any visible "분석", "정확도", or "신뢰도" copy with "단서", "흐름", "기록", or "선명도".
- Confirm no screen says "당신은 ~한 사람" or fixed tendency statements.
- Confirm U-Map "선명도" is explained as record-based visibility, not result quality.
- Confirm all Insight detail cards include edit, hide, and disagree controls.
- Confirm Diary and question completion messages do not imply diagnosis, treatment, counseling, or confirmed cause.
- Confirm relationship-related clues never judge the other person, predict the relationship, or imply compatibility.
- Confirm paid or locked experiences do not imply better accuracy or a truer self-understanding.
