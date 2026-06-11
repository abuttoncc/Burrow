---
domain: your-domain-slug
status: draft          # the gate REFUSES to compile into a draft domain — fill this file first
keywords: []           # routing keywords for the gate's domain matcher
review_horizon: 90d    # staleness threshold for T1 states
---

# Ontology: <Your Domain>

> One file = one domain's house rules. The gate enforces this file; lint checks against it.
> An empty-contract domain cannot be compiled into — fail loud, not silent.

## Node types

For each type: a one-line definition and the **pointing criterion** ("can you point at exactly one X?").

| type | definition | criterion |
|---|---|---|
| Entity | a nameable thing that persists | "Can you point at it?" |
| Indicator | a measurable series | "Does it have readings over time?" |
| Mechanism | standing logic linking things | "Would it still be claimed next month?" |
| Event | something that happened on a date | "Can you date it?" |
| Analysis | your own synthesis | "Did a human (or routine) conclude it?" |
| Source | where knowledge came from | immutable after registration |

## Controlled edge vocabulary

**Edges not in this table are rejected at the gate.** Extending the vocabulary = editing this file (write-type `axiom-change`, locked to human).

| rel_type | source → target | meaning |
|---|---|---|
| instance_of | Entity → Entity | taxonomy |
| part_of | any → any | composition |
| measures | Indicator → Entity | what the series tracks |
| affects | Mechanism → Entity/Indicator | causal claim (durability-graded) |
| references | Analysis → any | citation |
| created_by | any → Source | provenance |

## Three-way iron rule (applies in every domain)

1. **Values don't become nodes** — numbers go to T0 observations.
2. **Relations don't become nodes** — links go to the Relations section.
3. **Labels don't become nodes** — classifications go to `classified_as` edges or frontmatter.
