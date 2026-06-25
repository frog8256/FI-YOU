import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import {
  createDeliveryDecision,
  type DeliveryDecision,
  type UserCardHistoryItem,
  type UserExplorationState,
  type UserNodeProgressItem,
} from "../supabase/functions/_shared/card-delivery-engine.ts";
import {
  type CardType,
  type TimeAxis,
} from "../supabase/functions/_shared/card-delivery-config.ts";
import {
  explorationChildNodes,
  explorationParentNodes,
  type ExplorationChildNode,
} from "../supabase/functions/_shared/exploration-nodes.ts";
import { explorationNodeRelationshipByChildId } from "../supabase/functions/_shared/exploration-node-relationships.ts";

type Archetype = {
  readonly name: string;
  readonly description: string;
  readonly parentBiases: readonly string[];
  readonly anchorNodes: readonly string[];
};

type VirtualUser = {
  readonly id: string;
  readonly archetype: Archetype;
  readonly noveltyPreference: number;
  readonly contrastTolerance: number;
  readonly bridgePreference: number;
  state: UserExplorationState;
  history: UserCardHistoryItem[];
  progress: Map<string, UserNodeProgressItem>;
  deliveredNodeIds: string[];
};

type SimulationOptions = {
  readonly users: number;
  readonly cardsPerUser: number;
  readonly seed: number;
  readonly outputDir: string;
};

type DeliveryRecord = {
  readonly userId: string;
  readonly archetype: string;
  readonly index: number;
  readonly childNodeId: string;
  readonly childNode: string;
  readonly parentNode: string;
  readonly cardType: CardType;
  readonly timeAxis: TimeAxis;
  readonly depthLevel: number;
  readonly graphTransition: "related" | "bridge" | "opposite" | "none" | "start";
};

type SimulationReport = {
  readonly generatedAt: string;
  readonly options: SimulationOptions;
  readonly totals: {
    readonly users: number;
    readonly cardsDelivered: number;
    readonly childNodeCoveragePercent: number;
    readonly uniqueChildNodesExplored: number;
    readonly totalChildNodes: number;
    readonly repeatedNodeFrequencyPercent: number;
    readonly loopRatePercent: number;
    readonly deadNodeCount: number;
    readonly hotNodeCount: number;
    readonly parentDistributionMaxDeviationPercent: number;
  };
  readonly successCriteria: Record<string, boolean>;
  readonly parentDistribution: Record<string, number>;
  readonly depthDistribution: Record<string, number>;
  readonly cardTypeDistribution: Record<CardType, number>;
  readonly timeAxisDistribution: Record<TimeAxis, number>;
  readonly graphUsage: Record<DeliveryRecord["graphTransition"], number>;
  readonly topNodes: readonly NodeFrequency[];
  readonly deadNodes: readonly NodeFrequency[];
  readonly hotNodes: readonly NodeFrequency[];
  readonly loopDetection: {
    readonly totalLoops: number;
    readonly loopRatePercent: number;
    readonly examples: readonly string[];
  };
  readonly archetypeSummaries: readonly ArchetypeSummary[];
  readonly recommendations: readonly string[];
};

type NodeFrequency = {
  readonly childNodeId: string;
  readonly childNode: string;
  readonly parentNode: string;
  readonly count: number;
  readonly percent: number;
};

type ArchetypeSummary = {
  readonly archetype: string;
  readonly users: number;
  readonly childNodeCoveragePercent: number;
  readonly topParents: readonly [string, number][];
};

