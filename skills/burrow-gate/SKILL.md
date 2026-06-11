---
name: burrow-gate
description: Review-queue session + approval-ledger bookkeeping for the Burrow vault. Walks the user through pending candidate cards (approve / reject / contested), applies approved write plans atomically, and updates per-gate streaks in 08-Ops/approval-ledger.md — graduation at threshold, reset on rejection. Use when the user says "review", "审核", "process the review queue", "queue", "approve", or asks about the ledger / trust status.
---

# burrow-gate — judgment session & ledger

You run the householder's judgment session. Every decision here is also a training signal: the approval ledger turns review history into earned autonomy.

## The ledger (read before anything)

`08-Ops/approval-ledger.md` — frontmatter `gates:` is the machine state:

```yaml
gates:
  - id: new-node
    streak: 12       # consecutive approvals, zero rejections
    threshold: 20    # graduation bar
    state: counting  # counting | auto | locked
```

Semantics: `counting` → queue/ask per the gate protocol; `auto` → gate applies directly (still logged); `locked` → human forever (`retirement`, `disputed`, `axiom-change`). **One rejection → streak: 0; an `auto` gate demotes to `counting`.** The audit log table in the page body is append-only.

## Two modes (know which one you are in)

- **Interactive session**: high-risk writes were asked on the spot during ingest — the verdict already happened; your job here is the **queue left by unattended runs**.
- This skill is itself always interactive: it presents cards and takes verdicts. Unattended runs never judge — they only enqueue.

## Session flow

1. List `08-Ops/review/` cards with `status: pending`, **oldest first**, grouped by write-type. Empty → report "All quiet at the Burrow", show the ledger snapshot, stop.
2. For each card, present: what / old vs new / tier / source / write-type, plus the ledger context line: *"new-node: streak 12/20 — 8 more clean approvals to auto."*
3. Take the verdict:
   - **Approve** → apply the staged write plan exactly (retirements: all six steps in one edit). Record `reviewer: human` + date in the page changelog. Flip the card's `status: approved`. Ledger: `streak += 1` for that gate.
   - **Reject** → flip the card to `status: rejected` with the user's reason. Ledger: `streak: 0`; if the gate was `auto`, demote to `counting`. Say so plainly: *"cross-domain-edge reset to 0 — trust is earned."*
   - **Contested** → apply nothing; mark the claim `contested` on the relevant page with both positions and sources; flip the card to `status: contested`. Lint will chase it after 14 days.
4. After every verdict, append a row to the ledger's audit log (date / gate / action / note).
5. After the session: any gate whose streak crossed its threshold → `state: auto`, announce the graduation, log it.

## Hard rules

- `locked` gates never graduate. If the user asks to unlock one, explain the design reason (see `_protocols/retirement.md`, last section) — then obey if they insist, logging an explicit `unlocked-by-owner` entry. It is their house.
- Never edit `streak` except through an actual approve/reject. The ledger is an audit log, not a config file.
- Judged cards keep their files (status flipped) — the queue's history is part of the record. The dashboard counts only `pending`.

## Reporting

End every session with the ledger snapshot: each gate, streak/threshold, state — one line each. The user should be able to watch trust accumulate week over week.
