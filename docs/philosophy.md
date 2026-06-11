# The Burrow Pattern — Design Philosophy

> Why a magical household is the right mental model for autonomous knowledge work.

## The metaphor, taken seriously

In the Weasley household, every appliance works on its own: the knitting needles knit, the spoon stirs the pot, the pan flips the eggs. Three things make this charming instead of terrifying:

1. **The appliances have no free will.** A knitting needle never decides to stir the soup. Each is enchanted *within a narrow scope*.
2. **The magic carries the boundary.** It is not that the needle is watched constantly — the spell itself cannot reach the soup.
3. **Mrs. Weasley doesn't knit.** She decides *what* gets knitted and *when to stop*. Her attention goes to rules and exceptions, never to individual stitches.

Translate that to a knowledge workspace and you get the three design problems every "AI tends your notes" project must answer:

- What plays the role of the **spell's boundary**? → An ontology: typed nodes, a controlled relation vocabulary, time-tier axioms. *The ontology is not a warehouse of knowledge — it is the house rules that keep a crew of tireless little workers from fighting each other and wrecking the rooms.*
- What keeps an appliance from **rearranging the house**? → A single write gate. Appliances produce *candidates*; only the gate compiles candidates into canon.
- What does the **human** actually do? → Deep thinking, and adjudicating exceptions. If the human ends up approving every stitch, the design has failed.

## Five principles

### 1. One gate, and rigor lives only there

A knowledge system dies one of two deaths: it suffocates (so much structure that capture feels like filing taxes) or it dissolves (so little structure that retrieval returns mush). The resolution is asymmetry:

- **Capture is free.** INBOX accepts anything — half-thoughts, screenshots, pasted articles. No schema, no judgment, ever.
- **Promotion is strict.** The only path from INBOX to canon is a compilation step that routes by domain, extracts claims, adjudicates each into a time tier, checks every relation against the controlled vocabulary, and stages the result for review or auto-promotion.

Structure at the moment of *promotion*, never at the moment of *capture*.

### 2. Knowledge has tiers of time

Most note systems treat all knowledge as timeless prose. But "the 7-day reverse repo rate is 1.40%" (an observation), "the policy stance is accommodative" (a current state), "PPI transmits to CPI with a lag" (standing logic), and "the central bank cut rates on June 9" (an event) age in completely different ways. Burrow adjudicates every claim into one of six tiers — and the tier determines its physics:

- **T0 observations** accumulate; corrections supersede, never overwrite.
- **T1 states / T2 logic** live in a zipper: when the world changes, the old row is closed with a `valid_to` date and a `retired_by` event stamp, and a new row opens. *Retire, never delete.*
- **T4 events** are append-only and dated — they are what stamp the changes.
- **T5 axioms** (the ontology itself) change rarely and only by explicit human edit.

A vault with this discipline can answer: *what did we believe on March 3, what do we believe now, and which event changed it?* That is the difference between notes and knowledge.

### 3. Autonomy is earned, not configured

Every agent product faces the trust dial: always-ask is exhausting; always-allow is reckless; a static middle setting is wrong in both directions. Burrow makes the dial *move with evidence*:

- Each **write-type** (merge a verified fact, create a new node, draw a cross-domain edge, retire a state) has its own ledger entry.
- Everything starts in **manual review**. A write-type that accumulates N consecutive approvals with zero rejections (default 20) earns **auto-promotion**.
- **One rejection resets the streak to zero.** Some types — anything that changes the recorded current state of the world — are **locked to manual forever** by design.

The ledger is a plain YAML file. Trust is legible, auditable, and revocable. Your reviewing is not overhead — every approve/reject is a training signal to the household.

### 4. Determinism before intelligence

Not every appliance needs a brain. Broken-link checks, orphan detection, vocabulary validation, ledger bookkeeping — these are deterministic and should stay deterministic: no LLM, no drift, safe to run unattended forever. Spend intelligence only where judgment is genuinely required: extraction, tier adjudication, gap-driven research, semantic contradiction checks. A household where only some appliances are enchanted is much easier to trust.

### 5. The flywheel: notice what's missing

Organizing what you already captured is table stakes. The compounding loop is:

```
lint finds gaps (missing data · single-source claims · stale states · uncovered concepts)
  → research goes out to fill them (web, MCP tools, your own archives)
  → evidence returns through the same gate as everything else
  → the vault grows where it was weakest
```

Each turn of the wheel also answers your standing questions (append-only QA: every answer reviews the last one against what actually happened — the vault keeps score of its own predictions).

## The attention budget (an honest tension)

The more appliances you run, the scarcer the householder's attention. If every appliance dutifully queues candidates for review, the review queue becomes a second inbox-hell and "the human does deep thinking" collapses into "the human does approvals." The earned-autonomy ledger is the pressure valve: low-risk write-types graduate out of the queue, and the human's attention concentrates on genuine exceptions — which is exactly where it belongs. Watch one number: **median review-queue length per day**. If it trends up while streaks aren't graduating, your thresholds are wrong or your appliances are sloppy. Fix the appliance, don't lower the gate.

## Lineage

Burrow descends from [Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) — LLM as maintainer, human as reader — through our own [auto-wiki](https://github.com/hanlinlibham/auto-wiki) knowledge compiler, which ships inside Burrow as the compilation engine: its three-way compare (reinforce / update / conflict) is the engine-level answer to "how does new knowledge meet old," while Burrow's ledger answers "who may apply it." It also borrows honest ideas from the projects exploring this space: per-edit approval and vault hygiene from the gardener-style plugins, shadow-checkpoint undo from in-vault operators, temporal knowledge graphs from the memory-layer projects. What it adds: the compilation gate as the *only* write path, six-tier time adjudication, and a trust system where autonomy is earned per write-type rather than granted per session.

*The needles knit all night. The house stays a home.*
