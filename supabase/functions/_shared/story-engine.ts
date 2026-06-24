export type StoryType =
  | "current_chapter"
  | "emerging_direction"
  | "internal_tension"
  | "hidden_territory"
  | "change_over_time";

export type UserStoryOutput = {
  readonly story_type: StoryType;
  readonly title: string;
  readonly description: string;
  readonly supporting_insights: readonly SupportingInsight[];
};

export type UserStoryFeedItem = {
  readonly story_id: string;
  readonly story_type: StoryType;
  readonly title: string;
  readonly description: string;
  readonly supporting_insights: readonly SupportingInsight[];
};

export type StoryInsightRow = {
  readonly id: string;
  readonly insight_type: string;
  readonly title: string;
  readonly description: string;
  readonly supporting_nodes?: unknown;
  readonly active?: boolean;
  readonly updated_at: string;
};

export type StoryHistoryRow = {
  readonly parent_node?: string | null;
  readonly parent_node_id?: string | null;
  readonly child_node?: string | null;
  readonly child_node_id?: string | null;
  readonly answered: boolean;
  readonly created_at: string;
};

export type StoryRefreshResult = {
  readonly refreshed: boolean;
  readonly reason: "initial" | "twenty_five_card_interval" | "insight_change" | "not_due" | "insufficient_insights";
  readonly answered_count: number;
  readonly insight_count: number;
  readonly generated_count: number;
  readonly insight_signature: string;
};

