# FI-YOU P1 Layout Revalidation Guidance

## 0. 목적

이 문서는 QA 재검수에서 남은 P1 UI/UX 이슈를 해결하기 위한 Flutter layout 수정 지시문이다.

대상 이슈:

- Home, Explore 등에서 Bottom Nav overlap 지속
- 720x1280 작은 화면에서 Onboarding CTA가 첫 viewport에 보이지 않아 진행이 불안정함
- U-Map 상단 그래프와 Home 일부에 옛 라벨이 잔존함

이번 라운드의 목표는 모든 핵심 화면이 720x1280 Android 기준에서 안정적으로 읽히고, 마지막 카드/CTA가 Bottom Nav와 겹치지 않으며, U-Map 축 라벨 정책을 하나로 정리하는 것이다.

## 1. Bottom Nav Overlay 해결안

### 1.1 구조 원칙

Bottom Nav는 overlay다. 따라서 각 탭 화면의 scroll content가 Bottom Nav 영역을 모르는 상태로 렌더링되면 반드시 overlap이 재발한다.

다음 정책을 공통 컴포넌트로 강제한다.

- Bottom Nav가 있는 모든 tab root screen은 같은 scroll wrapper를 사용한다.
- 화면별 임시 `SizedBox(height: ...)`로 해결하지 않는다.
- 마지막 카드/CTA와 nav top 사이에 최소 48dp clearance를 확보한다.
- keyboard가 없는 일반 상태와 keyboard open 상태를 분리해서 계산한다.

### 1.2 권장 상수

```dart
const double kFiYouPageHorizontalPadding = 22;
const double kFiYouBottomNavHeight = 78;
const double kFiYouBottomNavOuterMargin = 14;
const double kFiYouBottomNavClearance = 48;
const double kFiYouMinScrollableBottomPadding = 140;
```

`kFiYouBottomNavClearance`는 QA 기준값이다. 마지막 콘텐츠의 visual bounds가 nav bounds와 겹치지 않을 뿐 아니라, 시각적으로 독립되어 보이기 위한 최소 여백이다.

### 1.3 Bottom Padding 산식

Bottom Nav overlay가 있는 화면:

```dart
double fiYouBottomOverlayPadding(BuildContext context) {
  final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
  return max(
    kFiYouMinScrollableBottomPadding,
    kFiYouBottomNavHeight +
        kFiYouBottomNavOuterMargin +
        safeBottom +
        kFiYouBottomNavClearance,
  );
}
```

권장 적용:

```dart
ListView(
  padding: EdgeInsets.fromLTRB(
    kFiYouPageHorizontalPadding,
    topPadding,
    kFiYouPageHorizontalPadding,
    fiYouBottomOverlayPadding(context),
  ),
  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
  children: children,
)
```

주의:

- 기존 `bottom: 128`은 720x1280에서 부족할 수 있다.
- Android gesture nav safe area가 24dp 안팎이면 필요한 bottom padding은 `78 + 14 + 24 + 48 = 164dp`다.
- 따라서 실제 최소값은 160-172dp 범위로 잡는 것이 안전하다.

### 1.4 Nav Bounds 충돌 판정 기준

QA에서는 다음 기준으로 fail 처리한다.

```text
lastContentBottom > bottomNavTop - 48dp
```

즉 마지막 카드, CTA, list item, destructive action의 하단이 nav top보다 최소 48dp 위에 있어야 한다.

예시:

```text
screen height: 1280
safe bottom: 24
nav height: 78
nav margin bottom: 14
nav bottom: 1280 - 24 - 14 = 1242
nav top: 1242 - 78 = 1164
last content max bottom: 1164 - 48 = 1116
```

720x1280 QA에서 마지막 콘텐츠가 y=1116보다 아래에 있으면 overlap 위험으로 본다.

### 1.5 App Shell 정책

App Shell에서 Bottom Nav 위치는 다음 구조를 권장한다.

```dart
Stack(
  children: [
    Positioned.fill(child: currentTabScreen),
    Positioned(
      left: 22,
      right: 22,
      bottom: MediaQuery.viewPaddingOf(context).bottom + 14,
      child: FiYouBottomNavigation(...),
    ),
  ],
)
```

탭 화면은 App Shell의 nav 위치를 직접 알지 않는다. 대신 공통 `FiYouPageScroll`이 `fiYouBottomOverlayPadding(context)`를 적용한다.

### 1.6 Keyboard 화면 예외

Question text, Diary write, Onboarding name input처럼 keyboard가 열리는 화면은 Bottom Nav가 없는 full-screen flow로 취급하는 것을 권장한다.