const archetypes: readonly Archetype[] = [
  {
    name: "Explorer",
    description: "Prefers novelty, freedom, and exploration paths.",
    parentBiases: ["삶의 방향", "가치관", "동기"],
    anchorNodes: ["자유", "탐험 욕구", "탐색 행동", "호기심", "변화 추구 동기"],
  },
  {
    name: "Builder",
    description: "Prefers achievement, planning, and action.",
    parentBiases: ["행동패턴", "의사결정", "동기"],
    anchorNodes: ["실행력", "계획성", "성취 동기", "목표 추적력", "결정 후 실행력"],
  },
  {
    name: "Connector",
    description: "Prefers relationships, trust, and emotional sharing.",
    parentBiases: ["인간관계", "감정패턴", "가치관"],
    anchorNodes: ["신뢰 형성", "감정 공유", "관계 지속성", "공감 능력", "친밀감 욕구"],
  },
  {
    name: "Stability Seeker",
    description: "Prefers security, routine, and predictability.",
    parentBiases: ["가치관", "행동패턴", "스트레스 반응"],
    anchorNodes: ["안정", "루틴 선호", "안정 동기", "안정 선호", "스트레스 예측력"],
  },
  {
    name: "Reflector",
    description: "Prefers self-understanding, identity, and inner standards.",
    parentBiases: ["자아상", "의사결정", "삶의 방향"],
    anchorNodes: ["자기인식", "내적 기준", "정체성 명확성", "기준 명확성", "목적 의식"],
  },
  {
    name: "Resilient",
    description: "Prefers stress recovery, emotion regulation, and repair.",
    parentBiases: ["스트레스 반응", "감정패턴", "인간관계"],
    anchorNodes: ["스트레스 회복력", "감정 회복력", "감정 조절력", "관계 회복력", "위기 적응력"],
  },
  {
    name: "Creator",
    description: "Prefers creativity, expression, and meaning.",
    parentBiases: ["가치관", "삶의 방향", "성격"],
    anchorNodes: ["창의성", "창조 욕구", "창조 동기", "자기표현 욕구", "자기실현"],
  },
  {
    name: "Decider",
    description: "Prefers choice clarity, criteria, and commitment.",
    parentBiases: ["의사결정", "가치관", "행동패턴"],
    anchorNodes: ["기준 명확성", "우선순위 판단", "가치 기반 선택", "결단력", "선택 책임감"],
  },
];

const allCardTypes: readonly CardType[] = [
  "scenario_choice",
  "multiple_choice",
  "priority_selection",
  "binary_choice",
];

const allTimeAxes: readonly TimeAxis[] = [
  "present",
  "past",
  "future",
  "repeated_pattern",
  "imagined_scenario",
];

function mulberry32(seed: number) {
  return () => {
    let value = seed += 0x6D2B79F5;
    value = Math.imul(value ^ (value >>> 15), value | 1);
    value ^= value + Math.imul(value ^ (value >>> 7), value | 61);
    return ((value ^ (value >>> 14)) >>> 0) / 4294967296;
  };
}

function parseArgs(): SimulationOptions {
  const args = new Map<string, string>();
  for (let index = 2; index < process.argv.length; index += 1) {
    const current = process.argv[index];
    if (!current.startsWith("--")) continue;
    const [key, inlineValue] = current.slice(2).split("=");
    const nextValue = process.argv[index + 1];
    if (inlineValue !== undefined) args.set(key, inlineValue);
    else if (nextValue && !nextValue.startsWith("--")) {
      args.set(key, nextValue);
      index += 1;
    } else args.set(key, "true");
  }

  return {
    users: Number(args.get("users") ?? 100),
    cardsPerUser: Number(args.get("cards") ?? 200),
    seed: Number(args.get("seed") ?? 20260623),
    outputDir: args.get("out") ?? "reports/exploration-simulation",
  };
}

function findNodeByName(name: string) {
  const node = explorationChildNodes.find((candidate) => candidate.name === name);
  if (!node) throw new Error(`Unknown simulation anchor node: ${name}`);
  return node;
}

function choose<T>(items: readonly T[], random: () => number) {
  return items[Math.floor(random() * items.length)] ?? items[0];
}

function makeHistoryItem(
  node: ExplorationChildNode,
  index: number,
  cardType: CardType = "scenario_choice",
  timeAxis: TimeAxis = "present",
  depthLevel = 1,
): UserCardHistoryItem {
  return {
    parentNode: node.parentName,
    parentNodeId: node.parentId,
    childNode: node.name,
    childNodeId: node.id,
    cardType,
    depthLevel,
    timeAxis,
    answered: true,
    createdAt: new Date(Date.UTC(2026, 0, 1, 0, 0, index)).toISOString(),
  };
}

function applyProgress(user: VirtualUser, node: ExplorationChildNode) {
  const current = user.progress.get(node.id);
  user.progress.set(node.id, {
    parentNode: node.parentName,
    parentNodeId: node.parentId,
    childNode: node.name,
    childNodeId: node.id,
    timesExplored: (current?.timesExplored ?? 0) + 1,
    coverageScore: (current?.coverageScore ?? 0) + 1,
    lastExploredAt: new Date().toISOString(),
  });
}

