# Getting Started — from clone to a self-tending vault

> The honest version: five phases, what each costs, and where people get stuck.
> Fastest path: run `/burrow-init` after installing the skills — it walks you through phases 0–2 interactively.

## Phase 0 · Move in (10 minutes)

```bash
git clone https://github.com/abuttoncc/Burrow.git

# Route A — fresh start: open vault-template/ as a new Obsidian vault
# Route B — graft onto an existing vault: copy these into your vault root:
#   INBOX/  wiki/  _ontology/  _protocols/  _burrow/  Dashboard.md

cp -r Burrow/skills/* your-vault/.claude/skills/
cd your-vault && claude
```

**Pick your mode — start Lite.** Lite mode is pure markdown, zero dependencies, and gets you to your first compilation in half an hour. Upgrade to engine mode (`pip install pydantic`, Python 3.8+) when you hit the real pain it solves: lots of numbers you want to query and aggregate (SQLite bitemporal storage), or a vault big enough to need BM25 search. Don't front-load the friction.

**Install the Dataview community plugin** (Obsidian → Settings → Community plugins) — `Dashboard.md` uses it. Without it the dashboard degrades to plain links; everything else still works.

## Phase 1 · Write the house rules (30–60 minutes — the step that matters most)

Every domain needs an ontology contract before the gate will compile into it: node types with pointing criteria, a controlled relation vocabulary, routing keywords. **The gate refuses `status: draft` domains — fail loud, by design.** A vault that grows without a contract is how knowledge bases turn to mush.

Two ways to do it:

- **Guided (recommended):** run `/burrow-init` — it interviews you (what domain? what things do you track? what concepts get confused?) and drafts `_ontology/<domain>.md` for your review.
- **Manual:** copy `_ontology/_template.md`, study `_ontology/macro.md` as a fully worked example, fill in your own.

Don't aim for completeness — aim for the 5–8 node types and 6–10 edge types you actually use. The vocabulary can grow later (vocabulary changes are `axiom-change`, locked to human, so growth stays deliberate).

## Phase 2 · Train the household (weeks 1–2, 10–20 minutes/day)

```
Drop anything into INBOX/        ← no rules here, ever
/burrow-ingest                   ← compile through the gate
/burrow-gate                     ← judge the queue: approve / reject / contested
```

**Set your expectations: the first two weeks are review-heavy, and that is the design working.** Every write-type starts in manual review. Each approval is a training signal; 20 consecutive approvals with zero rejections graduates that write-type to auto-promotion, and your review load drops off a cliff. One rejection resets the streak — so reject freely; sloppy approvals now mean a sloppy household later.

The sample paragraph in `INBOX/welcome` is a designed first meal: one compile demonstrates a T4 event, a T1 retirement, a T0 observation, and a locked item queuing for your judgment.

Also during this phase: put 2–3 standing questions in `_burrow/questions.md` (question + cadence + domain scope). They are the flywheel's fuel.

## Phase 3 · Switch on the magic

Morning ritual, manual:

```
/burrow-routine     # due questions → recall → review vs. last answer → lint → research gaps → ingest → report
```

Or unattended via OS cron:

```bash
0 4 * * * cd /path/to/vault && claude -p "/burrow-routine" >> _burrow/cron.log 2>&1
```

**⚠️ The permissions gotcha (read this before your first cron run).** Non-interactive `claude -p` cannot answer permission prompts — an unconfigured run will hang or bail. Configure the vault's `.claude/settings.json` first. Two options:

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
- **More standing questions:** add rows to `_burrow/questions.md`.
- **Tune the ledger:** if a write-type keeps a long clean streak but feels slow to graduate, lower its threshold in `gate-ledger.yaml`; if you regret an auto-promotion, one rejection demotes it. Never hand-edit streaks — the ledger is an audit log, not a config file.
- **Lite → engine migration:** install Python deps, and move each domain contract from `_ontology/<domain>.md` to `wiki/<domain>/_ontology.md` (the engine's authoritative location). `/burrow-init` offers to do this move when it detects the engine.

## The shape of the journey

| Phase | Cost | What you get |
|---|---|---|
| 0 Move in | 10 min | A vault with a gate |
| 1 House rules | 30–60 min | A domain the gate will accept |
| 2 Training | 2 weeks, 15 min/day | A ledger that has learned what you trust |
| 3 Magic on | one cron line | Mornings: 3 minutes of judgment, not hours of filing |
| 4 Expansion | as needed | More domains, same discipline |

The system's promise is not "no work" — it is that your work converges to **rules and exceptions**, which is where a householder's attention belongs.
