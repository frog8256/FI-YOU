# My Universe Pre-Launch Core Loop QA

Generated: 2026-06-24

## Executive Summary

Final verdict: **READY_WITH_MINOR_FIXES**

The core loop is technically working end to end in real Supabase mode:

Explore -> Card -> Answer -> Memory -> Insight -> Story -> Return to Explore

Live QA completed a real authenticated Supabase session, answered 50 exploration cards, verified insight/story refresh, verified persisted rows, and confirmed both Insight Feed and Story Feed return 200 responses and render in Flutter integration tests.

The system is not blocked by engine correctness. The remaining beta risks are experience polish and philosophy alignment:

- User-facing copy still contains forbidden/assessment-adjacent words.
- Story Feed and some feed section titles are still English in an otherwise Korean experience.
- Live card response does not expose `time_axis` in the returned card object, which limits UI/performance observability.
- Card phrasing is coherent but template-shaped; after 50 cards it can start to feel repetitive.
- Opposite-node traversal remains very low in simulation, even though all graph success criteria pass.

## Technical QA

### Local Flutter Verification

- `flutter analyze`: PASS
- `flutter test`: PASS
- Unit/widget coverage confirmed:
  - Explore entry loads first card in mock mode.
  - `binary_choice`, `multiple_choice`, `priority_selection`, `scenario_choice` render and can be answered.
  - `priority_selection` enforces required selection count.
  - Continue button is disabled before selection and enabled after selection.
  - Empty optional note submits successfully.
  - Optional note is limited to 300 characters.
  - Answer submission loads the next card.
  - Load failure shows retry UI.
  - Submit failure preserves answer and allows retry.
  - Node names, categories, and analysis metadata are not exposed in Explore card UI.

### Live Supabase API Verification

Authenticated user:

- Supabase Auth session created successfully.
- 50 live exploration cards delivered and answered through Edge Functions.
- `deliver-exploration-card`: PASS
- `answer-exploration-card`: PASS
- `insight-feed`: 200 PASS
- `story-feed`: 200 PASS

Refresh behavior observed:

- Insight refresh occurred via `ten_card_interval`.
- Story refresh occurred via `insight_change`.
- Later non-due responses correctly returned `not_due`.

Persistence observed through authenticated REST reads:

- `user_card_history`: 79 rows
- answered history: 79 rows
- `user_insights`: 23 rows
- active `user_stories`: 2 rows

### Live Flutter E2E

- `integration_test/insight_feed_supabase_e2e_test.dart`: PASS
- `integration_test/story_feed_supabase_e2e_test.dart`: PASS

Note: running both Android integration tests in parallel caused a Gradle `copyFlutterAssetsDebug` asset-copy conflict. Re-running Story Feed E2E alone passed. Treat this as a test execution constraint, not an app defect.

## Experience QA

50 cards were completed in live Supabase mode.

Observed distribution:

- `scenario_choice`: 20
- `multiple_choice`: 15
- `priority_selection`: 10
- `binary_choice`: 5

The delivery distribution feels aligned with the intended exploration cadence. The user does see varied nodes and card types, and the system does not get stuck.

Experience concerns:

- The fallback card prompt pattern is consistent but repetitive: many cards follow the shape `[node description] 지금의 나에게는 어떤 장면으로 떠오르나요?`
- Option sets are also template-like, especially for scenario and priority cards.
- This still feels closer to exploration than a personality test, but after 50 cards it risks feeling like a refined survey unless generated card wording becomes more varied.
- The journey transitions are technically natural because the graph keeps moving, but the UI does not expose enough narrative transition between cards to make the graph movement feel alive.

Recommendation: keep production logic, but improve card text generation/fallback variety before public beta.

## Insight QA

Insight generation passed the core rules:

- Insights are generated only after sufficient answer history.
- Live feed returned 8 active insights.
- Feed API returned 200.
- Flutter UI rendered persisted insights.
- No score/ranking/personality-type structure was observed in the feed contract.

