import {
  type CardDeliveryConfig,
  type CardType,
  defaultCardDeliveryConfig,
  getSemanticGroupKey,
  type TimeAxis,
} from "./card-delivery-config.ts";
import {
  type ExplorationChildNode,
  explorationChildNodes,
  explorationParentNodes,
} from "./exploration-nodes.ts";
import { explorationNodeRelationshipByChildId } from "./exploration-node-relationships.ts";

export type UserExplorationState = {
  readonly totalCardsAnswered: number;
  readonly currentDepthLevel: number;
};

export type UserCardHistoryItem = {
  readonly parentNode: string;
  readonly childNode: string;
  readonly parentNodeId?: string | null;
  readonly childNodeId?: string | null;
  readonly cardType: CardType;
  readonly depthLevel: number;
  readonly timeAxis: TimeAxis;
  readonly answered: boolean;
  readonly createdAt?: string;
};

export type UserNodeProgressItem = {
  readonly parentNode: string;
  readonly childNode: string;
  readonly parentNodeId?: string | null;
  readonly childNodeId?: string | null;
  readonly timesExplored: number;
  readonly coverageScore: number;
  readonly lastExploredAt?: string | null;
};

export type DeliveryEngineInput = {
  readonly state: UserExplorationState;
  readonly history: readonly UserCardHistoryItem[];
  readonly nodeProgress: readonly UserNodeProgressItem[];
  readonly userLanguage?: string;
  readonly config?: CardDeliveryConfig;
};

export type ExplorationCardRequestPayload = {
  readonly parent_node: string;
  readonly child_node: string;
  readonly child_node_description: string;
  readonly desired_card_type: CardType;
  readonly depth_level: number;
  readonly time_axis: TimeAxis;
  readonly user_language: string;
  readonly recent_cards: readonly UserCardHistoryItem[];
};

export type DeliveryDecision = {
  readonly payload: ExplorationCardRequestPayload;
  readonly selectedNode: ExplorationChildNode;
  readonly scores: readonly NodeScore[];
  readonly allowedDepthRange: readonly [number, number];
};

export type NodeScore = {
  readonly childNodeId: string;
  readonly parentNodeId: string;
  readonly parentNode: string;
  readonly childNode: string;
  readonly score: number;
  readonly excluded: boolean;
  readonly reasons: readonly string[];
};

type DistributionKey = CardType | TimeAxis;

const normalizeHistory = (history: readonly UserCardHistoryItem[]) =>
  [...history].sort((a, b) => {
    const aTime = a.createdAt ? Date.parse(a.createdAt) : 0;
    const bTime = b.createdAt ? Date.parse(b.createdAt) : 0;
    return bTime - aTime;
  });

const progressKey = (item: Pick<UserNodeProgressItem, "childNode" | "childNodeId">) =>
  item.childNodeId ?? item.childNode;

const historyChildKey = (item: Pick<UserCardHistoryItem, "childNode" | "childNodeId">) =>
  item.childNodeId ?? item.childNode;

export function getAllowedDepthRange(
  totalCardsAnswered: number,
  config: CardDeliveryConfig = defaultCardDeliveryConfig,
): readonly [number, number] {
  const band = config.depthBands.find((candidate) =>
    totalCardsAnswered >= candidate.minAnswered &&
    (candidate.maxAnswered === null || totalCardsAnswered <= candidate.maxAnswered)
  ) ?? config.depthBands[0];

  return [band.minDepth, band.maxDepth];
}

export function selectDepthLevel(
  state: UserExplorationState,
  config: CardDeliveryConfig = defaultCardDeliveryConfig,
) {
  const [minDepth, maxDepth] = getAllowedDepthRange(state.totalCardsAnswered, config);
  const currentDepth = Math.max(1, Math.min(5, state.currentDepthLevel || minDepth));
  const band = config.depthBands.find((candidate) =>
    state.totalCardsAnswered >= candidate.minAnswered &&
    (candidate.maxAnswered === null || state.totalCardsAnswered <= candidate.maxAnswered)
  );
  const bandSpan = band?.maxAnswered === null || band === undefined
    ? 1
    : Math.max(1, band.maxAnswered - band.minAnswered);
  const bandProgress = band?.maxAnswered === null || band === undefined
    ? 1
    : (state.totalCardsAnswered - band.minAnswered) / bandSpan;
  const targetDepth = bandProgress >= 0.5 ? maxDepth : minDepth;

  return Math.max(minDepth, Math.min(targetDepth, currentDepth + 1));
}

