#!/usr/bin/env bash
# PreToolUse hook for Bash.
# Denies git, build, test and dev-server commands. Allows typecheck.
# Reads the tool call as JSON on stdin, prints a permission decision as JSON on stdout.

set -u
input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
[ -z "$cmd" ] && exit 0

deny() {
  jq -cn --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

# Strip heredoc bodies (file contents being written) so that a file which merely
# *mentions* "npm run build" or a git command is not mistaken for running it.
# Keeps the line that opens the heredoc; drops everything up to the terminator.
stripped="$(printf '%s\n' "$cmd" | awk '
  BEGIN { term = "" }
  term != "" {
    line = $0; sub(/^[ \t]+/, "", line); sub(/[ \t\r]+$/, "", line)
    if (line == term) { term = "" }
    next
  }
  {
    print
    if (match($0, /<<-?[ \t]*['"'"'"]?[A-Za-z_][A-Za-z0-9_]*['"'"'"]?/)) {
      t = substr($0, RSTART, RLENGTH)
      sub(/^<<-?[ \t]*/, "", t); gsub(/['"'"'"]/, "", t)
      term = t
    }
  }
')"

# Normalise: collapse whitespace, lower-case for matching.
norm="$(printf '%s' "$stripped" | tr '\n' ' ' | tr -s ' ' | tr '[:upper:]' '[:lower:]')"

# A "command word" is preceded by start, a separator, or a subshell/pipe, and followed by space or end.
# `.git/config` and `.gitignore` do not match because they are preceded by a dot.
W='(^|[;&|(`]|[[:space:]])'

# 1) git — never.
if printf '%s' "$norm" | grep -Eq "${W}git([[:space:]]|$)"; then
  deny "Rule 1: git commands are never run by Claude. The owner handles version control. Suggest a commit message instead."
fi

# Runner prefixes that may precede a tool binary.
P='(pnpm exec |pnpm dlx |npx |pnpm |bunx |yarn )?'
# mise task runner: `mise run <task>` / `mise r <task>` (task names may be given as //task or with args).
M="${W}mise (run|r) (//)?"

# Allowed verification: astro check / tsc --noEmit / typecheck scripts / mise check task.
if printf '%s' "$norm" | grep -Eq "${W}${P}astro check" \
  || printf '%s' "$norm" | grep -Eq "${W}${P}tsc([[:space:]]|$)" \
  || printf '%s' "$norm" | grep -Eq "${W}(npm|pnpm|yarn|bun) (run )?(check|typecheck|type-check|lint)([[:space:]]|$)" \
  || printf '%s' "$norm" | grep -Eq "${M}(check|typecheck|type-check|lint)([[:space:]]|$)"; then
  exit 0
fi

# 2) dev server / preview.
if printf '%s' "$norm" | grep -Eq "${W}${P}astro (dev|preview)([[:space:]]|$)" \
  || printf '%s' "$norm" | grep -Eq "${W}(npm|pnpm|yarn|bun) (run )?(dev|start|preview|serve)([[:space:]]|$)" \
  || printf '%s' "$norm" | grep -Eq "${M}(dev|start|preview|serve)([[:space:]]|$)" \
  || printf '%s' "$norm" | grep -Eq "${W}${P}vite([[:space:]]|$)" \
  || printf '%s' "$norm" | grep -Eq "${W}${P}vite (dev|preview|serve)([[:space:]]|$)"; then
  deny "Rule 4: the dev server is never started by Claude. Ask the owner to run it (mise run dev) and report what they see."
fi

# 3) build.
if printf '%s' "$norm" | grep -Eq "${W}${P}astro build([[:space:]]|$)" \
  || printf '%s' "$norm" | grep -Eq "${W}(npm|pnpm|yarn|bun) (run )?build([[:space:]:]|$)" \
  || printf '%s' "$norm" | grep -Eq "${M}build([[:space:]:]|$)" \
  || printf '%s' "$norm" | grep -Eq "${W}${P}vite build([[:space:]]|$)"; then
  deny "Rule 3: build commands are never run by Claude. Only typecheck is allowed: mise run check / pnpm astro check / pnpm tsc --noEmit."
fi

# 3) test.
if printf '%s' "$norm" | grep -Eq "${W}(npm|pnpm|yarn|bun) (run )?(test|tests|e2e|test:[a-z0-9_-]+)([[:space:]]|$)" \
  || printf '%s' "$norm" | grep -Eq "${M}(test|tests|e2e|test:[a-z0-9_-]+)([[:space:]]|$)" \
  || printf '%s' "$norm" | grep -Eq "${W}${P}(vitest|jest|playwright|mocha|ava|cypress)([[:space:]]|$)"; then
  deny "Rule 3: test commands are never run by Claude. Only typecheck is allowed: mise run check / pnpm astro check / pnpm tsc --noEmit."
fi

exit 0
