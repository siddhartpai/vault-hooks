#!/usr/bin/env bash
# PostToolUse (Edit|Write): log the edited file to today's daily note.
set -u
. "$(dirname "$0")/lib.sh"
vh_load

tool="$(vh_field .tool_name)"
path="$(vh_field .tool_input.file_path)"
[ -z "$path" ] && exit 0
case "$tool" in Edit|Write|MultiEdit|NotebookEdit) ;; *) exit 0 ;; esac

daily="$(vh_ensure_daily)"
line="- $(vh_now) [$(vh_project)] $tool \`$(vh_rel "$path")\`"
vh_append_under "$ACTIVITY_HEADING" "$line" "$daily"
exit 0
