import {
  buildStoryInsightSignature,
  decideStoryRefresh,
  generateUserStories,
  type StoryHistoryRow,
  type StoryInsightRow,
} from "./story-engine.ts";

function assert(condition: unknown, message: string) {
  if (!condition) throw new Error(message);
}

const insight = (
  index: number,
  overrides: Partial<StoryInsightRow> = {},
): StoryInsightRow => ({
  id: `insight-${index}`,
  insight_type: "consistent_theme",
  title: `Insight ${index}`,
  description: `Observation ${index}`,
  active: true,
  updated_at: new Date(Date.UTC(2026, 0, 1, 0, index)).toISOString(),
  ...overrides,
});

const history = (
  index: number,
  overrides: Partial<StoryHistoryRow> = {},
): StoryHistoryRow => ({
  parent_node: `Area ${index}`,
  parent_node_id: `parent_${String(index).padStart(2, "0")}`,
  child_node: `Node ${index}`,
  child_node_id: `parent_${String(index).padStart(2, "0")}_child_01`,
  answered: true,
  created_at: new Date(Date.UTC(2026, 0, 2, 0, index)).toISOString(),
  ...overrides,
});

Deno.test("stories require at least three supporting insights", () => {
  const stories = generateUserStories({
    insights: [insight(1), insight(2)],
    history: [history(1), history(2), history(3)],
  });

  assert(stories.length === 0, "weak evidence must not create a story");
});

Deno.test("current chapter and emerging direction use multiple insights", () => {
  const stories = generateUserStories({
    insights: [insight(1), insight(2), insight(3), insight(4)],
    history: [history(1), history(2), history(3), history(4)],
  });

  const current = stories.find((story) => story.story_type === "current_chapter");
  const direction = stories.find((story) => story.story_type === "emerging_direction");
  assert(Boolean(current), "current chapter should be generated");
  assert(Boolean(direction), "emerging direction should be generated");
  assert(
    current!.supporting_insights.length >= 3,
    "stories must retain supporting insight references",
  );
});

Deno.test("type-specific stories require three matching insights", () => {
  const stories = generateUserStories({
    insights: [
      insight(1, { insight_type: "internal_tension" }),
      insight(2, { insight_type: "internal_tension" }),
      insight(3, { insight_type: "internal_tension" }),
      insight(4, { insight_type: "exploration_gap" }),
      insight(5, { insight_type: "exploration_gap" }),
      insight(6, { insight_type: "exploration_gap" }),
      insight(7, { insight_type: "change_over_time" }),
      insight(8, { insight_type: "change_over_time" }),
      insight(9, { insight_type: "change_over_time" }),
    ],
    history: Array.from({ length: 9 }, (_, index) => history(index + 1)),
  });

  assert(
    stories.some((story) => story.story_type === "internal_tension"),
    "three tension insights should create a tension story",
  );
  assert(
    stories.some((story) => story.story_type === "hidden_territory"),
    "three gap insights should create hidden territory",
  );
  assert(
    stories.some((story) => story.story_type === "change_over_time"),
    "three change insights should create change over time",
  );
});

Deno.test("story language avoids report and scoring terms", () => {
  const stories = generateUserStories({
    insights: [insight(1), insight(2), insight(3)],
    history: [history(1), history(2), history(3)],
  });
  const text = stories.map((story) => `${story.title} ${story.description}`).join(" ");

  for (const blocked of ["You are", "personality type", "diagnosis", "score", "assessment", "profile"]) {
    assert(!text.includes(blocked), `story copy must not include ${blocked}`);
  }
});

Deno.test("refresh cadence follows first, insight change, and 25-card interval", () => {
  const signature = buildStoryInsightSignature([insight(1), insight(2), insight(3)]);
  assert(
    decideStoryRefresh({
      answeredCount: 3,
      insightCount: 2,
      insightSignature: signature,
    }) === "insufficient_insights",
    "less than three insights should not refresh",
  );
  assert(
    decideStoryRefresh({
      answeredCount: 10,
      insightCount: 3,
      insightSignature: signature,
    }) === "initial",
    "first eligible story refresh should run",
  );
  assert(
    decideStoryRefresh({
      answeredCount: 35,
      insightCount: 3,
      lastAnsweredCount: 10,
      lastInsightSignature: signature,
      insightSignature: signature,
    }) === "twenty_five_card_interval",
    "25 more answers should refresh stories",
  );
  assert(
    decideStoryRefresh({
      answeredCount: 12,
      insightCount: 3,
      lastAnsweredCount: 10,
      lastInsightSignature: "old",
      insightSignature: signature,
    }) === "insight_change",
    "changed insight signature should refresh stories",
  );
});