Experience/philosophy concerns:

- Some insight titles were Korean, while one title was English: `Several areas are beginning to connect`.
- Mixed-language feed output weakens the calm journal-like experience.
- Evidence exists, but the UI currently presents the insight without much visible explanation of why it appeared. That is acceptable for private beta, but less ideal for public trust.

Recommendation: localize all generated insight titles/feed section labels and keep supporting evidence available without making the screen feel analytical.

## Story QA

Story generation passed the core rules:

- Story refresh occurred after insight changes.
- Story Feed API returned 200.
- Active `user_stories` rows exist.
- Flutter Story Feed E2E rendered persisted stories.
- Stories require at least 3 supporting insights.

Current active story types observed:

- `current_chapter`
- `emerging_direction`

Story content is gentle and non-diagnostic, but it is currently English:

- `Current Chapter`
- `Emerging Direction`
- `Recent exploration seems...`

This is not a logic blocker, but it is a product-experience blocker for a Korean beta. It reads less like a personal journal and more like an internal prototype surface.

Recommendation: localize story titles, feed sections, and narrative descriptions before broad public beta.

## Content Audit

Scope: `mobile/fi_you/lib/**/*.dart`

Forbidden/user-facing terms found: 11 occurrences.

### Direct Philosophy Risks

- `mobile/fi_you/lib/mock/fi_you_mock_data.dart:297`
  - `My Universe는 진단하거나 확정하지 않아요`
- `mobile/fi_you/lib/features/my/my_screen.dart:35`
  - `진단 결과가 아니라 지금까지의 기록에서 보이는 자기탐색 흐름입니다.`
- `mobile/fi_you/lib/features/onboarding/onboarding_flow_screen.dart:408`
  - `질문은 사용자를 분류하거나 진단하지 않아요...`
- `mobile/fi_you/lib/features/onboarding/onboarding_flow_screen.dart:880`
  - `...분류하거나 진단하기 위한 것이 아니에요...`

These are intended as reassurance, but the task explicitly forbids the word `진단`. Replace with softer language such as `확정하지 않아요`, `정답을 정하지 않아요`, or `탐험의 단서로만 다룹니다`.

### Technical/Hierarchy Language Risks

- `mobile/fi_you/lib/features/umap/u_map_screen.dart:606`
  - `상위 노드로 돌아가기`
- `mobile/fi_you/lib/features/umap/u_map_screen.dart:862`
  - `상위 노드를 선택하면 하위 성향 노드가 열려요.`
- `mobile/fi_you/lib/features/umap/u_map_screen.dart:1026`
  - `현재 지도는 10개의 상위 카테고리로 시작해요... 실제 분석 데이터에서 생성된 하위 성향 노드...`
- `mobile/fi_you/lib/features/umap/u_map_screen.dart:1147`
  - `하위 성향 노드의 평균값...`
- `mobile/fi_you/lib/features/umap/u_map_screen.dart:1342`
  - `...하위 성향 노드가 생기고...`
- `mobile/fi_you/lib/features/home/home_screen.dart:664`
  - `10개 노드의 대표 하위노드`
- `mobile/fi_you/lib/features/home/home_screen.dart:813`
  - `10개의 노드에서 지금 가장 선명한 하위 신호예요.`

These terms make the experience feel like a model/debug surface. Replace user-facing `상위/하위` with exploratory words such as `큰 영역`, `작은 신호`, `이어지는 단서`, `세부 흐름`.

## Graph QA

Fresh simulation run completed:

- Users: 100
- Cards delivered: 20,000
- Child node coverage: 100%
- Unique child nodes explored: 300/300
- Dead nodes: 0
- Hot nodes: 0
- Loop rate: 0%
- Repeated node frequency: 1.95%
- Parent max deviation: 0.38%

Criteria:

- Coverage > 95%: PASS
- Dead nodes = 0: PASS
- Hot nodes = 0: PASS
- Loop rate < 5%: PASS
- Parent variance < 2%: PASS

Graph usage:

- related: 22.89%
- bridge: 68.19%
- opposite: 0.40%
- none: 8.51%

The graph is healthy and balanced, but contrast exploration is underused. This does not block beta, but it may make journeys feel smoother than they are meaningful.

Recommendation: later tune contrast boost carefully, without changing the delivery engine's core logic or creating hot nodes.

## Empty State QA

Covered by current UI/tests:

- Loading state for Story Feed.
- Empty/retry states for Explore card loading.
- Feed screens can render without persisted rows.

Remaining manual QA need:

- Brand-new user with no answers.
- User with fewer than 10 answers and no insight.
- User with fewer than 25 answers and no story.
- User with many answers but temporarily unavailable feed API.

Current risk: empty states appear functional, but some copy still leans technical or English in story/feed areas.

## Performance QA

Live API timings from 50-card run:

### Auth

- Supabase Auth sign-in: 1,249 ms

### Card Delivery

- min: 421 ms
- avg: 558.1 ms
- p95: 675 ms
- max: 1,175 ms

### Answer Submit

- min: 460 ms
- avg: 707.1 ms
- p95: 1,267 ms
- max: 3,697 ms

### Feed Loads

- Insight Feed: 840 ms
- Story Feed: 765 ms

Assessment:

- Card delivery performance is healthy.
- Answer submit is acceptable but has a noticeable tail, likely when insight/story refresh work is triggered.
- Feed loads are acceptable for beta.
- No infinite loading or dead-end state was observed.

Recommendation: add lightweight timing logs around refresh paths later. Do not block beta unless answer p95 rises above 2 seconds consistently.

## Release Blockers

### Critical

None found.

### High

Issue: Story Feed live output is English in a Korean product.

Impact: The story experience feels like an internal prototype rather than a personal journal.

Recommendation: localize story titles, section labels, and narrative templates.

Priority: High

Issue: Forbidden/user-facing assessment language remains in app copy.

Impact: The product can still feel like it is distancing itself from diagnosis while repeatedly invoking diagnostic framing.

Recommendation: replace `진단`, `상위`, `하위`, and `분석 데이터` style phrases in visible copy.

Priority: High

### Medium

Issue: Card fallback wording becomes repetitive over 50 cards.

Impact: Exploration can drift toward survey-like interaction.

Recommendation: expand fallback prompt/option variants and ensure the external Exploration Card Engine is configured in production.

Priority: Medium

Issue: Opposite traversal is only 0.40%.

Impact: Journeys may underuse tension/contrast, making the graph feel overly smooth.

Recommendation: later apply a small contrast boost after repeated related/bridge moves, then rerun simulation.

Priority: Medium

Issue: `time_axis` is not exposed on the delivered `card` object in the live API response.

Impact: UI and QA tooling cannot directly verify time-axis variety from card payload alone.

Recommendation: expose `time_axis` in the card response or update tooling to read `payload.time_axis`.

Priority: Medium

### Low

Issue: Android integration tests conflict when run in parallel.

Impact: CI or local runs may fail if multiple Flutter integration tests build the same debug target simultaneously.

Recommendation: run Flutter Android integration tests sequentially or isolate build directories.

Priority: Low

Issue: Flutter Android plugins emit KGP migration warning.

Impact: Not currently failing, but future Flutter versions may make this a build blocker.

Recommendation: track plugin upgrades for `device_info_plus`, `package_info_plus`, `passkeys_android`, `shared_preferences_android`, and `ua_client_hints`.

Priority: Low

## Final Recommendation

**READY_WITH_MINOR_FIXES**

My Universe's core loop works technically in production-like Supabase mode. The delivery engine, answer submission, memory persistence, insight refresh, story refresh, feed APIs, Flutter UI, and graph simulation all pass the functional bar.

The product should not be widened to a public beta until the High items are addressed, especially Korean localization of Story Feed and removal of forbidden/assessment-adjacent copy. After those copy/localization fixes, the system is ready for a private beta and close to public beta readiness.