export function calculateParentCoverage(
  nodeProgress: readonly UserNodeProgressItem[],
) {
  const coverage = new Map<string, number>();

  for (const parent of explorationParentNodes) {
    coverage.set(parent.name, 0);
  }

  for (const item of nodeProgress) {
    coverage.set(
      item.parentNode,
      (coverage.get(item.parentNode) ?? 0) + Math.max(0, item.coverageScore),
    );
  }

  return coverage;
}

function selectDistributionValue<T extends DistributionKey>(
  distribution: Record<T, number>,
  historyValues: readonly T[],
  maxStreak: number,
) {
  const entries = Object.entries(distribution) as [T, number][];
  const counts = new Map<T, number>();

  for (const value of historyValues) {
    counts.set(value, (counts.get(value) ?? 0) + 1);
  }

  const streakValue = historyValues[0];
  const streakLength = historyValues.findIndex((value) => value !== streakValue);
  const effectiveStreak = streakValue === undefined
    ? 0
    : streakLength === -1
    ? historyValues.length
    : streakLength;

  const ranked = entries
    .filter(([value]) => !(value === streakValue && effectiveStreak >= maxStreak))
    .map(([value, target]) => ({
      value,
      deficit: target - ((counts.get(value) ?? 0) / Math.max(1, historyValues.length)),
      target,
    }))
    .sort((a, b) => (b.deficit - a.deficit) || (b.target - a.target));

  if (ranked[0]) return ranked[0].value;
  if (entries[0]) return entries[0][0];
  throw new Error("delivery_engine_empty_distribution");
}

export function selectCardType(
  history: readonly UserCardHistoryItem[],
  config: CardDeliveryConfig = defaultCardDeliveryConfig,
) {
  return selectDistributionValue(
    config.cardTypeDistribution,
    normalizeHistory(history).map((item) => item.cardType),
    config.maxCardTypeStreak,
  );
}

export function selectTimeAxis(
  history: readonly UserCardHistoryItem[],
  config: CardDeliveryConfig = defaultCardDeliveryConfig,
) {
  return selectDistributionValue(
    config.timeAxisDistribution,
    normalizeHistory(history).map((item) => item.timeAxis),
    config.maxTimeAxisStreak,
  );
}

