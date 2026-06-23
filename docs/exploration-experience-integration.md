# Exploration Experience Integration

This document records the mobile integration contract for the My Universe Exploration Experience.

## Principle

The experience is exploratory, not diagnostic. The mobile UI must not expose node names, depth, scores, scoring reasons, or graph internals. Users should only see:

- one question
- selectable options
- an optional note field
- a continue action

## Mobile Flow

Entry points on the Explore tab now open `ExplorationExperienceScreen`.

Runtime flow:

1. Load the next card through `FiYouRepository.loadNextExplorationCard()`.
2. Render the card based on `ExplorationCardType`.
3. Let the user select a valid answer.
4. Optionally collect a note, max 300 characters.
5. Submit through `FiYouRepository.submitExplorationAnswer()`.
6. Load the next card.

The optional note field is collapsed by default and uses the placeholder:

`떠오르는 생각이 있다면 남겨보세요.`

## Card Types

- `binary_choice`: exactly one selection from 2 options.
- `multiple_choice`: exactly one selection from 3-6 options.
- `scenario_choice`: exactly one selection from 3-5 options.
- `priority_selection`: multiple selection, usually 2 selections, capped at 3.

Priority cards show `Selected x/y`.

## Edge Functions

`deliver-exploration-card`

Returns a user-facing card under `card`:

```json
{
  "card_id": "uuid",
  "card_type": "scenario_choice",
  "question": "질문",
  "options": [{ "id": "option_1", "label": "선택지" }],
  "required_selections": 1
}
```

`answer-exploration-card`

Accepts:

```json
{
  "card_id": "uuid",
  "selected_options": ["option_1"],
  "user_note": "optional"
}
```

Answers are stored in `user_card_answers`, and the delivered card is marked answered through `mark_exploration_card_answered`.

## Verification

Run:

```bash
npm run simulate-exploration
cd mobile/fi_you
C:/Users/frog8/development/flutter/bin/flutter.bat analyze
```

The latest verification passed with:

- child coverage: 100%
- dead nodes: 0
- hot nodes: 0
- loop rate: 0%
- parent max deviation: 0.38%
- Flutter analyze: no issues
