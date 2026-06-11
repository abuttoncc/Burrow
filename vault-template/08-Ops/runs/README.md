# Run records

One file per unattended run: `YYYY-MM-DD-HHMM-<slug>.md`. Created at start (`status: running`), completed at end with flywheel steps, outputs (applied / queued / rejected), gaps found / researched, and budget spent. Stale detection: a `running` record older than 2h is treated as interrupted — re-entry resumes from the last completed step (compilation is idempotent by source hash).

Append-only as a set: records are never edited after completion, never pruned.

## Record format (the dashboard parses this)

Frontmatter: `type: run` · `routine:` (agent id, or `flywheel` for a full revolution) · `run-id:` · `started:` · `status: running|done|fail` · `outputs:` · `budget-spent:` · `escalations:`.
Body: a `## Flywheel` section with one step per line — `- HH:MM:SS ✓ what · detail · duration` (`✓` / `✗` / `…`).
