#!/usr/bin/env bash
# Vault Hooks Lite installer. Idempotent.
#   bash install.sh                            # interactive
#   VAULT_HOOKS_VAULT=/path bash install.sh    # non-interactive
set -eu
SRC="$(cd "$(dirname "$0")" && pwd)"
CONFIG="${VAULT_HOOKS_CONFIG:-$HOME/.config/vault-hooks/config}"
SETTINGS="${CLAUDE_SETTINGS:-$HOME/.claude/settings.json}"
HOOKS_DST="$HOME/.claude/hooks/vault-hooks"
SKILLS_DST="$HOME/.claude/skills"
say() { printf '%s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || die "jq is required. macOS: brew install jq   Debian/Ubuntu: sudo apt install jq"
vault="${VAULT_HOOKS_VAULT:-}"
if [ -z "$vault" ] && [ -f "$CONFIG" ]; then vault="$(. "$CONFIG"; printf '%s' "${VAULT:-}")"; fi
if [ -z "$vault" ]; then printf 'Path to your Obsidian vault: '; read -r vault; fi
vault="${vault/#\~/$HOME}"
[ -d "$vault" ] || die "vault directory not found: $vault"
mkdir -p "$(dirname "$CONFIG")"
if [ ! -f "$CONFIG" ]; then
  cat > "$CONFIG" <<CFG
VAULT="$vault"
DAILY_DIR="Daily"
DAILY_FORMAT="%Y-%m-%d"
SESSIONS_DIR="Claude/Sessions"
DECISIONS_FILE="Claude/Decisions.md"
MEMORY_DIR="Claude Memory"
ACTIVITY_HEADING="## Claude activity"
CFG
  say "wrote $CONFIG"
else
  sed -i.bak "s#^VAULT=.*#VAULT=\"$vault\"#" "$CONFIG" && rm -f "$CONFIG.bak"; say "updated VAULT in $CONFIG"
fi
mkdir -p "$HOOKS_DST"; cp "$SRC"/hooks/*.sh "$HOOKS_DST"/; chmod +x "$HOOKS_DST"/*.sh
mkdir -p "$(dirname "$SETTINGS")"; [ -f "$SETTINGS" ] || printf '{}\n' > "$SETTINGS"
jq -e . "$SETTINGS" >/dev/null || die "$SETTINGS is not valid JSON"
cp "$SETTINGS" "$SETTINGS.vault-hooks.bak"
add_hook() {
  local ev="$1" m="$2" cmd="$HOOKS_DST/$3" t="$4" tmp; tmp="$(mktemp)"
  jq --arg ev "$ev" --arg m "$m" --arg cmd "$cmd" --argjson t "$t" '
    .hooks //= {} | .hooks[$ev] //= [] |
    if ([.hooks[$ev][] | .hooks[]? | select(.command == $cmd)] | length) > 0 then .
    else .hooks[$ev] += [ ({"hooks":[{"type":"command","command":$cmd,"timeout":$t}]} + (if $m == "" then {} else {"matcher":$m} end)) ] end' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
}
add_hook SessionStart "startup|resume" session-start.sh 10
add_hook PostToolUse "Edit|Write|MultiEdit|NotebookEdit" post-tool.sh 10
mkdir -p "$SKILLS_DST/vault-daily"; cp "$SRC"/skills/vault-daily/* "$SKILLS_DST/vault-daily/"
mkdir -p "$vault/Daily"
[ -f "$vault/CLAUDE.md" ] || cp "$SRC/CLAUDE.vault.md" "$vault/CLAUDE.md"
say "Installed. Hooks: $HOOKS_DST. Settings backup: $SETTINGS.vault-hooks.bak"
say "Start a new Claude Code session, edit a file, then open $vault/Daily in Obsidian."
