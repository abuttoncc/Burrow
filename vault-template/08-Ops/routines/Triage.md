---
type: routine
routine: triage
name: Triage
kind: llm-light
status: active
sort: 1
trigger: scheduled scan + manual /burrow-ingest
domains: [macro]
reads: "Inbox/"
writes: "triage marks · compiled flags · delegates compilation to the gate"
budget: "≤10 items per pass"
escalation: "uncertain triage defaults to reference + human"
last-run:
last-result:
---

# Triage

Scans uncompiled prose in `Inbox/` → three-way routing (crystallize / reference / ephemeral) → crystallized items are delegated to `burrow-ingest` → marks `compiled`. **Writes triage marks only — never canon**; all compilation goes through the gate.

- skill: `burrow-ingest` (triage step)
