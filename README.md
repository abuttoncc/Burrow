# Burrow 陋居

> Self-growing knowledge workspace, tended by AI appliances — under a compilation gate, six-tier time discipline, and **earned autonomy**.
>
> *In the Weasley house, the knitting needles knit by themselves and the pan flips its own eggs. None of them has free will — each is enchanted within a narrow scope, and Mrs. Weasley decides what gets knitted. Your vault deserves the same: agents that work all night, a gate they cannot bypass, and trust they have to earn.*

[简体中文](README.zh-CN.md) · [Design Philosophy](docs/philosophy.md) · [Skills](#skills) · [Vault Template](#vault-template)

<p align="center"><img src="docs/demo.svg" alt="Burrow demo: ingest through the gate, retirement queued, autonomy earned" width="760"></p>

---

## What is this?

Burrow is an **Obsidian vault template + a set of agent skills** (Claude Code / any agent-skills-compatible CLI) that turn your vault into a knowledge system that grows on its own — without turning into mush:

- **One write gate.** Agents never edit canonical notes directly. Everything enters through `burrow-ingest`, a compilation step that classifies, time-stamps, and vocabulary-checks every piece of knowledge. Your INBOX stays friction-free; rigor lives only at the gate.
- **Six-tier time discipline.** Every claim is adjudicated into a tier — observation (T0), current state (T1), standing logic (T2), relation (T3), event (T4), or type axiom (T5) — before it lands. States are never overwritten: they retire with a date and an event stamp. Your vault can answer *"what did we believe on March 3rd, and why did it change?"*
- **Earned autonomy (the gate ledger).** Agents don't get blanket write permission. Each write-type starts in manual review; after N consecutive approvals with zero rejections it earns auto-promotion. One rejection resets the streak. Trust is a number in a YAML file you can read.
- **An auto-research flywheel.** `burrow-lint` finds gaps (missing data, single-source claims, stale states); `burrow-research` goes out to fill them; results come back through the same gate. The vault doesn't just organize what you feed it — it notices what's missing.

```
INBOX (anything goes) ──► burrow-ingest (THE gate) ──► wiki/ (typed, time-stamped, linked)
                              ▲                            │
                              │                            ▼
                    burrow-research ◄── gaps ◄── burrow-lint (health check)
                              
                    burrow-routine = one command that turns the whole wheel
```

## Why another AI + Obsidian project?

There are excellent projects in this space — [obsidian-wiki](https://github.com/Ar9av/obsidian-wiki) (LLM Wiki pattern at scale), [vault-intelligence](https://github.com/cybaea/obsidian-vault-intelligence) (the Gardener), [vault-operator](https://github.com/pssah4/vault-operator) (in-vault autonomous agent), [MegaMem](https://github.com/C-Bjorn/MegaMem) (temporal KG sync). Burrow descends from the same ancestor (the [LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)) via our own **[auto-wiki](https://github.com/hanlinlibham/auto-wiki)** knowledge compiler — bundled here as the engine — and adds three things none of them have:

| | Per-action approval (typical) | **Burrow** |
|---|---|---|
| Write control | "approve this edit?" | **Compilation gate**: typed tiers + controlled vocabulary + time adjudication, enforced before any canonical write |
| Trust model | static (always ask / always allow) | **Earned autonomy**: per-write-type approval streaks; auto-promotion is earned, one rejection demotes |
| Growth | organizes what you give it | **Research flywheel**: lint finds gaps → agent researches → results re-enter through the gate |

## Quickstart

**1. Get the vault**

```bash
git clone https://github.com/abuttoncc/Burrow.git
# Open vault-template/ as an Obsidian vault (or copy its contents into yours)
```

**2. Install the skills** (Claude Code shown; any agent-skills runner works)

```bash
cp -r Burrow/skills/* your-vault/.claude/skills/
cd your-vault && claude
```

**3. Feed it**

Drop anything into `INBOX/` — an article, a meeting note, a half-thought. Then:

```
/burrow-ingest          # compile INBOX through the gate
```

**4. Morning ritual** (or wire it to cron)

```
/burrow-routine         # recall → review → lint → research gaps → ingest → report
```

```bash
# unattended, via OS cron (Obsidian has no background runtime — nobody's does):
0 4 * * * cd /path/to/vault && claude -p "/burrow-routine" >> _burrow/cron.log 2>&1
```

**5. Watch the ledger earn trust**

```yaml
# _burrow/gate-ledger.yaml — after two weeks of use it might look like:
t0-merge:        { streak: 20, threshold: 20, status: auto }    # earned it
new-node:        { streak: 12, threshold: 20, status: manual }  # getting there
cross-domain-edge: { streak: 0,  threshold: 20, status: manual } # rejected 06-30, reset
retirement:      { status: locked }   # changes to current world-state: never automatic
```

## Architecture: two layers, two modes

```
┌─ Burrow (governance) ─────────────────────────────────────┐
│  the gate · write-types · earned-autonomy ledger ·        │
│  review queue · flywheel routine · recall discipline      │
├─ auto-wiki (compilation engine, bundled) ─────────────────┤
│  ingest 3-way compare · six-tier storage (data.db) ·      │
│  schema validation · seeds · validators · FTS5 scaling    │
└───────────────────────────────────────────────────────────┘
```

Burrow bundles **[auto-wiki](https://github.com/hanlinlibham/auto-wiki)** (v0.3, `skills/auto-wiki/`) as its compilation engine — the engine decides *how* knowledge compiles; the ledger decides *who may apply it*. Two modes:

- **Lite (zero dependencies)** — skip `skills/auto-wiki/`; the gate runs the pure-markdown protocols in `_protocols/`. Any agent, no Python.
- **Engine (full strength)** — install `skills/auto-wiki/` too (needs Python 3.8+ and `pip install pydantic`); you gain SQLite bitemporal storage (`data.db`), frontmatter schema validation, domain seeds (e.g. FIBO pensions), logic validators, and BM25 scaling for large vaults.

## Skills

| Skill | Role | Writes? |
|---|---|---|
| `auto-wiki` | **The engine** (bundled): ingest/recall/query/lint/deep-dive compilation core | via the gate only |
| `burrow-ingest` | **The gate.** Route → extract → six-tier adjudication → vocab check → stage → promote/queue | the only one that writes `wiki/` |
| `burrow-gate` | Review queue + ledger bookkeeping. Approve / reject / mark contested; updates streaks | ledger + staged items |
| `burrow-lint` | Health check: orphans, broken links, out-of-vocab edges, contested, staleness → Gap Report | report only |
| `burrow-research` | Takes gaps, researches (web/MCP), returns evidence bundles **to the gate** | nothing directly |
| `burrow-routine` | The flywheel: due questions → recall → review vs. last answer → lint → research → ingest → log | run log only |
| `burrow-recall` | Time-travel queries: "as of <date>" answers with provenance; reports gaps instead of guessing | nothing |

## Vault Template

```
vault-template/
├── Dashboard.md            # north-star metrics (Dataview)
├── INBOX/                  # zero-friction capture — no rules here, ever
├── wiki/                   # canonical knowledge — gate-only writes
│   └── macro/              #   one example domain, fully worked
├── _ontology/              # per-domain type criteria + controlled edge vocabulary
├── _protocols/             # the discipline, in prose (these ARE the prompts)
│   ├── compilation-gate.md
│   ├── six-tier-time.md
│   ├── retirement.md
│   └── lint.md
└── _burrow/
    ├── gate-ledger.yaml    # earned-autonomy bookkeeping
    └── runs.md             # flywheel log, append-only
```

The protocols are deliberately written as plain prose with examples: **the protocol text is the prompt**. Editing the discipline = editing a markdown file.

## Invariants (violate any of these and it's not Burrow anymore)

1. **One gate** — canonical writes happen only through ingest.
2. **Capture is free, promotion is strict** — INBOX has no rules; the gate has all of them.
3. **No tier, no entry** — every claim gets a time-tier or it doesn't land.
4. **Retire, never delete** — state changes close the old row with a date + event stamp.
5. **Controlled vocabulary** — relations outside the domain's edge vocab are rejected.
6. **Autonomy is earned** — auto-promotion requires a clean streak; one rejection demotes.
7. **Answers carry provenance** — recall cites or reports a gap; it never fills silence with confidence.

## The control panel (prototype)

The morning view we're building toward — a **Weasley clock** (each hand is an appliance, sectors are states: working / queued / idle / paused / anomaly), the flywheel trace, the review queue, and the trust ledger as a visible panel:

<p align="center"><img src="docs/dashboard-prototype.png" alt="Burrow dashboard prototype: Weasley clock, appliance list, flywheel trace, review queue, trust gates" width="900"></p>

Interactive HTML prototype: [docs/dashboard-prototype.html](docs/dashboard-prototype.html) — approve/reject cards and watch the ledger move; pause an appliance and watch its clock hand swing.

## Roadmap

- [ ] Weasley-clock dashboard plugin (live appliance states — prototype above)
- [ ] `npx skills add burrow` packaging
- [ ] Gap→research mappings for more domains
- [ ] Multi-vault / team promotion tiers — this is what **Burrow Cloud** (hosted, multi-tenant) is for. Watch this space.

## License

MIT — see [LICENSE](LICENSE).

*Knit on.* 🧶
