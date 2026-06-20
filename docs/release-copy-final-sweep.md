# FI-YOU Release Copy Final Sweep

Date: 2026-06-19
Owner: Self-Discovery Logic / Insight Safety Lead
Purpose: Final copy sweep after Flutter QA found old U-Map labels in Home/U-Map graph UI.

## 1. Deprecated Labels That Must Not Appear As Axis Labels

These labels must not be exposed as U-Map axis labels, graph node labels, insight chips, mini-metrics, axis hints, detail headers, mock axis names, backend seed labels, or fallback labels.

### Hard remove from axis/chip/graph contexts

- `탐색`
- `관계`
- `회복`
- `표현`
- `감정 흐름`
- `관계 반응`
- `회복 방식`
- `선택 기준`
- `몰입 패턴`
- `불안 신호`
- `표현 방식`
- `성장 단서`
- `관계지향`
- `감정패턴`

Reason:

- They are not the FI-YOU canonical 8 U-Map axes.
- Some sound like fixed traits, states, or simplified personality categories.
- `불안 신호`, `감정패턴`, `관계지향` are especially risky because they can feel like mental-state or personality labeling.

## 2. Canonical 8-Axis Replacement Table

Only these 8 labels should be visible as U-Map axes.

| Old / Unsafe Label | Replace With | Notes |
| --- | --- | --- |
| 탐색 | 삶의 방향 | Use when the copy means curiosity, future direction, or exploration. |
| 관계 | 관계 흐름 | Use for relationship-related U-Map axis or chip. |
| 회복 | 긴장과 회복 | Use for stress/recovery rhythm. |
| 표현 | 감정 인식 | Use when the copy means noticing or naming feelings. Use `선택 방식` only if it means communication around decisions. |
| 감정 흐름 | 감정 인식 | Avoid "pattern" or fixed emotional style. |
| 관계 반응 | 관계 흐름 | Keep focus on the user's experience inside relationships. |
| 회복 방식 | 긴장과 회복 | Broader and less prescriptive. |
| 선택 기준 | 가치 기준 | Use `선택 방식` only when the UI means decision process. |
| 몰입 패턴 | 에너지 리듬 | Use if it describes focus/energy. Do not use "패턴" as axis label. |
| 불안 신호 | 긴장과 회복 | Avoid mental-health-state framing. |
| 표현 방식 | 감정 인식 | Use if about emotion/language awareness. |
| 성장 단서 | 성장 동기 | Canonical growth axis. |
| 관계지향 | 관계 흐름 | Avoid trait-like "orientation". |
| 감정패턴 | 감정 인식 | Avoid fixed pattern language. |

Canonical labels:

- `에너지 리듬`
- `감정 인식`
- `가치 기준`
- `선택 방식`
- `관계 흐름`
- `긴장과 회복`
- `성장 동기`
- `삶의 방향`

## 3. Rule For Generic Words Like `탐색`, `관계`, `회복`, `표현`

These words are not globally banned. They are safe in ordinary sentence copy, but unsafe when they function as U-Map taxonomy labels.

Allowed sentence use:

- "오늘의 탐색을 이어가요."
- "관계 안에서 내가 경험한 흐름을 살펴봐요."
- "회복에 도움이 된 장면을 기록해요."
- "내 표현으로 수정할 수 있어요."

Not allowed as standalone UI taxonomy:

- Graph node label: `탐색`
- Axis chip: `관계`
- Mini metric: `회복`
- U-Map hint label: `표현`
- Insight chip: `관계지향`
- Axis detail title: `불안 신호`

Decision rule:

- If the label is a button/action/sentence: generic words may remain.
- If the label categorizes the user, an insight, an axis, a graph node, or a U-Map area: replace with the canonical 8-axis label.

## 4. Auth Release Placeholder Replacement

Remove release-placeholder copy from user-facing Auth screens.

Avoid:

- `Mock 계정으로 계속하기`
- `출시 연동 시 Google/이메일 로그인과 약관 링크가 이 영역에 연결됩니다.`
- `출시 전 준비 상태입니다.`
- `준비 화면입니다.`

Safe user-facing replacements:

| Current / Placeholder | Replace With |
| --- | --- |
| Mock 계정으로 계속하기 | 시작하기 |
| 출시 연동 시 Google/이메일 로그인과 약관 링크가 이 영역에 연결됩니다. | 계속하면 FI-YOU의 이용 기준과 개인정보 안내를 확인한 것으로 진행됩니다. |
| 안전한 기록 공간으로 시작하기 | 내 기록으로 시작하기 |
| 로그인 중이에요 | 시작하는 중이에요 |
| 연결을 확인하지 못했어요. | 시작하지 못했어요. |
| 로그인하지 못했어요. 잠시 뒤 다시 시도해주세요. | 잠시 뒤 다시 시도해 주세요. 입력한 내용은 유지됩니다. |

