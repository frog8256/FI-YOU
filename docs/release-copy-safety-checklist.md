# FI-YOU Release Copy Safety Checklist

Date: 2026-06-19
Owner: Self-Discovery Logic / Insight Safety Lead
Target flow: Auth/Onboarding -> Question -> Answer -> Clue -> U-Map -> Diary -> Repeat

## Product Frame

FI-YOU는 진단, 상담, 치료, 성격유형 앱이 아니다. 질문 응답과 Diary 기록에서 현재 자기탐색 흐름을 조심스럽게 정리하고, U-Map과 다음 질문으로 이어 주는 앱이다.

모든 문구는 짧고 부드럽게 쓴다. 결론보다 단서, 판단보다 기록, 확정보다 변화 가능성을 앞에 둔다.

## 1. 질문 답변 플로우 문구 가이드

사용 문구:

- "오늘의 질문"
- "정답이 아니라 지금의 흐름을 남기는 질문이에요."
- "가장 가까운 답을 골라 주세요."
- "더 적고 싶은 말이 있다면 한 문장만 남겨도 좋아요."
- "답변은 U-Map의 작은 단서로만 사용됩니다."

금지 문구:

- "정확한 분석을 위해 답해주세요."
- "당신의 유형을 알아볼게요."
- "성격을 판별하는 질문입니다."
- "진짜 나를 찾기 위한 질문입니다."

대체 문구:

- "정확한 분석" -> "현재 기록에서 보이는 흐름"
- "유형 확인" -> "탐색 단서 남기기"
- "진짜 나" -> "지금의 기록"

Flutter checklist:

- 질문은 한 번에 하나만 보여준다.
- 선택지는 2-5개로 제한한다.
- 자유 입력은 선택 사항으로 둔다.
- 건너뛰기/나중에 답하기를 제공한다.
- 질문 화면에 "정답 없음" 또는 "현재 흐름" 프레임을 한 줄 넣는다.

## 2. 답변 완료 / 단서 발견 피드백 문구 세트

사용 문구:

- "답변이 저장됐어요."
- "오늘의 U-Map 단서가 하나 더해졌습니다."
- "선택한 답변에서 작은 흐름을 살펴볼 수 있어요."
- "아직 결론은 아니에요. 다음 기록과 함께 달라질 수 있습니다."
- "오늘 발견된 단서"

단서 문구 샘플:

- "선택 전에 충분히 납득하고 싶어 하는 흐름이 조금 보였어요."
- "관계 안에서 편안함과 거리감을 함께 살피는 단서가 남았습니다."
- "감정이 커질 때 잠시 정리하려는 흐름이 보여요."
- "작은 진전에서 다시 움직일 힘을 얻는 단서가 있습니다."
- "조용한 회복 시간이 중요해지는 흐름이 조금 더 선명해졌어요."

금지 문구:

- "분석 완료"
- "정확도 92%"
- "유형이 확정됐어요."
- "당신은 신중한 사람입니다."

대체 문구:

- "분석 완료" -> "단서가 더해졌어요"
- "정확도" -> "선명도"
- "확정" -> "현재 기록에서는 이렇게 보여요"

Flutter checklist:

- 완료 화면은 결과 카드처럼 과하게 보이지 않게 한다.
- "단서 자세히 보기", "동의하지 않음", "이 단서 숨기기"를 제공한다.
- 단서 문장은 "보여요", "남았습니다", "살펴볼 수 있어요"로 끝낸다.

## 3. Insight 상세 화면 안전 문구

사용 문구:

- "현재 기록에서 이런 단서가 보였어요."
- "근거가 된 기록"
- "이 표현이 맞지 않으면 숨기거나 수정할 수 있어요."
- "동의하지 않음을 선택하면 이후 요약에서 덜 강조됩니다."
- "이 단서는 고정된 결론이 아니라 지금까지의 기록 요약이에요."

사용자 제어권 버튼:

- "내 표현으로 수정"
- "동의하지 않음"
- "이 단서 숨기기"
- "근거 기록 보기"
- "나중에 다시 보기"

금지 문구:

- "AI가 판단한 결과입니다."
- "이 단서는 신뢰도가 높습니다."
- "당신은 이런 사람입니다."
- "반드시 이렇게 행동합니다."

대체 문구:

