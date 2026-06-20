# FI-YOU UI Review Checklist

## 0. 목적

이 문서는 Flutter App Lead가 “핵심 사용자 플로우 완성 + UI 완성도 향상” 1차 구현을 마친 뒤, UI Design / Visual System 관점에서 바로 검수하기 위한 체크리스트다.

기준 문서:

- `docs/flutter/home-ui-v2-visual-handoff.md`
- `docs/flutter/core-screens-ui-visual-handoff.md`
- `docs/flutter/release-ui-system-worklist.md`

## 1. 리뷰 원칙

FI-YOU는 MBTI/진단/성격유형 앱이 아니다. 모든 UI는 사용자를 판정하거나 유형화하지 않고, 기록에서 발견되는 단서와 흐름을 조심스럽게 보여줘야 한다.

리뷰 중 가장 먼저 보는 것:

1. 작은 Android 화면에서 깨지지 않는가
2. 카드/박스가 밝은 회색 덩어리처럼 보이지 않는가
3. 한국어 긴 문장이 자연스럽게 줄바꿈되는가
4. CTA 계층이 명확한가
5. Star 재화와 Explore Spark 의미가 분리되는가
6. Bottom Nav 순서와 아이콘이 승인된 기준과 맞는가
7. Safe area, keyboard, bottom nav overlap이 없는가

## 2. P0 / P1 판정 기준

### P0: 출시 전 반드시 수정

- 화면이 overflow, clipped text, render error를 보인다.
- keyboard가 입력창 또는 저장 CTA를 가린다.
- bottom nav가 콘텐츠 또는 CTA를 덮는다.
- Auth/Onboarding/Question/Diary/Store/Settings 핵심 플로우를 완료할 수 없다.
- 한국어 문구가 mojibake로 보인다.
- 주요 CTA가 비활성처럼 보이거나 터치 영역이 44dp 미만이다.
- 카드가 너무 밝아 회색 박스처럼 보인다.
- Star 재화와 Spark 탐구 아이콘이 같은 의미처럼 보인다.
- Bottom Nav 순서가 `홈 / 다이어리 / 탐구 / U-Map / My`가 아니다.
- Explore 탭의 Spark 아이콘이 사라졌거나 Star 재화처럼 보인다.
- 오류/저장 실패 상태에서 사용자의 작성 내용이 사라진 것처럼 보인다.

### P1: 출시 완성도 수정

- 카드 hierarchy가 약해 모든 화면이 같은 박스 반복처럼 보인다.
- 제목/본문/캡션 크기 차이가 부족해 읽기 어렵다.
- glow가 과하거나 우주/판타지 느낌이 강하다.
- 단서/흐름/기록 톤 대신 분석 결과처럼 단정한다.
- skeleton/loading/empty/error 상태가 화면마다 다르게 보인다.
- U-Map 축 상세와 Insight 상세의 정보 구조가 한눈에 잡히지 않는다.
- Store 구매 상태와 사용 내역이 premium service처럼 정돈되어 보이지 않는다.
- Settings destructive action이 너무 약하거나 너무 위협적으로 보인다.

## 3. 공통 Visual System 체크

### 3.1 Color / Surface

P0:

- [ ] 앱 전체 배경은 dark navy 기반이다.
- [ ] 카드 fill은 `surface.base`, `surface.elevated`, `surface.map`, `surface.insight`, `surface.action`, `surface.compact` 계층 중 하나로 보인다.
- [ ] 큰 카드에 white overlay가 과하지 않다.
- [ ] 카드가 밝은 회색 유리판처럼 떠 보이지 않는다.
- [ ] border가 배경과 카드를 분리하지만 너무 강하지 않다.
- [ ] danger red는 삭제/오류에만 쓰이며 full red card로 과장되지 않는다.

P1:

- [ ] U-Map 관련 카드는 `map surface`로 더 깊게 보인다.
- [ ] Insight 관련 카드는 읽기 좋은 `insight surface`로 분리된다.
- [ ] Question/CTA 관련 카드는 cyan signal이 은은히 보인다.
- [ ] Store/Star 영역은 gold가 명확하지만 과한 판매 페이지처럼 보이지 않는다.

