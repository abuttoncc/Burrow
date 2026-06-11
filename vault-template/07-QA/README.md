# 07-QA — the standing questions

One file per question. The question stands still; **the answers are a time series** — every run appends a new answer block (as-of today) and never touches old ones (invariant 7).

Frontmatter contract per question:

```yaml
id: weekly-review          # = filename
type: qa
mode: dynamic              # dynamic = re-answered on cadence · static = answered once, superseded by appending
cadence: weekly            # weekly | monthly | adhoc
recall-scope: [macro]      # which domains recall loads
last-run:                  # maintained by the Answerer
last-summary:              # one-liner — the dashboard timeline reads this
status: due                # due | fresh
```

The body carries the question **and its answering protocol** (recall scope, structure, review-then-project discipline) — the question file is its own prompt. See [[weekly-review]] for the worked sample.

Trigger: `/burrow-routine`, or say "run today's routine".
