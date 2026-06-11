# Protocol: The Compilation Gate

> This file is read by `burrow-ingest` as its operating instructions. Editing this file edits the gate.

## The one rule above all rules

**Canonical knowledge (`wiki/`) is written through this gate and nowhere else.** INBOX, chat, drafts — none of them are constrained. All constraints live here. If you are an agent and you are about to edit a file under `wiki/` outside of this procedure: stop, you are about to break the house.

## Pipeline (seven steps, in order)

### 1. Route — which domain?

Match the source material against each domain's `keywords` in `_ontology/<domain>.md` frontmatter. Cross-domain material gets multi-domain tagging. **No match → stage as `needs_review` with reason `unrouted`** (a human assigns the domain; do not guess).

### 2. Register the source

Every compilation starts from an immutable source reference: the INBOX file path (or URL / research-bundle id), a content hash, the source date, and a source-type grade (`primary` / `official` / `secondary` / `social`). Same hash already registered → skip idempotently. Sources are never edited after registration.

### 3. Extract

Pull out the candidate knowledge: named things, claims, numbers, happenings. Apply the entity criterion from the domain's ontology file: **"can you point at exactly one thing?"** — if yes it's a node candidate; if it's a quality or a quantity it's a property or an observation, never a node (the three-way iron rule: *values don't become nodes; relations don't become nodes; labels don't become nodes*).

### 4. Canonical lookup

For every node candidate, search `wiki/<domain>/` by title **and** by the `aliases` field in frontmatter. Hit → this is a merge into the existing page. Miss → this is a new-page candidate. One thing, one page, one slug — near-duplicates are the rot that kills vaults.

### 5. Tier adjudication

Adjudicate every claim into exactly one tier per `_protocols/six-tier-time.md`. **No tier, no entry.** Numeric T0 claims that can be cross-checked (against an MCP data tool or a second independent source) get `verified` / `disputed` / `unverifiable`; disputed values are staged for human review with both values shown.

### 6. Stage the write plan

Produce a write plan — never raw edits: pages to create, pages to merge into, facts to append, states to retire-and-replace (per `_protocols/retirement.md`), edges to add (each checked against the domain's controlled vocabulary — out-of-vocab edges are **rejected here**, not queued). Tag every item in the plan with its **write-type**:

| write-type | meaning |
|---|---|
| `t0-merge` | append verified observation to an existing page |
| `t0-new` | observation requiring a new page |
| `new-node` | create a new entity/concept/mechanism page |
| `edge` | new relation within one domain |
| `cross-domain-edge` | relation spanning domains |
| `retirement` | close a current T1/T2 state and open a new one |
| `axiom-change` | any edit to `_ontology/` files |

### 7. Promote or queue (consult the ledger)

For each item, look up its write-type in `_burrow/gate-ledger.yaml`:

- `status: auto` → apply it now; record `reviewer: gate-auto` in the page's changelog.
- `status: manual` → write the item to `_burrow/review-queue/` as a card (what / old vs new / source / tier / write-type) and **do not apply**.
- `status: locked` → always queue, never eligible for auto. (`retirement` and `axiom-change` ship locked. This is a design decision, not a default to tweak on day two.)

Validation failure at any step fails the **whole batch** to the queue — no half-compiled entries, ever.

## After the gate

- Append one line to `_burrow/runs.md`: timestamp, source, items applied / queued / rejected.
- Mark the INBOX item compiled (move to `INBOX/_compiled/` with a pointer to what it became).
- If anything was queued, say so in your final report: the human decides when to review — never nag mid-task.
