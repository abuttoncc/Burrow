---
type: approval-ledger
updated: 2026-06-12
gates:
  - id: t0-merge
    name: T0 verified merge
    streak: 0
    threshold: 10
    state: counting
    note: fact-checked numeric merges into existing pages; lowest bar
  - id: new-node
    name: New node creation
    streak: 0
    threshold: 20
    state: counting
    note: 20 consecutive approvals with zero rejections earns the whitelist
  - id: edge
    name: New relation (within domain)
    streak: 0
    threshold: 20
    state: counting
    note: controlled-vocabulary edges inside one domain
  - id: cross-domain-edge
    name: Cross-domain edge
    streak: 0
    threshold: 20
    state: counting
    note: edges spanning domains; observation period
  - id: retirement
    name: Retirement (T1/T2 current-state change)
    streak: 0
    threshold: 0
    state: locked
    note: by design — rewriting the recorded present never goes automatic
  - id: disputed
    name: Fact-check dispute
    streak: 0
    threshold: 0
    state: locked
    note: numeric disagreements are judged case by case, forever
  - id: axiom-change
    name: Ontology change
    streak: 0
    threshold: 0
    state: locked
    note: the house rules change only by human hand
---

# Approval Ledger

> **Autonomy is earned.** Each high-risk write-type tracks a streak: `threshold` consecutive human
> approvals with zero rejections → `state: auto` (unattended runs may apply directly — still logged).
> **One rejection → streak resets to zero**; an `auto` gate demotes back to `counting`.
> `locked` gates never graduate.

## Two modes

- **Interactive session** — high-risk writes are asked on the spot; **the judgment itself is the bookkeeping** (approve → streak+1, reject → reset).
- **Unattended run** (cron / scheduled) — any gate not in `state: auto` queues a candidate card in `review/` instead of writing.

## Audit log (append-only)

| date | gate | action | note |
|---|---|---|---|
