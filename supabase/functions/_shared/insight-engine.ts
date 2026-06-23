import {
  type ExplorationChildNode,
  type ExplorationParentNodeSummary,
  explorationChildNodes,
  explorationParentNodes,
} from "./exploration-nodes.ts";
import {
  type ExplorationNodeRelationship,
  explorationNodeRelationshipByChildId,
} from "./exploration-node-relationships.ts";

export type InsightType =
  | "emerging_pattern"
  | "internal_tension"
  | "exploration_gap"
  | "consistent_theme"
  | "change_over_time";

export type ConfidenceLevel = "early" | "forming" | "consistent";

export type InsightOutput = {
  readonly insight_type: InsightType;
  readonly title: string;
  readonly description: string;
  readonly supporting_nodes: readonly SupportingNode[];
  readonly supporting_answers: readonly SupportingAnswer[];
  readonly confidence_level: ConfidenceLevel;
  readonly evidence_count: number;
};

export type UserInsightFeedItem = {
  readonly insight_id: string;
  readonly insight_type: InsightType;
  readonly title: string;
  readonly description: string;
  readonly supporting_nodes: readonly SupportingNode[];
  readonly confidence_level: ConfidenceLevel;
};

type SupportingNode = {
  readonly node_id: string;
  readonly node_name: string;
  readonly parent_node_id?: string | null;
  readonly parent_node?: string | null;
};

type SupportingAnswer = {
  readonly card_history_id: string;
  readonly selected_options?: readonly string[];
  readonly created_at?: string | null;
};

export type InsightHistoryRow = {
  readonly id: string;
  readonly parent_node: string;
  readonly parent_node_id?: string | null;
  readonly child_node: string;
  readonly child_node_id?: string | null;
  readonly card_type: string;
  readonly depth_level: number;
  readonly time_axis: string;
  readonly answered: boolean;
  readonly created_at: string;
};

export type InsightAnswerRow = {
  readonly card_history_id: string;
  readonly selected_options: readonly string[];
  readonly user_note?: string | null;
  readonly created_at: string;
};

export type InsightProgressRow = {
  readonly parent_node: string;
  readonly parent_node_id?: string | null;
  readonly child_node: string;
  readonly child_node_id?: string | null;
  readonly times_explored: number;
  readonly coverage_score: number;
  readonly last_explored_at?: string | null;
};

export type InsightRefreshResult = {
  readonly refreshed: boolean;
  readonly reason: "initial" | "ten_card_interval" | "pattern_change" | "not_due" | "insufficient_evidence";
  readonly answered_count: number;
  readonly generated_count: number;
  readonly pattern_signature: string;
};

type SupabaseLike = {
  from: (table: string) => {
    select: (columns?: string) => QueryBuilder;
    update: (values: Record<string, unknown>) => QueryBuilder;
    upsert: (values: unknown, options?: Record<string, unknown>) => QueryBuilder;
  };
};

type QueryResult = { data: unknown; error: unknown };

type QueryBuilder = PromiseLike<QueryResult> & {
  eq: (column: string, value: unknown) => QueryBuilder;
  order: (column: string, options?: Record<string, unknown>) => QueryBuilder;
  limit: (count: number) => QueryBuilder;
  maybeSingle: () => Promise<QueryResult>;
};

const MIN_SUPPORTING_SIGNALS = 3;
const MAX_INSIGHTS_PER_REFRESH = 8;

const typedChildNodes = explorationChildNodes as readonly ExplorationChildNode[];
const typedParentNodes = explorationParentNodes as readonly ExplorationParentNodeSummary[];
const relationshipByChildId = explorationNodeRelationshipByChildId as ReadonlyMap<
  string,
  ExplorationNodeRelationship
>;

const nodeById = new Map<string, ExplorationChildNode>(typedChildNodes.map((node) => [node.id, node]));
const parentById = new Map<string, ExplorationParentNodeSummary>(
  typedParentNodes.map((parent) => [parent.id, parent]),
);