- "AI 판단" -> "기록에서 보인 단서"
- "신뢰도" -> "반복해서 보인 정도"
- "당신은 이런 사람" -> "현재 기록에서는 이런 흐름이 보여요"

Flutter checklist:

- Insight 상세에는 사용자 제어권 버튼을 반드시 노출한다.
- 근거는 사용자의 답변/Diary에서만 보여준다.
- 동의하지 않음은 부정 평가가 아니라 선호 피드백으로 저장한다.
- 단서 상세에 병리/치료/상담 암시가 없도록 QA한다.

## 4. U-Map 8축 표현 방식

U-Map 설명 문구:

"U-Map은 현재 기록에서 보이는 흐름을 8개 축으로 정리한 지도예요. 기록이 쌓이면 선명도와 표현은 달라질 수 있습니다."

8축:

| Key | 화면 표시명 | 짧은 설명 |
| --- | --- | --- |
| `energyRhythm` | 에너지 리듬 | 에너지가 차오르고 소모되는 방식 |
| `emotionAwareness` | 감정 인식 | 감정을 알아차리고 기록하는 방식 |
| `valuesCompass` | 가치 기준 | 선택할 때 놓치고 싶지 않은 기준 |
| `decisionStyle` | 선택 방식 | 결정을 정리하고 납득하는 흐름 |
| `relationshipPattern` | 관계 흐름 | 관계 안에서 편안함과 거리감을 경험하는 방식 |
| `stressRecovery` | 긴장과 회복 | 부담 신호를 알아차리고 다시 정리하는 방식 |
| `growthMotivation` | 성장 동기 | 계속 움직이게 하는 의미와 진전의 단서 |
| `lifeDirection` | 삶의 방향 | 앞으로 더 자주 만들고 싶은 삶의 감각 |

사용 문구:

- "조금씩 선명해지는 영역"
- "아직 더 기록이 필요한 영역"
- "다음 질문으로 더 살펴볼 수 있어요."
- "선명도는 정확도가 아니라 기록에서 단서가 보이는 정도예요."

금지 문구:

- "정확도"
- "신뢰도"
- "성격유형"
- "이 축은 확정됐습니다."
- "당신은 감정적인 사람입니다."

Flutter checklist:

- raw key를 사용자에게 그대로 노출하지 않는다.
- "선명도" 옆에는 필요 시 "기록 기준"을 붙인다.
- 축별 상세에는 관련 기록 보기/동의하지 않음/숨기기 액션을 둔다.

## 5. Diary 저장 후 U-Map 반영 안내 문구

사용 문구:

- "Diary가 저장됐어요."
- "반복되는 단서가 있다면 U-Map에 천천히 반영됩니다."
- "오늘 기록은 감정 인식과 긴장-회복 축을 살펴보는 참고가 될 수 있어요."
- "기록이 쌓이면 표현은 달라질 수 있습니다."
- "한 줄의 기록도 현재의 탐색에 충분한 시작이 됩니다."

U-Map 반영 샘플:

- "새 기록이 U-Map에 작은 단서로 더해졌어요."
- "오늘 Diary가 다음 질문 추천에 작은 힌트가 됩니다."
- "반복되는 표현이 보이면 U-Map 흐름에 천천히 반영됩니다."
- "지금은 가볍게 저장하고, 나중에 다시 살펴볼 수 있어요."
- "기록은 고정된 결론이 아니라 흐름을 보는 재료예요."

금지 문구:

- "Diary 분석 완료"
- "감정 상태가 진단됐어요."
- "문제 원인을 찾았어요."
- "치료가 필요한 신호입니다."

Flutter checklist:

- 저장 완료 snackbar/toast는 짧게 쓴다.
- 상세 안내는 bottom sheet나 inline note로 분리한다.
- "Insight에 사용하지 않기" 또는 기록 숨김 옵션을 검토한다.

## 6. 금지어 / 위험 표현 리스트

절대 금지:

- "분석 완료"
- "정확도"
- "신뢰도"
- "진단"
- "치료"
- "상담"
- "성격유형"
- "유형"
- "진짜 나"
- "운명"
- "궁합"
- "당신은 ~한 사람"
- "정상 / 비정상"
- 병명, 정신건강 라벨, 치료 필요 암시

주의 표현:

