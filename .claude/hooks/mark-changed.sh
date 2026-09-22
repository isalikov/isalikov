#!/usr/bin/env bash
# PostToolUse hook for Write|Edit|MultiEdit|NotebookEdit.
# Records that source files changed in this session so the Stop hook can demand a commit message.
set -u
sid="$(jq -r '.session_id // "nosession"')"
touch "${TMPDIR:-/tmp}/claude-cv-changed-${sid}"
exit 0
