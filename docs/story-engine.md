# Story Engine

The Story Engine turns multiple insights into reflective narrative stories. It is
not a personality report, psychological assessment, diagnosis engine, scoring
system, or label generator.

The intended feeling is:

> I can see my journey.

## Inputs

The engine reads production data:

- `user_insights`
- `user_card_history`
- insight supporting nodes and answers
- story refresh state

Stories are downstream from real exploration and real insights. They do not
bypass the Delivery Engine or fabricate user signals.

## Database

`user_stories` stores active and historical stories:

- `story_type`
- `title`
- `description`
- `supporting_insights`
- `active`
- `created_at`
- `updated_at`

`user_story_refresh_state` stores the last completed-card count and compact
insight signature so stories are not regenerated after every card.

Both tables use RLS with owner-only authenticated reads. Edge Functions write
through the service role. Migrations include explicit `grant select` statements
for authenticated clients because Supabase public table API exposure defaults
are becoming stricter.

## Story Types

- `current_chapter`: what is most visible right now
- `emerging_direction`: where repeated observations appear to be moving
- `internal_tension`: meaningful contrasts across multiple insights
- `hidden_territory`: quieter or less explored areas, never framed as weakness
- `change_over_time`: evolution between earlier and recent exploration

Every story requires at least 3 supporting insights.

## Refresh Rules

Stories refresh when:

- at least 3 active insights exist, and
- this is the first eligible refresh, or
- 25 more completed cards have appeared since the last story refresh, or
- the active insight signature changes.

`answer-exploration-card` calls the Story Engine after the Insight Engine. If no
story refresh is due, it returns a lightweight `not_due` result.

## API

`story-feed`

- `GET /functions/v1/story-feed`
- `POST /functions/v1/story-feed`
- optional refresh: `?refresh=true` or `{ "refresh": true }`

Response shape:

```json
{
  "ok": true,
  "feed_title": "My Story",
  "sections": [
    "Current Chapter",
    "Emerging Direction",
    "Tensions",
    "Unexplored Territory",
    "Change Over Time"
  ],
  "stories": [
    {
      "story_id": "",
      "story_type": "current_chapter",
      "title": "Current Chapter",
      "description": "",
      "supporting_insights": []
    }
  ],
  "refresh": {
    "refreshed": true,
    "reason": "initial",
    "answered_count": 25,
    "insight_count": 4,
    "generated_count": 2
  }
}
```

## Language Guardrails

Story copy avoids:

- scores
- percentages
- rankings
- diagnoses
- personality labels
- identity claims such as "You are ..."

Preferred phrasing:

- "It seems ..."
- "Recent exploration suggests ..."
- "A recurring theme is ..."
- "One thread appearing repeatedly ..."

The UI should present stories like calm journal pages, not dashboards or
analytics panels.
