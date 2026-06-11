# Protocol: Six-Tier Time Adjudication

> Every claim gets exactly one tier. The tier decides how it ages. This text is the adjudication prompt.

## The tiers

| Tier | Name | One-line criterion | Physics |
|---|---|---|---|
| **T0** | Observation | A dated, point-in-time measurable: a number, a reading, a quote with a date | Accumulates forever. Corrections **supersede** (new entry pointing at the old), never overwrite |
| **T1** | Current state | "X *is currently* Y" — true until the world changes it | Lives in a zipper. Change = retire old row + open new row (see `retirement.md`) |
| **T2** | Standing logic | A mechanism or rule: "A transmits to B", "policy X constrains Y" — with a **durability** grade | Zipper like T1, plus `durability: high` (definitional) / `medium` (causal, can break) / `low` (empirical pattern) |
| **T3** | Relation | A typed edge between two pages, from the domain's controlled vocabulary | Lives in the page's Relations section as `rel_type [[target]]`. Out-of-vocab → reject |
| **T4** | Event | Something that **happened** on a date: an announcement, a change, a decision | Append-only, dated, never edited. Events are what stamp T1/T2 changes |
| **T5** | Type axiom | The ontology itself: node types, edge vocabulary, judging criteria | Changes only by explicit human edit to `wiki/<domain>/_ontology.md` (write-type `axiom-change`, locked) |

## Decision path (apply in order)

1. Does it have a **date and a value**? → T0.
2. Is it a statement about **how things currently stand**, which a future event could change? → T1.
3. Is it a **rule/mechanism** expected to hold across many dates? → T2 (grade its durability honestly; most extracted "insights" are `low`).
4. Is it a **typed link** between two nameable things? → T3 (check the vocab).
5. Did it **happen** at a moment? → T4 (must carry `event_date`).
6. Is it about **what kinds of things exist** in this domain? → T5 (stage for human; agents never apply axiom changes).

If a claim resists all six: it is probably opinion or vibe — leave it in the source note, cite it if useful, do not promote it.

## Common traps

- **"Fixed income" trap (category vs property):** asset-class labels, classifications → T3 `classified_as` edges or frontmatter fields, never new nodes.
- **State dressed as fact:** "the rate is 1.40%" with a date is T0; "the stance is accommodative" is T1 — the second one needs a zipper, the first one doesn't.
- **Logic inflation:** one co-occurrence is not a mechanism. T2 requires either a definitional basis or repeated observation; otherwise file the T0s and wait.
- **Events without dates:** if you cannot date it, it is not a T4. Find the date or downgrade to prose.