- "분석": 법적/정책 문맥이 아니라 UI 핵심 문구에서는 피한다.
- "패턴": 고정 성향처럼 보이면 "흐름"으로 바꾼다.
- "결과": 확정처럼 보이면 "요약" 또는 "단서"로 바꾼다.
- "평가": 사용자를 점수화하는 느낌이 있어 피한다.

## 7. Flutter 화면별 문구 검수 기준

Auth/Onboarding:

- "FI-YOU는 진단이나 유형화가 아니라 기록 기반 자기탐색을 돕습니다." 수준의 짧은 안전 프레임을 넣는다.

Question:

- 정답/검사/유형/정확도 암시 금지.
- 건너뛰기와 자유 입력 제공.

Answer Complete:

- "저장", "단서", "반영" 중심.
- "분석 완료", "확정" 금지.

Insight Detail:

- 수정/숨김/동의하지 않음/근거 보기 필수.
- "AI 판단" 금지.

U-Map:

- 8축 한글명 사용.
- "선명도"는 기록 기준임을 설명.

Diary:

- "저장", "기록", "천천히 반영" 중심.
- 감정/상태 진단 금지.

Empty/Error:

- 사용자 탓처럼 보이지 않게 쓴다.
- "아직 기록이 많지 않아요", "다시 시도" 중심.

## 8. P0 출시 차단 문구 기준

아래 문구가 앱 주요 화면, backend seed, mock data, snackbar, error, report, legal summary에 남아 있으면 출시 차단으로 본다.

- 진단/치료/상담/병명/정신건강 평가처럼 보이는 문구
- MBTI, 성격유형, OO형, OO타입 등 고정 분류 문구
- 정확도/신뢰도/분석 정확도 등 평가 지표 문구
- "당신은 ~한 사람입니다" 형태의 정체성 단정
- "진짜 나", "운명", "궁합" 등 결정론/관계 단정 문구
- 유료 기능이 더 정확한 자기이해를 제공한다는 문구
- 관계 기능에서 상대방의 성향, 의도, 미래 행동을 판단하는 문구
- Empty/Error에서 사용자의 입력 부족을 탓하거나 압박하는 문구

## Flutter App Lead Handoff Checklist

- [ ] 질문 화면에 "정답 없음 / 현재 흐름" 안내가 있다.
- [ ] 답변 완료는 "단서가 더해짐"으로 표현된다.
- [ ] Diary 저장은 "U-Map에 천천히 반영"으로 표현된다.
- [ ] U-Map 8축은 한글명으로 표시된다.
- [ ] U-Map 선명도는 정확도/신뢰도로 설명되지 않는다.
- [ ] Insight 상세에 수정/숨김/동의하지 않음/근거 보기 액션이 있다.
- [ ] Empty/Error 문구가 사용자를 압박하지 않는다.
- [ ] 금지어 검색에서 `분석 완료`, `정확도`, `신뢰도`, `진단`, `유형`, `진짜 나`, `치료`, `상담`, `궁합`이 사용자 노출 copy에 없다.

## Release Copy QA Checklist

Use this after Flutter core flow implementation is complete. This QA is for user-facing copy only: screen text, snackbar/toast, dialog, bottom sheet, empty/loading/error state, store copy, mock data, and hardcoded fallback strings.

### Global Search Gate

P0 fail if any user-facing copy contains:

- `분석 완료`
- `정확도`
- `신뢰도`
- `진단`
- `유형`
- `성격유형`
- `진짜 나`
- `치료`
- `상담`
- `궁합`
- `운명`
- `당신은`
- `확정`
- `판정`

Allowed only inside internal QA docs or explicit "avoid" lists, not in app UI.

Preferred replacements:

| Avoid | Use |
| --- | --- |
| 분석 완료 | 단서가 더해졌어요 |
| 정확도 / 신뢰도 | 기록에서 보이는 정도 / 선명도 |
| 유형 | 흐름 / 단서 |
| 진짜 나 | 현재 기록 / 지금의 탐색 |
| 진단 / 치료 / 상담 | 기록 기반 자기탐색 |
| 궁합 | 관계 안에서 내가 경험한 흐름 |
| 당신은 ~한 사람 | 현재 기록에서는 이런 흐름이 보여요 |

### Auth / Onboarding

QA principle:

- First impression must frame FI-YOU as record-based self-discovery, not a personality test.

Recommended copy:

