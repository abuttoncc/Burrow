---
name: burrow-routine
description: The Burrow flywheel — one command that turns the whole wheel: due standing questions → recall → review last answer against reality → lint → research the gaps → ingest the findings → append the run log. The morning ritual, or the cron target. Use when the user says "routine", "例行", "daily", "tick", "转飞轮", or via scheduled invocation (claude -p "/burrow-routine").
---

# burrow-routine — turn the wheel

One run = one full revolution. Steps run in order; each step's failure is logged and the wheel keeps turning (a stuck step never silently blocks the rest).

## The revolution

1. **Due questions.** Scan `07-QA/` — one file per question, frontmatter `mode / cadence / recall-scope / last-run / status`. Collect questions whose cadence has elapsed (or `status: due`). Empty folder → suggest creating one from `07-QA/README.md`'s contract and move on.
2. **Per due question:**
   a. **Recall** — answer it from the vault only, via the burrow-recall discipline (provenance or gap, never confident silence).
   b. **Review** — read the question file's most recent answer block (its `## Answers` section is append-only, newest first); compare its forward-looking calls against what the vault now records. Mark each: held ✓ / missed ✗ / unresolved.
   c. **Project** — base / upside / downside, each with an explicit trigger condition (what T4 event would confirm it).
   d. **Append** the new answer block at the top of the question file's `## Answers` section — *never edit previous entries* — then update frontmatter: `last-run`, `last-summary` (one line; the dashboard timeline reads it), `status: fresh`.
3. **Lint** — run burrow-lint (structural pass always; semantic pass only if the run budget allows).
4. **Research** — hand the Gap Report to burrow-research (its own budget applies).
5. **Ingest** — burrow-ingest compiles whatever research brought home; ledger decides promote vs queue.
6. **Log** — create the run record `08-Ops/runs/YYYY-MM-DD-HHMM-routine.md` at start (`status: running`), complete it at the end: flywheel steps, applied/queued/rejected, gaps found/researched, budget spent.

## Reporting (the morning headline)

End with a report the householder can read in 30 seconds:

```
🏠 Burrow run 2026-06-12 04:00 (cron)
Questions answered: 2 (1 call held ✓, 1 missed ✗ — see policy-stance)
Health: 3 defects (▼1) · Gaps: 4 found, 3 researched, 1 open
Gate: 11 auto-applied · 4 queued for your judgment ← start here
Ledger: new-node 12/20 · all others unchanged
```

## Unattended mode

When invoked non-interactively (cron), never wait for input: anything requiring judgment goes to the review queue, and the run record in `08-Ops/runs/` is the report — the dashboard reads it automatically.
