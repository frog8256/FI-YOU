# Exploration Node Relationship Map

This graph powers exploration-first movement for the Card Delivery Engine. Edges are designed as journeys, not personality labels.

- `related_nodes`: natural continuation inside or near the same exploration thread.
- `opposite_nodes`: contrast or productive tension. Some nodes intentionally have no opposite.
- `bridge_nodes`: movement into another parent domain.

Runtime source:

- `supabase/functions/_shared/exploration-node-relationships.ts`

Machine-readable JSON:

- `docs/exploration-node-relationships.json`

Validation summary:

- Child nodes: 300
- Related edges: 1500
- Opposite edges: 116
- Bridge edges: 900
- Related/opposite overlap: 0
- Reciprocal edge ratio: 0.207
- Isolated nodes: 0
