---
type: routine
routine: compiler
name: Compiler
kind: llm-core
status: active
sort: 2
trigger: delegated by Triage / Researcher / manual /burrow-ingest
domains: [macro]
reads: "Inbox/ · wiki/<domain>/_ontology.md · _protocols/"
writes: "wiki/ — THE only writer, through the gate pipeline"
budget: "whole-batch fail to queue on any validation error"
escalation: "retirement · disputed · new-node (until earned) → review/"
last-run:
last-result:
---

# Compiler

The gate itself: route → register source → extract → canonical lookup → six-tier adjudication → vocabulary check → consult the [[approval-ledger]] → apply or queue. The only appliance with canon write access, and only via this pipeline.

- skill: `burrow-ingest` · protocol: `_protocols/compilation-gate.md`
