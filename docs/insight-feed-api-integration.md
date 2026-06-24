# Insight Feed API Integration

## Edge Function

Flutter calls the Supabase Edge Function:

- `insight-feed`

The function is expected to return discovery-oriented insight feed data. It must
not expose scores, diagnosis, personality labels, raw graph scoring, or backend
debug metadata to the user-facing app layer.

## Flutter Models

The repository layer defines:

- `InsightSupportingNode`
- `UserInsight`
- `InsightFeedResponse`

Expected response shape:

```json
{
  "feed_title": "Recent Exploration",
  "sections": ["Recent Exploration", "Patterns Emerging"],
  "insights": [
    {
      "insight_id": "uuid",
      "insight_type": "emerging_pattern",
      "title": "A direction appearing more than once",
      "description": "Recent exploration shows ...",
      "supporting_nodes": [
        {
          "node_id": "parent_01_child_01",
          "node_name": "Self direction",
          "parent_node": "Exploration"
        }
      ],
      "confidence_level": "forming",
      "created_at": "2026-06-24T00:00:00Z"
    }
  ]
}
```

All parsing is defensive. Missing fields become empty strings or empty lists.
Malformed top-level responses return `InsightFeedResponse.empty` with an
`errorMessage`.

## Repository Contract

`FiYouRepository` exposes:

```dart
Future<InsightFeedResponse> getInsightFeed();
```

Implementations:

- `MockFiYouRepository`: returns realistic discovery-oriented sample insights.
- `SupabaseFiYouRepository`: calls `client.functions.invoke('insight-feed')`.

## Error Handling

The Supabase implementation does not crash the app for expected feed failures.
It returns an empty feed with `errorMessage` for:

- missing auth/session
- Edge Function errors
- auth errors
- malformed responses
- unexpected exceptions

The UI decides how to present retry or empty states.

## Tests

Repository tests cover:

- mock feed success
- empty feed parsing
- malformed response handling
- supporting node parsing
- forbidden analysis language in mock insight copy

## UI Integration

`InsightFeedScreen` calls `FiYouRepository.getInsightFeed()` directly from the
repository scope.

The screen supports:

- loading state with explanatory copy
- empty state when no insights are available yet
- error state with retry
- successful insight cards
- supporting node chips using `node_name` only

The UI intentionally does not render:

- confidence as a number or visible label
- raw node IDs
- backend metadata
- graph scores
- diagnostic wording

The Explore tab includes a lightweight entry card that opens the feed without
mixing feed data into the card delivery flow.

Widget tests cover loading, empty, success, retry, forbidden copy, and raw node
ID suppression.
