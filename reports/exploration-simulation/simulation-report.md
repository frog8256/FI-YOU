# Exploration Simulation Report

## Summary

- Generated: 2026-06-24T05:23:12.531Z
- Users: 100
- Cards delivered: 20000
- Child node coverage: 100%
- Dead nodes: 0
- Loop rate: 0%

## Coverage

- Unique child nodes explored: 300/300
- Repeated node frequency: 1.95%
- Hot nodes: 0

## Parent Distribution

- 자아상: 10.03%
- 행동패턴: 10.38%
- 삶의 방향: 9.99%
- 성격: 9.93%
- 가치관: 10.36%
- 동기: 10.02%
- 감정패턴: 9.9%
- 스트레스 반응: 9.75%
- 인간관계: 9.63%
- 의사결정: 10.02%

## Depth Distribution

- Depth 1: 2.59%
- Depth 2: 25.5%
- Depth 3: 70%
- Depth 4: 1.91%
- Depth 5: 0%

## Card Type Distribution

- scenario_choice: 40.17%
- multiple_choice: 30.06%
- priority_selection: 19.94%
- binary_choice: 9.83%

## Time Axis Distribution

- present: 40.38%
- past: 9.66%
- future: 9.9%
- repeated_pattern: 14.95%
- imagined_scenario: 25.1%

## Top Nodes

- 소속 동기 (동기): 110 (0.55%)
- 감정 민감도 (감정패턴): 107 (0.53%)
- 감정 표현력 (감정패턴): 106 (0.53%)
- 인정 욕구 (인간관계): 106 (0.53%)
- 진정성 (가치관): 105 (0.53%)
- 압박 민감도 (스트레스 반응): 105 (0.53%)
- 감정 의존도 (의사결정): 105 (0.53%)
- 외향성 (성격): 102 (0.51%)
- 내향성 (성격): 102 (0.51%)
- 지속성 (행동패턴): 101 (0.51%)

## Dead Nodes

- None

## Loop Detection

- Total loops: 0
- Loop rate: 0%

## Graph Usage

- related: 22.89%
- bridge: 68.19%
- opposite: 0.4%
- none: 8.51%
- start: 0%

## Archetype Summaries

- Explorer: 13 users, 99.67% child coverage, top parents 의사결정 10.38%, 감정패턴 10.31%, 자아상 10.27%
- Builder: 13 users, 100% child coverage, top parents 가치관 10.69%, 삶의 방향 10.27%, 자아상 10.15%
- Connector: 13 users, 100% child coverage, top parents 행동패턴 10.77%, 의사결정 10.46%, 자아상 10.38%
- Stability Seeker: 13 users, 100% child coverage, top parents 자아상 10.23%, 삶의 방향 10.19%, 성격 10.19%
- Reflector: 12 users, 99.67% child coverage, top parents 행동패턴 10.88%, 동기 10.46%, 가치관 10.33%
- Resilient: 12 users, 99.67% child coverage, top parents 행동패턴 10.83%, 가치관 10.42%, 의사결정 10.38%
- Creator: 12 users, 98.33% child coverage, top parents 행동패턴 10.75%, 가치관 10.71%, 의사결정 10.71%
- Decider: 12 users, 99% child coverage, top parents 가치관 10.75%, 행동패턴 10.54%, 인간관계 10.33%

## Success Criteria

- childNodeCoverageAbove90: PASS
- parentDistributionVarianceBelow15: PASS
- loopRateBelow5: PASS
- deadNodesZero: PASS
- depthProgressionHealthy: PASS
- graphUsageBalanced: PASS

## Recommendations

- Opposite-node traversal is low; consider a controlled contrast boost after several related/bridge moves.
