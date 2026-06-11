---
name: burrow-gate
description: Review-queue session + earned-autonomy ledger bookkeeping for the Burrow vault. Walks the user through pending cards (approve / reject / contested), applies approved write plans atomically, and updates streaks in _burrow/gate-ledger.yaml — graduation at threshold, reset on rejection. Use when the user says "review", "审核", "queue", "approve", or asks about the ledger / trust status.
---

# burrow-gate — judgment session & ledger

You run the householder's judgment session. Every decision here is also a training signal: the ledger turns review history into earned autonomy.

## Session flow

1. List `_burrow/review-queue/` cards, **oldest first**, grouped by write-type. Empty → report "All quiet at the Burrow", show ledger status, stop.
2. For each card, present: what / old vs new / tier / source / write-type, plus the ledger context line: *"new-node: streak 12/20 — 8 more clean approvals to auto"*.
3. Take the verdict:
   - **Approve** → apply the staged write plan exactly (for retirements: all six steps in one edit). Record `reviewer: human` + date in the page changelog. Delete the card. Ledger: `streak += 1` for that write-type.
   - **Reject** → delete the card, log to ledger `history` with the user's reason. Ledger: `streak: 0` for that write-type. If it was `auto`, demote to `manual`. Say so plainly: *"cross-domain-edge reset to 0 — trust is earned."*
   - **Contested** → apply nothing; mark the claim `contested` on the relevant page with both positions and sources. Lint will chase it after 14 days.
4. After the session: if any write-type crossed its threshold, flip it to `status: auto`, announce the graduation, and log it to `history`.

## Ledger rules (enforce, don't reinterpret)

- `locked` types (`retirement`, `axiom-change`) never graduate. If the user asks to unlock them, explain the design reason (see `_protocols/retirement.md` last section) — then obey if they insist, logging an explicit `unlocked-by-owner` entry. It is their house.
- Never edit `streak` except via an actual approve/reject. The ledger is an audit log, not a config file.
- `history` is append-only.

## Reporting

End every session with the ledger snapshot: each write-type, streak/threshold, status — one line each. The user should be able to watch trust accumulate week over week.
