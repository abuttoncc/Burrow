---
type: routine
routine: inspector
name: Inspector
kind: deterministic
status: active
sort: 3
trigger: nightly run step + manual /burrow-lint
domains: [macro]
reads: "wiki/ (read-only)"
writes: "08-Ops/gap-report.md · run records"
budget: "structural pass: full scan · semantic pass: ≤40 pages, on request"
escalation: "zipper violations are top-severity defects"
last-run:
last-result:
---

# Inspector

Health checks: broken links, orphans, out-of-vocabulary edges, zipper violations, stale states, unresolved contested. Structural pass is **pure code — no LLM, no drift**, safe to run unattended forever. Findings become the Gap Report that feeds the Researcher. **Reports only; never repairs.**

- skill: `burrow-lint` · protocol: `_protocols/lint.md`
