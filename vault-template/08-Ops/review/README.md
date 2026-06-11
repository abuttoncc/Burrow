# Review queue

Candidate cards for high-risk writes, one file per card, frontmatter `status: pending → approved / rejected / contested`.

Cards arrive from **unattended runs** (interactive sessions judge on the spot instead). Judge them with `/burrow-gate` or by saying "process the review queue" — every verdict is also ledger bookkeeping: approve → streak +1, reject → streak resets, contested → recorded on the page, queue cleared.

Oldest first. An empty folder means: all quiet at the Burrow.

## Card format (the dashboard parses this)

Frontmatter: `type: candidate` · `status: pending|approved|rejected|contested` · `gate:` (write-type id from the ledger) · `target:` · `domain:` · `routine:` (which agent staged it) · `created:`.
Body sections the dashboard previews: `## Change` (the diff, first lines shown) and `## Source`.