만약 Bottom Nav가 있는 상태에서 input을 다뤄야 한다면:

```dart
final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;
final bottomPadding = keyboardBottom > 0
    ? keyboardBottom + 24
    : fiYouBottomOverlayPadding(context);
```

Sticky CTA는 다음 기준을 지킨다.

- keyboard closed: safe bottom + 20 이상
- keyboard open: keyboard top + 16 이상
- CTA height: 52dp
- CTA와 keyboard/nav가 겹치면 P0로 본다.

## 2. 공통 컴포넌트 정책

### 2.1 FiYouPageScroll

`FiYouPageScroll`은 Bottom Nav overlay가 있는 화면의 유일한 기본 scroll wrapper여야 한다.

필수 옵션:

```dart
class FiYouPageScroll extends StatelessWidget {
  const FiYouPageScroll({
    required this.children,
    this.topPadding = 20,
    this.hasBottomNav = true,
    this.extraBottomPadding = 0,
  });
}
```

정책:

- `hasBottomNav == true`: `fiYouBottomOverlayPadding(context) + extraBottomPadding`
- `hasBottomNav == false`: `MediaQuery.viewPaddingOf(context).bottom + 28 + extraBottomPadding`
- Store/Settings처럼 긴 리스트는 `extraBottomPadding: 16` 허용
- 화면별 마지막 spacer는 제거하거나 16dp 이하의 시각 여백으로만 사용

### 2.2 Fixed Height 금지 영역

720x1280에서 다음 영역은 fixed height를 피한다.

- Onboarding hero
- U-Map graph section
- Home U-Map summary card
- Store package list
- Settings section list

고정 높이가 필요하면 `ConstrainedBox`와 `Flexible` 조합을 사용한다.

권장:

```dart
ConstrainedBox(
  constraints: const BoxConstraints(maxHeight: 260),
  child: ...
)
```

금지:

```dart
SizedBox(height: 360)
```

### 2.3 카드 하단 CTA 정책

카드 내부 CTA는 카드 하단 padding을 포함해 최소 20dp 여백을 유지한다.

- Primary CTA height: 52dp
- Round CTA size: 56-64dp
- CTA 주변 최소 여백: 16dp
- 카드 마지막 요소가 CTA라면 카드 외부 하단과 nav top 사이 clearance 48dp 필수

## 3. 720x1280 화면별 체크리스트

### 3.1 Auth

P1 통과 기준:

- FI-YOU 로고/타이틀/핵심 카피/CTA가 첫 viewport 안에 보인다.
- CTA가 하단 gesture area와 최소 24dp 떨어져 있다.
- `Mock`, `.mock`, `예시`, `준비 상태` 문구가 보이지 않는다.
- 에러 카드가 뜬 상태에서도 CTA가 viewport 밖으로 밀리지 않는다.

권장 레이아웃:

- top padding 48 이하
- brand block 120-150dp
- main card 내부 padding 20
- CTA는 card 하단 또는 sticky bottom 중 하나만 사용

### 3.2 Onboarding

P1 통과 기준:

- 첫 단계에서 headline, 핵심 카피, name input, primary CTA가 첫 viewport 안에 보인다.
- keyboard open 시 input과 CTA가 동시에 보인다.
- hero/preview가 CTA를 밀어내지 않는다.
- 720x1280에서 스크롤이 필요하더라도 CTA가 없어진 것처럼 보이면 fail이다.

권장 레이아웃은 4장을 따른다.

### 3.3 Home

P1 통과 기준:

- Greeting과 U-Map summary가 첫 viewport에서 자연스럽게 시작된다.
- 마지막 Daily Activity 카드 하단이 nav top보다 48dp 이상 위에 있다.
- Home 하단 캡처에서 nav 뒤에 카드 텍스트가 비치지 않는다.
- 옛 라벨 또는 이전 U-Map 그래프 라벨이 보이지 않는다.

조정 기준:

- U-Map card graph max size: 220-240dp
- Home top visual block은 720x1280에서 과도하게 길지 않게 한다.
- Daily Activity 카드 이후 공통 bottom padding 외 임시 큰 spacer를 두지 않는다.

### 3.4 Explore

P1 통과 기준:

- Explore hero, status, 추천 질문이 순서대로 읽힌다.
- 추천 질문 카드 또는 마지막 mode card가 nav 뒤에 들어가지 않는다.
- Spark 아이콘은 유지하되 Star 재화처럼 보이지 않는다.
- 3열 mode grid가 좁으면 2열 또는 세로 list로 전환한다.

