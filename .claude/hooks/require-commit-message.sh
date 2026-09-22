#!/usr/bin/env bash
# Stop hook.
# If files were changed this turn and the final reply has no suggested commit message,
# block once and ask for it. stop_hook_active prevents an infinite loop.
set -u
input="$(cat)"
sid="$(printf '%s' "$input" | jq -r '.session_id // "nosession"')"
active="$(printf '%s' "$input" | jq -r '.stop_hook_active // false')"
transcript="$(printf '%s' "$input" | jq -r '.transcript_path // empty')"
flag="${TMPDIR:-/tmp}/claude-cv-changed-${sid}"

[ -f "$flag" ] || exit 0

if [ "$active" = "true" ]; then
  rm -f "$flag"
  exit 0
fi

# Accepts: "Suggested commit:", "commit message", or a Conventional Commits subject line.
PATTERN='suggested commit|commit message|^(feat|fix|chore|docs|style|refactor|content|perf|a11y|seo|test|ci|build)(\([^)]*\))?!?: '

has_marker() { printf '%s' "$1" | grep -Eqi "$PATTERN"; }

# 1) Newer Claude Code versions pass the final reply directly.
direct="$(printf '%s' "$input" | jq -r '.last_assistant_message // empty')"
if [ -n "$direct" ] && has_marker "$direct"; then
  rm -f "$flag"
  exit 0
fi

# 2) Fall back to the transcript: all assistant text since the last human message.
#    The transcript can lag the Stop event by a few hundred ms, so retry briefly if it looks empty.
read_since_last_human() {
  jq -rs '
    . as $all
    | ([ range(0; length) as $i
        | $all[$i]
        | select(.type == "user")
        | (.message.content // "") as $c
        | select(($c | type) == "string" or (($c | map(.type)) | index("tool_result") | not))
        | $i ] | last // -1) as $h
    | [ $all[$h+1:][]
        | select(.type == "assistant")
        | (.message.content // "")
        | if type == "string" then . else (map(select(.type == "text") | .text) | join("\n")) end ]
    | join("\n")
  ' "$1" 2>/dev/null || true
}

text=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  for _ in 1 2 3 4; do
    text="$(read_since_last_human "$transcript")"
    if printf '%s' "$text" | grep -q '[^[:space:]]'; then break; fi
    sleep 0.3
  done
fi

if has_marker "$text"; then
  rm -f "$flag"
  exit 0
fi

jq -cn '{
  decision: "block",
  reason: "Files were changed this turn but the reply has no suggested commit message. Rule 2: end the reply with `Suggested commit:` followed by a Conventional Commits message in a fenced code block."
}'
exit 0