function createVirtualUsers(options: SimulationOptions) {
  const random = mulberry32(options.seed);
  const users: VirtualUser[] = [];

  for (let index = 0; index < options.users; index += 1) {
    const archetype = archetypes[index % archetypes.length];
    const user: VirtualUser = {
      id: `virtual_user_${String(index + 1).padStart(3, "0")}`,
      archetype,
      noveltyPreference: random(),
      contrastTolerance: random(),
      bridgePreference: random(),
      state: { totalCardsAnswered: 0, currentDepthLevel: 1 },
      history: [],
      progress: new Map(),
      deliveredNodeIds: [],
    };

    const warmupCount = 3 + Math.floor(random() * 5);
    const anchors = [...archetype.anchorNodes].sort(() => random() - 0.5);
    for (let warmupIndex = 0; warmupIndex < warmupCount; warmupIndex += 1) {
      const node = findNodeByName(anchors[warmupIndex % anchors.length]);
      const historyItem = makeHistoryItem(
        node,
        warmupIndex,
        choose(allCardTypes, random),
        choose(allTimeAxes, random),
        1,
      );
      user.history.unshift(historyItem);
      user.deliveredNodeIds.push(node.id);
      applyProgress(user, node);
      user.state = {
        totalCardsAnswered: user.state.totalCardsAnswered + 1,
        currentDepthLevel: historyItem.depthLevel,
      };
    }

    users.push(user);
  }

  return users;
}

function detectGraphTransition(previousNodeId: string | undefined, currentNodeId: string) {
  if (!previousNodeId) return "start" as const;
  const relationship = explorationNodeRelationshipByChildId.get(previousNodeId);
  if (relationship?.related_node_ids.includes(currentNodeId)) return "related" as const;
  if (relationship?.bridge_node_ids.includes(currentNodeId)) return "bridge" as const;
  if (relationship?.opposite_node_ids.includes(currentNodeId)) return "opposite" as const;
  return "none" as const;
}

function runSimulation(options: SimulationOptions) {
  const users = createVirtualUsers(options);
  const records: DeliveryRecord[] = [];

  for (const user of users) {
    for (let index = 0; index < options.cardsPerUser; index += 1) {
      const previousNodeId = user.deliveredNodeIds.at(-1);
      const decision: DeliveryDecision = createDeliveryDecision({
        state: user.state,
        history: user.history,
        nodeProgress: [...user.progress.values()],
        userLanguage: "ko",
      });
      const selected = decision.selectedNode;
      const graphTransition = detectGraphTransition(previousNodeId, selected.id);

      records.push({
        userId: user.id,
        archetype: user.archetype.name,
        index: index + 1,
        childNodeId: selected.id,
        childNode: selected.name,
        parentNode: selected.parentName,
        cardType: decision.payload.desired_card_type,
        timeAxis: decision.payload.time_axis,
        depthLevel: decision.payload.depth_level,
        graphTransition,
      });

      const historyItem = makeHistoryItem(
        selected,
        options.cardsPerUser * Number(user.id.slice(-3)) + index,
        decision.payload.desired_card_type,
        decision.payload.time_axis,
        decision.payload.depth_level,
      );
      user.history.unshift(historyItem);
      user.deliveredNodeIds.push(selected.id);
      applyProgress(user, selected);
      user.state = {
        totalCardsAnswered: user.state.totalCardsAnswered + 1,
        currentDepthLevel: decision.payload.depth_level,
      };
    }
  }

  return { users, records };
}

function countBy<T extends string | number>(items: readonly T[]) {
  const counts = new Map<T, number>();
  for (const item of items) counts.set(item, (counts.get(item) ?? 0) + 1);
  return counts;
}

function percent(count: number, total: number) {
  return total === 0 ? 0 : Number(((count / total) * 100).toFixed(2));
}

function distribution<T extends string>(
  keys: readonly T[],
  counts: Map<T, number>,
  total: number,
) {
  return Object.fromEntries(keys.map((key) => [key, percent(counts.get(key) ?? 0, total)])) as Record<T, number>;
}