function assertNoJudgmentLanguage(insight: InsightOutput) {
  const blocked = [
    "당신은",
    "성격 유형",
    "진단",
    "점수",
    "등급",
    "상위",
    "하위",
  ];
  const text = `${insight.title} ${insight.description}`;
  if (blocked.some((word) => text.includes(word))) {
    throw new Error(`insight_judgment_language_detected:${insight.title}`);
  }
}

function confidenceLevel(evidenceCount: number): ConfidenceLevel {
  if (evidenceCount >= 8) return "consistent";
  if (evidenceCount >= 5) return "forming";
  return "early";
}

function normalizeHistory(history: readonly InsightHistoryRow[]) {
  return [...history]
    .filter((item) => item.answered)
    .sort((a, b) => Date.parse(a.created_at) - Date.parse(b.created_at));
}

function childNodeFor(row: Pick<InsightHistoryRow | InsightProgressRow, "child_node" | "child_node_id" | "parent_node" | "parent_node_id">) {
  return row.child_node_id ? nodeById.get(row.child_node_id) : undefined;
}

function supportNodeFromId(nodeId: string): SupportingNode | null {
  const node = nodeById.get(nodeId);
  if (!node) return null;
  return {
    node_id: node.id,
    node_name: node.name,
    parent_node_id: node.parentId,
    parent_node: node.parentName,
  };
}

function supportNodeFromRow(row: Pick<InsightHistoryRow | InsightProgressRow, "child_node" | "child_node_id" | "parent_node" | "parent_node_id">): SupportingNode {
  const node = childNodeFor(row);
  return {
    node_id: node?.id ?? row.child_node_id ?? row.child_node,
    node_name: node?.name ?? row.child_node,
    parent_node_id: node?.parentId ?? row.parent_node_id ?? null,
    parent_node: node?.parentName ?? row.parent_node ?? null,
  };
}

function answerSupport(
  answerByHistoryId: Map<string, InsightAnswerRow>,
  historyRows: readonly InsightHistoryRow[],
  limit = 6,
): SupportingAnswer[] {
  return historyRows.slice(-limit).map((row) => {
    const answer = answerByHistoryId.get(row.id);
    return {
      card_history_id: row.id,
      selected_options: answer?.selected_options ?? [],
      created_at: answer?.created_at ?? row.created_at,
    };
  });
}

function pushInsight(target: InsightOutput[], insight: InsightOutput) {
  if (insight.evidence_count < MIN_SUPPORTING_SIGNALS) return;
  assertNoJudgmentLanguage(insight);
  if (!target.some((item) => item.insight_type === insight.insight_type && item.title === insight.title)) {
    target.push(insight);
  }
}

function countBy<T extends string>(values: readonly T[]) {
  const counts = new Map<T, number>();
  for (const value of values) counts.set(value, (counts.get(value) ?? 0) + 1);
  return counts;
}

function topCounts<T extends string>(counts: Map<T, number>, minimum: number) {
  return [...counts.entries()]
    .filter(([, count]) => count >= minimum)
    .sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]));
}

function generateEmergingPatterns(
  history: readonly InsightHistoryRow[],
  progress: readonly InsightProgressRow[],
  answerByHistoryId: Map<string, InsightAnswerRow>,
) {
  const insights: InsightOutput[] = [];
  const historyByNodeId = new Map<string, InsightHistoryRow[]>();
  for (const row of history) {
    const key = row.child_node_id ?? row.child_node;
    historyByNodeId.set(key, [...(historyByNodeId.get(key) ?? []), row]);
  }

  for (const row of [...progress].sort((a, b) => Number(b.times_explored) - Number(a.times_explored)).slice(0, 6)) {
    const evidence = Number(row.times_explored ?? 0);
    if (evidence < MIN_SUPPORTING_SIGNALS) continue;
    const node = supportNodeFromRow(row);
    const matchingHistory = historyByNodeId.get(node.node_id) ?? historyByNodeId.get(node.node_name) ?? [];
    pushInsight(insights, {
      insight_type: "emerging_pattern",
      title: `${node.node_name}의 반복되는 단서`,
      description: `최근 탐험에서 ${node.node_name} 쪽의 선택이 여러 장면에 걸쳐 반복해서 나타납니다. 아직 하나의 결론이라기보다, 다시 살펴볼 만한 흐름으로 보입니다.`,
      supporting_nodes: [node],
      supporting_answers: answerSupport(answerByHistoryId, matchingHistory),
      confidence_level: confidenceLevel(evidence),
      evidence_count: evidence,
    });
  }

  return insights;
}

