# Protocol: The Compilation Gate

> This file is read by `burrow-ingest` as its operating instructions. Editing this file edits the gate.

## The one rule above all rules

**Canonical knowledge (`wiki/`) is written through this gate and nowhere else.** Inbox, chat, drafts — none of them are constrained. All constraints live here. If you are an agent and you are about to edit a file under `wiki/` outside of this procedure: stop, you are about to break the house.

## Pipeline (seven steps, in order)

### 1. Route — which domain?

Match the source material against each domain's `keywords` in `wiki/<domain>/_ontology.md` frontmatter. Cross-domain material gets multi-domain tagging. **No match → stage as `needs_review` with reason `unrouted`** (a human assigns the domain; do not guess).

### 2. Register the source

Every compilation starts from an immutable source reference: the Inbox file path (or URL / research-bundle id), a content hash, the source date, and a source-type grade (`primary` / `official` / `secondary` / `social`). Same hash already registered → skip idempotently. Sources are never edited after registration.

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
| `axiom-change` | any edit to `wiki/<domain>/_ontology.md` files |

### 7. Promote or queue (consult the ledger)

For each item, look up its write-type in the frontmatter `gates` of `08-Ops/approval-ledger.md`:

- `state: auto` → apply it now; record `reviewer: gate-auto` in the page's changelog (still logged — auto means trusted, not invisible).
- `state: counting` → **interactive session**: ask the user on the spot; their verdict is the bookkeeping. **Unattended run**: write a candidate card to `08-Ops/review/` and do not apply.
- `state: locked` → always requires a human verdict; never eligible for auto. (`retirement`, `disputed`, and `axiom-change` ship locked. This is a design decision, not a default to tweak on day two.)

Validation failure at any step fails the **whole batch** to the queue — no half-compiled entries, ever.

## Engine mode (auto-wiki inside)

If `skills/auto-wiki/` is installed (the [auto-wiki](https://github.com/hanlinlibham/auto-wiki) compilation engine, v0.2+), steps 2–6 **delegate to the engine's protocols** — they are the full-strength implementation of the same discipline:

- Extraction, three-way compare (reinforce / update / conflict), and page writes follow `skills/auto-wiki/references/ingest-protocol.md` and `wiki-format.md`.
- Storage follows `storage-spec.md`: numbers and states go to the domain's `data.db` (T0 `data_points`, T1/T2 `facts` zipper, T4 `events`); markdown stays the narrative layer. Run `schema.py` validation on every touched page.
- The domain contract lives at `wiki/<domain>/_ontology.md` in **both modes** — one location, no migration.
- Engine `seeds/` are cold-start vocabularies; engine `validators/` plug into lint.

**Burrow's own layer is unchanged in either mode**: write-type tagging (step 6), the gate ledger (step 7), the review queue, and the locked types. The engine decides *how* knowledge compiles; the ledger decides *who may apply it*. Without the engine, the pure-markdown procedure above is the complete fallback — zero dependencies, any agent can run it.

## After the gate

- Record the run in `08-Ops/runs/`: timestamp, source, items applied / queued / rejected.
- Mark the Inbox item compiled (move to `Inbox/_compiled/` with a pointer to what it became).
- If anything was queued, say so in your final report: the human decides when to review — never nag mid-task.
