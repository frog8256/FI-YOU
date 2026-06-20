# FI-YOU Cardless Visual Refinement Guidance

## 0. 목적

현재 FI-YOU Android 앱은 화면마다 카드가 연속으로 쌓이는 인상이 강하다. 이번 라운드는 사용자가 매일 쓰는 self-discovery 앱처럼 더 편안하고, 목적 중심적이며, 고급스럽게 보이도록 화면 구조를 재정리하는 UI/Visual System 가이드다.

코드 수정 전 Flutter App Lead가 구현 방향을 바로 잡을 수 있도록 화면별 hierarchy, component 사용 기준, cardless/full-width 전환 지점, spacing과 typography 기준을 정리한다.

## 1. 공통 Visual Direction

### 1.1 유지할 원칙

- 다크 네이비 기반 premium self-discovery 서비스
- 과한 우주/판타지 금지
- Signal, Node, Discovery, Map 느낌
- Glow는 active, focus, Star balance, 주요 CTA에만 최소 사용
- 카드 남발 금지
- 기록이 쌓이면서 U-Map이 선명해진다는 목적을 우선
- 매일 쓰는 앱처럼 편안하고 밀도 있게

### 1.2 카드 사용 기준

카드가 필요한 곳:

- 사용자가 선택하거나 눌러야 하는 독립 action
- 다른 정보와 분리되어야 하는 상태 요약
- 결제, 설정, 삭제 등 명확한 행 단위가 필요한 곳
- Insight, U-Map axis처럼 하나의 객체를 표현하는 경우

카드를 줄여야 하는 곳:

- 화면의 첫 인사/타이틀 영역
- 글쓰기 입력 영역
- 설명이 긴 안내 영역
- 같은 목적의 작은 정보가 여러 개 반복되는 영역
- 단순 label/value 묶음

대체 패턴:

- cardless section
- full-width band
- inline row
- divider list
- compact metric rail
- bottom sheet
- sticky action bar

### 1.3 Surface 사용 규칙

- `background.base`: 전체 화면
- `surface.map`: U-Map 핵심 영역, 단 큰 카드 남발 금지
- `surface.insight`: Insight/단서 객체
- `surface.action`: 질문/탐구 CTA
- `surface.compact`: list row 또는 small summary
- `surface.nav`: bottom nav

카드가 많아 보이면 fill을 줄이기보다, 먼저 카드 수를 줄인다.

### 1.4 Spacing / Typography

권장:

- Page horizontal padding: 22dp
- Section gap: 22-28dp
- Related item gap: 10-14dp
- Card padding: 16-20dp
- Card radius: 18-22dp
- Large card radius: 24dp 이하
- Screen title: 24-26sp
- Section title: 17-18sp
- Body: 14-15sp
- Caption/meta: 12-13sp

주의:

- `bodySmall 11sp`는 한국어에서 최소화한다.
- 긴 문구는 카드 안에서 3줄 이상 늘리지 않는다.
- fixed height card 안에 긴 한국어를 넣지 않는다.
- Bottom Nav가 있는 화면은 마지막 콘텐츠와 nav 사이 48dp clearance를 유지한다.

## 2. Home

### 2.1 Visual Direction

Home은 “오늘 내가 어디서 이어가면 되는지”가 보여야 한다. U-Map을 크게 보여주는 showcase 화면이 아니라, 매일 진입하는 조용한 dashboard가 되어야 한다.

핵심 변화:

- U-Map 카드 축소
- Level / Star / Profile 동선 정리
- Diary 작성 유도 추가
- Header 버튼 상태와 터치 피드백 명확화
- 카드 수를 줄이고 section 간 역할을 분명히 나눔

### 2.2 Layout Hierarchy

권장 순서:

```text
Header: FI-YOU + 알림 + 프로필
Greeting / Level row: User님 + Level + Star
Compact U-Map status
Today action rail: Diary 쓰기 / 질문 이어가기
Today Insight preview
Daily Activity compact summary
```

### 2.3 U-Map 축소안

기존 대형 U-Map 카드는 720x1280에서 너무 많은 첫 화면 공간을 차지한다.

권장:

- 높이: 168-196dp
- 그래프: 92-118dp
- 텍스트: `U-Map 선명도 14%`, `Lv.2 탐험가`
- CTA: `U-Map 보기`
- 배경 orbit/node는 1-2개만 사용
- 카드 내부 설명문은 2줄 이하

구조:

```text
[small map visual]  U-Map 선명도 14%
                    Lv.2 탐험가
                    아직 발견되지 않은 흐름이 남아 있어요.
                    [U-Map 보기]
```

### 2.4 Level / Star / Profile 동선