### 3.2 Typography / Korean Wrapping

P0:

- [ ] 카드 안 제목은 1-2줄 안에서 자연스럽게 줄바꿈된다.
- [ ] 본문은 3-4줄을 넘으면 상세로 이동하거나 접힌다.
- [ ] 버튼 텍스트가 2줄로 터지지 않는다.
- [ ] chip 텍스트가 줄바꿈되지 않는다.
- [ ] 한국어 문장이 카드 밖으로 넘치지 않는다.

P1:

- [ ] Screen title, section title, body, caption의 크기 계층이 명확하다.
- [ ] 한국어 line-height가 답답하지 않다.
- [ ] 긴 문구를 FittedBox로 과하게 축소하지 않는다.

### 3.3 Buttons / CTA

P0:

- [ ] 화면마다 primary CTA가 하나 명확하다.
- [ ] secondary action은 primary보다 낮은 시각 강도다.
- [ ] destructive action은 red text/outline로 구분된다.
- [ ] disabled CTA는 이유가 문구로 보조된다.
- [ ] 모든 touch target은 44dp 이상, 권장 48dp 이상이다.

P1:

- [ ] Round CTA는 질문 시작/다음 action처럼 특별한 흐름에만 사용된다.
- [ ] Text button 남용으로 화면 action이 흩어지지 않는다.

### 3.4 Icon Meaning

P0:

- [ ] Star 재화는 gold coin/badge/잔액 문맥으로만 쓰인다.
- [ ] Explore Spark는 탐구/발견 의미로만 쓰인다.
- [ ] Store에서 Spark 장식이 Star 재화와 섞이지 않는다.
- [ ] Bottom Nav Explore 탭은 Spark 계열 아이콘을 유지한다.

P1:

- [ ] icon style이 한 화면에서 outline/filled로 무질서하게 섞이지 않는다.
- [ ] decorative spark가 텍스트 읽기를 방해하지 않는다.

### 3.5 Layout / Safe Area

P0:

- [ ] 360dp width에서 모든 핵심 플로우가 완료된다.
- [ ] keyboard open 상태에서 입력 중인 필드와 CTA가 보인다.
- [ ] bottom nav가 마지막 카드/CTA를 덮지 않는다.
- [ ] status bar / navigation gesture area와 UI가 겹치지 않는다.
- [ ] scrollable 화면의 bottom padding이 충분하다.

P1:

- [ ] 주요 카드 간 spacing이 16-22dp 범위로 안정적이다.
- [ ] 카드 내부 padding이 화면마다 일관된다.

## 4. Bottom Nav 검수

승인 기준:

1. `홈`
2. `다이어리`
3. `탐구`
4. `U-Map`
5. `My`

P0:

- [ ] 순서가 위 기준과 같다.
- [ ] 탐구 탭은 Spark / 별빛 계열 아이콘이다.
- [ ] Star 재화 아이콘과 탐구 Spark 아이콘이 혼동되지 않는다.
- [ ] active tab은 purple 계열 chip/glow/text로 구분된다.
- [ ] inactive tab은 muted text/icon이다.
- [ ] nav height는 72-78dp 수준이며 safe area를 포함한다.

P1:

- [ ] active glow가 과하지 않다.
- [ ] label이 작은 화면에서도 읽힌다.

## 5. 화면별 체크리스트

## 5.1 Auth / Onboarding / Launch Gate

P0:

- [ ] Launch gate가 splash에서 멈추지 않는다.
- [ ] Auth 첫 화면이 FI-YOU premium dark navy 톤과 맞는다.
- [ ] 로그인 입력창, Google login, loading, error 상태가 있다.
- [ ] 약관/개인정보 링크가 작지만 읽을 수 있다.
- [ ] Onboarding에서 FI-YOU가 진단 앱이 아니라 기록 기반 discovery 앱임을 설명한다.
- [ ] name input에서 keyboard가 CTA를 가리지 않는다.
- [ ] Auth/Onboarding 한국어 문구가 깨지지 않는다.

P1:

- [ ] Onboarding은 3-step 또는 single scroll 중 하나로 명확하다.
- [ ] U-Map preview가 과한 우주 그래픽이 아니라 map/signal 느낌이다.

