# Insight Engine

The Insight Engine turns exploration history into record-based self-discovery
analysis results.

It is an analysis engine for FI-YOU's product domain: preferences, interests,
fit, friction, tendencies, temperament, relationship patterns, work-style
patterns, and changes over time.

It is not a clinical diagnosis system, treatment tool, fixed personality type
classifier, compatibility judge, hiring decision tool, or destiny predictor.

Clues are inputs. User-facing output should be a clear analysis result when
there is enough evidence.

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

## Result Strength

Insight language should become clearer as evidence grows:

- `early`: a concrete observed clue; do not make a stable result claim yet.
- `forming`: a repeated pattern; present as a current analysis result.
- `consistent`: a strong repeated pattern; present as one of the user's clearest current results.

Safety should not be implemented by making every sentence vague. Instead:

- be clear about the result,
- show the evidence count and supporting records,
- keep the result scoped to the current record,
- let the user edit, hide, disagree, or report it.

Safe strong language:

- "Analysis result: autonomy is one of your clearest current values."
- "Your records repeatedly point to quiet, self-directed environments as a better fit."
- "This pattern is not a one-time signal anymore."

Unsafe strong language:

- "This is your fixed personality."
- "You must choose this career."
- "You are incompatible with this kind of person."

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
