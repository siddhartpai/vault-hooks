#!/usr/bin/env bash
# SessionStart: brief Claude with today's daily note, open tasks, recent
# decisions, and the last session note for this project. Output is JSON.
set -u
. "$(dirname "$0")/lib.sh"
vh_load

project="$(vh_project)"
daily="$(vh_daily_path)"
ctx=""

if [ -f "$daily" ]; then
  ctx="$ctx## Today's daily note ($(vh_rel "$daily"))
$(head -c 3000 "$daily")

"
  tasks="$(grep -E '^\s*- \[ \]' "$daily" | head -20)"
  [ -n "$tasks" ] && ctx="$ctx## Open tasks today
$tasks

"
fi

dec="$VAULT/$DECISIONS_FILE"
if [ -f "$dec" ]; then
  ctx="$ctx## Recent decisions ($(vh_rel "$dec"))
$(tail -n 12 "$dec")

"
fi

sess_dir="$VAULT/$SESSIONS_DIR"
if [ -d "$sess_dir" ]; then
  last="$(ls -t "$sess_dir"/*" $project "*.md 2>/dev/null | head -1)"
  if [ -n "$last" ]; then
    ctx="$ctx## Last Claude session for $project ($(vh_rel "$last"))
$(tail -n 15 "$last")
"
  fi
fi

[ -z "$ctx" ] && exit 0
ctx="# Obsidian vault context (Vault Hooks)
Vault: $VAULT
Write durable notes into the vault. Daily note: $(vh_rel "$daily").

$ctx"
jq -n --arg c "$ctx" '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$c}}'