function detectLoops(sequence: readonly string[]) {
  const examples: string[] = [];
  let loops = 0;

  for (let index = 3; index < sequence.length; index += 1) {
    const a = sequence[index - 3];
    const b = sequence[index - 2];
    const c = sequence[index - 1];
    const d = sequence[index];
    if (a === c && b === d && a !== b) {
      loops += 1;
      if (examples.length < 10) examples.push([a, b, c, d].join(" -> "));
    }
  }

  for (let index = 5; index < sequence.length; index += 1) {
    const first = sequence.slice(index - 5, index - 2).join("|");
    const second = sequence.slice(index - 2, index + 1).join("|");
    if (first === second) {
      loops += 1;
      if (examples.length < 10) examples.push(sequence.slice(index - 5, index + 1).join(" -> "));
    }
  }

  return { loops, examples };
}

function analyze(options: SimulationOptions, users: readonly VirtualUser[], records: readonly DeliveryRecord[]): SimulationReport {
  const total = records.length;
  const nodeCounts = countBy(records.map((record) => record.childNodeId));
  const parentCounts = countBy(records.map((record) => record.parentNode));
  const depthCounts = countBy(records.map((record) => String(record.depthLevel)));
  const cardTypeCounts = countBy(records.map((record) => record.cardType));
  const timeAxisCounts = countBy(records.map((record) => record.timeAxis));
  const graphCounts = countBy(records.map((record) => record.graphTransition));
  const exploredNodeIds = new Set(records.map((record) => record.childNodeId));
  const repeatedDeliveries = records.filter((record, index) =>
    records.findIndex((candidate) =>
      candidate.userId === record.userId && candidate.childNodeId === record.childNodeId
    ) !== index
  ).length;

  const loopsByUser = users.map((user) => ({
    user,
    ...detectLoops(user.deliveredNodeIds),
  }));
  const totalLoops = loopsByUser.reduce((sum, item) => sum + item.loops, 0);
  const loopExamples = loopsByUser.flatMap((item) => item.examples).slice(0, 10);

  const nodeFrequencies: NodeFrequency[] = explorationChildNodes.map((node) => ({
    childNodeId: node.id,
    childNode: node.name,
    parentNode: node.parentName,
    count: nodeCounts.get(node.id) ?? 0,
    percent: percent(nodeCounts.get(node.id) ?? 0, total),
  }));
  const meanNodeCount = total / explorationChildNodes.length;
  const hotThreshold = Math.max(1, meanNodeCount * 3);
  const topNodes = [...nodeFrequencies].sort((a, b) => b.count - a.count).slice(0, 20);
  const deadNodes = nodeFrequencies.filter((node) => node.count === 0);
  const hotNodes = nodeFrequencies.filter((node) => node.count > hotThreshold)
    .sort((a, b) => b.count - a.count);

  const parentDistribution = distribution(
    explorationParentNodes.map((parent) => parent.name),
    parentCounts,
    total,
  );
  const idealParentPercent = 100 / explorationParentNodes.length;
  const maxParentDeviation = Math.max(
    ...Object.values(parentDistribution).map((value) => Math.abs(value - idealParentPercent)),
  );

  const archetypeSummaries = archetypes.map((archetype) => {
    const archetypeRecords = records.filter((record) => record.archetype === archetype.name);
    const archetypeParentCounts = countBy(archetypeRecords.map((record) => record.parentNode));
    const topParents = [...archetypeParentCounts.entries()]
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3)
      .map(([parent, count]) => [parent, percent(count, archetypeRecords.length)] as [string, number]);
    return {
      archetype: archetype.name,
      users: users.filter((user) => user.archetype.name === archetype.name).length,
      childNodeCoveragePercent: percent(
        new Set(archetypeRecords.map((record) => record.childNodeId)).size,
        explorationChildNodes.length,
      ),
      topParents,
    };
  });

  const graphUsage = distribution(
    ["related", "bridge", "opposite", "none", "start"] as const,
    graphCounts,
    total,
  );
  const loopRatePercent = percent(totalLoops, total);
  const childCoveragePercent = percent(exploredNodeIds.size, explorationChildNodes.length);

  const recommendations = buildRecommendations({
    childCoveragePercent,
    deadNodes,
    hotNodes,
    maxParentDeviation,
    loopRatePercent,
    graphUsage,
    parentDistribution,
  });

  return {
    generatedAt: new Date().toISOString(),
    options,
    totals: {
      users: users.length,
      cardsDelivered: total,
      childNodeCoveragePercent: childCoveragePercent,
      uniqueChildNodesExplored: exploredNodeIds.size,
      totalChildNodes: explorationChildNodes.length,
      repeatedNodeFrequencyPercent: percent(repeatedDeliveries, total),
      loopRatePercent,
      deadNodeCount: deadNodes.length,
      hotNodeCount: hotNodes.length,
      parentDistributionMaxDeviationPercent: Number(maxParentDeviation.toFixed(2)),
    },
    successCriteria: {
      childNodeCoverageAbove90: childCoveragePercent > 90,
      parentDistributionVarianceBelow15: maxParentDeviation < 15,
      loopRateBelow5: loopRatePercent < 5,
      deadNodesZero: deadNodes.length === 0,
      depthProgressionHealthy: (depthCounts.get("1") ?? 0) > 0 && (depthCounts.get("4") ?? 0) > 0,
      graphUsageBalanced: (graphCounts.get("related") ?? 0) > 0 &&
        (graphCounts.get("bridge") ?? 0) > 0 &&
        (graphCounts.get("opposite") ?? 0) > 0,
    },
    parentDistribution,
    depthDistribution: distribution(["1", "2", "3", "4", "5"], depthCounts, total),
    cardTypeDistribution: distribution(allCardTypes, cardTypeCounts, total),
    timeAxisDistribution: distribution(allTimeAxes, timeAxisCounts, total),
    graphUsage,
    topNodes,
    deadNodes,
    hotNodes,
    loopDetection: {
      totalLoops,
      loopRatePercent,
      examples: loopExamples,
    },
    archetypeSummaries,
    recommendations,
  };
}

