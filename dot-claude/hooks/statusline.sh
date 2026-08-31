#!/usr/bin/env bash
# StatusLine: dir ⎇ branch state · model · effort · context%.
# Claude Code passes session context as JSON on stdin.
set -euo pipefail
input="$(cat 2>/dev/null || true)"

model="claude"; effort=""; ctx=""
if command -v jq >/dev/null 2>&1; then
  model="$(printf '%s' "$input" | jq -r '.model.display_name // "claude"' 2>/dev/null)"
  effort="$(printf '%s' "$input" | jq -r '.effort.level // empty' 2>/dev/null)"
  # used_percentage puede ser null al arrancar / justo después de /compact → se omite.
  ctx="$(printf '%s' "$input" | jq -r 'if (.context_window.used_percentage // null) == null then empty else (.context_window.used_percentage | floor | tostring) end' 2>/dev/null)"
else
  model="$(printf '%s' "$input" | sed -n 's/.*"display_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
  [ -z "$model" ] && model="claude"
fi

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '-')"
dirty=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  [ -n "$(git status --porcelain 2>/dev/null)" ] && dirty="✱"
fi
dir="$(basename "$(pwd)")"

line="$dir ⎇ $branch$dirty · $model"
[ -n "$effort" ] && line="$line · effort $effort"
[ -n "$ctx" ]    && line="$line · ctx ${ctx}%"
printf '%s' "$line"
