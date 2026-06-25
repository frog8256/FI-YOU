# FI-YOU Common Control Visual System

Scope: Android 1차 출시 준비 기준으로 현재 화면 구성과 큰 카드 Liquid Glass 값은 유지한다. 이 문서는 작은 컨트롤만 고정한다.

## 1. Trailing `>` Button

기준: Home 화면 `Diary 작성하기` 액션의 trailing chevron.

- 공통 컴포넌트: `FiYouChevronButton`
- visual size: `32 x 32`
- icon: `Icons.chevron_right_rounded`
- icon size: `20`
- radius: `FiYouGlass.glassRadiusSmall` (`18`)
- surface: 기존 Liquid Glass v5 `FiYouGlass.decoration(...)`
- color: 화면 의미색을 허용하되, 기본은 `FiYouGlass.textSoft`
- press: 단독 액션이면 `onPressed`를 연결하고, 카드 전체가 눌리는 구조면 chevron은 표시 전용으로 둔다.

금지:
- raw `Icon(Icons.chevron_right_rounded)`만 trailing에 두지 않는다.
- `30`, `42`, `44` 등 화면별 임의 chevron 박스 크기를 만들지 않는다.
- 큰 카드의 padding/radius/glass preset을 chevron 통일 목적으로 바꾸지 않는다.

## 2. Icon Box

공통 컴포넌트: `FiYouIconTile`

- medium leading: `42 x 42`, icon `20`, spark `22`
- small metric/axis: `32 x 32`, icon `17`
- xsmall inline status: `22 x 22`, icon `13`
- list row icon: `38 x 38`, icon `20`
- radius: 기본 `18`, 축/초소형처럼 공간이 좁은 경우에만 `12` 허용

적용 원칙:
- Home 주요 카드 leading은 medium.
- Home activity, U-Map axis compact tile은 small.
- Home inline task/status는 xsmall.
- My insight row는 list row.
- 프로필 아바타, 로고, Star 재화 배지는 이 토큰의 강제 대상이 아니다.

## 3. Buttons

기준: My 화면 하단 `Settings` 버튼.

- 공통 컴포넌트: `FiYouSettingsActionButton` 또는 직접 `FiYouLiquidButton`
- regular: height `52`, font `14`, icon `18`, radius `18`
- CTA: height `58`, font `16`, icon `18`, radius `18`
- pill: height `38`, font `13`, radius `999`
- disabled: `FiYouLiquidButton`의 opacity/disabled state를 사용한다.

금지:
- `BackdropFilter + InkWell + Container`로 버튼을 새로 만들지 않는다.
- 버튼마다 별도 fill, border, glow 값을 만들지 않는다.
- CTA 위치, 문구, 라우팅을 버튼 스타일 통일 목적으로 바꾸지 않는다.

허용 예외:
- 로그아웃/삭제 같은 destructive action은 같은 Liquid button 물성을 쓰되 foreground color만 danger로 둔다.
- Star 가격/잔액은 의미색 gold를 텍스트와 아이콘에만 사용한다.

## 4. Android Capture QA

검수 해상도:
- 기본: `720 x 1280`
- 보조: `360 x 800 logical`

체크 포인트:
- 모든 trailing `>`가 같은 visual size로 보이는지 확인한다.
- 카드 안 leading icon box가 화면마다 갑자기 커지거나 작아 보이지 않는지 확인한다.
- 버튼은 My `Settings`와 같은 liquid press/stretch/glow 물성으로 보이는지 확인한다.
- 작은 화면에서 버튼 텍스트가 1줄 ellipsis 처리되고 nav와 겹치지 않는지 확인한다.
- 큰 카드/박스의 배치, radius, padding, Liquid Glass v5 preset이 이번 작업으로 바뀌지 않았는지 확인한다.

## 5. Current Follow-up Items

- Settings logout은 foreground danger를 유지한 `FiYouSettingsActionButton` 변형으로 치환하는 것이 다음 후보이다.
- Diary FAB가 FloatingActionButton 기본 물성으로 남아 있으면, 위치는 유지하고 내부 button surface만 `FiYouLiquidButton` 계열로 맞춘다.
- Explore/U-Map/Diary의 임의 `height: 52`, `fontSize: 14` 버튼은 새 코드 작성 시 `FiYouControlTokens`를 사용한다.
