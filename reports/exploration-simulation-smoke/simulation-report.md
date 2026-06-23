# Exploration Simulation Report

## Summary

- Generated: 2026-06-23T09:07:31.439Z
- Users: 4
- Cards delivered: 32
- Child node coverage: 8.67%
- Dead nodes: 274
- Loop rate: 0%

## Coverage

- Unique child nodes explored: 26/300
- Repeated node frequency: 0%
- Hot nodes: 6

## Parent Distribution

- 자아상: 15.63%
- 행동패턴: 9.38%
- 삶의 방향: 9.38%
- 성격: 9.38%
- 가치관: 9.38%
- 동기: 6.25%
- 감정패턴: 9.38%
- 스트레스 반응: 9.38%
- 인간관계: 12.5%
- 의사결정: 9.38%

## Depth Distribution

- Depth 1: 53.13%
- Depth 2: 46.88%
- Depth 3: 0%
- Depth 4: 0%
- Depth 5: 0%

## Card Type Distribution

- scenario_choice: 34.38%
- multiple_choice: 28.13%
- priority_selection: 28.13%
- binary_choice: 9.38%

## Time Axis Distribution

- present: 43.75%
- past: 3.13%
- future: 12.5%
- repeated_pattern: 9.38%
- imagined_scenario: 31.25%

## Top Nodes

- 자기인식 (자아상): 2 (6.25%)
- 자기표현 욕구 (자아상): 2 (6.25%)
- 외향성 (성격): 2 (6.25%)
- 감정 민감도 (감정패턴): 2 (6.25%)
- 압박 민감도 (스트레스 반응): 2 (6.25%)
- 친밀감 욕구 (인간관계): 2 (6.25%)
- 내면 이미지 (자아상): 1 (3.13%)
- 안정 추구 행동 (행동패턴): 1 (3.13%)
- 자기관리 (행동패턴): 1 (3.13%)
- 목표 추적력 (행동패턴): 1 (3.13%)

## Dead Nodes

- 자기수용 (자아상)
- 자기비판 (자아상)
- 자기신뢰 (자아상)
- 자기존중감 (자아상)
- 자존감 안정성 (자아상)
- 이상적 자아 (자아상)
- 현실적 자아 (자아상)
- 사회적 자아 (자아상)
- 숨겨진 자아 (자아상)
- 열등감 (자아상)
- 우월감 (자아상)
- 자기확신 (자아상)
- 자기의심 (자아상)
- 정체성 명확성 (자아상)
- 역할 인식 (자아상)
- 타인의 시선 의식 (자아상)
- 인정 욕구 (자아상)
- 외적 이미지 관리 (자아상)
- 실패에 대한 자기평가 (자아상)
- 성공에 대한 자기평가 (자아상)
- 자기효능감 (자아상)
- 자기통제감 (자아상)
- 내적 기준 (자아상)
- 비교 성향 (자아상)
- 자기방어 (자아상)
- 성장 가능성 인식 (자아상)
- 존재감 욕구 (자아상)
- 실행력 (행동패턴)
- 추진력 (행동패턴)
- 지속성 (행동패턴)
- 루틴 선호 (행동패턴)
- 즉흥성 (행동패턴)
- 계획성 (행동패턴)
- 습관 형성력 (행동패턴)
- 미루기 성향 (행동패턴)
- 완수 성향 (행동패턴)
- 시작 민감도 (행동패턴)
- 몰입력 (행동패턴)
- 집중 지속력 (행동패턴)
- 행동 속도 (행동패턴)
- 반응 속도 (행동패턴)
- 에너지 관리 (행동패턴)
- 반복 행동 (행동패턴)
- 회피 행동 (행동패턴)
- 도전 행동 (행동패턴)
- 탐색 행동 (행동패턴)
- 충동성 (행동패턴)
- 우선순위 설정 (행동패턴)
- 환경 의존성 (행동패턴)
- 타인 영향성 (행동패턴)

## Loop Detection

- Total loops: 0
- Loop rate: 0%

## Graph Usage

- related: 21.88%
- bridge: 59.38%
- opposite: 0%
- none: 18.75%
- start: 0%

## Archetype Summaries

- Explorer: 1 users, 2.67% child coverage, top parents 자아상 25%, 인간관계 25%, 의사결정 12.5%
- Builder: 1 users, 2.67% child coverage, top parents 자아상 25%, 스트레스 반응 12.5%, 감정패턴 12.5%
- Connector: 1 users, 2.67% child coverage, top parents 행동패턴 25%, 동기 25%, 가치관 12.5%
- Stability Seeker: 1 users, 2.67% child coverage, top parents 성격 25%, 감정패턴 12.5%, 인간관계 12.5%
- Reflector: 0 users, 0% child coverage, top parents 
- Resilient: 0 users, 0% child coverage, top parents 
- Creator: 0 users, 0% child coverage, top parents 
- Decider: 0 users, 0% child coverage, top parents 

## Success Criteria

- childNodeCoverageAbove90: FAIL
- parentDistributionVarianceBelow15: PASS
- loopRateBelow5: PASS
- deadNodesZero: FAIL
- depthProgressionHealthy: FAIL
- graphUsageBalanced: FAIL

## Recommendations

- Increase underexplored-node scoring or reduce graph continuation weight until child coverage exceeds 90%.
- Add bridge or related inbound paths to dead nodes, especially nodes with zero selections across the full run.
- Reduce graph or semantic-group weight for hot nodes, or add a stronger per-user repeat penalty.
- Opposite-node traversal is low; consider a controlled contrast boost after several related/bridge moves.
