# Protocol: Retirement (never deletion)

> How current states (T1) and standing logic (T2) change. The vault remembers everything it ever believed — and why it stopped.

## The six steps (atomic — one edit, all or nothing)

When a T1/T2 entry's current value changes:

1. **Locate** the current row in the page's State section (the row with `valid_to: —`).
2. **Close it**: set `valid_to:` to the change date.
3. **Stamp the cause**: set `retired_by:` to the T4 event that ended it (`[[events/YYYY-MM-DD-slug]]`). No event page yet → create it in the same batch (events are cheap; unexplained changes are expensive).
4. **Open the new row**: same predicate, new value, `valid_from:` = change date, `valid_to: —`.
5. **Stamp the origin**: set the new row's `caused_by:` to the same event.
6. **Never touch** any other historical row.

## State section format (in any wiki page)

```markdown
## State

| predicate | value | valid_from | valid_to | caused_by | retired_by |
|---|---|---|---|---|---|
| reserve-ratio (major banks) | 7.50% | 2026-06-15 | — | [[events/2026-06-09-rrr-cut]] | — |
| reserve-ratio (major banks) | 8.00% | 2026-02-05 | 2026-06-15 | [[events/2026-02-01-rrr-cut]] | [[events/2026-06-09-rrr-cut]] |
```

Current state = the row where `valid_to` is `—`. History = everything else. **There is exactly one current row per predicate** (lint checks this).

## Why this is locked to manual review forever

A retirement rewrites what the vault asserts about the present. A wrong observation is one bad data point; a wrong retirement silently corrupts every downstream answer until someone notices. The gate ledger marks `retirement` as `locked`: the agent prepares all six steps perfectly, and a human clicks approve. This is not distrust of agents — it is the same reason banks dual-control the vault door.
