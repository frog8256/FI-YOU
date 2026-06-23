import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import {
  createDeliveryDecision,
  type ExplorationCardRequestPayload,
  type UserCardHistoryItem,
  type UserNodeProgressItem,
} from "../_shared/card-delivery-engine.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (status: number, body: Record<string, unknown>) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

type DeliveryRequest = {
  userLanguage?: string;
  persistHistory?: boolean;
};

type CardType = ExplorationCardRequestPayload["desired_card_type"];
type TimeAxis = ExplorationCardRequestPayload["time_axis"];

type DeliveredCard = {
  card_id: string;
  card_type: CardType;
  question: string;
  options: { id: string; label: string }[];
  required_selections: number;
};

const fallbackOptions: Record<CardType, string[]> = {
  binary_choice: [
    "네, 지금은 이쪽에 가까워요",
    "아니요, 다른 흐름이 더 가까워요",
  ],
  multiple_choice: [
    "혼자 조용히 정리하는 쪽",
    "사람들과 나누며 확인하는 쪽",
    "새로운 시도를 해보는 쪽",
    "익숙한 리듬을 지키는 쪽",
  ],
  priority_selection: [
    "내 선택의 기준",
    "반복되는 감정",
    "관계 안의 거리감",
    "행동으로 옮기는 힘",
    "앞으로의 방향",
  ],
  scenario_choice: [
    "잠시 멈추고 마음을 살펴보는 장면",
    "대화를 통해 실마리를 찾는 장면",
    "직접 움직이며 확인해보는 장면",
    "익숙한 방식으로 안정감을 찾는 장면",
  ],
};

function normalizeGeneratedCard(
  generatedCard: unknown,
  fallbackCardId: string,
  payload: ExplorationCardRequestPayload,
): DeliveredCard {
  const source = generatedCard && typeof generatedCard === "object"
    ? generatedCard as Record<string, unknown>
    : {};
  const cardType = (source.card_type ?? source.cardType ?? payload.desired_card_type) as CardType;
  const rawOptions = Array.isArray(source.options) ? source.options : [];
  const options = rawOptions
    .map((option, index) => {
      if (typeof option === "string") return { id: `option_${index + 1}`, label: option };
      if (option && typeof option === "object") {
        const item = option as Record<string, unknown>;
        return {
          id: String(item.id ?? item.option_id ?? `option_${index + 1}`),
          label: String(item.label ?? item.text ?? item.title ?? ""),
        };
      }
      return { id: `option_${index + 1}`, label: "" };
    })
    .filter((option) => option.label.trim().length > 0);
  const fallback = fallbackOptions[cardType] ?? fallbackOptions.scenario_choice;

  return {
    card_id: String(source.card_id ?? source.cardId ?? fallbackCardId),
    card_type: cardType,
    question: String(
      source.question ??
        source.prompt ??
        `${payload.child_node_description} 지금의 나에게는 어떤 장면으로 떠오르나요?`,
    ),
    options: options.length > 0
      ? options
      : fallback.map((label, index) => ({ id: `option_${index + 1}`, label })),
    required_selections: cardType === "priority_selection"
      ? Number(source.required_selections ?? source.requiredSelections ?? 2)
      : 1,
  };
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (request.method !== "POST") return json(405, { error: "method_not_allowed" });

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !serviceRoleKey) throw new Error("missing_supabase_env");

    const authHeader = request.headers.get("Authorization") ?? "";
    const jwt = authHeader.replace(/^Bearer\s+/i, "");
    if (!jwt) return json(401, { error: "missing_authorization" });

    const body = await request.json().catch(() => ({})) as DeliveryRequest;
    const admin = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });

    const { data: userData, error: userError } = await admin.auth.getUser(jwt);
    if (userError || !userData.user) return json(401, { error: "invalid_user_session" });
    const userId = userData.user.id;

    const { data: stateRow, error: stateError } = await admin
      .from("user_exploration_state")
      .select("total_cards_answered,current_depth_level")
      .eq("user_id", userId)
      .maybeSingle();
    if (stateError) throw stateError;

    const { data: historyRows, error: historyError } = await admin
      .from("user_card_history")
      .select("parent_node,parent_node_id,child_node,child_node_id,card_type,depth_level,time_axis,answered,created_at")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(100);
    if (historyError) throw historyError;

    const { data: progressRows, error: progressError } = await admin
      .from("user_node_progress")
      .select("parent_node,parent_node_id,child_node,child_node_id,times_explored,last_explored_at,coverage_score")
      .eq("user_id", userId);
    if (progressError) throw progressError;

    const decision = createDeliveryDecision({
      state: {
        totalCardsAnswered: Number(stateRow?.total_cards_answered ?? 0),
        currentDepthLevel: Number(stateRow?.current_depth_level ?? 1),
      },
      history: (historyRows ?? []).map((row): UserCardHistoryItem => ({
        parentNode: row.parent_node,
        parentNodeId: row.parent_node_id,
        childNode: row.child_node,
        childNodeId: row.child_node_id,
        cardType: row.card_type as CardType,
        depthLevel: Number(row.depth_level),
        timeAxis: row.time_axis as TimeAxis,
        answered: Boolean(row.answered),
        createdAt: row.created_at,
      })),
      nodeProgress: (progressRows ?? []).map((row): UserNodeProgressItem => ({
        parentNode: row.parent_node,
        parentNodeId: row.parent_node_id,
        childNode: row.child_node,
        childNodeId: row.child_node_id,
        timesExplored: Number(row.times_explored ?? 0),
        coverageScore: Number(row.coverage_score ?? 0),
        lastExploredAt: row.last_explored_at,
      })),
      userLanguage: body.userLanguage ?? "ko",
    });

    let generatedCard: unknown = null;
    const explorationEngineUrl = Deno.env.get("EXPLORATION_CARD_ENGINE_URL");
    if (explorationEngineUrl) {
      const generationResponse = await fetch(explorationEngineUrl, {
        method: "POST",
        headers: {
          "Authorization": authHeader,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(decision.payload),
      });
      generatedCard = await generationResponse.json().catch(() => null);
      if (!generationResponse.ok) {
        return json(502, {
          error: "exploration_card_engine_failed",
          status: generationResponse.status,
          payload: decision.payload,
        });
      }
    }

    let cardHistoryId = crypto.randomUUID();
    if (body.persistHistory !== false) {
      const { data: recordedCard, error: recordError } = await admin.rpc("record_delivered_exploration_card", {
        p_user_id: userId,
        p_parent_node: decision.payload.parent_node,
        p_parent_node_id: decision.selectedNode.parentId,
        p_child_node: decision.payload.child_node,
        p_child_node_id: decision.selectedNode.id,
        p_card_type: decision.payload.desired_card_type,
        p_depth_level: decision.payload.depth_level,
        p_time_axis: decision.payload.time_axis,
      });
      if (recordError) throw recordError;
      if (recordedCard && typeof recordedCard === "object" && "id" in recordedCard) {
        cardHistoryId = String((recordedCard as { id: unknown }).id);
      }
    }
    const card = normalizeGeneratedCard(generatedCard, cardHistoryId, decision.payload);

    return json(200, {
      ok: true,
      payload: decision.payload,
      card,
      debug: {
        selectedNodeId: decision.selectedNode.id,
        allowedDepthRange: decision.allowedDepthRange,
        topScores: decision.scores,
        generationCalled: Boolean(explorationEngineUrl),
      },
    });
  } catch (error) {
    return json(500, {
      error: "deliver_exploration_card_failed",
      message: error instanceof Error ? error.message : String(error),
    });
  }
});

