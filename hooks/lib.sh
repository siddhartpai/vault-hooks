#!/usr/bin/env bash
# Vault Hooks shared library. Sourced by every hook. Bash 3.2 compatible.
# Never writes to stdout: hook stdout is Claude's context on some events.

VH_CONFIG="${VAULT_HOOKS_CONFIG:-$HOME/.config/vault-hooks/config}"

# Defaults; overridden by the config file.
VAULT=""
DAILY_DIR="Daily"
DAILY_FORMAT="%Y-%m-%d"
SESSIONS_DIR="Claude/Sessions"
DECISIONS_FILE="Claude/Decisions.md"
MEMORY_DIR="Claude Memory"
ACTIVITY_HEADING="## Claude activity"
CLAUDE_PROJECTS_DIR="${CLAUDE_PROJECTS_DIR:-$HOME/.claude/projects}"

vh_log() { printf 'vault-hooks: %s\n' "$*" >&2; }

# Load config. Exit 0 quietly if not configured: a missing config must never
# break a Claude session.
vh_load() {
  if [ ! -f "$VH_CONFIG" ]; then vh_log "no config at $VH_CONFIG (run install.sh)"; exit 0; fi
  # shellcheck disable=SC1090
  . "$VH_CONFIG"
  if [ -z "$VAULT" ] || [ ! -d "$VAULT" ]; then vh_log "VAULT not found: '$VAULT'"; exit 0; fi
  if ! command -v jq >/dev/null 2>&1; then vh_log "jq is required (brew install jq / apt install jq)"; exit 0; fi
  VH_INPUT="$(cat)"
}

vh_field() { printf '%s' "$VH_INPUT" | jq -r "$1 // empty" 2>/dev/null; }

vh_today() { date +"$DAILY_FORMAT"; }
vh_now() { date +"%H:%M"; }

vh_project() {
  local cwd; cwd="$(vh_field .cwd)"
  [ -z "$cwd" ] && cwd="$PWD"
  basename "$cwd"
}

vh_sid8() { vh_field .session_id | cut -c1-8; }

vh_daily_path() { printf '%s/%s/%s.md' "$VAULT" "$DAILY_DIR" "$(vh_today)"; }

# Create the daily note if missing.
vh_ensure_daily() {
  local p; p="$(vh_daily_path)"
  mkdir -p "$(dirname "$p")"
  [ -f "$p" ] || printf '# %s\n' "$(vh_today)" > "$p"
  printf '%s' "$p"
}

# Append $2 (a line) under heading $1 in file $3. The line is inserted at the
# end of that heading's section (before the next "## " heading). If the heading
# is absent it is appended to the end of the file.
vh_append_under() {
  local heading="$1" line="$2" file="$3"
  if ! grep -qxF "$heading" "$file"; then
    printf '\n%s\n%s\n' "$heading" "$line" >> "$file"
    return
  fi
  local tmp; tmp="$(mktemp)"
  awk -v h="$heading" -v l="$line" '
    BEGIN { insec = 0; done = 0 }
    {
      if (!done && insec && $0 ~ /^## /) { print l; done = 1; insec = 0 }
      print
      if (!done && $0 == h) { insec = 1 }
    }
    END { if (!done) print l }
  ' "$file" > "$tmp" && mv "$tmp" "$file"
}

# Shorten a path: relative to the vault, else relative to the session cwd,
# else unchanged.
vh_rel() {
  local cwd; cwd="$(vh_field .cwd)"
  case "$1" in
    "$VAULT"/*) printf '%s' "${1#"$VAULT"/}" ;;
    "$cwd"/*) [ -n "$cwd" ] && printf '%s' "${1#"$cwd"/}" || printf '%s' "$1" ;;
    *) printf '%s' "$1" ;;
  esac
}
