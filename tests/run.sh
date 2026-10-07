#!/usr/bin/env bash
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/.." && pwd)"
TMP="$(mktemp -d)"; VAULT="$TMP/vault"; mkdir -p "$VAULT"
export VAULT_HOOKS_CONFIG="$TMP/config"
printf 'VAULT="%s"\nDAILY_DIR="Daily"\nDAILY_FORMAT="%%Y-%%m-%%d"\nACTIVITY_HEADING="## Claude activity"\n' "$VAULT" > "$VAULT_HOOKS_CONFIG"
TODAY="$(date +%Y-%m-%d)"; pass=0; fail=0
ok(){ pass=$((pass+1)); echo "  ok   $1"; }; bad(){ fail=$((fail+1)); echo "  FAIL $1"; }
run(){ sed -e "s#__TMP__#$TMP#g" "$HERE/fixtures/$2" | bash "$ROOT/hooks/$1"; }
run post-tool.sh post-tool-edit.json >/dev/null
grep -qF '[myproj] Edit `src/app.ts`' "$VAULT/Daily/$TODAY.md" && ok "logs edit to daily note" || bad "logs edit"
run post-tool.sh post-tool-bash.json >/dev/null
grep -qF 'Bash' "$VAULT/Daily/$TODAY.md" && bad "ignores Bash" || ok "ignores non-edit tools"
out="$(run session-start.sh session-start.json)"
printf '%s' "$out" | jq -e '.hookSpecificOutput.hookEventName=="SessionStart"' >/dev/null && ok "session-start emits JSON" || bad "session-start JSON"
printf '%s' "$out" | jq -r '.hookSpecificOutput.additionalContext' | grep -q "Daily/$TODAY.md" && ok "session-start names daily note" || bad "names daily"
export VAULT_HOOKS_CONFIG="$TMP/none"; out="$(run post-tool.sh post-tool-edit.json 2>/dev/null)"
[ $? = 0 ] && [ -z "$out" ] && ok "missing config exits 0" || bad "missing config"
rm -rf "$TMP"; printf '\n%s passed, %s failed\n' "$pass" "$fail"; [ "$fail" = 0 ]
