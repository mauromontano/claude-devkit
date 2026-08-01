#!/usr/bin/env bash
# StatusLine: one line with git branch, dirty/clean state, and model.
# Claude Code passes session context as JSON on stdin.
set -euo pipefail
input="$(cat 2>/dev/null || true)"

if command -v jq >/dev/null 2>&1; then
  model="$(printf '%s' "$input" | jq -r '.model.display_name // empty' 2>/dev/null)"
else
  model="$(printf '%s' "$input" | sed -n 's/.*"display_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
fi
[ -z "${model:-}" ] && model="claude"

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '-')"
dirty=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  [ -n "$(git status --porcelain 2>/dev/null)" ] && dirty="✱"
fi

dir="$(basename "$(pwd)")"
printf '%s ⎇ %s%s · %s' "$dir" "$branch" "$dirty" "$model"
