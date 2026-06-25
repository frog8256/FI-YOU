# Card Delivery Engine

The Card Delivery Engine chooses what the next exploration card should explore before the Exploration Card Engine generates the actual card.

## Runtime Shape

1. The frontend calls `deliver-exploration-card`.
2. The Edge Function authenticates the Supabase user.
3. It loads `user_exploration_state`, recent `user_card_history`, and `user_node_progress`.
4. `_shared/card-delivery-engine.ts` selects:
   - child node
   - card type
   - depth level
   - time axis
5. If `EXPLORATION_CARD_ENGINE_URL` is configured, the function posts the payload to that service.
6. Otherwise, if `OPENAI_API_KEY` is configured, the function calls the OpenAI Responses API directly and asks for a strict JSON card shape.
7. The delivered card is recorded through `record_delivered_exploration_card`.

If neither `EXPLORATION_CARD_ENGINE_URL` nor `OPENAI_API_KEY` is configured, the function still returns the generated request payload and a safe fallback card. This keeps the delivery layer testable before generation is wired.

## AI Configuration

For the built-in OpenAI path, set the secret on the Supabase project:

```bash
supabase secrets set OPENAI_API_KEY=... --project-ref debgzfnbthaipqvbytko
```

The default OpenAI model is `gpt-4.1`. Override it with:

```bash
supabase secrets set OPENAI_MODEL=gpt-4.1 --project-ref debgzfnbthaipqvbytko
```

Deploy the function after changing secrets or code:

```bash
supabase functions deploy deliver-exploration-card --project-ref debgzfnbthaipqvbytko
```

## Data

The canonical 10 parent / 300 child taxonomy lives in:

- `supabase/functions/_shared/exploration-nodes.ts`
- `docs/exploration-node-taxonomy.md`

The delivery state tables are introduced in:

- `supabase/migrations/20260623090000_card_delivery_engine.sql`

## Selection Rules

The algorithm is score based, not random.

- Excludes the last 10 child nodes.
- Gives more score to under-covered parent nodes.
- Gives more score to under-covered child nodes.
- Uses the relationship graph to continue, bridge, or contrast the last explored child node.
- Penalizes recently repeated parent nodes.
- Penalizes configured semantic similarity groups.
- Selects card type and time axis by target distribution while breaking streaks.
- Selects depth from answered-card bands and never advances by more than one level from the current depth.

Configuration is separate from business logic in:

- `supabase/functions/_shared/card-delivery-config.ts`
- `supabase/functions/_shared/exploration-node-relationships.ts`

## Output Payload

```json
{
  "parent_node": "자아상",
  "child_node": "자기인식",
  "child_node_description": "자신이 어떤 사람인지 스스로 이해하는 정도",
  "desired_card_type": "scenario_choice",
  "depth_level": 1,
  "time_axis": "present",
  "user_language": "ko",
  "recent_cards": []
}
```

## Tests

Run the pure engine tests with Deno:

```bash
deno test supabase/functions/_shared/card-delivery-engine.test.ts
```