- "질문과 Diary로 지금의 흐름을 천천히 살펴봐요."
- "FI-YOU는 진단이나 유형화가 아니라 기록 기반 자기탐색을 돕습니다."
- "기록이 쌓이면 U-Map과 표현은 달라질 수 있어요."

Avoid:

- "나의 유형 알아보기"
- "진짜 나 찾기"
- "정확한 나 분석 시작"

Required checks:

- [ ] Onboarding does not promise a result.
- [ ] No MBTI/personality-test framing.
- [ ] User can continue without feeling pressured to disclose sensitive details.

### Home

QA principle:

- Home should show the loop: question -> record -> clue -> U-Map -> repeat.
- It should not look like AI instantly judged the user.

Recommended copy:

- "오늘의 질문"
- "오늘 발견된 단서"
- "현재 기록에서 보이는 흐름"
- "조금씩 선명해지는 U-Map"
- "기록이 쌓이면 달라질 수 있어요."

Avoid:

- "AI 분석 완료"
- "정확한 결과"
- "당신의 성격 리포트"

Required checks:

- [ ] Home card titles use "단서", "흐름", "기록", "U-Map".
- [ ] No "analysis completed" moment after one answer.
- [ ] U-Map progress is not presented as user score.

### Explore / Question Answer Flow / Clue Found Feedback

QA principle:

- Question flow should feel exploratory and low-pressure.
- Clue feedback should be provisional.

Recommended copy:

- "정답이 아니라 지금의 흐름을 남기는 질문이에요."
- "답변이 저장됐어요. 오늘의 U-Map 단서가 하나 더해졌습니다."
- "선택한 답변에서 작은 흐름을 살펴볼 수 있어요."
- "아직 결론은 아니에요. 다음 기록과 함께 달라질 수 있습니다."

Avoid:

- "분석 완료"
- "정확한 결과가 나왔어요."
- "유형이 확정됐어요."
- "AI가 당신을 판단했어요."

Required checks:

- [ ] 2-5 balanced choices.
- [ ] Optional free-text field is optional, not required.
- [ ] Feedback appears as "saved/clue added", not "AI analyzed".
- [ ] Clue card has "동의하지 않음" or route to detail with user controls.

### Diary Write / Diary Saved Feedback

QA principle:

- Diary is the user's record. It should not be treated as clinical evidence.

Recommended copy:

- "Diary가 저장됐어요."
- "반복되는 단서가 있다면 U-Map에 천천히 반영됩니다."
- "한 줄의 기록도 현재의 탐색에 충분한 시작이 됩니다."
- "기록이 쌓이면 표현은 달라질 수 있습니다."

Avoid:

- "Diary 분석 완료"
- "감정 상태가 진단됐어요."
- "문제 원인을 찾았어요."
- "치료가 필요한 신호입니다."

Required checks:

- [ ] Save snackbar/toast is short and non-final.
- [ ] Diary saved feedback does not claim cause, diagnosis, or certainty.
- [ ] User can edit/delete Diary.
- [ ] If available, user can exclude/hide a record from insight use.

### U-Map Detail / Axis Detail

QA principle:

- U-Map is a map of current record-based flow, not fixed personality judgment.
- All 8 axes must use safe Korean labels.

Recommended copy:

- "U-Map은 현재 기록에서 보이는 흐름을 8개 축으로 정리한 지도예요."
- "선명도는 정확도가 아니라 기록에서 단서가 보이는 정도예요."
- "아직 더 기록이 필요한 영역이에요."
- "다음 질문으로 더 살펴볼 수 있어요."

Avoid:

- "정확도"
- "신뢰도"
- "성격유형"
- "이 축은 확정됐습니다."
- "당신은 감정적인 사람입니다."

Required checks:

- [ ] Axis labels: 에너지 리듬, 감정 인식, 가치 기준, 선택 방식, 관계 흐름, 긴장과 회복, 성장 동기, 삶의 방향.
- [ ] Raw keys are not visible to users.
- [ ] Axis detail uses "현재 기록", "단서", "흐름".
- [ ] Relationship axis does not judge the other person.

### Insight Detail

QA principle:

- Insight must be editable, hideable, and rejectable.
- It must show record basis without overclaiming.

Recommended copy:

- "현재 기록에서 이런 단서가 보였어요."
- "근거가 된 기록"
- "이 표현이 맞지 않으면 숨기거나 수정할 수 있어요."
- "동의하지 않음을 선택하면 이후 요약에서 덜 강조됩니다."

