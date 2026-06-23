# Insight Engine

The Insight Engine turns exploration history into discovery-oriented observations.
It is deliberately not an analysis engine, scoring system, diagnosis, or personality
classifier.

## Inputs

The engine reads production exploration data:

- `user_card_history`
- `user_card_answers`
- `user_node_progress`
- `explorationNodeRelationships`
- `explorationNodeTaxonomy`

It does not bypass Delivery Engine behavior. Insights are derived from cards the
user actually received and answered.

## Database

`user_insights` stores active and historical insights:

- `insight_type`
- `title`
- `description`
- `supporting_nodes`
- `supporting_answers`
- `confidence_level`
- `evidence_count`

`user_insight_refresh_state` stores the last answered-card count and a compact
pattern signature so refreshes do not run after every card.

Both tables use RLS with owner-only authenticated reads. Writes are performed by
Edge Functions with the service role.

## Refresh Rules

Insights refresh when:

- the user has at least 3 supporting signals, and
- this is the first eligible refresh, or
- 10 more completed cards have appeared since the last refresh, or
- a repeated pattern changes after at least 3 new answers.

`answer-exploration-card` calls the refresh check after saving an answer. If no
refresh is due, it returns a lightweight `not_due` result.

## Insight Types

- `emerging_pattern`: repeated child-node signals
- `internal_tension`: both sides of an opposite relationship appear
- `exploration_gap`: an area remains relatively unexplored
- `consistent_theme`: linked nodes appear across several parent domains
- `change_over_time`: recent exploration shifts compared with earlier answers

Every generated insight requires at least 3 supporting signals.

## Language Guardrails

Insight copy avoids:

- scores
- percentages
- rankings
- diagnoses
- personality labels
- direct identity claims such as "당신은 ..."

Preferred phrasing:

- "최근 탐험에서 ..."
- "함께 등장합니다 ..."
- "흐름으로 보입니다 ..."
- "가능성이 보입니다 ..."

## API

`insight-feed`

- `GET /functions/v1/insight-feed`
- `POST /functions/v1/insight-feed`
- optional refresh: `?refresh=true` or `{ "refresh": true }`

Response shape:

```json
{
  "feed_title": "Recent Exploration",
  "insights": [
    {
      "insight_id": "",
      "insight_type": "emerging_pattern",
      "title": "",
      "description": "",
      "supporting_nodes": [],
      "confidence_level": "forming"
    }
  ]
}
```
