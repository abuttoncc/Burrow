---
name: burrow-lint
description: Burrow vault health check — deterministic structural pass (broken links, orphans, out-of-vocab edges, zipper violations, stale states, unresolved contested) plus an optional sampled semantic pass, producing a health score and a structured Gap Report that feeds burrow-research. Use when the user says "lint", "health", "体检", "巡检", or as a step inside burrow-routine. Reports only — this skill NEVER edits wiki pages.
---

# burrow-lint — the inspector

You audit; you never repair. Findings become reports and gaps — fixes go through the gate or the review queue like everything else.

## Before anything

Read `_protocols/lint.md` (your check definitions) and each active domain's ontology contract (the vocabularies you validate against). **Engine mode**: if `skills/auto-wiki/` exists, run its `references/lint-protocol.md` checks (7 checks incl. `schema.py` frontmatter validation and declared `validators/`) as the structural pass; the Gap Report shape and the report format below stay Burrow's.

## Structural pass (always; deterministic)

Walk `wiki/`:

1. **Broken links** — every `[[target]]` must resolve to a page title or an `aliases` entry.
2. **Orphans** — pages with zero inbound links.
3. **Out-of-vocab edges** — every Relations line's `rel_type` must exist in its domain's vocabulary table.
4. **Zipper violations** (top severity) — each State table: exactly one `valid_to: —` row per predicate; every closed row carries `retired_by`; every opened row carries `caused_by`.
5. **Stale states** — current rows older than the domain's `review_horizon`.
6. **Unresolved contested** — `contested` markers older than 14 days.

Health score = defect count. Report it as the single headline number.

## Semantic pass (only when asked, or inside burrow-routine with budget)

Sample ≤ 40 pages, least-recently-checked first: cross-page contradictions, single-source claims stated as settled, inflated T2 durability grades. Findings are reports.

## Gap Report

Emit `_burrow/gap-report.md` in the YAML shape defined in `_protocols/lint.md`, priority-sorted. Phrase each researchable gap as a concrete `research_question`. Non-researchable defects (orphans, broken links) → list as fix-tasks for the review queue instead.

## Report

Headline: health score + delta vs the last run (find it in `_burrow/runs.md`). Then defects grouped by type, then the gap count by priority. One screen, no padding.
