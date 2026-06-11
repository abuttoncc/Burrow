---
type: routine
routine: researcher
name: Researcher
kind: llm-async
status: active
sort: 4
trigger: gap report from Inspector / manual /burrow-research
domains: [macro]
reads: "08-Ops/gap-report.md · web · MCP data tools"
writes: "evidence bundles → Inbox/ (re-enter through the gate)"
budget: "≤10 gaps/run · 1 retry/gap · web confidence ceiling: medium"
escalation: "conflicting sources → bundle flagged, gate stages as disputed"
last-run:
last-result:
---

# Researcher

Takes gaps, goes out (web search / MCP tools), returns evidence bundles **into Inbox** — never stocks the pantry directly. "Gap remains open" is a valid, recorded outcome; invented answers are corruption.

- skill: `burrow-research`