function buildRecommendations(input: {
  childCoveragePercent: number;
  deadNodes: readonly NodeFrequency[];
  hotNodes: readonly NodeFrequency[];
  maxParentDeviation: number;
  loopRatePercent: number;
  graphUsage: Record<DeliveryRecord["graphTransition"], number>;
  parentDistribution: Record<string, number>;
}) {
  const recommendations: string[] = [];
  if (input.childCoveragePercent <= 90) {
    recommendations.push("Increase underexplored-node scoring or reduce graph continuation weight until child coverage exceeds 90%.");
  }
  if (input.deadNodes.length > 0) {
    recommendations.push("Add bridge or related inbound paths to dead nodes, especially nodes with zero selections across the full run.");
  }
  if (input.hotNodes.length > 0) {
    recommendations.push("Reduce graph or semantic-group weight for hot nodes, or add a stronger per-user repeat penalty.");
  }
  if (input.maxParentDeviation >= 15) {
    const mostSelected = Object.entries(input.parentDistribution).sort((a, b) => b[1] - a[1])[0];
    recommendations.push(`Parent coverage is imbalanced; inspect scoring pressure around ${mostSelected?.[0] ?? "the leading parent"}.`);
  }
  if (input.loopRatePercent >= 5) {
    recommendations.push("Increase loop penalties for ABAB and ABCABC paths, or expand recent-child exclusion beyond 10 for long sessions.");
  }
  if (input.graphUsage.opposite < 1) {
    recommendations.push("Opposite-node traversal is low; consider a controlled contrast boost after several related/bridge moves.");
  }
  if (recommendations.length === 0) {
    recommendations.push("Simulation meets the first-pass health targets. Next tuning pass should compare reports across larger seeds.");
  }
  return recommendations;
}

