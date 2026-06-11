# 08-Ops — the automation layer

> The Burrow's engine room. Humans do deep thinking and global control; "when X happens → do Y"
> pattern work belongs to contract-bound agents (routines).

| Here | What it is |
|---|---|
| [[approval-ledger]] | The trust ledger: per-write-type streaks, thresholds, states. **Autonomy is earned.** |
| `routines/` | Agent contract pages — one page per appliance. Frontmatter **is** the contract (trigger / scope / budget / escalation). Changing the contract = changing the permission. |
| `review/` | The review queue: candidate cards for high-risk writes from unattended runs (`pending → approved / rejected / contested`) |
| `runs/` | Unattended run records — one file per run: status, flywheel steps, outputs, budget spent |

Four principles on top of the vault's invariants:

1. **Outputs funnel to the gate** — unattended agents never write high-risk canon directly; they submit candidates.
2. **Capture is free, promotion is strict.**
3. **Consecutive approvals graduate · one rejection demotes** (the approval ledger).
4. **Determinism first** — anything pure code can do is never given to an LLM.

Trigger phrase: say **"process the review queue"** (or `/burrow-gate`) to judge pending cards.
