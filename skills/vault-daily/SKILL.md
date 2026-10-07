---
name: vault-daily
description: Open, create, or update today's Obsidian daily note from Claude Code. Use when the user says "daily note", "log this", "add a task for today", "what did I do today", or asks to plan the day.
---

# Daily note

Config lives in `~/.config/vault-hooks/config` (keys: VAULT, DAILY_DIR, DAILY_FORMAT).
Resolve today's note path with:

```bash
. ~/.config/vault-hooks/config; echo "$VAULT/$DAILY_DIR/$(date +"$DAILY_FORMAT").md"
```

## Rules
- Create the note with a `# <date>` heading if it does not exist.
- Keep these sections in this order: `## Plan`, `## Notes`, `## Claude activity`. The last one is written by the hooks. Do not rewrite it.
- Tasks are `- [ ] text`. Mark done with `- [x]`.
- Append; never delete the user's text. Use the Edit tool for targeted inserts.
- Link projects and people with `[[wikilinks]]`.

## Actions
- "log X" -> append `- HH:MM X` under `## Notes`.
- "add task X" -> append `- [ ] X` under `## Plan`.
- "what did I do today" -> read the note and summarise the activity section in five lines.
- "plan my day" -> read open tasks from the last three daily notes, propose a `## Plan` with at most five tasks, then write it after the user agrees.
