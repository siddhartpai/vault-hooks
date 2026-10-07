# Vault Hooks Lite

Claude Code hooks that write into your Obsidian vault. Pure bash + jq.

**Lite (this repo, MIT):**
- `PostToolUse` on Edit/Write: a timestamped line for every file Claude edits, under `## Claude activity` in today's daily note.
- `SessionStart`: Claude is briefed with today's daily note and open tasks.
- `/vault-daily` skill: log a line, add a task, plan the day.

**Full kit ($29, lifetime updates):** https://siddhart24.gumroad.com/l/obsidian-vault-hooks-claude-code
- `Stop`: one note per Claude session, every reply appended, frontmatter for Bases.
- `PreCompact`: decision sentences extracted before context compaction into `Claude/Decisions.md`.
- `SessionEnd`: Claude Code's memory files mirrored into `Claude Memory/`.
- `/vault-weekly-review`, `/vault-capture`, `/vault-synthesize`, `/vault-health`.
- Two Bases dashboards, uninstaller, 39 tests, 12-section guide with troubleshooting.

## Install

```bash
brew install jq            # Linux: sudo apt install jq
git clone https://github.com/siddhartpai/vault-hooks && cd vault-hooks-lite
bash tests/run.sh          # 5 checks
bash install.sh            # asks for your vault path
```

The installer merges two entries into `~/.claude/settings.json` (backup: `settings.json.vault-hooks.bak`). Start a new Claude Code session; hooks load at session start.

## Config

`~/.config/vault-hooks/config`:

```
VAULT="/path/to/vault"
DAILY_DIR="Daily"          # match your Daily Notes plugin folder
DAILY_FORMAT="%Y-%m-%d"    # date(1) format of your daily note names
ACTIVITY_HEADING="## Claude activity"
```

## How it works

Claude Code pipes a JSON event to each hook on stdin. `post-tool.sh` reads `tool_name` and `tool_input.file_path`, then inserts a line at the end of the activity section with awk. `session-start.sh` prints `{"hookSpecificOutput":{"additionalContext": ...}}`, which Claude Code adds to the model's context.

Hooks exit 0 on every failure path (missing jq, config, or vault) so a bad setup never breaks a session. Hooks only append or create; nothing is deleted.

## Uninstall

Remove the two `vault-hooks` entries from `~/.claude/settings.json` (or restore the backup), then `rm -rf ~/.claude/hooks/vault-hooks ~/.claude/skills/vault-daily ~/.config/vault-hooks`.

## License

MIT.
