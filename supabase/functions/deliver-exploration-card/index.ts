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

type OpenAIResponseBody = {
  output_text?: unknown;
  output?: unknown;
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

const allowedCardTypes = new Set<CardType>([
  "binary_choice",
  "multiple_choice",
  "priority_selection",
  "scenario_choice",
]);

function explorationCopy(value: string) {
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

function outputTextFromOpenAI(body: OpenAIResponseBody): string | null {
  if (typeof body.output_text === "string" && body.output_text.trim()) {
    return body.output_text;
  }
  if (!Array.isArray(body.output)) return null;

  for (const item of body.output) {
    if (!item || typeof item !== "object") continue;
    const content = (item as { content?: unknown }).content;
    if (!Array.isArray(content)) continue;
    for (const part of content) {
      if (!part || typeof part !== "object") continue;
      const text = (part as { text?: unknown }).text;
      if (typeof text === "string" && text.trim()) return text;
    }
  }

  return null;
}

function buildCardSchema(cardType: CardType) {
  return {
    type: "object",
    additionalProperties: false,
    required: ["card_type", "question", "options", "required_selections"],
    properties: {
      card_type: {
        type: "string",
        enum: [cardType],
      },
      question: {
        type: "string",
      },
      options: {
        type: "array",
        items: {
          type: "object",
          additionalProperties: false,
          required: ["id", "label"],
          properties: {
            id: {
              type: "string",
              pattern: "^option_[1-5]$",
            },
            label: {
              type: "string",
            },
          },
        },
      },
      required_selections: {
        type: "integer",
        enum: cardType === "priority_selection" ? [2, 3] : [1],
      },
    },
  };
}

async function generateCardWithOpenAI(
  apiKey: string,
  payload: ExplorationCardRequestPayload,
): Promise<unknown> {
  const model = Deno.env.get("OPENAI_MODEL") ?? "gpt-4.1";
  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      instructions: [
        "You create safe Korean self-discovery exploration cards for FI-YOU.",
        "Return only JSON matching the requested schema.",
        "Do not diagnose, label personality type, counsel, prescribe, or make fixed claims about the user.",
        "Write warm, neutral Korean copy based on the exploration payload.",
        "The question should invite reflection without exposing internal field names.",
        "Use ids option_1, option_2, and so on. binary_choice needs 2 options; multiple_choice and scenario_choice need 3-4 options; priority_selection needs 4-5 options.",
      ].join("\n"),
      input: [
        {
          role: "user",
          content: [
            {
              type: "input_text",
              text: JSON.stringify({
                desired_card_type: payload.desired_card_type,
                depth_level: payload.depth_level,
                time_axis: payload.time_axis,
                parent_node: payload.parent_node,
                parent_node_description: payload.parent_node_description,
                child_node: payload.child_node,
                child_node_description: payload.child_node_description,
                user_language: payload.user_language,
              }),
            },
          ],
        },
      ],
      max_output_tokens: 700,
      text: {
        format: {
          type: "json_schema",
          name: "fi_you_exploration_card",
          strict: true,
          schema: buildCardSchema(payload.desired_card_type),
        },
      },
    }),
  });

  const body = await response.json().catch(() => null) as OpenAIResponseBody | null;
  if (!response.ok) {
    const message = body && typeof body === "object" && "error" in body
      ? JSON.stringify((body as { error: unknown }).error)
      : `OpenAI request failed with status ${response.status}`;
    throw new Error(message);
  }

  const text = body ? outputTextFromOpenAI(body) : null;
  if (!text) throw new Error("openai_response_missing_output_text");
  return JSON.parse(text);
}

function normalizeGeneratedCard(
  generatedCard: unknown,
  fallbackCardId: string,
  payload: ExplorationCardRequestPayload,
): DeliveredCard {
  const source = generatedCard && typeof generatedCard === "object"
    ? generatedCard as Record<string, unknown>
    : {};
  const rawCardType = source.card_type ?? source.cardType ?? payload.desired_card_type;
  const cardType = allowedCardTypes.has(rawCardType as CardType)
    ? rawCardType as CardType
    : payload.desired_card_type;
  const rawOptions = Array.isArray(source.options) ? source.options : [];
  const options = rawOptions
    .map((option, index) => {
      if (typeof option === "string") return { id: `option_${index + 1}`, label: explorationCopy(option) };
      if (option && typeof option === "object") {
        const item = option as Record<string, unknown>;
        return {
          id: String(item.id ?? item.option_id ?? `option_${index + 1}`),
          label: explorationCopy(String(item.label ?? item.text ?? item.title ?? "")),
        };
      }
      return { id: `option_${index + 1}`, label: "" };
    })
    .filter((option) => option.label.trim().length > 0);
  const fallback = fallbackOptions[cardType] ?? fallbackOptions.scenario_choice;

  return {
    card_id: String(source.card_id ?? source.cardId ?? fallbackCardId),
    card_type: cardType,
    question: explorationCopy(String(
      source.question ??
        source.prompt ??
        `${payload.child_node_description} 지금의 나에게는 어떤 장면으로 떠오르나요?`,
    )),
    options: options.length > 0
      ? options
      : fallback.map((label, index) => ({ id: `option_${index + 1}`, label: explorationCopy(label) })),
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
    const openAIApiKey = Deno.env.get("OPENAI_API_KEY");
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
    } else if (openAIApiKey) {
      try {
        generatedCard = await generateCardWithOpenAI(openAIApiKey, decision.payload);
      } catch (error) {
        return json(502, {
          error: "openai_card_generation_failed",
          message: error instanceof Error ? error.message : String(error),
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
        generationCalled: Boolean(explorationEngineUrl || openAIApiKey),
        generationProvider: explorationEngineUrl ? "external" : openAIApiKey ? "openai" : "fallback",
      },
    });
  } catch (error) {
    return json(500, {
      error: "deliver_exploration_card_failed",
      message: error instanceof Error ? error.message : String(error),
    });
  }
});