function generateInternalTensions(
  history: readonly InsightHistoryRow[],
  answerByHistoryId: Map<string, InsightAnswerRow>,
) {
  const insights: InsightOutput[] = [];
  const counts = countBy(history.map((row) => row.child_node_id ?? row.child_node));
  const historyByNode = new Map<string, InsightHistoryRow[]>();
  for (const row of history) {
    const key = row.child_node_id ?? row.child_node;
    historyByNode.set(key, [...(historyByNode.get(key) ?? []), row]);
  }

  for (const [nodeId, nodeCount] of topCounts(counts, 1)) {
    const relationship = relationshipByChildId.get(nodeId);
    if (!relationship) continue;

    for (const oppositeId of relationship.opposite_node_ids) {
      const oppositeCount = counts.get(oppositeId) ?? 0;
      const evidence = nodeCount + oppositeCount;
      if (nodeId > oppositeId || nodeCount < 1 || oppositeCount < 1 || evidence < MIN_SUPPORTING_SIGNALS) continue;
      const node = supportNodeFromId(nodeId);
      const opposite = supportNodeFromId(oppositeId);
      if (!node || !opposite) continue;
      const supportingHistory = [
        ...(historyByNode.get(nodeId) ?? []),
        ...(historyByNode.get(oppositeId) ?? []),
      ].sort((a, b) => Date.parse(a.created_at) - Date.parse(b.created_at));

      pushInsight(insights, {
        insight_type: "internal_tension",
        title: `${node.node_name}와 ${opposite.node_name} 사이의 균형`,
        description: `${node.node_name}와 ${opposite.node_name}, 두 단서가 함께 등장합니다. 한쪽으로 단정되기보다, 상황에 따라 서로 다른 필요가 같이 움직이는 모습으로 보입니다.`,
        supporting_nodes: [node, opposite],
        supporting_answers: answerSupport(answerByHistoryId, supportingHistory),
        confidence_level: confidenceLevel(evidence),
        evidence_count: evidence,
      });
    }
  }

  return insights;
}

function generateExplorationGaps(history: readonly InsightHistoryRow[]) {
  if (history.length < 10) return [];

  const parentCounts = countBy(history.map((row) => row.parent_node_id ?? row.parent_node));
  const exploredParents = [...parentCounts.values()].filter((count) => count > 0).length;
  if (exploredParents < MIN_SUPPORTING_SIGNALS) return [];

  const leastExplored = typedParentNodes
    .map((parent) => ({
      parent,
      count: parentCounts.get(parent.id) ?? parentCounts.get(parent.name) ?? 0,
    }))
    .sort((a, b) => a.count - b.count || a.parent.order - b.parent.order)[0];

  if (!leastExplored || leastExplored.count > 1) return [];

  const starterNodes = leastExplored.parent.id
    ? typedChildNodes
      .filter((node) => node.parentId === leastExplored.parent.id)
      .slice(0, 3)
      .map((node) => ({
        node_id: node.id,
        node_name: node.name,
        parent_node_id: node.parentId,
        parent_node: node.parentName,
      }))
    : [];

  return [{
    insight_type: "exploration_gap",
    title: `${leastExplored.parent.name}에 남아 있는 여백`,
    description: `${leastExplored.parent.name} 영역은 아직 비교적 적게 다뤄졌습니다. 이 부분은 부족함이라기보다, 앞으로 탐험할 수 있는 빈 공간에 가깝습니다.`,
    supporting_nodes: starterNodes,
    supporting_answers: [],
    confidence_level: confidenceLevel(exploredParents),
    evidence_count: exploredParents,
  }] satisfies InsightOutput[];
}

