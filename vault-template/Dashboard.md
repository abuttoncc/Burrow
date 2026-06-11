---
cssclasses: [burrow-dashboard]
---

# 🏠 The Burrow — Morning View

> One glance tells you what the appliances did overnight. Three clicks settle the exceptions.
> (Requires the Dataview community plugin. Everything below degrades gracefully to links without it.)

## North star

```dataviewjs
const wiki = dv.pages('"wiki"');
const inbox = dv.pages('"INBOX"').where(p => !p.file.path.includes("_compiled"));
const queue = dv.pages('"_burrow/review-queue"');
dv.table(["", "count"], [
  ["📚 wiki pages", wiki.length],
  ["📥 INBOX awaiting compile", inbox.length],
  ["⚖️ awaiting your judgment", queue.length],
]);
if (queue.length > 0) dv.paragraph("**→ Review queue first.** Every approve/reject trains the ledger.");
if (inbox.length >= 5) dv.paragraph("🔴 INBOX backlog ≥ 5 — run `/burrow-ingest`.");
```

## Review queue (exceptions only)

```dataview
table without id file.link as item, write-type, tier, source
from "_burrow/review-queue"
sort file.ctime desc
```

## Recently grown

```dataview
table without id file.link as page, file.mtime as updated
from "wiki"
sort file.mtime desc
limit 10
```

## The ledger (autonomy earned so far)

See [[_burrow/gate-ledger.yaml|gate-ledger]] — streaks graduate at their threshold; one rejection resets.

## Run history

See [[_burrow/runs|runs]] for the append-only flywheel log.