Avoid:

- "AI가 판단한 결과입니다."
- "이 단서는 신뢰도가 높습니다."
- "당신은 이런 사람입니다."
- "반드시 이렇게 행동합니다."

Required controls:

- [ ] "내 표현으로 수정"
- [ ] "동의하지 않음"
- [ ] "이 단서 숨기기"
- [ ] "근거 기록 보기"
- [ ] "나중에 다시 보기" or close

### Store / Star

QA principle:

- Store copy must not imply paid features produce more accurate self-understanding.
- Core loop must remain framed as available without pressure.

Recommended copy:

- "Star는 선택형 확장 기능에 사용됩니다."
- "확장 리포트는 기록을 더 긴 호흡으로 정리하는 보기예요."
- "질문과 Diary의 기본 탐색은 계속 이어갈 수 있어요."

Avoid:

- "더 정확한 분석"
- "진짜 나를 더 깊게 알기"
- "결제하면 정확도가 올라갑니다."
- "Star가 없으면 나를 알 수 없습니다."

Required checks:

- [ ] Paid copy says "확장 정리", not accuracy.
- [ ] No urgency/shame pressure.
- [ ] Star shortage copy points back to free question/Diary loop.

### My / Settings / Data Delete

QA principle:

- Settings should reinforce user control over records.
- Delete copy should be clear, calm, and non-manipulative.

Recommended copy:

- "내 기록 관리"
- "저장된 답변과 Diary를 확인하고 관리할 수 있어요."
- "계정 삭제를 요청하면 관련 기록도 함께 처리됩니다."
- "삭제 전 필요한 기록을 먼저 확인해 주세요."

Avoid:

- "삭제하면 분석 정확도가 사라집니다."
- "당신의 진짜 기록이 사라집니다."
- "복구할 수 없으니 신중하세요" without clear specifics.

Required checks:

- [ ] Data delete copy explains what is deleted.
- [ ] No fear-based retention copy.
- [ ] User control language is clear: view, edit, delete, export if available.

### Empty / Loading / Error States

QA principle:

- Empty states reduce pressure.
- Loading states should not say "analyzing the user".
- Error states should reassure and give next action.

Recommended copy:

- "아직 단서를 정리하기에는 기록이 많지 않아요."
- "오늘의 질문이나 Diary 한 줄부터 시작해도 충분합니다."
- "기록을 불러오는 중이에요."
- "기록을 불러오지 못했어요. 저장된 내용은 사라지지 않도록 다시 확인하겠습니다."

Avoid:

- "분석 중"
- "데이터가 부족해 분석할 수 없습니다."
- "정확한 결과를 위해 더 많이 입력하세요."
- "사용자 상태를 확인할 수 없습니다."

Required checks:

- [ ] Loading uses "기록을 불러오는 중", "정리하는 중".
- [ ] Empty state gives a gentle next step.
- [ ] Error state has "다시 시도" or clear recovery action.

### Final Release Copy Sign-Off

Before Android release, PM / Flutter / Insight Safety should confirm:

- [ ] Global Search Gate passes for user-facing copy.
- [ ] Every generated or mock insight has user controls.
- [ ] U-Map is explained as record-based flow.
- [ ] Answer completion does not look like instant AI diagnosis.
- [ ] Store copy does not sell accuracy.
- [ ] Relationship copy is about the user's experience, not the other person's traits.

## Final Correction Criteria After Flutter QA

This section reflects the first Flutter implementation review and should be used as the final copy correction baseline before release QA.

### U-Map 8 Axis Canonical Terms

The following 8 labels are safe and should be the only user-facing U-Map axis labels:

| Key | Canonical Korean Label | Safe Short Meaning |
| --- | --- | --- |
| `energyRhythm` | 에너지 리듬 | 에너지가 차오르고 소모되는 리듬 |
| `emotionAwareness` | 감정 인식 | 감정을 알아차리고 기록하는 방식 |
| `valuesCompass` | 가치 기준 | 선택할 때 놓치고 싶지 않은 기준 |
| `decisionStyle` | 선택 방식 | 결정을 정리하고 납득하는 흐름 |
| `relationshipPattern` | 관계 흐름 | 관계 안에서 편안함과 거리감을 경험하는 흐름 |
| `stressRecovery` | 긴장과 회복 | 부담 신호를 알아차리고 다시 정리하는 방식 |
| `growthMotivation` | 성장 동기 | 계속 움직이게 하는 의미와 진전의 단서 |
| `lifeDirection` | 삶의 방향 | 앞으로 더 자주 만들고 싶은 삶의 감각 |