function renderMarkdown(report: SimulationReport) {
  const lines: string[] = [];
  lines.push("# Exploration Simulation Report", "");
  lines.push("## Summary", "");
  lines.push(`- Generated: ${report.generatedAt}`);
  lines.push(`- Users: ${report.totals.users}`);
  lines.push(`- Cards delivered: ${report.totals.cardsDelivered}`);
  lines.push(`- Child node coverage: ${report.totals.childNodeCoveragePercent}%`);
  lines.push(`- Dead nodes: ${report.totals.deadNodeCount}`);
  lines.push(`- Loop rate: ${report.totals.loopRatePercent}%`);
  lines.push("");
  lines.push("## Coverage", "");
  lines.push(`- Unique child nodes explored: ${report.totals.uniqueChildNodesExplored}/${report.totals.totalChildNodes}`);
  lines.push(`- Repeated node frequency: ${report.totals.repeatedNodeFrequencyPercent}%`);
  lines.push(`- Hot nodes: ${report.totals.hotNodeCount}`);
  lines.push("");
  lines.push("## Parent Distribution", "");
  for (const [parent, value] of Object.entries(report.parentDistribution)) {
    lines.push(`- ${parent}: ${value}%`);
  }
  lines.push("");
  lines.push("## Depth Distribution", "");
  for (const [depth, value] of Object.entries(report.depthDistribution)) {
    lines.push(`- Depth ${depth}: ${value}%`);
  }
  lines.push("");
  lines.push("## Card Type Distribution", "");
  for (const [type, value] of Object.entries(report.cardTypeDistribution)) {
    lines.push(`- ${type}: ${value}%`);
  }
  lines.push("");
  lines.push("## Time Axis Distribution", "");
  for (const [axis, value] of Object.entries(report.timeAxisDistribution)) {
    lines.push(`- ${axis}: ${value}%`);
  }
  lines.push("");
  lines.push("## Top Nodes", "");
  for (const node of report.topNodes.slice(0, 10)) {
    lines.push(`- ${node.childNode} (${node.parentNode}): ${node.count} (${node.percent}%)`);
  }
  lines.push("");
  lines.push("## Dead Nodes", "");
  if (report.deadNodes.length === 0) lines.push("- None");
  else for (const node of report.deadNodes.slice(0, 50)) lines.push(`- ${node.childNode} (${node.parentNode})`);
  lines.push("");
  lines.push("## Loop Detection", "");
  lines.push(`- Total loops: ${report.loopDetection.totalLoops}`);
  lines.push(`- Loop rate: ${report.loopDetection.loopRatePercent}%`);
  if (report.loopDetection.examples.length > 0) {
    lines.push("- Examples:");
    for (const example of report.loopDetection.examples) lines.push(`  - ${example}`);
  }
  lines.push("");
  lines.push("## Graph Usage", "");
  for (const [type, value] of Object.entries(report.graphUsage)) {
    lines.push(`- ${type}: ${value}%`);
  }
  lines.push("");
  lines.push("## Archetype Summaries", "");
  for (const summary of report.archetypeSummaries) {
    lines.push(`- ${summary.archetype}: ${summary.users} users, ${summary.childNodeCoveragePercent}% child coverage, top parents ${summary.topParents.map(([parent, value]) => `${parent} ${value}%`).join(", ")}`);
  }
  lines.push("");
  lines.push("## Success Criteria", "");
  for (const [criterion, passed] of Object.entries(report.successCriteria)) {
    lines.push(`- ${criterion}: ${passed ? "PASS" : "FAIL"}`);
  }
  lines.push("");
  lines.push("## Recommendations", "");
  for (const recommendation of report.recommendations) {
    lines.push(`- ${recommendation}`);
  }
  lines.push("");
  return lines.join("\n");
}

function writeReports(report: SimulationReport) {
  const outputDir = resolve(report.options.outputDir);
  mkdirSync(outputDir, { recursive: true });
  const jsonPath = resolve(outputDir, "simulation-report.json");
  const markdownPath = resolve(outputDir, "simulation-report.md");
  writeFileSync(jsonPath, `${JSON.stringify(report, null, 2)}\n`, "utf8");
  writeFileSync(markdownPath, renderMarkdown(report), "utf8");
  return { jsonPath, markdownPath };
}

const options = parseArgs();
if (options.users <= 0 || options.cardsPerUser <= 0) {
  throw new Error("Simulation requires positive --users and --cards values.");
}

const { users, records } = runSimulation(options);
const report = analyze(options, users, records);
const paths = writeReports(report);

console.log(JSON.stringify({
  reportJson: paths.jsonPath,
  reportMarkdown: paths.markdownPath,
  summary: report.totals,
  successCriteria: report.successCriteria,
}, null, 2));
