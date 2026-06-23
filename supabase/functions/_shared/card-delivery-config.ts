import type { ExplorationChildNode } from "./exploration-nodes.ts";

export type CardType =
  | "scenario_choice"
  | "multiple_choice"
  | "priority_selection"
  | "binary_choice";

export type TimeAxis =
  | "present"
  | "past"
  | "future"
  | "repeated_pattern"
  | "imagined_scenario";

export type WeightedDistribution<T extends string> = Record<T, number>;

export type DepthBand = {
  readonly minAnswered: number;
  readonly maxAnswered: number | null;
  readonly minDepth: number;
  readonly maxDepth: number;
};

export type CardDeliveryConfig = {
  readonly recentChildExclusionCount: number;
  readonly recentContextCount: number;
  readonly maxCardTypeStreak: number;
  readonly maxTimeAxisStreak: number;
  readonly depthBands: readonly DepthBand[];
  readonly cardTypeDistribution: WeightedDistribution<CardType>;
  readonly timeAxisDistribution: WeightedDistribution<TimeAxis>;
  readonly semanticSimilarityGroups: readonly (readonly string[])[];
  readonly scoreWeights: {
    readonly parentUnderCoverage: number;
    readonly childUnderCoverage: number;
    readonly graphRelatedContinuation: number;
    readonly graphBridgeExpansion: number;
    readonly graphOppositeContrast: number;
    readonly recentParentPenalty: number;
    readonly semanticPenalty: number;
    readonly explorationNovelty: number;
  };
};

export const defaultCardDeliveryConfig: CardDeliveryConfig = {
  recentChildExclusionCount: 10,
  recentContextCount: 10,
  maxCardTypeStreak: 3,
  maxTimeAxisStreak: 2,
  depthBands: [
    { minAnswered: 0, maxAnswered: 20, minDepth: 1, maxDepth: 2 },
    { minAnswered: 21, maxAnswered: 100, minDepth: 2, maxDepth: 3 },
    { minAnswered: 101, maxAnswered: 300, minDepth: 3, maxDepth: 4 },
    { minAnswered: 301, maxAnswered: null, minDepth: 4, maxDepth: 5 },
  ],
  cardTypeDistribution: {
    scenario_choice: 0.4,
    multiple_choice: 0.3,
    priority_selection: 0.2,
    binary_choice: 0.1,
  },
  timeAxisDistribution: {
    present: 0.4,
    imagined_scenario: 0.25,
    repeated_pattern: 0.15,
    future: 0.1,
    past: 0.1,
  },
  semanticSimilarityGroups: [
    ["자유", "독립", "탐험 욕구", "개방성", "자율 동기", "자유 지향"],
    ["안정", "안정 지향", "안정 동기", "안정 선호", "안전 행동"],
    ["인정 욕구", "인정 동기", "사회적 자아", "타인의 시선 의식", "명예"],
    ["성장", "성장 지향", "성장 동기", "성장 가능성 인식", "성취"],
    ["감정 민감성", "감정 기복", "상처 민감성", "불안 패턴", "스트레스 민감성"],
    ["관계", "소속감 욕구", "친밀감 욕구", "관계 지향", "관계 불안"],
  ],
  scoreWeights: {
    parentUnderCoverage: 5,
    childUnderCoverage: 3.6,
    graphRelatedContinuation: 2.5,
    graphBridgeExpansion: 2,
    graphOppositeContrast: 1.6,
    recentParentPenalty: 1.25,
    semanticPenalty: 4,
    explorationNovelty: 0.15,
  },
};

export function getSemanticGroupKey(
  child: Pick<ExplorationChildNode, "name">,
  config: CardDeliveryConfig = defaultCardDeliveryConfig,
) {
  return config.semanticSimilarityGroups.findIndex((group) => group.includes(child.name));
}
