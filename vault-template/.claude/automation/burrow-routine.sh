#!/bin/bash
# Burrow unattended runner — turns the flywheel headlessly.
# Usage: bash .claude/automation/burrow-routine.sh
#
# Wire it to a scheduler:
#   cron (Linux/macOS):
#     0 4 * * * /bin/bash /path/to/vault/.claude/automation/burrow-routine.sh
#   launchd (macOS, survives sleep better): create a LaunchAgent plist whose
#     ProgramArguments runs this script; load with `launchctl load`.
#
# Prerequisites:
#   - permissions configured in .claude/settings.json (shipped with the template) —
#     headless `claude -p` cannot answer permission prompts
#   - if your machine reaches the net through a proxy, export it here explicitly:
#     some runtimes (e.g. Node's fetch) ignore system proxy settings
#     export HTTPS_PROXY="http://127.0.0.1:7890"; export NODE_USE_ENV_PROXY=1
set -u

VAULT="$(cd "$(dirname "$0")/../.." && pwd)"
LOG_DIR="$VAULT/08-Ops/runs"
LOG="$LOG_DIR/cron-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "$LOG_DIR"

export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

cd "$VAULT" || exit 1
echo "[burrow] $(date -Iseconds) flywheel start" >> "$LOG"
claude -p "/burrow-routine" >> "$LOG" 2>&1
echo "[burrow] $(date -Iseconds) exit=$?" >> "$LOG"