function generateConsistentThemes(
  history: readonly InsightHistoryRow[],
  answerByHistoryId: Map<string, InsightAnswerRow>,
) {
  const insights: InsightOutput[] = [];
  const nodeIdsInHistory = new Set(history.map((row) => row.child_node_id ?? row.child_node));
  const parentIdsByTheme = new Map<string, Set<string>>();
  const historyByTheme = new Map<string, InsightHistoryRow[]>();

  for (const row of history) {
    const nodeId = row.child_node_id ?? row.child_node;
    const relationship = relationshipByChildId.get(nodeId);
    if (!relationship) continue;
    const linkedIds = [
      ...relationship.related_node_ids,
      ...relationship.bridge_node_ids,
    ].filter((id) => nodeIdsInHistory.has(id));
    if (linkedIds.length === 0) continue;
    const themeKey = nodeId;
    const parents = parentIdsByTheme.get(themeKey) ?? new Set<string>();
    parents.add(row.parent_node_id ?? row.parent_node);
    for (const linkedId of linkedIds) {
      const linked = nodeById.get(linkedId);
      if (linked) parents.add(linked.parentId);
    }
    parentIdsByTheme.set(themeKey, parents);
    historyByTheme.set(themeKey, [...(historyByTheme.get(themeKey) ?? []), row]);
  }

  for (const [nodeId, parents] of [...parentIdsByTheme.entries()].sort((a, b) => b[1].size - a[1].size)) {
    if (parents.size < MIN_SUPPORTING_SIGNALS) continue;
    const node = supportNodeFromId(nodeId);
    if (!node) continue;
    const parentNames = [...parents]
      .map((id) => parentById.get(id)?.name ?? id)
      .slice(0, 3)
      .join(", ");
    const supportingNodes = [
      node,
      ...[...(relationshipByChildId.get(nodeId)?.bridge_node_ids ?? [])]
        .map(supportNodeFromId)
        .filter((item): item is SupportingNode => Boolean(item))
        .slice(0, 2),
    ];

    pushInsight(insights, {
      insight_type: "consistent_theme",
      title: `${node.node_name}로 이어지는 연결`,
      description: `${node.node_name}와 연결된 단서가 ${parentNames}처럼 서로 다른 영역에서 함께 보입니다. 하나의 주제가 여러 방향으로 이어지는 중일 수 있습니다.`,
      supporting_nodes: supportingNodes,
      supporting_answers: answerSupport(answerByHistoryId, historyByTheme.get(nodeId) ?? []),
      confidence_level: confidenceLevel(parents.size),
      evidence_count: parents.size,
    });
  }

  return insights;
}

function generateChangesOverTime(
  history: readonly InsightHistoryRow[],
  answerByHistoryId: Map<string, InsightAnswerRow>,
) {
  if (history.length < 6) return [];
  const midpoint = Math.floor(history.length / 2);
  const earlier = history.slice(0, midpoint);
  const recent = history.slice(midpoint);
  const earlierParents = countBy(earlier.map((row) => row.parent_node_id ?? row.parent_node));
  const recentParents = countBy(recent.map((row) => row.parent_node_id ?? row.parent_node));

  const shifted = [...recentParents.entries()]
    .map(([parentId, recentCount]) => ({
      parentId,
      recentCount,
      earlierCount: earlierParents.get(parentId) ?? 0,
    }))
    .filter((item) => item.recentCount >= MIN_SUPPORTING_SIGNALS && item.recentCount > item.earlierCount)
    .sort((a, b) => (b.recentCount - b.earlierCount) - (a.recentCount - a.earlierCount))[0];

  if (!shifted) return [];
  const parentName = parentById.get(shifted.parentId)?.name ?? shifted.parentId;
  const supportingHistory = recent.filter((row) => (row.parent_node_id ?? row.parent_node) === shifted.parentId);
  const supportingNodes = supportingHistory
    .map(supportNodeFromRow)
    .filter((node, index, nodes) => nodes.findIndex((item) => item.node_id === node.node_id) === index)
    .slice(0, 4);

  return [{
    insight_type: "change_over_time",
    title: `최근 더 자주 나타난 ${parentName}`,
    description: `최근 탐험에서는 ${parentName}와 관련된 단서가 이전보다 더 자주 이어집니다. 관심의 방향이 조금씩 이동하고 있을 가능성이 보입니다.`,
    supporting_nodes: supportingNodes,
    supporting_answers: answerSupport(answerByHistoryId, supportingHistory),
    confidence_level: confidenceLevel(shifted.recentCount),
    evidence_count: shifted.recentCount,
  }] satisfies InsightOutput[];
}

