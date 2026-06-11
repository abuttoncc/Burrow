---
name: burrow-init
description: Guided onboarding for a Burrow vault — checks the scaffold (Dashboard, Inbox, wiki, 07-QA, 08-Ops, protocols, ledger), detects lite vs engine mode, interviews the user to draft a domain ontology contract (node types, pointing criteria, controlled edge vocabulary, routing keywords) at wiki/<domain>/_ontology.md, seeds standing questions in 07-QA/, and registers the domain in wiki/_index.md. Use when the user says "init", "setup", "new domain", "开新域", "初始化", or is clearly starting fresh with Burrow.
---

# burrow-init — the housewarming

You walk a new householder from an empty vault to a domain the gate will accept. You are an interviewer and a drafter; the user is the authority on their domain. **Everything you produce is a draft for their review — `axiom-change` is locked, and that includes births.**

## Step 1 · Check the scaffold

Verify the vault has: `00-Dashboard/Dashboard.md`, `Inbox/`, `wiki/_index.md`, `06-Templates/`, `07-QA/README.md`, `08-Ops/` (with `approval-ledger.md`, `routines/`, `review/`, `runs/`), `_protocols/` (4 files), root `CLAUDE.md`. Create anything missing from the vault-template shapes — the ledger gets the standard gates with `streak: 0` (**never overwrite an existing ledger**). `05-Daily/` is optional; mention it, don't create it unbidden. Report what existed vs what you created. Remind once: the dashboard needs the Dataview community plugin and the Burrow theme lives in `.obsidian/themes/`.

## Step 2 · Detect the mode

- `skills/auto-wiki/` present + `python3 -c "import pydantic"` succeeds → **engine mode** (offer `new_domain.py` scaffolding and data.db init).
- Otherwise → **lite mode**. Say so, note the upgrade path exists — do not push it.

The domain contract lives at `wiki/<domain>/_ontology.md` in both modes — one location, no migration.

## Step 3 · Interview for the domain contract

Ask, in order, conversationally (one question at a time, listen before the next):

1. **"What domain is this — in one phrase?"** → domain slug + hub name.
2. **"What kinds of *things* do you track here?"** → candidate node types. Push each through the pointing criterion ("can you point at exactly one X?"). Steer values, classifications, and relations OUT of the type list (the three-way iron rule).
3. **"Which of these change over time, and what makes them change?"** → identifies what will live as T1 states and what the domain's T4 events look like; also yields a sensible `review_horizon`.
4. **"What pairs of concepts do people in this field confuse or conflate?"** → becomes the "domain traps" section — these are the highest-value lines you will write.
5. **"How do things in this domain relate?"** → draft the controlled edge vocabulary, 6–10 edges max to start. Reuse the universal set (`instance_of / part_of / classified_as / created_by / references`) and add only domain-specific verbs.
6. **"What words would appear in material that belongs to this domain?"** → routing `keywords` (include native-language terms if the user's sources are bilingual).

Aim small: 5–8 node types, 6–10 edge types. Tell the user the vocabulary can grow later through the locked `axiom-change` path — a thin contract that's right beats a thick one that's guessed.

## Step 4 · Draft, review, activate

1. Write the draft contract to `wiki/<domain>/_ontology.md` following the structure of `wiki/macro/_ontology.md` (template: `06-Templates/Domain Ontology Contract.md`), with `status: draft`.
2. Walk the user through it section by section. Apply their corrections.
3. **Only on their explicit confirmation**, flip `status: active`. The gate now accepts this domain.
4. Scaffold the domain: type subdirectories per the contract, a hub page (`wiki/<domain>/<Hub>.md`, frontmatter `type: hub`), and a row in `wiki/_index.md` (engine mode: `new_domain.py` does this and regenerates the registry).

## Step 5 · Light the flywheel

1. Ask for 1–3 standing questions ("what do you want this vault to keep answering?") → create one file each in `07-QA/` per the frontmatter contract in `07-QA/README.md` (mode/cadence/recall-scope), body = the question + its answering protocol (copy the shape of `07-QA/weekly-review.md`).
2. Point at `Inbox/README.md`'s sample paragraph (or any note they have) and suggest the first compile: `/burrow-ingest`.
3. Close with the two-week expectation, verbatim spirit: *"For the next two weeks everything queues for your judgment — that's the ledger learning what you trust. Reject freely; streaks graduate at their thresholds."*

## Hard rules

- You never write into `wiki/` content pages — you only scaffold structure, hubs, and draft contracts. Knowledge enters through the gate.
- You never edit ledger streaks or thresholds (creating the file fresh with zeros is the one exception).
- One domain per run unless the user asks for more. A focused housewarming beats a tour of empty rooms.
