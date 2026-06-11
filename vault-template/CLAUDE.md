# Burrow Vault — agent instructions

> Read by your agent at every session. This file is the vault's navigation contract; per-domain
> ontology details live in `wiki/<domain>/_ontology.md` (the authoritative truth source on conflict).

A two-layer knowledge vault plus an automation layer:

- **Work layer** (humans write prose, zero constraints): `Inbox/`, `05-Daily/` (optional), templates in `06-Templates/`.
- **Ontology layer `wiki/`** (compiled product, fully constrained): one directory per **domain**, type subdirectories = graph coloring, contract at `wiki/<domain>/_ontology.md`.
- **Automation layer `08-Ops/`**: agent contracts, run records, review queue, approval ledger.

**Compilation is one-way**: `Inbox (prose) → /burrow-ingest (the gate) → wiki (typed knowledge)`.
The wiki is consumed back only via recall. **Rigor applies to crystallized knowledge (wiki), never to crystallizing knowledge (Inbox).**

## The map

| Folder | What |
|---|---|
| `00-Dashboard/` | Morning view (Dataview; theme: Burrow; snippet: dashboard.css) |
| `Inbox/` | Capture — anything, no rules, ever |
| `05-Daily/` | Optional daily notes (dashboard today-list reads it when present) |
| `06-Templates/` | Research Note (confusion/goal/threads/notes) · Domain Ontology Contract |
| `07-QA/` | Standing questions — one file each; answers append as a time series |
| `08-Ops/` | Routines (contracts) · runs · review queue · [[approval-ledger]] |
| `wiki/` | The ontology. Step 0 of ingest/recall: read `wiki/_index.md`, route by keywords |
| `_protocols/` | The discipline in prose — these files ARE the operating prompts |
| `.claude/` | Skills (copied from the repo) · `settings.json` permissions · `automation/` headless runner |

## Invariants (violating any of these is a bug, not a style choice)

1. **One gate** — canonical writes happen only through the ingest pipeline (`_protocols/compilation-gate.md`).
2. **Capture is free, promotion is strict** — Inbox has no schema; the gate has all of it.
3. **No tier, no entry** — every claim is adjudicated into T0–T5 (`_protocols/six-tier-time.md`).
4. **Retire, never delete** — state changes close the old row with a date + event stamp (`_protocols/retirement.md`).
5. **Controlled vocabulary** — relations outside the domain's edge vocab are rejected.
6. **Autonomy is earned** — consult `08-Ops/approval-ledger.md` before applying high-risk writes; one rejection resets the streak. `locked` gates never graduate.
7. **Answers carry provenance** — recall cites pages/rows or declares a gap; QA answers are append-only.
8. **Outputs funnel to the gate** — unattended agents submit candidates to `08-Ops/review/`, never write high-risk canon directly.

## Using the vault (the read side — this is the point of everything above)

The wiki is not an archive; it is your **compiled context store**. Reading it is not optional behavior — it is Rule 0:

**Rule 0 — recall first.** Before any substantive task (research, analysis, writing, answering a domain question): read `wiki/_index.md`, identify the touched domain(s), load the hub and the relevant pages (one wikilink hop; State tables for current truth). **Start your thinking from what the vault already knows, and say so** ("the vault records X as of Y"). If the vault has nothing relevant, say that too — then work, and offer to compile what you produce. Skipping recall and reasoning from your own priors when the vault had an answer is a bug, not a style choice.

**Provenance trichotomy.** Every claim in your output is one of exactly three things:
1. **Vault-backed** — cite the page (`[[...]]`) or the data row; respect its `valid_from/valid_to` window and surface `contested` as contested.
2. **Tool-backed** — fresh from a data tool / web source; name it.
3. **Model knowledge** — fenced explicitly: *"beyond the vault: …"*. Never blended unmarked into 1 or 2.

Before sending an answer: scan it for claims wearing no badge from this list — fence them or cut them.

**Production reflow.** When a conversation produces a substantive analysis (a conclusion someone might rely on later), offer once to compile it into `wiki/<domain>/analyses/` through the gate — your good answers are also sources. Inbox prose and daily notes are never citable context (uncompiled = unadjudicated).

## Two judgment modes

- **Interactive session**: ask the user on the spot for non-auto gates; their verdict is the ledger bookkeeping.
- **Unattended run**: never wait for input — queue candidates, log the run in `08-Ops/runs/`, report on the dashboard.

## Trigger phrases → skills

| The user says | Run |
|---|---|
| "ingest" / "compile this" / drops material in Inbox | `burrow-ingest` |
| "process the review queue" / "review" | `burrow-gate` |
| "health check" / "lint" | `burrow-lint` |
| "fill the gaps" / "research" | `burrow-research` |
| "run today's routine" / cron | `burrow-routine` |
| a knowledge question / "as of <date>" | `burrow-recall` |
| "new domain" / first-time setup | `burrow-init` |

## Engine note

If `skills/auto-wiki/` is installed (engine mode), the compile core follows the engine's protocols
(`ingest-protocol.md`, `storage-spec.md`: numbers/states go to the domain's `data.db`) and
`wiki/_index.md` is regenerated by `new_domain.py --reindex`. Without it, the pure-markdown
protocols in `_protocols/` are the complete fallback.