Recommended Auth copy:

- Title: `내 기록으로 시작하기`
- Body: `FI-YOU는 사람을 단정하지 않고, 질문과 Diary 기록에서 보이는 단서와 흐름을 정리합니다.`
- CTA: `시작하기`
- Footnote: `기록이 쌓이면 U-Map과 표현은 달라질 수 있어요.`

## 5. Small-Screen Safe Copy

Use these shorter copies when CTA or onboarding text wraps awkwardly.

### CTA replacements

| Long Copy | Short Safe Copy |
| --- | --- |
| 저장하고 단서 보기 | 단서 보기 |
| 오늘 질문 시작하기 | 질문 시작 |
| 다른 질문 이어가기 | 다음 질문 |
| Diary에 이어쓰기 | Diary 쓰기 |
| U-Map에서 보기 | U-Map 보기 |
| 내 표현으로 수정 | 표현 수정 |
| 이 단서 숨기기 | 숨기기 |
| 동의하지 않음 | 동의 안 함 |
| 근거 기록 보기 | 근거 보기 |
| 함께 있었던 상황/관계 단서(선택) | 상황/관계 단서 |

### Onboarding replacements

| Long Copy | Short Safe Copy |
| --- | --- |
| 몇 가지 기대만 맞추고 바로 첫 질문으로 이어갈게요. | 첫 질문 전, 흐름만 가볍게 맞춰요. |
| 정답을 찾는 질문이 아니라, 지금 가까운 반응을 기록하는 질문이에요. | 정답보다 가까운 반응을 남겨요. |
| 짧은 장면과 감정 태그가 U-Map에 반영될 작은 단서가 됩니다. | 짧은 기록도 U-Map 단서가 돼요. |
| 기록이 쌓일수록 8개 축의 표현이 조금씩 섬세해집니다. | 기록이 쌓이면 8축이 선명해져요. |
| 어떻게 불러드릴까요? | 닉네임을 알려주세요. |

### U-Map small card replacements

| Long Copy | Short Safe Copy |
| --- | --- |
| 오늘의 기록 흐름이 8개 축의 지도처럼 이어지고 있어요. | 기록이 8개 축으로 이어져요. |
| 질문과 Diary가 쌓이면 8개 축이 더 섬세하게 나타납니다. | 기록이 쌓이면 8축이 선명해져요. |
| 지도에 표시할 단서가 조금 더 필요해요. | 단서가 조금 더 필요해요. |
| 질문과 Diary가 더 쌓이면 축별 흐름을 조금 더 자세히 볼 수 있어요. | 기록이 쌓이면 축별 흐름이 더 보여요. |

## 6. Flutter Lead Direct Replacement List

Apply these replacements before QA rerun:

- `탐색` as U-Map mini metric / graph label -> `삶의 방향`
- `관계` as U-Map hint / graph label -> `관계 흐름`
- `회복` as U-Map hint / graph label -> `긴장과 회복`
- `표현` as U-Map hint / graph label -> `감정 인식`
- `강한 흐름` -> `조금 선명한 영역`
- `관계지향` -> `관계 흐름`
- `감정패턴` -> `감정 인식`
- `감정 흐름` -> `감정 인식`
- `관계 반응` -> `관계 흐름`
- `회복 방식` -> `긴장과 회복`
- `선택 기준` -> `가치 기준`
- `몰입 패턴` -> `에너지 리듬`
- `불안 신호` -> `긴장과 회복`
- `표현 방식` -> `감정 인식`
- `성장 단서` -> `성장 동기`
- `Mock 계정으로 계속하기` -> `시작하기`
- `출시 연동 시 Google/이메일 로그인과 약관 링크가 이 영역에 연결됩니다.` -> `기록이 쌓이면 U-Map과 표현은 달라질 수 있어요.`
- `저장하고 단서 보기` -> `단서 보기` on small screens
- `오늘 질문 시작하기` -> `질문 시작` on small screens

## 7. QA Rerun Points

Run copy search after replacement:

- Deprecated axis labels in U-Map context:
  - `탐색`
  - `관계`
  - `회복`
  - `표현`
  - `관계지향`
  - `감정패턴`
  - `불안 신호`
  - `몰입 패턴`

- Release placeholders:
  - `Mock`
  - `출시 연동`
  - `출시 전`
  - `준비 화면`

- P0 safety terms:
  - `분석 완료`
  - `정확도`
  - `신뢰도`
  - `진단`
  - `성격유형`
  - `MBTI`
  - `치료`
  - `상담`
  - `궁합`
  - `진짜 나`
  - `당신은`

Pass criteria:

- The only visible U-Map axis labels are the canonical 8 labels.
- Generic words such as `관계`, `회복`, `표현`, `탐색` appear only inside sentences or action copy, not as standalone taxonomy labels.
- Auth screen has no release placeholder text.
- Small-screen CTA labels fit without changing safety meaning.
