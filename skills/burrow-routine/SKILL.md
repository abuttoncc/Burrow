---
name: burrow-routine
description: The Burrow flywheel — one command that turns the whole wheel: due standing questions → recall → review last answer against reality → lint → research the gaps → ingest the findings → append the run log. The morning ritual, or the cron target. Use when the user says "routine", "例行", "daily", "tick", "转飞轮", or via scheduled invocation (claude -p "/burrow-routine").
---

# burrow-routine — turn the wheel

One run = one full revolution. Steps run in order; each step's failure is logged and the wheel keeps turning (a stuck step never silently blocks the rest).

## The revolution

1. **Due questions.** Read `_burrow/questions.md` (create it with a starter template if missing: title / cadence weekly|monthly / recall scope / last_run). Collect questions whose cadence has elapsed.
2. **Per due question:**
   a. **Recall** — answer it from the vault only, via the burrow-recall discipline (provenance or gap, never confident silence).
   b. **Review** — fetch the previous answer from `_burrow/answers/<question-slug>.md`; compare its forward-looking calls against what the vault now records. Mark each: held ✓ / missed ✗ / unresolved.
   c. **Project** — base / upside / downside, each with an explicit trigger condition (what T4 event would confirm it).
   d. **Append** the answer block to `_burrow/answers/<question-slug>.md` — *append-only, never edit previous entries.* Include a one-line summary at top of the block for the Dashboard.
3. **Lint** — run burrow-lint (structural pass always; semantic pass only if the run budget allows).
4. **Research** — hand the Gap Report to burrow-research (its own budget applies).
5. **Ingest** — burrow-ingest compiles whatever research brought home; ledger decides promote vs queue.
6. **Log** — append one row to `_burrow/runs.md`: timestamp, trigger (manual/cron), applied/queued/rejected, gaps found/researched, notes.

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

When invoked non-interactively (cron), never wait for input: anything requiring judgment goes to the review queue, and the run report is written to the top of `Dashboard.md` under a `## Last run` heading (replace that section only — it is the one mutable region the routine owns).