Header와 Greeting 사이에 compact status row를 둔다.

```text
안녕하세요, User님
[Lv.2 탐험가] [150 Star] [프로필]
```

주의:

- Star는 gold pill
- Level은 purple/cyan tonal chip
- Profile은 avatar/icon button
- Profile 진입과 Settings 진입을 혼동하지 않도록 Profile은 My로, Settings는 My 하단에서 진입

### 2.5 Diary 작성 유도

Home에 Diary 작성 유도는 필요하지만, 또 하나의 큰 카드가 되면 안 된다.

권장: action rail 또는 compact full-width row

```text
오늘의 기록을 남겨볼까요?
짧은 장면 하나도 U-Map의 단서가 돼요.
[Diary 쓰기]
```

형태:

- `surface.action` 얇은 band
- 높이 76-92dp
- 좌측 icon, 중앙 copy, 우측 CTA
- 카드 radius 18dp

### 2.6 Header Button

Glass icon button 상태:

- default: border subtle, icon muted
- pressed: fill 8-12% 증가
- unread notification: 6dp purple/cyan dot
- profile incomplete: small accent dot
- touch target: 44-48dp

### 2.7 Home 구현 우선순위

P0:

- U-Map card 높이 축소
- Diary action rail 추가
- Bottom Nav overlap 제거

P1:

- Header button state
- Level / Star / Profile row 정리
- Insight preview card density 조정

## 3. Diary

### 3.1 Visual Direction

Diary는 “폼을 채우는 화면”이 아니라 “오늘의 장면을 쓰는 조용한 canvas”여야 한다. 박스형 입력 필드를 여러 개 쌓는 구조를 피한다.

핵심 변화:

- Home의 중복 작성 박스 제거
- 작성 상세는 writing canvas 중심
- 제목 입력 추가
- 감정 선택 제거
- 본문 영역 최우선
- 함께 있었던 사람 유지
- 하단 안내 문구와 저장 버튼 배치
- 익일 오전 9시 수정 제한 표시

### 3.2 Diary Home

Home에 Diary 작성 유도 rail이 생기면 Diary Home의 중복 작성 박스는 제거한다.

Diary Home 구조:

```text
Page title: Diary
Today quick entry button
Recent diary list
Empty state if needed
```

`Today quick entry`는 큰 카드가 아니라 compact button row로 둔다.

### 3.3 Diary Write Layout

권장 구조:

```text
Top bar: 닫기 / 오늘의 기록 / 저장 상태
Title input
Writing canvas
Together field
Edit limit note
Sticky bottom: helper text + save button
```

### 3.4 Writing Canvas

본문 영역은 박스형 card 안에 넣지 않는다.

권장:

- 배경과 같은 dark navy
- 내부에 아주 약한 border bottom 또는 focused line만 사용
- min height: 280dp
- keyboard open 시 canvas가 자연스럽게 줄어들거나 스크롤
- hint: `오늘 남기고 싶은 장면을 편하게 적어보세요.`

Title input:

- single line
- placeholder: `제목을 붙인다면`
- body보다 작은 visual weight
- 선택 입력

Together field:

- label: `함께 있었던 사람`
- chip input 또는 simple text input
- placeholder: `혼자, 친구, 가족, 동료 등`

감정 선택:

- 이번 라운드에서는 제거
- 감정은 AI가 기록에서 단서로 읽어낼 수 있다는 톤 유지

### 3.5 하단 안내 / 저장

권장 sticky action bar:

```text
작성한 내용은 내일 오전 9시 전까지 수정할 수 있어요.
[저장]
```

스타일:

- background: backgroundBase 92-96% + top border
- helper text 12-13sp muted
- save button 52dp
- keyboard open 시 keyboard 위로 이동

### 3.6 익일 오전 9시 수정 제한

표시 위치:

- 작성 화면 하단 helper
- 상세 화면 meta row

Copy:

```text
내일 오전 9시 전까지 수정할 수 있어요.
수정 가능 시간이 지나면 기록은 U-Map 단서로 고정돼요.
```

Visual:

- clock icon
- muted cyan
- card가 아니라 inline notice

### 3.7 Diary 구현 우선순위

P0:

- Writing canvas 전환
- 제목 입력 추가
- 감정 선택 제거
- 저장 CTA keyboard/nav overlap 제거

P1:

- 수정 제한 표시
- 함께 있었던 사람 입력 정리
- Diary Home 중복 작성 박스 제거

## 4. Explore

### 4.1 Visual Direction

Explore는 추상적인 탐구 홍보 화면이 아니라 “오늘 어떤 탐구를 이어갈지 고르는 화면”이어야 한다.

핵심 변화:

- Hero 박스 제거
- 탐구 흐름 카드를 덜 추상적으로 재구성
- 자유 탐구 30 Star CTA를 탐구 흐름 아래 배치
- 오늘의 탐구 추천을 그 아래 배치
- 무료 버튼 제거

### 4.2 Layout Hierarchy

권장 순서:

```text
Page title: 탐구
Current flow section
Free exploration CTA: 30 Star
Today recommendation
Recent clues / insight feed
```

### 4.3 Hero 제거

큰 hero card는 제거한다. 대신 title 아래 짧은 subtitle과 current flow section으로 바로 진입한다.

```text
탐구
오늘 이어갈 질문을 선택해 보세요.
```

### 4.4 탐구 흐름 재구성

추상적인 U-Map flow graphic보다 실제 상태를 보여준다.

```text
최근 이어진 흐름
관계 장면에서 감정이 먼저 올라오는 패턴을 보고 있어요.

완료한 질문 12
발견된 단서 5
열릴 준비 중인 축 3
```

형태:

- full-width section
- 필요 시 하나의 compact card
- 숫자 metric은 inline row
- 그래픽은 작은 node line 정도만 사용

### 4.5 자유 탐구 30 Star CTA

위치:

- 탐구 흐름 바로 아래
- 오늘의 추천 질문보다 위

형태:

```text
자유 탐구
지금 떠오르는 주제로 질문을 열어요.
[30 Star] [시작]
```

주의:

- 무료 버튼 제거
- Star 사용 CTA이므로 gold를 쓰되 결제 상품처럼 보이지 않게 한다.
- Star chip은 작게, CTA는 cyan/purple action으로 유지

### 4.6 오늘의 탐구 추천

자유 탐구 아래에 배치한다.

```text
오늘의 탐구 추천
갈등 상황에서 나는 어떤 반응을 보일까?
예상 3-5분
[질문 시작]
```

### 4.7 Explore 구현 우선순위

P0:

- Hero card 제거
- 무료 버튼 제거
- 자유 탐구 30 Star CTA 위치 변경

P1:

- 탐구 흐름 section 구체화
- 오늘의 추천 density 조정
- Spark/Star 의미 분리

## 5. U-Map

### 5.1 Visual Direction

U-Map은 앱의 정체성을 보여주되, 그래프 하나에 모든 의미를 넣지 않는다. 상단은 compact overview, 아래는 축별 요약 list로 목적을 분리한다.

핵심 변화:

- 공유 아이콘 추가
- 축별 요약을 세로 리스트 카드 1개로 정리
- 각 축 우측 chevron
- 축 상세 bottom sheet/section 제안
- Growth Map, Relation-Map, Report를 Star 소비 콘텐츠로 배치
- Empty copy `단서가 부족해요.`와 아이콘 align

### 5.2 Layout Hierarchy

```text
Header: U-Map + share
Compact graph overview
Axis summary list card
Star content section: Growth Map / Relation-Map / Report
Empty or data 부족 state
```

### 5.3 Header Share Icon

- 위치: page title row trailing
- icon: share/outbound
- touch target 44dp
- disabled state가 필요하면 muted icon + tooltip copy
- share sheet 준비 전이라도 사용자에게 `공유 준비중`이라고 쓰지 않는다.

권장 disabled copy:

```text
공유할 수 있는 요약이 아직 충분하지 않아요.
```

### 5.4 Axis Summary List

8축을 여러 카드로 나누지 말고 하나의 list card로 묶는다.

Card title:

```text
8개 축 요약
```

Row:

```text
[node] 탐색
       새로운 질문에 반응하는 흐름
       기록 12개 · 최근 반영 오늘
                              chevron
```

Row 기준:

- min height 64-72dp
- divider 1dp alpha 40%
- chevron muted
- selected/strong axis만 subtle purple/cyan dot

Canonical 8축:

```text
탐색 / 관계 / 회복 / 표현 / 선택 / 몰입 / 갈등 / 성장
```

### 5.5 Axis Detail

1차 구현 권장: bottom sheet

이유:

- U-Map overview 맥락을 유지한다.
- 상세 화면 전환보다 가볍다.
- 작은 화면에서 한 축의 정보만 집중해서 보여주기 쉽다.

Bottom sheet 구조:

```text
Axis name + clarity
최근 단서
관련 기록 흐름
다음 질문 제안
[이 축 더 탐구하기]
```

Visual:

- modal surface
- top handle
- max height 80-88% screen
- 내부 scroll
- CTA bottom safe area 반영

2차 확장:

- Axis full detail screen
- evidence timeline
- related diary/question list

### 5.6 Star 소비 콘텐츠 배치

Growth Map, Relation-Map, Report는 U-Map의 하단 premium section으로 묶는다.

