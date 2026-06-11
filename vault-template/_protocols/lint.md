# Protocol: Lint (health check + gap report)

> Read by `burrow-lint`. Two passes: a deterministic structural pass (safe to run forever, no LLM needed) and a sampled semantic pass.

## Structural pass (deterministic)

| Check | Definition | Severity |
|---|---|---|
| **Broken link** | `[[target]]` with no matching page or alias | defect |
| **Orphan** | wiki page with zero inbound links | defect |
| **Out-of-vocab edge** | Relations line whose `rel_type` is not in the domain's vocabulary | defect — quarantine the line, report |
| **Unresolved contested** | claim marked `contested` older than 14 days | defect |
| **Zipper violation** | a State table with ≠1 current row per predicate, or rows missing event stamps | defect — **top priority**, this is corruption |
| **Stale state** | T1 row untouched past its domain's `review_horizon` (e.g. policy rates: 90d) | gap |

Health score = total defects. **The dashboard shows one number; zero means healthy.**

## Semantic pass (LLM, sampled)

On a sample (≤40 pages per run, rotate by least-recently-checked): contradictions between pages, single-source claims presented as settled, T2 entries whose durability grade looks inflated. Findings are **reports, never edits**.

## Gap Report (the flywheel's fuel)

Output a structured list, each entry:

```yaml
- gap_type: data_missing | single_source | stale_state | concept_missing | broken_link
  page: wiki/macro/mlf-rate.md        # or "(new)" for concept_missing
  detail: "no observation since 2026-03; review_horizon is 90d"
  research_question: "What is the current MLF rate and when did it last change?"
  priority: high | medium | low
```

`burrow-research` consumes this report top-down within its budget. Gaps that cannot be phrased as a research question (e.g. orphans) are fix-tasks, not research tasks — route them to the review queue instead.
