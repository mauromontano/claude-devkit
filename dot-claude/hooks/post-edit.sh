#!/usr/bin/env bash
# PostToolUse hook: runs lint/format on the file that was just edited.
# INFORMATIVE only — never blocks (always exit 0). Returns the result as
# additionalContext so the agent sees problems immediately.
#
# Claude Code passes the event as JSON on stdin. We extract the edited path.

set -euo pipefail
input="$(cat)"

# file_path from tool_input (Edit/Write/MultiEdit). jq when available; sed fallback.
if command -v jq >/dev/null 2>&1; then
  file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
else
  file="$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
fi

[ -z "${file:-}" ] && exit 0
[ ! -f "$file" ] && exit 0

out=""
case "$file" in
  *.ts|*.tsx|*.js|*.jsx)
    if command -v npx >/dev/null 2>&1 && [ -f package.json ]; then
      out="$(npx --no-install eslint --fix "$file" 2>&1 || true)"
    fi
    ;;
  *.rb)
    if command -v rubocop >/dev/null 2>&1; then
      out="$(rubocop -a "$file" 2>&1 || true)"
    elif command -v bundle >/dev/null 2>&1 && [ -f Gemfile ]; then
      out="$(bundle exec rubocop -a "$file" 2>&1 || true)"
    fi
    ;;
  *.php)
    if [ -x vendor/bin/pint ]; then
      out="$(vendor/bin/pint "$file" 2>&1 || true)"
    elif command -v pint >/dev/null 2>&1; then
      out="$(pint "$file" 2>&1 || true)"
    fi
    ;;
esac

if [ -n "$out" ]; then
  # Emit JSON to inject the result as additional context.
  if command -v jq >/dev/null 2>&1; then
    esc="$(printf '%s' "$out" | tail -30 | jq -Rs . 2>/dev/null || printf '""')"
  else
    esc="$(printf '%s' "$out" | tail -30 | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' 2>/dev/null || printf '""')"
  fi
  printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":%s}}\n' "$esc"
fi

exit 0
