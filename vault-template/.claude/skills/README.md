# Skills go here

Copy the Burrow skills (and optionally the auto-wiki engine) from the repo root into this folder:

```bash
# from the repo root:
cp -r skills/burrow-* vault-template/.claude/skills/
cp -r skills/auto-wiki vault-template/.claude/skills/   # engine mode only (needs python3 + pydantic)
```

If you grafted the template onto an existing vault, copy into `<your-vault>/.claude/skills/` instead.
This folder ships with only this README so the two copies (repo `skills/` = source of truth) can't drift silently.
