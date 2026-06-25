# Story Feed API Integration

This document describes the Flutter repository integration for the Supabase Edge
Function `story-feed`.

## Edge Function

`story-feed`

- `GET /functions/v1/story-feed`
- `POST /functions/v1/story-feed`
- Flutter calls it with `{ "refresh": false }`.

The client does not force refresh on empty responses. Story refresh scheduling is
owned by the backend Story Engine and `answer-exploration-card`.

## Flutter Models

`UserStory`

- `id`
- `type`
- `title`
- `description`
- `supportingInsights`
- `createdAt`
- `updatedAt`
- `active`

`StorySupportingInsight`

- `insightId`
- `insightType`
- `title`

`StoryFeedResponse`

- `feedTitle`
- `sections`
- `stories`
- `errorMessage`

All parsing is defensive. Missing or malformed fields produce empty strings,
empty lists, or an empty response instead of throwing.

## Repository Contract

`FiYouRepository`

```dart
Future<StoryFeedResponse> getStoryFeed();
```

Implementations:

- `MockFiYouRepository`: returns reflective sample stories.
- `SupabaseFiYouRepository`: invokes `story-feed` with the current Supabase
  Auth session.

## Expected Response Shape

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
      "supporting_insights": [
        {
          "insight_id": "",
          "insight_type": "consistent_theme",
          "title": ""
        }
      ],
      "created_at": "",
      "updated_at": "",
      "active": true
    }
  ]
}
```

Known story types:

- `current_chapter`
- `emerging_direction`
- `internal_tension`
- `hidden_territory`
- `change_over_time`

Unknown story types are preserved and should render safely.

## Error Handling

The Supabase repository returns an empty `StoryFeedResponse` with an
`errorMessage` for:

- missing Auth session
- invalid Auth session
- Function errors
- malformed response shapes
- unexpected client errors

The app should show retry UI for `hasError` and a gentle empty state for
`isEmpty`.

## Mock Behavior

Mock stories use reflective narrative copy such as:

- `Current Chapter`
- `A direction becoming clearer`
- `A quiet area still waiting`

Mock copy avoids scoring, diagnosis, personality labels, rankings, assessment
language, and direct identity claims.

## Testing

Repository tests cover:

- mock story feed success
- empty response parsing
- malformed response handling
- unknown story type preservation
- supporting insight parsing
- forbidden copy checks

## UI Integration

`StoryFeedScreen` loads data through `FiYouRepository.getStoryFeed()` and
supports:

- loading state
- empty state
- error state with retry
- success state with story cards
- unknown story type fallback

The UI intentionally hides:

- raw story IDs
- raw insight IDs
- raw enum names
- backend refresh metadata
- scoring or assessment language

Story type labels are mapped into reader-facing section names:

- `current_chapter` -> `Current Chapter`
- `emerging_direction` -> `Emerging Direction`
- `internal_tension` -> `Tensions`
- `hidden_territory` -> `Unexplored Territory`
- `change_over_time` -> `Change Over Time`
- unknown -> `Story Thread`

The Explore screen exposes a subtle `My Story` entry point without replacing the
existing Insight Feed or exploration cards.
