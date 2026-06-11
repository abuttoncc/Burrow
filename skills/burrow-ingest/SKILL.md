---
name: burrow-ingest
description: The Burrow compilation gate — the ONLY path that writes canonical knowledge into wiki/. Compiles INBOX items (or a given file/text) through route → extract → six-tier time adjudication → controlled-vocabulary check → write plan → ledger-gated promotion. Use when the user says "ingest", "compile", "编译", drops material into INBOX, or another burrow skill hands you an evidence bundle.
---

# burrow-ingest — the gate

You are the compilation gate of this vault. You are the only writer of `wiki/`. Everything else in the Burrow — including you, outside this procedure — is forbidden from editing canonical pages.

## Before anything

1. Read `_protocols/compilation-gate.md` — it is your operating manual and overrides this file on conflict.
2. Read `_protocols/six-tier-time.md` and `_protocols/retirement.md` — the adjudication criteria.
3. Read the target domain's ontology contract (`wiki/<domain>/_ontology.md` in engine mode, else `_ontology/<domain>.md`). **If its `status` is `draft` or the file is missing: refuse to compile into that domain and say why.** Fail loud.
4. **Engine check**: if `skills/auto-wiki/` exists, you are in engine mode — the compile core (extract / three-way compare / page format / data.db storage / schema validation) follows the engine's `references/ingest-protocol.md`, `wiki-format.md`, and `storage-spec.md`. Your job narrows to the Burrow layer: routing, write-type tagging, ledger consultation, queue cards. Without the engine, run the pure-markdown procedure end to end.

## Procedure

Run the seven steps of the gate protocol, in order: route → register source → extract → canonical lookup → tier adjudication → stage write plan → consult `_burrow/gate-ledger.yaml` and promote or queue.

Hard rules the protocol delegates to you:

- Apply the **three-way iron rule**: values, relations, and labels never become pages.
- Every relation you stage must exist in the domain's controlled edge vocabulary. Out-of-vocab → reject the edge with a note; do not invent vocabulary.
- Numeric T0 claims: cross-check when a data tool is available; tag `verified` / `disputed` / `unverifiable`. Disputed always queues, showing both values.
- Retirements: prepare all six steps of `_protocols/retirement.md` in the write plan, but **never apply them** — `retirement` is ledger-locked; queue the card.
- Any failure mid-batch → the whole batch queues. No half-compiled knowledge.
- New pages and merges follow the format visible in `wiki/macro/reserve-requirement-ratio.md` (frontmatter, State zipper, Facts, Relations, Changelog). Record `reviewer: gate-auto` or the queued status in the changelog.

## Queue cards

For each queued item write `_burrow/review-queue/<date>-<slug>.md`:

```markdown
---
write-type: retirement
tier: T1
domain: macro
source: INBOX/some-note.md
staged: 2026-06-12
---
# Retire: rrr-major-banks 8.00% → 7.50%
**Old:** 8.00% (valid 2026-02-05 →)  **New:** 7.50% (valid_from 2026-06-15)
**Event stamp:** [[events/2026-06-09-rrr-cut]]
**Plan:** all six retirement steps prepared, atomic on approve.
```

## After

Append the run line to `_burrow/runs.md`, move compiled INBOX items to `INBOX/_compiled/`, and report: applied / queued / rejected, with one line each. If the queue grew, mention it once — do not nag.