export function generateUserInsights(input: {
  readonly history: readonly InsightHistoryRow[];
  readonly answers: readonly InsightAnswerRow[];
  readonly progress: readonly InsightProgressRow[];
}) {
  const history = normalizeHistory(input.history);
  const answerByHistoryId = new Map(input.answers.map((answer) => [answer.card_history_id, answer]));
  const insights: InsightOutput[] = [];

  for (const insight of generateEmergingPatterns(history, input.progress, answerByHistoryId)) {
    pushInsight(insights, insight);
  }
  for (const insight of generateInternalTensions(history, answerByHistoryId)) {
    pushInsight(insights, insight);
  }
  for (const insight of generateConsistentThemes(history, answerByHistoryId)) {
    pushInsight(insights, insight);
  }
  for (const insight of generateChangesOverTime(history, answerByHistoryId)) {
    pushInsight(insights, insight);
  }
  for (const insight of generateExplorationGaps(history)) {
    pushInsight(insights, insight);
  }

  return insights
    .sort((a, b) =>
      b.evidence_count - a.evidence_count ||
      a.insight_type.localeCompare(b.insight_type) ||
      a.title.localeCompare(b.title)
    )
    .slice(0, MAX_INSIGHTS_PER_REFRESH);
}

export function buildInsightPatternSignature(historyRows: readonly InsightHistoryRow[]) {
  const recent = normalizeHistory(historyRows).slice(-20);
  const parentCounts = topCounts(countBy(recent.map((row) => row.parent_node_id ?? row.parent_node)), 2)
    .slice(0, 3)
    .map(([key, count]) => `${key}:${count}`)
    .join("|");
  const repeatCounts = topCounts(countBy(recent.map((row) => row.child_node_id ?? row.child_node)), 2)
    .slice(0, 3)
    .map(([key, count]) => `${key}:${count}`)
    .join("|");
  return `parents:${parentCounts};repeat:${repeatCounts}`;
}

export function decideInsightRefresh(input: {
  readonly answeredCount: number;
  readonly lastAnsweredCount?: number | null;
  readonly lastPatternSignature?: string | null;
  readonly patternSignature: string;
}) {
  if (input.answeredCount < MIN_SUPPORTING_SIGNALS) return "insufficient_evidence" as const;
  if (!input.lastAnsweredCount) return "initial" as const;
  if (input.answeredCount - input.lastAnsweredCount >= 10) return "ten_card_interval" as const;
  const hasRepeatedPattern = input.patternSignature.includes("repeat:parent_");
  if (
    input.answeredCount - input.lastAnsweredCount >= 3 &&
    hasRepeatedPattern &&
    input.patternSignature !== input.lastPatternSignature
  ) {
    return "pattern_change" as const;
  }
  return "not_due" as const;
}

async function selectRows<T>(
  supabase: SupabaseLike,
  table: string,
  columns: string,
  userId: string,
  options: { order?: string; ascending?: boolean; limit?: number } = {},
): Promise<T[]> {
  let query = supabase.from(table).select(columns);
  query = query.eq("user_id", userId);
  if (options.order) query = query.order(options.order, { ascending: options.ascending ?? true });
  const result = options.limit ? await query.limit(options.limit) : await query;
  if (result.error) throw result.error;
  return (result.data ?? []) as T[];
}

