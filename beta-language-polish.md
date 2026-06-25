# My Universe Beta Language Polish

Generated: 2026-06-24

## Summary

Beta language polish is complete for the user-facing Flutter experience and local Edge Function copy templates.

Goal:

- Make the product feel like self-exploration.
- Avoid personality-test, assessment, diagnosis, report, or analytics language.
- Keep business logic and core engines unchanged.

Verification:

- Flutter user-facing forbidden-language scan: 0 matches in `mobile/fi_you/lib/**/*.dart`
- `flutter analyze`: PASS
- `flutter test`: PASS
- Deno CLI was not available in this environment, so Edge Function unit tests were not run locally.

## Replaced Phrases

### Flutter Screens

- `My Universe는 진단하거나 확정하지 않아요`
  -> `My Universe는 단정하지 않고 함께 탐험해요`

- `분석내용`
  -> `탐험의 흐름`

- `진단 결과가 아니라 지금까지의 기록에서 보이는 자기탐색 흐름입니다.`
  -> `지금까지의 기록에서 보이는 자기탐색의 흔적입니다.`

- `질문은 사용자를 분류하거나 진단하지 않아요...`
  -> `질문은 사용자를 한 가지 모습으로 고정하지 않아요...`

- `고정된 유형`
  -> `고정된 모습`

- `상위 노드`
  -> `큰 영역`

- `하위 성향 노드`
  -> `작은 성향 신호`

- `실제 분석 데이터`
  -> `기록에서 이어진 작은 성향 신호`

- `분석 흐름`
  -> `탐험 흐름`

- `아직 확정된 분석`
  -> `아직 고정된 결론`

### Explore / Insight / Story Entry Points

- `Things Becoming Clearer`
  -> `조금씩 선명해지는 방향`

- `See gentle observations from your recent exploration.`
  -> `최근 탐험에서 떠오른 발견을 살펴보세요.`

- `My Story`
  -> `나의 이야기`

- `Read the quieter chapters forming from your exploration.`
  -> `탐험에서 이어지는 조용한 장을 읽어보세요.`

## Removed Analysis Language

Removed from Flutter user-facing copy:

- 분석
- 분석 결과
- 평가
- 진단
- 유형
- 성격 유형
- 점수
- 등급
- 상위
- 하위
- 검사
- 결과 리포트
- 프로파일

Replacement language used:

- 탐험
- 흐름
- 모습
- 선택
- 방향
- 이야기
- 발견
- 장면
- 연결
- 변화
- 흔적
- 우주

## Story Feed Localization

Applied in Edge Function response, Flutter fallback parsing, and Story UI labels:

- `Current Chapter`
  -> `현재의 장`

- `Emerging Direction`
  -> `선명해지는 방향`

- `Internal Tension` / `Tensions`
  -> `함께 나타나는 두 흐름`

- `Hidden Territory` / `Unexplored Territory`
  -> `아직 조용한 영역`

- `Change Over Time`
  -> `변화의 흔적`

- `Story Thread`
  -> `이어지는 이야기`

Raw story type ids remain internal values only and are not exposed in the UI.

## Insight Feed Language

Updated Insight Feed UI:

- Loading:
  - `탐험의 흐름을 정리하고 있어요...`
  - `최근 카드에서 이어진 발견을 차분히 모으고 있어요.`

- Empty:
  - `조금 더 탐험하면 흐름이 보이기 시작할 거예요.`
  - `카드를 몇 장 더 지나면 반복해서 나타나는 방향이 이곳에 머물기 시작합니다.`

- Error:
  - `잠시 흐름을 불러오지 못했어요.`
  - `다시 시도하면 탐험의 흐름을 이어서 볼 수 있어요.`

Updated mock insight content to Korean discovery-oriented language.

## Story Feed Language

Updated Story Feed UI:

- Loading:
  - `탐험의 조각을 이야기로 엮고 있어요...`
  - `최근에 이어진 흐름을 차분한 장면으로 정리하고 있어요.`

- Empty:
  - `조금 더 탐험하면 이야기가 모습을 갖출 거예요.`
  - `카드가 더 쌓이면 흩어진 선택들이 하나의 장처럼 읽히기 시작합니다.`

- Error:
  - `잠시 이야기를 불러오지 못했어요.`
  - `다시 시도하면 이어지던 장면을 불러올 수 있어요.`

Updated Story Engine generated titles/descriptions to Korean journal-like narrative copy.

## API-Generated Copy

Updated:

- `supabase/functions/story-feed/index.ts`
- `supabase/functions/insight-feed/index.ts`
- `supabase/functions/_shared/story-engine.ts`
- `supabase/functions/_shared/insight-engine.ts`
- `supabase/functions/deliver-exploration-card/index.ts`

Changes:

- Story Feed API now returns Korean section labels and feed title.
- Insight Feed API now returns Korean section labels and feed title.
- Story Engine generated copy is Korean and reflective.
- Insight Engine supporting node names are sanitized before entering user-visible insight output.
- Card delivery output sanitizes fallback/generated question and option labels before returning to the client.

## Mock Content

Updated mock feed/story content so local/mock mode matches beta language:

- Insight feed title: `최근 탐험`
- Story feed title: `나의 이야기`
- Mock insight titles/descriptions localized.
- Mock story titles/descriptions localized.
- Supporting insight/node labels localized.

## Tests Updated

Updated tests to assert the new beta language:

- `mobile/fi_you/test/insight_feed_repository_test.dart`
- `mobile/fi_you/test/insight_feed_screen_test.dart`
- `mobile/fi_you/test/story_feed_repository_test.dart`
- `mobile/fi_you/test/story_feed_screen_test.dart`

## Remaining Concerns

Internal Human Model and Node Relationship Map data still contain original node names such as `자기평가`, `분석성`, and related relationship references. These are core graph/model labels and were not renamed to avoid changing relationship-map behavior.

Mitigation added:

- Card questions/options are sanitized before API response.
- Insight supporting node labels are sanitized before feed output.
- Story supporting insight labels are sanitized before feed output.
- Flutter feed parsing sanitizes remote text again before display.

Recommended later:

- Create a display-label layer for nodes, separate from engine identifiers.
- Keep engine ids stable while replacing public node labels with exploration-first language.
- Deploy updated Edge Functions before beta so live API output matches local QA.

## Final QA

Commands run:

- `flutter analyze`
- `flutter test`
- User-facing Flutter forbidden-language scan

Results:

- `flutter analyze`: PASS
- `flutter test`: PASS
- Flutter user-facing forbidden-language scan: PASS, 0 matches
- Edge Function local Deno tests: not run, Deno CLI unavailable

Final status: beta language polish is ready for app-side QA and Edge Function deployment.