Do not use these as axis labels in release UI:

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

- Some labels sound like fixed traits or mental-state labels.
- The canonical 8 axes are broader, softer, and less diagnostic.

### P0 Copy/Flow Blockers Before Release

P0 if any user-facing screen, snackbar, modal, mock data, backend seed, or fallback string includes:

- `진단`, `치료`, `상담`, `정신건강 평가`, 병명 또는 병리 라벨
- `성격유형`, `MBTI`, `OO형`, `OO타입`, `유형 확정`
- `정확도`, `신뢰도`, `분석 정확도`
- `분석 완료`
- `진짜 나`, `운명`, `궁합`
- `당신은 ~한 사람입니다`
- 관계 기능에서 상대의 성향, 의도, 미래 행동, 관계 지속 여부를 단정하는 문구
- Store/Star copy that implies payment unlocks more accurate or truer self-understanding
- Question completion that appears to say AI instantly judged the user

### P1 Copy/Flow Fixes Before Release Candidate

P1 if present:

- U-Map labels are not the canonical 8 labels.
- Insight chips use trait-like labels such as `관계지향`, `감정패턴`, `불안 신호`.
- Question CTA or free exploration CTA has a Star badge in a way that implies the core loop costs Stars.
- Question completion clue has no route to `수정`, `숨기기`, `동의하지 않음`, or `신고`.
- U-Map axis detail has no user control for hiding or disagreeing with an axis clue.
- Diary asks for other people's names without privacy guidance.
- Empty/error copy says the user has insufficient data in a blaming or pressuring tone.

### Safe Copy Set For Flutter App Lead

Auth / Onboarding:

- "질문과 Diary 기록으로 현재의 자기탐색 흐름을 차분히 정리해요."
- "FI-YOU는 사람을 단정하지 않고, 기록을 바탕으로 단서와 흐름을 보여주는 앱입니다."
- "기록이 쌓이면 U-Map의 표현은 달라질 수 있어요."

Home:

- "오늘 발견된 단서"
- "현재 기록에서 보이는 흐름"
- "조금씩 선명해지는 U-Map"
- "기록이 쌓이면 달라질 수 있어요."
- "U-Map 반영"

Explore / Question:

- "정답이 아니라 지금의 흐름을 남기는 질문이에요."
- "가장 가까운 답을 골라 주세요."
- "더 적고 싶은 말이 있다면 한 문장만 남겨도 좋아요."
- "답변은 U-Map의 작은 단서로만 사용됩니다."

Question completion:

- "답변이 저장됐어요."
- "오늘의 U-Map 단서가 하나 더해졌습니다."
- "선택한 답변에서 작은 흐름을 살펴볼 수 있어요."
- "아직 결론은 아니에요. 다음 기록과 함께 달라질 수 있습니다."
- CTA: "단서 상세 보기"
- CTA: "U-Map에서 보기"
- CTA: "Diary에 이어쓰기"
- CTA: "다른 질문 이어가기"

Insight detail:

- "현재 기록에서 이런 단서가 보였어요."
- "근거가 된 기록"
- "이 표현이 맞지 않으면 숨기거나 수정할 수 있어요."
- "동의하지 않음을 선택하면 이후 요약에서 덜 강조됩니다."
- "이 단서는 고정된 결론이 아니라 지금까지의 기록 요약이에요."

Insight controls:

- Revise: "내 표현으로 수정"
- Hide: "이 단서 숨기기"
- Disagree: "동의하지 않음"
- Report: "이 단서 신고하기"
- Low-friction quality feedback: "도움되지 않음"

Diary:

- "오늘 남기고 싶은 장면"
- "오늘 오래 남은 장면, 감정, 선택의 이유를 적어보세요."
- "함께 있었던 상황/관계 단서(선택)"
- "실명이나 민감한 정보는 적지 않아도 괜찮아요."
- "Diary가 저장됐어요."
- "반복되는 단서가 있다면 U-Map에 천천히 반영됩니다."

U-Map:

- "U-Map은 현재 기록에서 보이는 흐름을 8개 축으로 정리한 지도예요."
- "선명도는 기록에서 단서가 보이는 정도예요."
- "아직 더 기록이 필요한 영역이에요."
- "질문과 Diary가 더 쌓이면 달라질 수 있어요."

Store / Star:

- "핵심 탐구 흐름은 결제 없이 이어집니다."
- "Star는 선택형 확장 기능에 사용됩니다."
- "확장 리포트는 기록을 더 긴 호흡으로 정리하는 보기예요."
- "Google Play Billing 연결 후 구매 CTA를 활성화합니다."

### Report / Feedback Action Copy Guidance

Recommended visible hierarchy:

1. `내 표현으로 수정`
   - Use when the clue is close but wording feels off.
   - Backend action: `revise`

2. `동의하지 않음`
   - Use when the user does not want this clue emphasized.
   - Backend action: `disagree`

3. `이 단서 숨기기`
   - Use when the user does not want the clue visible.
   - Backend action: `hide`

4. `도움되지 않음`
   - Use as low-friction quality feedback.
   - Safer than "문제 신고" for everyday mismatch.
   - Backend action: `not_helpful`

5. `이 단서 신고하기`
   - Use for harmful, unsafe, privacy-invasive, offensive, diagnostic, or relationship-judging output.
   - More precise than "문제 신고".
   - Backend action: `report`

Avoid as primary copy:

- `문제 신고`

Reason:

- It is broad and can feel alarming. Use `이 단서 신고하기` for actual report and `도움되지 않음` for low-friction feedback.

### Backend Insight Feedback / Report Enum Proposal

Recommended table fields:

- `insight_id`
- `user_id`
- `action`
- `reason`
- `user_note`
- `source_screen`
- `created_at`

Recommended `action` enum:

- `revise`
- `disagree`
- `hide`
- `not_helpful`
- `report`
- `restore`

Recommended `reason` enum:

- `wording_mismatch`
- `not_my_experience`
- `too_strong`
- `too_personal`
- `privacy_sensitive`
- `medical_or_diagnostic`
- `fixed_type_or_label`
- `relationship_judgment`
- `payment_pressure`
- `offensive_or_harmful`
- `unsafe_advice`
- `other`

Report reasons shown to users:

- "내 경험과 달라요"
- "표현이 너무 단정적이에요"
- "개인정보가 걱정돼요"
- "진단이나 판단처럼 느껴져요"
- "관계를 단정하는 것 같아요"
- "불편하거나 안전하지 않아요"
- "기타"

### Question Completion Feedback Safety

Safe completion sequence:

1. Save confirmation:
   - "답변이 저장됐어요."

2. U-Map contribution:
   - "오늘의 U-Map 단서가 하나 더해졌습니다."

3. Soft clue:
   - "현재 기록에서는 이런 흐름이 조금 보였어요."

4. Changeability:
   - "아직 결론은 아니에요. 다음 기록과 함께 달라질 수 있습니다."

5. User control CTAs:
   - "단서 상세 보기"
   - "U-Map에서 보기"
   - "Diary에 이어쓰기"
   - "다른 질문 이어가기"

Avoid:

- "AI가 분석했어요."
- "분석 완료"
- "결과가 나왔어요."
- "유형이 정리됐어요."

### Diary Privacy Copy

For people/situation fields, use:

- Field label: "함께 있었던 상황/관계 단서(선택)"
- Hint: "실명이나 민감한 정보는 적지 않아도 괜찮아요."
- Helper: "이 기록은 내가 그 장면에서 느낀 흐름을 돌아보기 위한 용도예요."

Avoid:

- "함께 있었던 사람"
- "상대 이름"
- "상대의 성격"
- "상대가 왜 그랬는지"

### Store / Star Safety Avoid List

Avoid:

- "더 정확한 분석"
- "진짜 나를 더 깊게 알기"
- "결제하면 정확도가 올라갑니다."
- "Star가 없으면 나를 알 수 없습니다."
- "프리미엄 분석 완료"
- "유료 리포트가 더 신뢰도 높습니다."

Use:

- "선택형 확장 기능"
- "기록을 더 긴 호흡으로 정리"
- "핵심 탐구 흐름은 결제 없이 이어집니다."
- "기본 질문과 Diary는 계속 사용할 수 있어요."
