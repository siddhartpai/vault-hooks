# Vault conventions for Claude Code

This folder is an Obsidian vault. Notes are Markdown with YAML frontmatter.

## Layout
- `Daily/YYYY-MM-DD.md` daily notes. Sections: `## Plan`, `## Notes`, `## Claude activity`.
- `Inbox/` captures to process. `Syntheses/` cross-note summaries. `Reviews/` weekly reviews.
- `Claude/Sessions/` one note per Claude Code session (written by hooks).
- `Claude/Decisions.md` decisions pulled from sessions (written by hooks).
- `Claude Memory/` read-only mirror of Claude's memory. Never edit here.

## Rules
- Prefer appending to rewriting. Never delete a user's lines.
- Link with `[[wikilinks]]`. Create links only to notes that exist.
- Frontmatter keys: `type`, `created`, `tags`, plus type-specific keys.
- Do not touch `.obsidian/`.
- Skills: `/vault-daily`, `/vault-weekly-review`, `/vault-capture`, `/vault-synthesize`, `/vault-health`.