async function maybeSingle<T>(
  supabase: SupabaseLike,
  table: string,
  columns: string,
  userId: string,
): Promise<T | null> {
  const query = supabase.from(table).select(columns);
  const result = await query.eq("user_id", userId).maybeSingle();
  if (result.error) throw result.error;
  return (result.data as T | null) ?? null;
}

export async function refreshUserInsights(
  supabase: SupabaseLike,
  userId: string,
  options: { force?: boolean } = {},
): Promise<InsightRefreshResult> {
  const history = await selectRows<InsightHistoryRow>(
    supabase,
    "user_card_history",
    "id,parent_node,parent_node_id,child_node,child_node_id,card_type,depth_level,time_axis,answered,created_at",
    userId,
    { order: "created_at", ascending: true, limit: 240 },
  );
  const answeredHistory = normalizeHistory(history);
  const answeredCount = answeredHistory.length;
  const patternSignature = buildInsightPatternSignature(answeredHistory);
  const state = await maybeSingle<{
    last_answered_count: number;
    last_pattern_signature: string | null;
  }>(
    supabase,
    "user_insight_refresh_state",
    "last_answered_count,last_pattern_signature",
    userId,
  );
  const reason = options.force && answeredCount >= MIN_SUPPORTING_SIGNALS
    ? "initial"
    : decideInsightRefresh({
      answeredCount,
      lastAnsweredCount: state?.last_answered_count ?? null,
      lastPatternSignature: state?.last_pattern_signature ?? null,
      patternSignature,
    });

  if (reason === "not_due" || reason === "insufficient_evidence") {
    return {
      refreshed: false,
      reason,
      answered_count: answeredCount,
      generated_count: 0,
      pattern_signature: patternSignature,
    };
  }

  const [answers, progress] = await Promise.all([
    selectRows<InsightAnswerRow>(
      supabase,
      "user_card_answers",
      "card_history_id,selected_options,user_note,created_at",
      userId,
      { order: "created_at", ascending: true, limit: 240 },
    ),
    selectRows<InsightProgressRow>(
      supabase,
      "user_node_progress",
      "parent_node,parent_node_id,child_node,child_node_id,times_explored,coverage_score,last_explored_at",
      userId,
      { order: "updated_at", ascending: false, limit: 300 },
    ),
  ]);
  const insights = generateUserInsights({ history: answeredHistory, answers, progress });

  const deactivate = supabase.from("user_insights").update({ active: false });
  const deactivateResult = await deactivate.eq("user_id", userId);
  if (deactivateResult.error) throw deactivateResult.error;

  if (insights.length > 0) {
    const rows = insights.map((insight) => ({
      user_id: userId,
      insight_type: insight.insight_type,
      title: insight.title,
      description: insight.description,
      supporting_nodes: insight.supporting_nodes,
      supporting_answers: insight.supporting_answers,
      confidence_level: insight.confidence_level,
      evidence_count: insight.evidence_count,
      active: true,
    }));
    const upsertResult = await supabase
      .from("user_insights")
      .upsert(rows, { onConflict: "user_id,insight_type,title" });
    if (upsertResult.error) throw upsertResult.error;
  }

  const stateResult = await supabase
    .from("user_insight_refresh_state")
    .upsert({
      user_id: userId,
      last_answered_count: answeredCount,
      last_pattern_signature: patternSignature,
      last_refreshed_at: new Date().toISOString(),
    }, { onConflict: "user_id" });
  if (stateResult.error) throw stateResult.error;

  return {
    refreshed: true,
    reason,
    answered_count: answeredCount,
    generated_count: insights.length,
    pattern_signature: patternSignature,
  };
}

export function toFeedItem(row: Record<string, unknown>): UserInsightFeedItem {
  return {
    insight_id: String(row.id),
    insight_type: row.insight_type as InsightType,
    title: String(row.title),
    description: String(row.description),
    supporting_nodes: Array.isArray(row.supporting_nodes) ? row.supporting_nodes as SupportingNode[] : [],
    confidence_level: row.confidence_level as ConfidenceLevel,
  };
}
