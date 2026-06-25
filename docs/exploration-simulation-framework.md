# Exploration Simulation Framework

The simulation framework validates the exploration system before real users arrive. It does not generate cards and does not modify production delivery logic.

## Run

```bash
npm install
npm run simulate-exploration
```

Default run:

- 100 virtual users
- 200 delivered cards per user
- 20,000 total deliveries
- Output directory: `reports/exploration-simulation`

Optional flags:

```bash
npm run simulate-exploration -- --users 250 --cards 500 --seed 42 --out reports/large-simulation
```

## What It Uses

The runner imports the production Delivery Engine:

- `supabase/functions/_shared/card-delivery-engine.ts`
- `supabase/functions/_shared/exploration-nodes.ts`
- `supabase/functions/_shared/exploration-node-relationships.ts`

Each simulated delivery calls `createDeliveryDecision` and then updates the same state shapes the Edge Function reads: exploration state, card history, and node progress.

## Reports

The run writes:

- `simulation-report.json`
- `simulation-report.md`

The markdown report includes summary, coverage, parent distribution, depth distribution, card type distribution, time axis distribution, top nodes, dead nodes, loop detection, graph usage, and recommendations.

## Virtual Users

The framework creates diversified archetypes:

- Explorer
- Builder
- Connector
- Stability Seeker
- Reflector
- Resilient
- Creator
- Decider

Archetype preferences are represented as initial exploration history and node progress. The Delivery Engine still receives only production-shaped state.