Section title:

```text
심화 지도
```

Items:

```text
Growth Map       40 Star
Relation-Map     40 Star
Report           80 Star
```

Style:

- Store 상품처럼 보이지 않게 한다.
- U-Map 기반 심화 콘텐츠로 표현한다.
- disabled면 lock icon + `단서가 더 필요해요.`

### 5.7 Empty State

Copy:

```text
단서가 부족해요.
질문과 Diary 기록이 쌓이면 U-Map이 조금씩 선명해집니다.
```

Visual:

- icon과 title baseline align
- icon size 28-32dp
- card가 아니라 compact state block 권장
- CTA: `질문 시작하기` 또는 `Diary 쓰기`

### 5.8 U-Map 구현 우선순위

P0:

- 옛 라벨 제거
- canonical 8축 정리
- 축 리스트를 하나의 card로 통합

P1:

- share icon 추가
- axis detail bottom sheet
- Star content section 배치

## 6. My

### 6.1 Visual Direction

My는 설정 목록이 아니라 사용자의 FI-YOU 프로필과 진행 상태를 보여주는 공간이어야 한다. Settings는 하단 이동 버튼으로 분리한다.

핵심 변화:

- 프로필 카드 중심
- `관찰과 탐구를 좋아하는`
- `User 님`
- `Level 3 / Star 130`
- 설정은 하단 이동 버튼으로 분리

### 6.2 Layout Hierarchy

```text
Profile card
Level / Star / U-Map clarity
Recent self-discovery summary
Shortcuts
Settings button at bottom
```

### 6.3 Profile Card

구조:

```text
[avatar]
관찰과 탐구를 좋아하는
User 님

[Level 3] [130 Star]
```

Style:

- 한 개의 중심 card
- background: surface.map 또는 surface.elevated
- avatar는 과한 glow 없이 subtle purple/cyan ring
- Star chip은 gold
- Level chip은 purple/cyan

### 6.4 Settings 이동 버튼

Settings 항목을 My 상단에 섞지 않는다.

하단:

```text
[설정으로 이동]
```

형태:

- full-width tonal button
- icon: settings
- height 52dp
- bottom nav clearance 48dp

### 6.5 My 구현 우선순위

P0:

- Settings와 profile summary 역할 분리
- bottom nav overlap 제거

P1:

- profile card copy 정리
- Level/Star visual hierarchy
- recent summary compact화

## 7. 구현 우선순위

### P0

1. Bottom Nav overlap 방지 공통 padding 유지
2. Home U-Map card 축소
3. Diary writing canvas 전환
4. Explore hero card 제거 및 무료 버튼 제거
5. U-Map 옛 라벨 제거, canonical 8축 적용
6. My profile/settings 역할 분리

### P1

1. Home Diary action rail 추가
2. Header button states 정리
3. Explore current flow section 구체화
4. U-Map axis bottom sheet
5. Store/Star와 Explore Spark 의미 분리 유지
6. Settings/My 하단 clearance 재검수

### P2

1. U-Map share flow polish
2. Axis evidence timeline
3. Diary 수정 제한 microcopy refinement
4. Home activity summary density 조정
5. My recent summary personalization

## 8. Flutter 구현 형태 요약

### 공통

- `FiYouPageScroll`: bottom nav padding 산식 유지
- `SectionHeader`: cardless section title
- `CompactActionRail`: Home Diary, Explore free exploration
- `AxisListCard`: U-Map 8축 묶음
- `WritingCanvas`: Diary body input
- `StickyActionBar`: Diary save / keyboard 대응
- `ProfileSummaryCard`: My 중심 카드

### Cardless 우선 적용

- Home greeting
- Explore page intro
- Diary write canvas
- U-Map graph overview 주변 설명
- My settings 이동 영역

### Card 유지

- Home compact U-Map status
- Today Insight preview
- U-Map axis list wrapper
- My profile summary
- Store package rows
- Settings section list

## 9. 재검수 기준

720x1280에서 확인한다.

- 첫 화면이 카드 3개 이상 연속으로 보이면 density를 다시 조정한다.
- Home 첫 화면에서 U-Map card가 전체를 과도하게 차지하면 fail이다.
- Diary Write에서 본문 canvas보다 보조 입력/안내가 더 강하면 fail이다.
- Explore 첫 화면에 큰 hero card가 남아 있으면 fail이다.
- U-Map 축이 여러 개의 독립 카드로 흩어져 있으면 fail이다.
- My 첫 화면에서 Settings list가 profile보다 먼저 보이면 fail이다.
- 마지막 콘텐츠와 Bottom Nav 사이 48dp clearance가 없으면 fail이다.

