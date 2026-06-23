import {
  createDeliveryDecision,
  getAllowedDepthRange,
  scoreCandidateNodes,
  selectDepthLevel,
  selectCardType,
  selectTimeAxis,
  type UserCardHistoryItem,
} from "./card-delivery-engine.ts";

function assert(condition: unknown, message: string) {
  if (!condition) throw new Error(message);
}

const historyItem = (
  overrides: Partial<UserCardHistoryItem>,
  index: number,
): UserCardHistoryItem => ({
  parentNode: "자아상",
  childNode: `자기인식-${index}`,
  cardType: "scenario_choice",
  depthLevel: 1,
  timeAxis: "present",
  answered: true,
  createdAt: new Date(Date.UTC(2026, 0, 1, 0, index)).toISOString(),
  ...overrides,
});

Deno.test("depth range follows answered-card progression", () => {
  assert(getAllowedDepthRange(0).join(",") === "1,2", "0 answers should allow depth 1-2");
  assert(getAllowedDepthRange(20).join(",") === "1,2", "20 answers should allow depth 1-2");
  assert(getAllowedDepthRange(21).join(",") === "2,3", "21 answers should allow depth 2-3");
  assert(getAllowedDepthRange(101).join(",") === "3,4", "101 answers should allow depth 3-4");
  assert(getAllowedDepthRange(301).join(",") === "4,5", "301 answers should allow depth 4-5");
});

Deno.test("depth selection advances gradually within the allowed band", () => {
  assert(
    selectDepthLevel({ totalCardsAnswered: 0, currentDepthLevel: 1 }) === 1,
    "new users should start at depth 1",
  );
  assert(
    selectDepthLevel({ totalCardsAnswered: 20, currentDepthLevel: 1 }) === 2,
    "late in the first band can advance to depth 2",
  );
  assert(
    selectDepthLevel({ totalCardsAnswered: 301, currentDepthLevel: 3 }) === 4,
    "depth must not jump by more than one level",
  );
});

Deno.test("card type selection breaks overlong streaks", () => {
  const history = [0, 1, 2, 3].map((index) => historyItem({
    cardType: "scenario_choice",
  }, index));

  assert(
    selectCardType(history) !== "scenario_choice",
    "scenario_choice should be blocked after max streak",
  );
});

Deno.test("time axis selection breaks overlong streaks", () => {
  const history = [0, 1, 2].map((index) => historyItem({
    timeAxis: "present",
  }, index));

  assert(selectTimeAxis(history) !== "present", "present should be blocked after max streak");
});

Deno.test("node selection excludes the last ten child nodes", () => {
  const recent = Array.from({ length: 10 }, (_, index) =>
    historyItem({
      parentNode: "자아상",
      childNode: `child-${index}`,
      childNodeId: `parent_01_child_${String(index + 1).padStart(2, "0")}`,
    }, index)
  );

  const decision = createDeliveryDecision({
    state: { totalCardsAnswered: 5, currentDepthLevel: 1 },
    history: recent,
    nodeProgress: [],
  });

  assert(
    !recent.some((item) => item.childNodeId === decision.selectedNode.id),
    "selected node must not be in the recent child exclusion window",
  );
});

Deno.test("relationship graph contributes exploration-journey score", () => {
  const scores = scoreCandidateNodes([
    historyItem({
      parentNode: "가치관",
      childNode: "자유",
      childNodeId: "parent_05_child_01",
    }, 0),
  ], []);

  const related = scores.find((score) => score.childNodeId === "parent_05_child_24");
  const bridge = scores.find((score) => score.childNodeId === "parent_06_child_12");
  const contrast = scores.find((score) => score.childNodeId === "parent_05_child_02");

  assert(
    related?.reasons.includes("graph_related_continuation"),
    "freedom should continue into independence",
  );
  assert(
    bridge?.reasons.includes("graph_bridge_expansion"),
    "freedom should bridge into freedom motivation",
  );
  assert(
    contrast?.reasons.includes("graph_opposite_contrast"),
    "freedom should contrast with stability",
  );
});