type SupportingInsight = {
  readonly insight_id: string;
  readonly insight_type: string;
  readonly title: string;
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

const MIN_SUPPORTING_INSIGHTS = 3;
const MAX_STORIES_PER_REFRESH = 5;

function explorationLabel(value: string) {
  return value
    .replaceAll("분석", "살펴보기")
    .replaceAll("평가", "바라보기")
    .replaceAll("진단", "탐험")
    .replaceAll("유형", "모습")
    .replaceAll("점수", "흐름")
    .replaceAll("등급", "흐름")
    .replaceAll("상위", "큰")
    .replaceAll("하위", "작은")
    .replaceAll("검사", "탐험")
    .replaceAll("프로파일", "이야기");
}

function normalizeInsights(insights: readonly StoryInsightRow[]) {
  return [...insights]
    .filter((insight) => insight.active !== false)
    .filter((insight) => insight.title.trim().length > 0 && insight.description.trim().length > 0)
    .sort((a, b) => Date.parse(a.updated_at) - Date.parse(b.updated_at));
}

function normalizeHistory(history: readonly StoryHistoryRow[]) {
  return [...history]
    .filter((item) => item.answered)
    .sort((a, b) => Date.parse(a.created_at) - Date.parse(b.created_at));
}

function supportFromInsights(insights: readonly StoryInsightRow[], limit = 5): SupportingInsight[] {
  return insights.slice(-limit).map((insight) => ({
    insight_id: insight.id,
    insight_type: insight.insight_type,
    title: explorationLabel(insight.title),
  }));
}

function byType(insights: readonly StoryInsightRow[], insightType: string) {
  return insights.filter((insight) => insight.insight_type === insightType);
}

function uniqueParentNames(history: readonly StoryHistoryRow[]) {
  const names: string[] = [];
  for (const row of history) {
    const name = row.parent_node?.trim() || row.parent_node_id?.trim();
    if (name && !names.includes(name)) names.push(name);
  }
  return names;
}

function assertNoReportLanguage(story: UserStoryOutput) {
  const blocked = [
    "You are",
    "you are",
    "personality type",
    "diagnosis",
    "score",
    "percent",
    "ranking",
    "rank",
    "assessment",
    "profile",
  ];
  const text = `${story.title} ${story.description}`;
  if (blocked.some((word) => text.includes(word))) {
    throw new Error(`story_report_language_detected:${story.title}`);
  }
}

function pushStory(target: UserStoryOutput[], story: UserStoryOutput) {
  if (story.supporting_insights.length < MIN_SUPPORTING_INSIGHTS) return;
  assertNoReportLanguage(story);
  if (!target.some((item) => item.story_type === story.story_type && item.title === story.title)) {
    target.push(story);
  }
}

function currentChapterStory(insights: readonly StoryInsightRow[], history: readonly StoryHistoryRow[]) {
  if (insights.length < MIN_SUPPORTING_INSIGHTS) return null;
  const parents = uniqueParentNames(history).slice(-4);
  const areaText = parents.length > 0
    ? ` ${parents.map(explorationLabel).join(", ")}에서`
    : " 최근 탐험에서";
  return {
    story_type: "current_chapter",
    title: "현재의 장",
    description:
      `최근 탐험은${areaText} 여러 흐름을 천천히 모으고 있어요. 아직 고정된 결론은 아니지만, 몇 가지 발견이 서로 가까이 놓이기 시작합니다.`,
    supporting_insights: supportFromInsights(insights, 5),
  } satisfies UserStoryOutput;
}

function emergingDirectionStory(insights: readonly StoryInsightRow[]) {
  const candidates = insights.filter((insight) =>
    insight.insight_type === "emerging_pattern" ||
    insight.insight_type === "consistent_theme"
  );
  if (candidates.length < MIN_SUPPORTING_INSIGHTS) return null;
  return {
    story_type: "emerging_direction",
    title: "선명해지는 방향",
    description:
      "반복해서 나타나는 발견 사이에서 하나의 방향이 조금씩 또렷해지고 있어요. 정해진 답이라기보다, 조금 더 머물러 살펴볼 만한 길처럼 보입니다.",
    supporting_insights: supportFromInsights(candidates, 5),
  } satisfies UserStoryOutput;
}

function internalTensionStory(insights: readonly StoryInsightRow[]) {
  const tensions = byType(insights, "internal_tension");
  if (tensions.length < MIN_SUPPORTING_INSIGHTS) return null;
  return {
    story_type: "internal_tension",
    title: "함께 나타나는 두 흐름",
    description:
      "몇 가지 발견은 서로 다른 흐름이 나란히 나타나는 장면을 보여줘요. 상황과 선택에 따라 다른 필요가 함께 움직이는 모습으로 읽힙니다.",
    supporting_insights: supportFromInsights(tensions, 5),
  } satisfies UserStoryOutput;
}

function hiddenTerritoryStory(insights: readonly StoryInsightRow[]) {
  const gaps = byType(insights, "exploration_gap");
  if (gaps.length < MIN_SUPPORTING_INSIGHTS) return null;
  return {
    story_type: "hidden_territory",
    title: "아직 조용한 영역",
    description:
      "우주의 몇몇 영역은 아직 다른 곳보다 조용하게 남아 있어요. 부족함이 아니라, 탐험이 닿을 때 새롭게 의미가 생길 수 있는 열린 공간에 가깝습니다.",
    supporting_insights: supportFromInsights(gaps, 5),
  } satisfies UserStoryOutput;
}

function changeOverTimeStory(insights: readonly StoryInsightRow[]) {
  const changes = byType(insights, "change_over_time");
  if (changes.length < MIN_SUPPORTING_INSIGHTS) return null;
  return {
    story_type: "change_over_time",
    title: "변화의 흔적",
    description:
      "최근 발견에서는 여정이 조금씩 달라지는 흔적이 보입니다. 아직 단정할 수는 없지만, 새로 나타난 흐름이 이전의 장면과 다른 결을 만들고 있어요.",
    supporting_insights: supportFromInsights(changes, 5),
  } satisfies UserStoryOutput;
}

export function generateUserStories(input: {
  readonly insights: readonly StoryInsightRow[];
  readonly history: readonly StoryHistoryRow[];
}) {
  const insights = normalizeInsights(input.insights);
  const history = normalizeHistory(input.history);
  const stories: UserStoryOutput[] = [];

  const builders = [
    currentChapterStory(insights, history),
    emergingDirectionStory(insights),
    internalTensionStory(insights),
    hiddenTerritoryStory(insights),
    changeOverTimeStory(insights),
  ];
  for (const story of builders) {
    if (story) pushStory(stories, story);
  }

  return stories.slice(0, MAX_STORIES_PER_REFRESH);
}

export function buildStoryInsightSignature(insights: readonly StoryInsightRow[]) {
  return normalizeInsights(insights)
    .slice(-20)
    .map((insight) => `${insight.id}:${insight.insight_type}:${Date.parse(insight.updated_at) || 0}`)
    .join("|");
}

export function decideStoryRefresh(input: {
  readonly answeredCount: number;
  readonly insightCount: number;
  readonly lastAnsweredCount?: number | null;
  readonly lastInsightSignature?: string | null;
  readonly insightSignature: string;
}) {
  if (input.insightCount < MIN_SUPPORTING_INSIGHTS) return "insufficient_insights" as const;
  if (!input.lastAnsweredCount) return "initial" as const;
  if (input.answeredCount - input.lastAnsweredCount >= 25) return "twenty_five_card_interval" as const;
  if (input.insightSignature !== input.lastInsightSignature) return "insight_change" as const;
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

export async function refreshUserStories(
  supabase: SupabaseLike,
  userId: string,
  options: { force?: boolean } = {},
): Promise<StoryRefreshResult> {
  const [insights, history] = await Promise.all([
    selectRows<StoryInsightRow>(
      supabase,
      "user_insights",
      "id,insight_type,title,description,supporting_nodes,active,updated_at",
      userId,
      { order: "updated_at", ascending: true, limit: 80 },
    ),
    selectRows<StoryHistoryRow>(
      supabase,
      "user_card_history",
      "parent_node,parent_node_id,child_node,child_node_id,answered,created_at",
      userId,
      { order: "created_at", ascending: true, limit: 300 },
    ),
  ]);
  const activeInsights = normalizeInsights(insights);
  const answeredCount = normalizeHistory(history).length;
  const insightSignature = buildStoryInsightSignature(activeInsights);
  const state = await maybeSingle<{
    last_answered_count: number;
    last_insight_signature: string | null;
  }>(
    supabase,
    "user_story_refresh_state",
    "last_answered_count,last_insight_signature",
    userId,
  );
  const reason = options.force && activeInsights.length >= MIN_SUPPORTING_INSIGHTS
    ? "initial"
    : decideStoryRefresh({
      answeredCount,
      insightCount: activeInsights.length,
      lastAnsweredCount: state?.last_answered_count ?? null,
      lastInsightSignature: state?.last_insight_signature ?? null,
      insightSignature,
    });

  if (reason === "not_due" || reason === "insufficient_insights") {
    return {
      refreshed: false,
      reason,
      answered_count: answeredCount,
      insight_count: activeInsights.length,
      generated_count: 0,
      insight_signature: insightSignature,
    };
  }

  const stories = generateUserStories({ insights: activeInsights, history });
  const deactivate = supabase.from("user_stories").update({ active: false });
  const deactivateResult = await deactivate.eq("user_id", userId);
  if (deactivateResult.error) throw deactivateResult.error;

  if (stories.length > 0) {
    const rows = stories.map((story) => ({
      user_id: userId,
      story_type: story.story_type,
      title: story.title,
      description: story.description,
      supporting_insights: story.supporting_insights,
      active: true,
    }));
    const upsertResult = await supabase
      .from("user_stories")
      .upsert(rows, { onConflict: "user_id,story_type,title" });
    if (upsertResult.error) throw upsertResult.error;
  }

  const stateResult = await supabase
    .from("user_story_refresh_state")
    .upsert({
      user_id: userId,
      last_answered_count: answeredCount,
      last_insight_signature: insightSignature,
      last_refreshed_at: new Date().toISOString(),
    }, { onConflict: "user_id" });
  if (stateResult.error) throw stateResult.error;

  return {
    refreshed: true,
    reason,
    answered_count: answeredCount,
    insight_count: activeInsights.length,
    generated_count: stories.length,
    insight_signature: insightSignature,
  };
}

export function toStoryFeedItem(row: Record<string, unknown>): UserStoryFeedItem {
  return {
    story_id: String(row.id),
    story_type: row.story_type as StoryType,
    title: String(row.title),
    description: String(row.description),
    supporting_insights: Array.isArray(row.supporting_insights)
      ? row.supporting_insights as SupportingInsight[]
      : [],
  };
}
