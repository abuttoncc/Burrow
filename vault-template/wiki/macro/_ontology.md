---
domain: macro
status: active
keywords: [central bank, monetary policy, interest rate, repo, MLF, LPR, reserve ratio, CPI, PPI, GDP, PMI, liquidity, 央行, 货币政策, 利率, 逆回购, 降准, 流动性]
review_horizon: 90d
---

# Ontology: Macro (monetary policy)

> A fully worked example domain. Copy `_template.md` to start your own.

## Node types

| type | definition | criterion |
|---|---|---|
| Institution | a body that acts: central bank, ministry, exchange | "Can it sign a document?" |
| PolicyInstrument | a tool an institution operates: reverse repo, MLF, RRR | "Can the institution adjust it?" |
| Indicator | a measurable series: a rate, an index, a flow | "Does it have dated readings?" |
| Mechanism | standing transmission logic: "RRR cut → interbank liquidity up" | "A rule, not a reading" |
| Event | dated happening: an announcement, a cut, a meeting | "Has an event_date" |
| Analysis | a synthesized view (yours or a routine's) | "A conclusion with an author" |
| Source | registered origin of knowledge | immutable |

## Controlled edge vocabulary

| rel_type | source → target | meaning |
|---|---|---|
| operated_by | PolicyInstrument → Institution | who runs the tool |
| implements | PolicyInstrument → Mechanism | the tool enacts the logic |
| transmits_to | PolicyInstrument/Indicator → Indicator | transmission channel |
| bounds | PolicyInstrument → Indicator | corridor edges (carry `bound_role: upper/lower`) |
| measures | Indicator → Institution/Mechanism | what the series tracks |
| classified_as | any → label | classification (label is NOT a node) |
| instance_of / part_of | any → any | taxonomy / composition |
| created_by / references / changed_by | provenance & citation | — |

## Domain traps (feed these to the adjudicator)

- 名义利率 ≠ 实际利率 ≠ 有效利率 — never merge readings across these without an explicit conversion note.
- 官方 PMI ≠ 财新 PMI — different samples; two Indicators, never one.
- CPI 同比 ≠ CPI 环比 — base effects make them disagree; the period field is part of the fact's identity.
- "Accommodative stance" is a **T1 state**, not a fact — it needs a zipper and an event stamp when it changes.