권장 responsive rule:

```dart
final isShortScreen = MediaQuery.sizeOf(context).height <= 1280;
final useCompactExploreModes = MediaQuery.sizeOf(context).width <= 720;
```

720x1280에서는 Explore mode를 3열 카드보다 compact list로 보여주는 것을 권장한다.

### 3.5 U-Map

P1 통과 기준:

- 상단 그래프가 headline/subtitle을 밀어내지 않는다.
- 8축 라벨 정책이 canonical하게 정리되어 있다.
- 마지막 axis card 또는 data 부족 CTA가 nav 뒤에 들어가지 않는다.
- 상단 그래프 라벨에 옛 라벨이 보이지 않는다.

권장:

- 그래프 내부 축 라벨 제거
- 아래 `8축 카드/list`에서 canonical label 표시
- graph max size: 260dp
- axis list item min height: 64dp

### 3.6 Store

P1 통과 기준:

- Balance card와 package list가 첫 viewport에서 안정적으로 보인다.
- disabled package card가 clickable처럼 보이지 않는다.
- Store 마지막 사용 내역 row가 nav 뒤에 들어가지 않는다.
- Billing 미연동 상태에서 `예시`, `출시 전`, `준비 상태` 문구가 보이지 않는다.

권장:

- disabled package card alpha는 낮추되 text contrast는 유지한다.
- CTA 자리에는 `현재 이용 불가` chip을 사용한다.
- 긴 안내문은 2줄 이하로 줄이고 자세한 내용은 상태 카드로 분리한다.

### 3.7 Settings

P1 통과 기준:

- 법무/계정/삭제 섹션이 nav 또는 gesture area에 걸리지 않는다.
- 마지막 destructive row 아래에 48dp clearance가 보인다.
- confirmation sheet 버튼이 safe area 위에 있다.
- `.mock` fallback email이 보이지 않는다.

권장:

- Settings는 `extraBottomPadding: 16` 적용
- destructive section은 마지막에 두되 nav와 충분히 분리
- legal section row min height 56dp

## 4. Onboarding CTA 첫 화면 미노출 해결안

### 4.1 추천 방향

FI-YOU 톤에는 과한 sticky footer보다 `compact hero + visible CTA + gentle scroll affordance` 조합이 가장 적합하다.

권장 구조:

```text
SafeArea
  ScrollView
    Brand mini header
    Title / philosophy copy
    3 compact principle rows
    Name input card
    Primary CTA
    Scroll affordance or helper copy
```

CTA는 첫 viewport 안에 보여야 한다. 단, keyboard가 열렸을 때만 CTA를 keyboard 위 sticky 형태로 보조한다.

### 4.2 Onboarding 높이 예산

720x1280 기준 첫 viewport 사용 예산:

```text
top safe/status area: 40-56
brand mini header: 52
title/copy: 96-120
principle rows: 156-180
input card: 92-112
CTA + helper: 72-88
section gaps total: 72-88
bottom safe: 24
total target: 604-720
```

첫 화면에서 CTA가 보이지 않는다면 다음 순서로 줄인다.

1. hero/preview illustration 제거 또는 80dp 이하로 축소
2. philosophy copy를 2줄 이하로 축약
3. 3개 feature card를 큰 카드가 아니라 compact row로 전환
4. CTA를 input card 바로 아래 배치
5. keyboard open 상태에서만 sticky CTA 적용

### 4.3 Onboarding 금지 패턴

- 큰 U-Map preview가 name input과 CTA를 아래로 밀어내는 구조
- 3개 onboarding feature를 각각 큰 card로 쌓는 구조
- 첫 단계부터 긴 철학 문구를 4줄 이상 보여주는 구조
- CTA가 스크롤 아래 있다는 것을 알 수 없는 구조

### 4.4 권장 카피 축약

Title:

```text
나를 발견하는 흐름을 준비해요.
```

Body:

```text
FI-YOU는 기록과 질문에서 단서를 모아 U-Map을 선명하게 만들어갑니다.
```

Feature rows:

```text
질문: 가벼운 선택부터 시작해요.
Diary: 오늘의 장면을 짧게 남겨요.
U-Map: 반복되는 흐름을 지도처럼 정리해요.
```

CTA:

```text
시작하기
```

## 5. U-Map 그래프 라벨 정책

### 5.1 UI 관점 추천

추천안: 상단 그래프에서는 축 라벨을 제거하고, 아래 카드/list에서만 canonical 8축을 보여준다.

이유:

- 720x1280에서 그래프 주변 라벨은 겹침과 잔존 라벨 문제를 만들기 쉽다.
- FI-YOU의 U-Map은 진단표가 아니라 기록 기반 지도이므로, 상단 그래프는 overview visual로 두는 편이 더 적합하다.
- canonical 8축은 아래 카드/list에서 설명과 함께 보여야 이해가 쉽다.
- 옛 라벨 잔존 문제를 구조적으로 없앨 수 있다.

### 5.2 상단 그래프 역할

상단 그래프는 다음만 표현한다.

- 현재 U-Map clarity
- 기록이 쌓이는 node/flow
- selected axis가 있다면 subtle highlight
- 라벨 없는 map preview

그래프 안 또는 주변에 텍스트 라벨을 넣지 않는다.

### 5.3 Canonical 8축 표시 위치

8축은 그래프 아래에서 카드/list로 보여준다.

Canonical 8축:

```text
탐색
관계
회복
표현
선택
몰입
갈등
성장
```

각 축 카드 구조:

```text
[axis icon/node] 축 이름
              최근 단서 요약 1줄
              기록 n개 · 최근 반영 날짜
              clarity/progress bar
```

### 5.4 Home U-Map 카드 라벨

Home에서는 8축 전체를 보여주지 않는다.

권장:

- `강한 흐름: 탐색`
- `관찰 중: 회복`

Home에서 옛 라벨이 보이는 경우 전부 canonical 8축 중 하나로 교체한다.

### 5.5 라벨을 그래프에 유지해야 할 경우

만약 제품 요구상 그래프에 라벨이 꼭 필요하면 다음 조건을 지킨다.

- 라벨은 canonical 8축만 사용
- 720x1280에서는 라벨 숨김
- 1080x2400 이상에서만 4개 이하 primary label 표시
- label collision 방지
- maxLines 1, ellipsis 금지, 짧은 2글자 축 이름만 사용

하지만 UI Design 관점 최종 추천은 라벨 제거다.

## 6. Flutter Lead 작업 지시 요약

### P1 Layout Fix

- `FiYouPageScroll`에 bottom nav overlay padding 산식을 공통 적용한다.
- Bottom Nav가 있는 탭 화면의 bottom padding을 최소 160dp 이상으로 만든다.
- 마지막 콘텐츠와 nav top 사이 48dp clearance QA 기준을 적용한다.
- Settings, Store처럼 긴 화면은 `extraBottomPadding: 16`을 허용한다.
- keyboard 화면은 Bottom Nav 없는 full-screen flow로 분리하거나 keyboard inset을 sticky CTA에 반영한다.

### Small Screen Fix

- 720x1280에서 Auth/Onboarding/Home/Explore/U-Map/Store/Settings를 필수 캡처한다.
- Onboarding은 hero/preview를 축소하고 CTA를 첫 viewport 안에 배치한다.
- Explore 3열 mode grid는 작은 화면에서 compact list로 전환한다.
- U-Map graph는 max 260dp로 제한한다.
- 긴 제목과 본문은 fixed height card 안에 넣지 않는다.

### U-Map Label Fix

- 상단 U-Map graph 라벨은 제거한다.
- canonical 8축은 그래프 아래 card/list에서만 보여준다.
- Home의 `강한 흐름`, `관찰 중` 값은 canonical 8축 중 하나만 사용한다.
- 옛 라벨이 남아 있는 mock data, graph painter, home summary copy를 전부 audit한다.

## 7. 재검수 캡처 기준

저장 경로:

```text
mobile/fi_you/screenshots/p1_layout_revalidation/720x1280/
mobile/fi_you/screenshots/p1_layout_revalidation/1080x2400/
```

필수 캡처:

```text
01_auth.png
02_onboarding_first_viewport.png
03_onboarding_keyboard.png
04_home_top.png
05_home_bottom_nav_clearance.png
06_explore_top.png
07_explore_bottom_nav_clearance.png
08_umap_top_graph.png
09_umap_axis_list_bottom.png
10_store_disabled_packages.png
11_store_bottom_nav_clearance.png
12_settings_bottom_legal_delete.png
```

PNG 검증:

```powershell
python - <<'PY'
from pathlib import Path
root = Path("mobile/fi_you/screenshots/p1_layout_revalidation")
for p in sorted(root.rglob("*.png")):
    ok = p.read_bytes()[:8] == b"\x89PNG\r\n\x1a\n"
    print(("OK  " if ok else "BAD "), p)
PY
```

모든 파일이 `OK`여야 UI 검수 가능하다.

