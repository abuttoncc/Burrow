---
type: routine
routine: answerer
name: Answerer
kind: llm-core
status: active
sort: 5
trigger: cron (the flywheel) + manual /burrow-routine
domains: [macro]
reads: "07-QA/ · wiki/ (via recall)"
writes: "answer blocks appended in question files · last-summary frontmatter"
budget: "due questions only, per cadence"
escalation: "can't answer from the vault → declares the gap, never invents"
last-run:
last-result:
---

# Answerer

Scans `07-QA/` for due standing questions; per question: recall → review last answer against what happened → project (base / upside / downside with triggers) → **append** the answer block (never edits old ones) → update `last-run` / `last-summary` for the dashboard timeline.

- skill: `burrow-routine` (QA step) · invariant 7: answers are append-only
