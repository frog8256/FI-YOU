# FI-YOU AI Logic Principles

FI-YOU의 AI Logic은 사용자를 고정 유형으로 분류하지 않는다. 질문 응답과 Diary 기록을 바탕으로 현재까지 드러난 흐름을 보여주고, 기록이 쌓이면 U-Map과 Signature가 달라질 수 있음을 전제로 한다.

## Android Release Goal

Flutter Android 정식 출시 준비에서는 아래 핵심 루프를 안정적으로 완성하는 것을 목표로 한다.

온보딩 → 질문 응답 → Diary 기록 → U-Map 확인 → Signature 흐름 확인 → 다음 질문 추천 → 반복 탐구

공식 웹사이트는 이 AI Logic 범위에서 제외한다.

## Release Boundaries

P0:

- 8축 U-Map
- 온보딩/초기/반복 질문 세트
- 모든 질문의 2~5개 선택지
- 모든 질문의 선택적 서술 입력
- 답변/Diary 기반 rule-based signal 추출
- signal 기반 U-Map 선명도와 흐름 반영
- 고정 유형이 아닌 현재 흐름 Signature
- 온보딩 완료 후 낮은 선명도 축을 우선하는 다음 질문 추천
- 안전 문체 가드레일
- AI API 없이도 동작하는 fallback

P1:

- AI API 연결 후 분석 품질 고도화
- 리포트 히스토리와 변화 분석
- Relation-Map 별도 분석

## Non-Diagnostic Language

분석 문장은 관찰, 가능성, 현재 기록, 업데이트 가능성을 포함해야 한다.

Preferred:

- "현재까지의 기록을 바탕으로 보면..."
- "이런 흐름이 조금씩 보여요."
- "이 축은 현재 기록 안에서 비교적 선명하게 드러났어요."
- "다음 답변과 Diary에 따라 달라질 수 있어요."

Avoid:

- "당신은 OO형입니다."
- "정확도"
- "진단"
- "정상/비정상"
- "궁합이 좋다/나쁘다"
- "이 직업이 맞습니다."

## U-Map Axes

| Key | Label | Meaning |
| --- | --- | --- |
| `energyRhythm` | 에너지 리듬 | 에너지가 차오르고 소모되는 방식 |
| `emotionAwareness` | 감정 인식 | 감정을 알아차리고 이름 붙이며 다루는 방식 |
| `valuesCompass` | 가치 기준 | 선택의 기준이 되는 가치와 우선순위 |
| `decisionStyle` | 선택 방식 | 결정할 때 확신을 얻는 방식 |
| `relationshipPattern` | 관계 흐름 | 관계 안에서 편안함과 거리감을 경험하는 방식 |
| `stressRecovery` | 긴장과 회복 | 긴장 신호와 회복 방식 |
| `growthMotivation` | 성장 동기 | 계속 움직이게 만드는 힘 |
| `lifeDirection` | 삶의 방향 | 앞으로 더 자주 만들고 싶은 삶의 감각 |

## U-Map Growth Rule

U-Map은 완성되지 않는다. 선명도는 정확도가 아니라 현재 기록의 밀도와 반복 단서의 정도를 뜻한다.

Every U-Map result should include:

- 현재까지 기록이 쌓인 영역
- 아직 단서가 부족한 영역
- 다음 질문으로 더 선명해질 수 있는 영역
- 과거 기록과 새 기록 사이의 변화 가능성

## Signature Rule

Signature는 성격 유형명이 아니다. 현재까지 반복된 signal을 바탕으로 만든 상징적 흐름 요약이다.

Good:

- "자기 리듬으로 방향을 고르는 흐름"
- "관계의 온도를 살피며 이어지는 흐름"
- "안쪽의 의미를 천천히 밝히는 흐름"

Bad:

- "회피형"
- "완벽주의형"
- "불안형"
- "내향형 인간"

## Relation Language

정식 출시에서는 `relationshipPattern` 축에서 관계 단서를 다룬다. Relation-Map 별도 분석은 P1이다. 관계 문장은 상대를 분석하거나 단정하지 않는다.

Use:

- "이 관계 안에서 내가 편안함을 느끼는 조건이 일부 보여요."
- "가까워질 때 여백이 필요해지는 흐름이 보여요."

Avoid:

- "상대는 이런 사람입니다."
- "둘은 궁합이 좋습니다."
- "이 관계는 오래갑니다."