## 5.2 Home

P0:

- [ ] Home 진입 시 가장 먼저 Greeting과 U-Map Progress가 보인다.
- [ ] U-Map Progress 카드가 밝은 회색 박스처럼 보이지 않는다.
- [ ] Today Insight, Next Question, Daily Activity 카드가 서로 다른 역할의 surface로 구분된다.
- [ ] Star badge는 gold 재화로 보이고 spark와 혼동되지 않는다.
- [ ] 작은 화면에서 U-Map 카드 텍스트가 잘리지 않는다.

P1:

- [ ] U-Map card의 node/orbit 장식이 절제되어 있다.
- [ ] Home의 CTA 우선순위가 `질문 시작` 또는 `U-Map 보기` 중심으로 명확하다.

## 5.3 Explore / Question Answer Flow / Clue Found Feedback

### Explore

P0:

- [ ] Explore는 탐구 시작/이어가기 역할이 분명하다.
- [ ] Spark 아이콘이 탐구 의미로 유지된다.
- [ ] Insight feed와 Question entry가 구분된다.

P1:

- [ ] unclear axis shortcuts가 U-Map과 연결되는 느낌을 준다.

### Question Answer Flow

P0:

- [ ] 선택형, 서술형, 복합형이 모두 overflow 없이 작동한다.
- [ ] 질문 본문은 2-4줄 내에서 자연스럽다.
- [ ] 선택지는 최소 56dp 높이이며 터치하기 쉽다.
- [ ] selected state가 명확하다.
- [ ] 서술형 입력에서 keyboard가 저장 CTA를 가리지 않는다.
- [ ] 저장 실패 시 작성 내용이 남아 있다는 안내가 보인다.

P1:

- [ ] “정답이 아니라 가까운 쪽” 톤이 유지된다.
- [ ] progress strip이 사용자의 위치를 알려준다.

### Clue Found Feedback

P0:

- [ ] “결과 발표”가 아니라 “새 단서 발견” 톤이다.
- [ ] U-Map 반영 축이 표시된다.
- [ ] primary action과 secondary action이 분명하다.

P1:

- [ ] success spark/glow가 과하지 않다.

## 5.4 Diary Home / Write / Detail

### Diary Home

P0:

- [ ] empty state가 첫 기록을 자연스럽게 유도한다.
- [ ] diary item은 date/title/body preview가 읽힌다.
- [ ] floating/add CTA가 bottom nav와 겹치지 않는다.

### Diary Write

P0:

- [ ] title optional, body required 구조가 명확하다.
- [ ] body input은 충분히 크고 keyboard 대응이 된다.
- [ ] save CTA가 항상 접근 가능하다.
- [ ] save failed state에서 작성 내용 보존 안내가 있다.

### Diary Detail

P0:

- [ ] edit/delete actions가 있다.
- [ ] delete는 confirmation sheet를 거친다.
- [ ] linked question/insight가 있다면 구분되어 표시된다.

P1:

- [ ] 긴 Diary 본문이 읽기 좋은 line-height로 표시된다.

## 5.5 U-Map Detail / Axis Detail / Data 부족 상태

P0:

- [ ] 데이터 부족 상태가 실패처럼 보이지 않는다.
- [ ] `기록이 쌓이면 U-Map이 선명해져요` 톤이 유지된다.
- [ ] U-Map overview와 axis list가 구분된다.
- [ ] 8개 축이 작은 화면에서 과밀하지 않다.

P1:

- [ ] Axis detail은 clarity, recent signals, record flow, next question을 포함한다.
- [ ] 축별 근거가 “판정 근거”가 아니라 “기록 흐름”으로 보인다.
- [ ] U-Map은 점수판이 아니라 지도처럼 보인다.

## 5.6 Insight Detail

P0:

- [ ] 단서 요약, 기반 데이터, U-Map 반영 축이 보인다.
- [ ] 수정하기 / 숨기기 / 동의하지 않음 action이 있다.
- [ ] 동의하지 않음은 feedback action으로 보이며 destructive delete처럼 보이지 않는다.
- [ ] “확정된 판단이 아니에요” 톤이 유지된다.

P1:

- [ ] 기반 데이터 카드가 source/date/excerpt를 명확히 보여준다.
- [ ] action sheet가 조용하고 신뢰감 있다.

## 5.7 Store / Star

P0:

- [ ] Star balance가 gold 재화로 명확하다.
- [ ] Star와 Spark 의미가 분리된다.
- [ ] 구매 중 / 결제 확인 중 / 성공 / 실패 / 복원 상태가 있다.
- [ ] 실패 상태는 retry와 설명을 제공한다.
- [ ] mock 결제 상태가 release build에 노출되지 않는다.

P1:

- [ ] 패키지 카드 hierarchy가 명확하다.
- [ ] 사용 내역이 premium service처럼 정돈되어 있다.
- [ ] Store가 과한 판매 페이지처럼 보이지 않는다.

## 5.8 My / Settings

### My

P0:

- [ ] My는 개인 탐구 요약과 설정 진입을 구분한다.
- [ ] profile, U-Map, Insight, Star shortcuts가 읽힌다.

### Settings

P0:

- [ ] 알림, 개인정보, 약관, 로그아웃, 계정삭제가 section으로 구분된다.
- [ ] 로그아웃 confirmation이 있다.
- [ ] 계정삭제/데이터삭제는 destructive confirmation이 있다.
- [ ] destructive action은 full red fill이 아니라 red text/outline 중심이다.

P1:

- [ ] 법적 문서 화면은 긴 텍스트 읽기에 적합하다.
- [ ] 알림 권한 off 상태 copy가 있다.

## 5.9 공통 Loading / Empty / Error / Save Failed

P0:

- [ ] 각 주요 화면에 empty/loading/error 상태가 있다.
- [ ] loading은 skeleton 또는 calm indicator를 사용한다.
- [ ] error는 retry CTA를 제공한다.
- [ ] save failed는 작성 내용 보존 안내를 제공한다.
- [ ] 상태 화면이 사용자 탓으로 읽히지 않는다.

P1:

- [ ] 상태 카드의 icon, title, body, CTA hierarchy가 일관된다.
- [ ] empty state가 다음 행동을 부드럽게 안내한다.

## 6. 리뷰 진행 순서

1. 360dp width Android 에뮬레이터에서 전체 플로우 확인
2. Auth → Onboarding → Home 진입
3. Bottom Nav 순서와 active state 확인
4. Explore → Question 선택형/서술형/복합형 확인
5. Clue Found feedback 확인
6. Diary 작성 → 저장 실패 mock → 상세 → 수정 → 삭제 확인
7. U-Map 데이터 부족 / 데이터 있음 / Axis detail 확인
8. Insight detail actions 확인
9. Store 구매 상태 / 실패 / 복원 / 내역 확인
10. My / Settings destructive action 확인
11. Loading / Empty / Error / Save Failed 전수 확인

## 7. 리뷰 리포트 형식

각 이슈는 다음 형식으로 기록한다.

```text
[Priority] P0/P1/P2
[Screen] 화면명
[Issue] 무엇이 문제인지
[Expected] FI-YOU 기준에서 기대하는 모습
[Evidence] 스크린샷 또는 재현 경로
[Design Note] 관련 visual token / copy / component 기준
```

예:

```text
[Priority] P0
[Screen] Diary Write
[Issue] 키보드가 열린 상태에서 저장 버튼이 bottom nav 뒤로 가려짐
[Expected] keyboard inset 반영, 저장 버튼은 항상 접근 가능해야 함
[Evidence] 360dp emulator, body input focus
[Design Note] Android 작은 화면 기준: CTA 48dp 이상, keyboard overlap 금지
```

## 8. 최종 승인 기준

P0가 모두 해결되어야 내부 출시 QA로 넘길 수 있다.

P1은 출시 전 최대한 해결하되, 일정상 남길 경우 PM/Design/App Lead가 명시적으로 accept해야 한다.

P2는 출시 후 polish로 이동 가능하다.

FI-YOU의 최종 UI는 “차분하고 신뢰감 있는 기록 기반 self-discovery 앱”이어야 한다. 사용자가 판정받는 느낌보다, 자신의 기록에서 단서를 발견하고 U-Map이 조금씩 선명해지는 감각을 받아야 한다.
