# Getting Started — from clone to a self-tending vault

> The honest version: five phases, what each costs, and where people get stuck.
> Fastest path: run `/burrow-init` after installing the skills — it walks you through phases 0–2 interactively.

## Phase 0 · Move in (10 minutes)

```bash
git clone https://github.com/abuttoncc/Burrow.git

# Route A — fresh start: open vault-template/ as a new Obsidian vault
# Route B — graft onto an existing vault: copy these into your vault root:
#   00-Dashboard/  Inbox/  wiki/  07-QA/  08-Ops/  _protocols/  CLAUDE.md  (+ .obsidian theme/snippet if you want the look)

cp -r Burrow/skills/burrow-* your-vault/.claude/skills/
cp -r Burrow/skills/auto-wiki your-vault/.claude/skills/   # engine mode only
cd your-vault && claude
```

**Pick your mode — start Lite.** Lite mode is pure markdown, zero dependencies, and gets you to your first compilation in half an hour. Upgrade to engine mode (`pip install pydantic`, Python 3.8+) when you hit the real pain it solves: lots of numbers you want to query and aggregate (SQLite bitemporal storage), or a vault big enough to need BM25 search. Don't front-load the friction.

**Install the Dataview community plugin** (Obsidian → Settings → Community plugins) — the dashboard is a live Dataview view; it is the only hard plugin requirement. The shipped `.obsidian/` already enables the **Burrow theme**, the `dashboard` snippet, a graph view filtered to `path:wiki` with one color per type directory (the graph shows the ontology, not your prose), and daily notes pointed at `05-Daily/`. Optional plugins: **Terminal** (integrated terminal for the dashboard's console buttons), **Homepage** (boot into the dashboard), **obsidian-git** (auto-backup).

## Phase 1 · Write the house rules (30–60 minutes — the step that matters most)

Every domain needs an ontology contract before the gate will compile into it: node types with pointing criteria, a controlled relation vocabulary, routing keywords. **The gate refuses `status: draft` domains — fail loud, by design.** A vault that grows without a contract is how knowledge bases turn to mush.

Two ways to do it:

- **Guided (recommended):** run `/burrow-init` — it interviews you (what domain? what things do you track? what concepts get confused?) and drafts `wiki/<domain>/_ontology.md` for your review.
- **Manual:** copy `06-Templates/Domain Ontology Contract.md` to `wiki/<domain>/_ontology.md`, study `wiki/macro/_ontology.md` as a fully worked example, fill in your own.

Don't aim for completeness — aim for the 5–8 node types and 6–10 edge types you actually use. The vocabulary can grow later (vocabulary changes are `axiom-change`, locked to human, so growth stays deliberate).

## Phase 2 · Train the household (weeks 1–2, 10–20 minutes/day)

```
Drop anything into Inbox/        ← no rules here, ever
/burrow-ingest                   ← compile through the gate
/burrow-gate                     ← judge the queue: approve / reject / contested
```

**Set your expectations: the first two weeks are review-heavy, and that is the design working.** Every write-type starts in manual review. Each approval is a training signal; 20 consecutive approvals with zero rejections graduates that write-type to auto-promotion, and your review load drops off a cliff. One rejection resets the streak — so reject freely; sloppy approvals now mean a sloppy household later.

The sample paragraph in `Inbox/README` is a designed first meal: one compile demonstrates a T4 event, a T1 retirement, a T0 observation, and a locked item queuing for your judgment.

Also during this phase: create 2–3 standing questions in `07-QA/` (one file each — copy the shape of `07-QA/weekly-review.md`). They are the flywheel's fuel.

## Phase 3 · Switch on the magic

Morning ritual, manual:

```
/burrow-routine     # due questions → recall → review vs. last answer → lint → research gaps → ingest → report
```

Or unattended via OS cron:

```bash
0 4 * * * /bin/bash /path/to/vault/.claude/automation/burrow-routine.sh
```

**⚠️ The permissions gotcha.** Non-interactive `claude -p` cannot answer permission prompts — an unconfigured run hangs or bails. **The template ships `.claude/settings.json` with Option A below already in place**; review it, don't just trust it. The shipped runner `.claude/automation/burrow-routine.sh` handles PATH, logging to `08-Ops/runs/`, and has proxy notes in its header. Two postures:

```jsonc
// Option A — precise allowlist (recommended): permit what the routine actually does
{
  "permissions": {
    "allow": [
      "Read(./**)", "Edit(./**)", "Write(./**)",   // vault files only
      "Bash(python3 *)",                            // engine mode tools
      "WebSearch", "WebFetch(domain:*)"             // burrow-research
    ]
  }
}

// Option B — full bypass: only if the vault machine is yours alone and you accept the risk
{ "defaultMode": "bypassPermissions" }
```

Burrow's own invariants are your real safety net here — even a fully-permissioned routine can only write canon through the gate, and locked write-types still queue for you. But scope the OS-level permissions anyway; defense in depth.

From here your day looks like: open `Dashboard.md` (3 minutes) → read the QA timeline one-liners → judge the exceptions in the review queue → done. During deep work, ask `/burrow-recall` — answers come with provenance, including "as of <date>" time travel.

## Phase 4 · Expand the household

- **New domain:** `/burrow-init` again (or copy the template; engine mode: `python skills/auto-wiki/references/new_domain.py`).
- **More standing questions:** add files to `07-QA/`.
- **Tune the ledger:** if a write-type keeps a long clean streak but feels slow to graduate, lower its threshold in `08-Ops/approval-ledger.md`; if you regret an auto-promotion, one rejection demotes it. Never hand-edit streaks — the ledger is an audit log, not a config file.
- **Lite → engine migration:** just install the Python deps — the domain contract lives at `wiki/<domain>/_ontology.md` in both modes; nothing moves.

## The shape of the journey

| Phase | Cost | What you get |
|---|---|---|
| 0 Move in | 10 min | A vault with a gate |
| 1 House rules | 30–60 min | A domain the gate will accept |
| 2 Training | 2 weeks, 15 min/day | A ledger that has learned what you trust |
| 3 Magic on | one cron line | Mornings: 3 minutes of judgment, not hours of filing |
| 4 Expansion | as needed | More domains, same discipline |

The system's promise is not "no work" — it is that your work converges to **rules and exceptions**, which is where a householder's attention belongs.
