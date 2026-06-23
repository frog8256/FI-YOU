const requiredEnv = [
  "SUPABASE_URL",
  "SUPABASE_PUBLISHABLE_KEY",
  "SUPABASE_SERVICE_ROLE_KEY",
];

for (const key of requiredEnv) {
  if (!process.env[key]) {
    throw new Error(`Missing ${key}`);
  }
}

const supabaseUrl = process.env.SUPABASE_URL.replace(/\/$/, "");
const publishableKey = process.env.SUPABASE_PUBLISHABLE_KEY;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const stamp = Date.now();
const email = `codex-exploration-e2e-${stamp}@example.com`;
const password = `Codex-e2e-${stamp}!`;

let userId = null;

async function requestJson(url, options) {
  const response = await fetch(url, options);
  const text = await response.text();
  let data = null;
  try {
    data = text ? JSON.parse(text) : null;
  } catch {
    data = { raw: text };
  }
  if (!response.ok) {
    throw new Error(
      `${options.method ?? "GET"} ${url} failed: ${response.status} ${JSON.stringify(data)}`,
    );
  }
  return data;
}

function authHeaders(key, bearer = key) {
  return {
    apikey: key,
    Authorization: `Bearer ${bearer}`,
    "Content-Type": "application/json",
  };
}

function assertCard(card, label) {
  const allowedTypes = new Set([
    "binary_choice",
    "multiple_choice",
    "priority_selection",
    "scenario_choice",
  ]);
  if (!card || typeof card !== "object") {
    throw new Error(`${label}: card is missing`);
  }
  if (!card.card_id || typeof card.card_id !== "string") {
    throw new Error(`${label}: card_id missing`);
  }
  if (!allowedTypes.has(card.card_type)) {
    throw new Error(`${label}: invalid card_type ${card.card_type}`);
  }
  if (!card.question || typeof card.question !== "string") {
    throw new Error(`${label}: question missing`);
  }
  if (!Array.isArray(card.options) || card.options.length < 2) {
    throw new Error(`${label}: options missing`);
  }
  const serialized = JSON.stringify(card);
  for (const forbidden of [
    "parent_node",
    "child_node",
    "depth_level",
    "coverage_score",
    "topScores",
  ]) {
    if (serialized.includes(forbidden)) {
      throw new Error(`${label}: leaked internal field ${forbidden}`);
    }
  }
}

function selectOptionIds(card) {
  if (card.card_type === "priority_selection") {
    const required = Math.min(
      Math.max(Number(card.required_selections ?? 2), 2),
      Math.min(3, card.options.length),
    );
    return card.options.slice(0, required).map((option) => option.id);
  }
  return [card.options[0].id];
}

try {
  const created = await requestJson(`${supabaseUrl}/auth/v1/admin/users`, {
    method: "POST",
    headers: authHeaders(serviceRoleKey),
    body: JSON.stringify({
      email,
      password,
      email_confirm: true,
      user_metadata: { source: "codex-exploration-e2e" },
    }),
  });
  userId = created.id;

  const session = await requestJson(
    `${supabaseUrl}/auth/v1/token?grant_type=password`,
    {
      method: "POST",
      headers: authHeaders(publishableKey),
      body: JSON.stringify({ email, password }),
    },
  );
  const accessToken = session.access_token;
  if (!accessToken) throw new Error("No user access token returned");

  const functionHeaders = authHeaders(publishableKey, accessToken);
  const first = await requestJson(
    `${supabaseUrl}/functions/v1/deliver-exploration-card`,
    {
      method: "POST",
      headers: functionHeaders,
      body: JSON.stringify({ userLanguage: "ko" }),
    },
  );
  assertCard(first.card, "first delivery");

  const selectedOptions = selectOptionIds(first.card);
  await requestJson(`${supabaseUrl}/functions/v1/answer-exploration-card`, {
    method: "POST",
    headers: functionHeaders,
    body: JSON.stringify({
      card_id: first.card.card_id,
      selected_options: selectedOptions,
      user_note: "",
    }),
  });

  const second = await requestJson(
    `${supabaseUrl}/functions/v1/deliver-exploration-card`,
    {
      method: "POST",
      headers: functionHeaders,
      body: JSON.stringify({ userLanguage: "ko" }),
    },
  );
  assertCard(second.card, "second delivery");

  const history = await requestJson(
    `${supabaseUrl}/rest/v1/user_card_history?select=id,answered,card_type&order=created_at.desc&limit=2`,
    { headers: authHeaders(publishableKey, accessToken) },
  );
  const answers = await requestJson(
    `${supabaseUrl}/rest/v1/user_card_answers?select=card_history_id,selected_options,user_note`,
    { headers: authHeaders(publishableKey, accessToken) },
  );

  if (!Array.isArray(history) || history.length < 2) {
    throw new Error(`Expected at least 2 history rows, got ${history.length}`);
  }
  if (!history.some((row) => row.id === first.card.card_id && row.answered)) {
    throw new Error("First delivered card was not marked answered");
  }
  if (!Array.isArray(answers) || answers.length < 1) {
    throw new Error("No answer row was stored");
  }

  console.log(
    JSON.stringify(
      {
        ok: true,
        userCreated: true,
        firstCard: {
          id: first.card.card_id,
          type: first.card.card_type,
          optionCount: first.card.options.length,
          selectedCount: selectedOptions.length,
        },
        secondCard: {
          id: second.card.card_id,
          type: second.card.card_type,
          optionCount: second.card.options.length,
        },
        storedHistoryRows: history.length,
        storedAnswerRows: answers.length,
        firstCardAnswered: true,
      },
      null,
      2,
    ),
  );
} finally {
  if (userId) {
    await fetch(`${supabaseUrl}/auth/v1/admin/users/${userId}`, {
      method: "DELETE",
      headers: authHeaders(serviceRoleKey),
    });
  }
}