export function scoreCandidateNodes(
  history: readonly UserCardHistoryItem[],
  nodeProgress: readonly UserNodeProgressItem[],
  config: CardDeliveryConfig = defaultCardDeliveryConfig,
) {
  const recentHistory = normalizeHistory(history);
  const recentChildKeys = new Set(
    recentHistory.slice(0, config.recentChildExclusionCount).map(historyChildKey),
  );
  const lastExploredNode = recentHistory[0]
    ? explorationChildNodes.find((node) =>
      node.id === recentHistory[0].childNodeId || node.name === recentHistory[0].childNode
    )
    : undefined;
  const lastRelationship = lastExploredNode
    ? explorationNodeRelationshipByChildId.get(lastExploredNode.id)
    : undefined;
  const relatedContinuationIds = new Set(lastRelationship?.related_node_ids ?? []);
  const bridgeExpansionIds = new Set(lastRelationship?.bridge_node_ids ?? []);
  const oppositeContrastIds = new Set(lastRelationship?.opposite_node_ids ?? []);
  const recentParentCounts = new Map<string, number>();
  const recentSemanticGroups = new Set<number>();

  for (const item of recentHistory.slice(0, config.recentContextCount)) {
    recentParentCounts.set(item.parentNode, (recentParentCounts.get(item.parentNode) ?? 0) + 1);
    const matchedNode = explorationChildNodes.find((node) =>
      node.id === item.childNodeId || node.name === item.childNode
    );
    if (matchedNode) {
      const group = getSemanticGroupKey(matchedNode, config);
      if (group >= 0) recentSemanticGroups.add(group);
    }
  }

  const parentCoverage = calculateParentCoverage(nodeProgress);
  const maxParentCoverage = Math.max(1, ...parentCoverage.values());
  const progressByChild = new Map(nodeProgress.map((item) => [progressKey(item), item]));

  return explorationChildNodes
    .map((node) => {
      const reasons: string[] = [];
      const recentKeyExcluded = recentChildKeys.has(node.id) || recentChildKeys.has(node.name);
      if (recentKeyExcluded) reasons.push("recent_child_excluded");

      const parentCoverageScore = parentCoverage.get(node.parentName) ?? 0;
      const parentUnderCoverage =
        (maxParentCoverage - parentCoverageScore) / maxParentCoverage;
      const progress = progressByChild.get(node.id) ?? progressByChild.get(node.name);
      const childCoverage = Math.max(0, progress?.coverageScore ?? 0);
      const childUnderCoverage = 1 / (1 + childCoverage);
      const recentParentPenalty =
        (recentParentCounts.get(node.parentName) ?? 0) * config.scoreWeights.recentParentPenalty;
      const semanticGroup = getSemanticGroupKey(node, config);
      const semanticPenalty = semanticGroup >= 0 && recentSemanticGroups.has(semanticGroup)
        ? config.scoreWeights.semanticPenalty
        : 0;
      if (semanticPenalty > 0) reasons.push("semantic_similarity_penalty");

      const novelty = 1 / (1 + Math.max(0, progress?.timesExplored ?? 0));
      const graphScore =
        (relatedContinuationIds.has(node.id) ? config.scoreWeights.graphRelatedContinuation : 0) +
        (bridgeExpansionIds.has(node.id) ? config.scoreWeights.graphBridgeExpansion : 0) +
        (oppositeContrastIds.has(node.id) ? config.scoreWeights.graphOppositeContrast : 0);
      if (relatedContinuationIds.has(node.id)) reasons.push("graph_related_continuation");
      if (bridgeExpansionIds.has(node.id)) reasons.push("graph_bridge_expansion");
      if (oppositeContrastIds.has(node.id)) reasons.push("graph_opposite_contrast");
      const score = recentKeyExcluded
        ? Number.NEGATIVE_INFINITY
        : config.scoreWeights.parentUnderCoverage * parentUnderCoverage +
          config.scoreWeights.childUnderCoverage * childUnderCoverage +
          graphScore +
          config.scoreWeights.explorationNovelty * novelty -
          recentParentPenalty -
          semanticPenalty;

      return {
        childNodeId: node.id,
        parentNodeId: node.parentId,
        parentNode: node.parentName,
        childNode: node.name,
        score,
        excluded: recentKeyExcluded,
        reasons,
      } satisfies NodeScore;
    })
    .sort((a, b) =>
      Number.isFinite(b.score) && Number.isFinite(a.score)
        ? b.score - a.score || a.childNodeId.localeCompare(b.childNodeId)
        : Number.isFinite(b.score)
        ? 1
        : -1
    );
}

export function selectNextNode(input: DeliveryEngineInput) {
  const scores = scoreCandidateNodes(input.history, input.nodeProgress, input.config);
  const selected = scores.find((score) => !score.excluded) ?? scores[0];
  if (!selected) throw new Error("delivery_engine_empty_taxonomy");
  const node = explorationChildNodes.find((child) => child.id === selected.childNodeId);
  if (!node) throw new Error("delivery_engine_node_selection_failed");
  return { node, scores };
}

export function createDeliveryDecision(input: DeliveryEngineInput): DeliveryDecision {
  const config = input.config ?? defaultCardDeliveryConfig;
  const history = normalizeHistory(input.history);
  const { node, scores } = selectNextNode({ ...input, config });
  const depthLevel = selectDepthLevel(input.state, config);
  const cardType = selectCardType(history, config);
  const timeAxis = selectTimeAxis(history, config);

  return {
    payload: {
      parent_node: node.parentName,
      child_node: node.name,
      child_node_description: node.description,
      desired_card_type: cardType,
      depth_level: depthLevel,
      time_axis: timeAxis,
      user_language: input.userLanguage ?? "ko",
      recent_cards: history.slice(0, config.recentContextCount),
    },
    selectedNode: node,
    scores: scores.slice(0, 20),
    allowedDepthRange: getAllowedDepthRange(input.state.totalCardsAnswered, config),
  };
}
